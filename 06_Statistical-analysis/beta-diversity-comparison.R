library(vegan)

# Input Bray-Curtis distance matrix and metadata
distance_matrix <- read.table("distance-matrix.tsv", header = TRUE, row.names = 1, sep = "\t")
distance_matrix <- as.dist(distance_matrix)
metadata <- read.table("metadata.txt", header = TRUE, sep = "\t")



##### PERMANOVA #####
adonis_result <- adonis2(distance_matrix ~ Group, data = metadata)
print(adonis_result)



##### Pairwise PERMANOVA #####
groups <- unique(metadata$Group)
group_pairs <- combn(groups, 2, simplify = FALSE)

# Make dataframe to store results
pairwise_results <- data.frame(Group1 = character(),
                               Group2 = character(),
                               PseudoF = numeric(),
                               R2 = numeric(),
                               PValue = numeric(),
                               stringsAsFactors = FALSE)
                               
# Perform PERMANOVA for each pair
for (pair in group_pairs) {
  # Group name
  group1 <- pair[1]
  group2 <- pair[2]

  # Extract samples
  subset_metadata <- metadata[metadata$Group %in% c(group1, group2), ]
  subset_samples <- subset_metadata$SampleID

  # Subset distance matrix
  subset_dist <- as.dist(as.matrix(distance_matrix)[subset_samples, subset_samples])

  # PERMANOVA
  adonis_pair <- adonis2(subset_dist ~ Group, data = subset_metadata)

  # Store results
  pairwise_results <- rbind(pairwise_results, data.frame(
    Group1 = group1,
    Group2 = group2,
    PseudoF = adonis_pair$F[1],
    R2 = adonis_pair$R2[1],
    PValue = adonis_pair$`Pr(>F)`[1]
  ))
}
print(pairwise_results)

# Benjamini-Hochberg adjustment
pairwise_results$QValue <- p.adjust(pairwise_results$PValue, method = "BH")
print(pairwise_results)

# Save results
write.table(pairwise_results, "pairwise_permanova_results.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
