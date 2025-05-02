# Input data
data <- data.frame(
  group = factor(rep(c("Light-2m", "Dark-2m", "Light-3m", "Dark-3m"), each = 3), 
                 levels = c("Light-2m", "Dark-2m", "Light-3m", "Dark-3m")),
  value = c(2.4, 2.1, 2.5, 1.2, 0.60, 1.6, 2.5, 2.2, 1.7, 0.03, 0.10, 0.15)
)

L2 <- data$value[data$group == "Light-2m"]
D2 <- data$value[data$group == "Dark-2m"]
L3 <- data$value[data$group == "Light-3m"]
D3 <- data$value[data$group == "Dark-3m"]

# Welch's t-test
t.test(L2, D2, var.equal = FALSE)
t.test(L3, D3, var.equal = FALSE)
t.test(L2, L3, var.equal = FALSE)
