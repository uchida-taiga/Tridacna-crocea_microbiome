# Basecalling with bcl2fastq
# Resulting files are saved in the directory named "bcl2fastq"

/path/to/bin/bcl2fastq \
--processing-threads 24 \
--create-fastq-for-index-reads \
--use-bases-mask Y300n,I9,I5,Y300n \
--runfolder-dir /path/to/raw-data \
--sample-sheet Dummy.csv \
--output-dir bcl2fastq
