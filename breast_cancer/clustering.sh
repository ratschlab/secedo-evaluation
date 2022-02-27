# Splits aligned BAM files by chromosome, creates 23 pileup files distributed on 23 machines and then runs
# variant calling

slices="A B C D E"
coverage=2

base_dir="/cluster/work/grlab/projects/projects2019-secedo/datasets/breastcancer/all_slices"
slices_no_space=${slices//[[:blank:]]/}
pileup_dir="${base_dir}/pileups${slices_no_space}"
code_dir="/cluster/work/grlab/projects/projects2019-secedo/code"


# split the aligned BAMs by chromosome for easier parallelization
function split_bams() {

  for slice in ${slices}; do
    slice_dir="/cluster/work/grlab/projects/projects2019-secedo/datasets/breastcancer/slice${slice}/processed_files"
    bam_dir="${slice_dir}/aligned_cells"
    split_dir="${slice_dir}/aligned_cells_split"

    echo "Splitting aligned BAMs in slice ${bam_dir} by chromosome..."

    files=($(find ${bam_dir} -name *.bam ))
    n_cells=${#files[@]}
    echo "Found ${n_cells} files"


    step=100
    mkdir -p "${split_dir}"
    logs_dir="${split_dir}/logs"
    mkdir -p ${logs_dir}

    for idx in $(seq 0 ${step} $((n_cells-1))); do
      echo "Processing files ${idx}->$((idx+step-1))..."
      cmd="echo hello"
      for i in $(seq "${idx}" $((idx+step-1))); do
        bam_file=${files[${i}]}
        cmd="${cmd}; ${code_dir}/experiments/breast_cancer/split.sh ${bam_file} ${split_dir} \
            | tee ${logs_dir}/split-${i}.log"
      done
      # echo "${cmd}"
      bsub -K -J "split-${i}" -W 1:00 -n 1 -R "rusage[mem=8000]" -R "span[hosts=1]" \
          -oo "${logs_dir}/split-${i}.lsf.log" "${cmd}" &
    done
  done

  wait
}

# Starts jobs for creating pileup files from the aligned BAM files. One job per Chromosome.
# Waits for jobs to complete
function create_pileup() {
  module load openblas

  echo "Generating pileups..."

  log_dir="${pileup_dir}/logs"
  pileup="${code_dir}/build/pileup"

  mkdir -p ${pileup_dir}
  mkdir -p ${log_dir}
  for chromosome in {1..22} X; do # Y was not added - maybe it confuses things
          scratch_dir=$(mktemp -d -t pileup-XXXXXXXXXX --tmpdir=/scratch)
          source_files=""
          for slice in ${slices}; do
            slice_dir="/cluster/work/grlab/projects/projects2019-secedo/datasets/breastcancer/slice${slice}/processed_files"
            split_dir="${slice_dir}/aligned_cells_split"

            source_files="${source_files} ${split_dir}/*_chr${chromosome}.bam*"
          done
          num_files=`ls -l ${source_files} | wc -l`
          echo "Found ${num_files} files for chromosome ${chromosome}"
          copy_command="echo Copying data...; mkdir ${scratch_dir}; cp ${source_files} ${scratch_dir}"
          command="echo Running pileup binary...; /usr/bin/time ${pileup} -i ${scratch_dir}/ \
            -o ${pileup_dir}/chromosome --num_threads  20 --log_level=trace --min_base_quality 20 --max_coverage 1000 \
            --chromosomes ${chromosome} | tee ${log_dir}/pileup-${chromosome}.log"
          echo "Copy command: ${copy_command}"
          echo "Pileup command: $command"
          # allocating 40G scratch space; for the 1400 simulated Varsim cells, chromosomes 1/2 (the longest) need ~22G
          bsub  -K -J "pile-${chromosome}-${slices}" -W 04:00 -n 20 \
                -R "rusage[mem=10000,scratch=2000]" -R "span[hosts=1]" \
                -oo "${log_dir}/pileup-${chromosome}.lsf.log" "${copy_command}; ${command}; rm -rf ${scratch_dir}" &
  done

  wait
}

# Runs the variant caller on pileup files (either binary generated by our own pileup binary, or textual
# generated by samtools mpileup)
# ~5 minutes for 1000 cells coverage 0.05x
function variant_calling() {
  echo "Running variant calling..."
  module load openblas
  secedo="${code_dir}/build/secedo"
  flagfile="${code_dir}/flags_breast"
  for hprob in 0.5; do
    for seq_error_rate in 0.05; do
      out_dir="${base_dir}/secedo_${coverage}x_${slices_no_space}_${hprob#*.}_${seq_error_rate#*.}"
      log_dir="${out_dir}/logs"
      mkdir -p "${log_dir}"
      command="/usr/bin/time ${secedo} -i ${pileup_dir}/ -o ${out_dir}/ --num_threads 20 --log_level=trace \
        --flagfile ${flagfile} \
        --homozygous_filtered_rate=${hprob} --seq_error_rate=${seq_error_rate} --min_cluster_size 500 \
        --reference_genome=/cluster/work/grlab/projects/projects2019-secedo/datasets/breastcancer/GRCh37.p13.genome.fa \
        --merge_file "${code_dir}/experiments/breast_cancer/breast_group_${slices_no_space}_${coverage}" \
        --clustering_type SPECTRAL6 --max_coverage 300 | tee ${log_dir}/secedo.log"
      echo "$command"

      # for slices ABCDE needs 160GB if using min_different=3 (default), otherwise  about 1.6TB if using
      # --min_different=1
      # needs about 1.2TB (20*60GB) for slices BCDE (if using min_different=1), otherwise 120GB
      # for a single slice 130GB is enough (if keeping all loci with at least 1 different base), otherwise 16GB
      bsub -K -J "secedo${slices}_${hprob#*.}_${seq_error_rate#*.}" -W 08:00 -n 20 -R "rusage[mem=80000]" \
           -R  "span[hosts=1]" -oo "${log_dir}/secedo.lsf.log" "${command}" &
    done
  done

  wait
}

# check the command-line arguments
if [ "$#" -ne 1 ]; then
            echo "Usage: main.sh <start_step>"
            echo "start_step=1 -> Split aligned BAMs by chromosome (~10 mins)"
            echo "start_step=2 -> Create pileup files (one per chromosome) (~10 mins)"
            echo "start_step=3 -> Run variant calling (~20 mins/cluster)"
            exit 1
fi

action=$1

if (( action <= 1)); then
  split_bams
fi
if (( action <= 2)); then
  create_pileup
fi
if (( action <= 3)); then
  variant_calling
fi
