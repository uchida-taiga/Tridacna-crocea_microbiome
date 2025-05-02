##### Tissue-specific microbiome #####

library(dunn.test)

# Input data
data <- read.delim("shannon.tsv", header = TRUE, sep = "\t")

# Exclude seawater samples
data <- subset(data, tissue != "water")

# Kruskal-Wallis test
kruskal_result <- kruskal.test(shannon_entropy ~ tissue, data = data)
print(kruskal_result)

# Dunn's test
dunn_result <- dunn.test(data$shannon_entropy, data$tissue, method = "none")
# Benjamini-Hochberg adjustment
adjusted_p_values <- p.adjust(dunn_result$P, method = "BH")
# Summerize results
results_table <- data.frame(
  Comparison = dunn_result$comparisons,
  Unadjusted_P_Value = dunn_result$P,
  Adjusted_P_Value_BH = adjusted_p_values
)
print(results_table)
write.table(results_table, file = "shannon_dunn-test_results.tsv", sep = "\t", quote = FALSE, row.names = FALSE)



##### Dark-induced bleaching experiment #####

library(dplyr)

# Input data
data <- read.delim("shannon.tsv", sep = "\t", header = TRUE)

# Specify combinations to compare
pairwise_comparisons <- list(
  c("2m-light", "2m-dark"),
  c("3m-light", "3m-dark")
)

# Mann-Whitney U-test
results <- lapply(pairwise_comparisons, function(pair) {
  group1 <- data %>% filter(`condition.month` == pair[1]) %>% pull(shannon_entropy)
  group2 <- data %>% filter(`condition.month` == pair[2]) %>% pull(shannon_entropy)
  test <- wilcox.test(group1, group2, exact = FALSE)
  data.frame(
    Comparison = paste(pair[1], "vs", pair[2]),
    P_Value = test$p.value
  )
})
results_df <- bind_rows(results)
print(results_df)
