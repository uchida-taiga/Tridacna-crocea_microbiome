# Demultiplexing with Claident
# Resulting files are saved in the directory named "Demultiplexed."

clsplitseq \
--runname=240701 \
--index1file=index1.fa \
--index2file=index2.fa \
--minqualtag=30 \
--numthreads=32 \
--truncateN=enable \
bcl2fastq/Undetermined_S0_L001_R1_001.fastq.gz \
bcl2fastq/Undetermined_S0_L001_I1_001.fastq.gz \
bcl2fastq/Undetermined_S0_L001_I2_001.fastq.gz \
bcl2fastq/Undetermined_S0_L001_R2_001.fastq.gz \
Demultiplexed
