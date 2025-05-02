from Bio import SeqIO
from itertools import combinations
import pandas as pd

def calculate_identity(seq1, seq2):
    # Calculate sequence identity between two ASVs
    matches = sum(1 for a, b in zip(seq1, seq2) if a == b and a != '-')
    length = sum(1 for a, b in zip(seq1, seq2) if a != '-' and b != '-')
    return (matches / length) * 100 if length > 0 else 0

# Read FASTA file
fasta_file = "sequence.fa.mafft.nogap"
sequences = list(SeqIO.parse(fasta_file, "fasta"))

# List sequence IDs
ids = [record.id for record in sequences]

# Create empty dataframe
identity_matrix = pd.DataFrame(index=ids, columns=ids, dtype=float)

# Calculate sequence identities among all pairs and store them in a matrix
for rec1, rec2 in combinations(sequences, 2):
    id1, id2 = rec1.id, rec2.id
    identity = calculate_identity(str(rec1.seq), str(rec2.seq))
    identity_matrix.loc[id1, id2] = identity
    identity_matrix.loc[id2, id1] = identity

# Self-comparison is 100.0%
for id in ids:
    identity_matrix.loc[id, id] = 100.0

# Export as TSV file
identity_matrix.to_csv("sequence_identity_matrix.tsv", sep='\t', float_format="%.2f")
