#!/bin/sh
#SBATCH --job-name=hisat2_align    # Job name
#SBATCH --mail-type=ALL               # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=l.xiangfei@ufl.edu   # Where to send mail	
#SBATCH --nodes=1                     # Use one node
#SBATCH --ntasks=1                    # Run a single task
#SBATCH --cpus-per-task=4
#SBATCH --mem=8gb                   # Memory limit
#SBATCH --time=24:00:00               # Time limit hrs:min:sec
#SBATCH --output=hisat2_align%j.log   # Standard output and error log

pwd; hostname; date

module load gcc/5.2.0 hisat2/2.1.0 samtools stringtie

echo "hisat2 align"

hisat2 -p 4 --dta -x hg38/genome -1 SiC_R1.fastq.gz -2 SiC_R2.fastq.gz -S SiC.sam
hisat2 -p 4 --dta -x hg38/genome -1 SiM_R1.fastq.gz -2 SiM_R2.fastq.gz -S SiM.sam

echo "samtools sort"

samtools sort -@ 4 -o SiC.bam SiC.sam
samtools sort -@ 4 -o SiM.bam SiM.sam


echo "samtools index"

samtools index SiC.bam
samtools index SiM.bam

echo "stringtie assemble"

stringtie -p 4 -G hg38.gtf -o SiC.gtf -l SiC SiC.bam
stringtie -p 4 -G hg38.gtf -o SiM.gtf -l SiM SiM.bam


echo "stringtie merge"

stringtie --merge -p 4 -G hg38.gtf -o stringtie_merged.gtf mergelist.txt

echo "stringtie ballgown"

stringtie -e -B -p 4 -G stringtie_merged.gtf -o ballgown/SiC/SiC.gtf SiC.bam
stringtie -e -B -p 4 -G stringtie_merged.gtf -o ballgown/SiM/SiM.gtf SiM.bam


date 2020-06-08
