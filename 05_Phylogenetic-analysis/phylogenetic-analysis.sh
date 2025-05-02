# Alignment
mafft --auto sequence.fa > sequence.fa.mafft

# Trimming
trimal -in sequence.fa.mafft -out sequence.fa.mafft.nogap -nogaps

# Maximum likelihood phylogenetic analysis
raxmlHPC-PTHREADS-AVX -f a -# 100 -n rax1 -T 48 -x 12345 -p 12345 -m GTRGAMMAI -s sequence.fa.mafft.nogap

# Calculation of sequence identity
python calculate_identity.py
