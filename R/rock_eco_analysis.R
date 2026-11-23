# ROCK-ECO | Reproducible ecological modelling workflow
# IMPORTANT: Input data are synthetic and for workflow demonstration only.
# They are NOT field observations and must not be reported as empirical findings.

# 0. Setup -----------------------------------------------------------------
packages <- c("ggplot2")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing)
library(ggplot2)

data_path <- file.path("data", "synthetic_stone_lichen_surveys.csv")
out_dir <- "outputs"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

dat <- read.csv(data_path)
stopifnot(all(c("lichen_presence", "surface_temperature_c",
                "substrate_moisture_index", "substrate_roughness_index",
                "surface_pH", "shade_fraction", "site_id") %in% names(dat)))

# 1. Data quality checks ---------------------------------------------------
cat("Rows:", nrow(dat), "\n")
cat("Sites:", length(unique(dat$site_id)), "\n")
cat("Missing values:", sum(is.na(dat)), "\n")
cat("Lichen occurrence rate:", round(mean(dat$lichen_presence), 3), "\n")
capture.output(
  summary(dat),
  file = file.path(out_dir, "data_summary.txt")
)

# 2. Exploratory analysis --------------------------------------------------
p1 <- ggplot(dat, aes(x = substrate_moisture_index,
                      y = lichen_presence)) +
  geom_jitter(height = 0.06, width = 0.015, alpha = 0.55) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"),
              se = TRUE, colour = "steelblue") +
  labs(title = "Lichen occurrence along a substrate-moisture gradient",
       x = "Substrate moisture index", y = "Occurrence (0/1)") +
  theme_minimal()
ggsave(file.path(out_dir, "01_moisture_occurrence.png"), p1,
       width = 7, height = 5, dpi = 300)

# 3. PCA of environmental predictors --------------------------------------
env <- dat[, c("surface_temperature_c", "relative_humidity_pct",
               "substrate_moisture_index", "substrate_roughness_index",
               "surface_pH", "shade_fraction")]
pca <- prcomp(env, center = TRUE, scale. = TRUE)
pca_scores <- data.frame(pca$x[,1:2], site_id = dat$site_id,
                         lichen_presence = factor(dat$lichen_presence))
pca_plot <- ggplot(pca_scores, aes(PC1, PC2, colour = lichen_presence,
                                   shape = site_id)) +
  geom_point(size = 2.5, alpha = 0.8) +
  labs(title = "PCA of environmental conditions",
       colour = "Lichen presence", shape = "Site") +
  theme_minimal()
ggsave(file.path(out_dir, "02_environmental_PCA.png"), pca_plot,
       width = 7, height = 5, dpi = 300)
write.csv(as.data.frame(pca$rotation),
          file.path(out_dir, "PCA_loadings.csv"))

# 4. Binomial GLM ----------------------------------------------------------
# Site is included as a fixed effect to account for between-site differences.
model <- glm(lichen_presence ~ substrate_moisture_index +
               substrate_roughness_index + surface_temperature_c +
               surface_pH + shade_fraction + site_id,
             data = dat, family = binomial(link = "logit"))
capture.output(summary(model), file = file.path(out_dir, "GLM_summary.txt"))

# Odds ratios and Wald confidence intervals
coefs <- summary(model)$coefficients
or_table <- data.frame(
  term = rownames(coefs),
  estimate = coefs[,1],
  std_error = coefs[,2],
  odds_ratio = exp(coefs[,1]),
  conf_low = exp(coefs[,1] - 1.96*coefs[,2]),
  conf_high = exp(coefs[,1] + 1.96*coefs[,2]),
  p_value = coefs[,4],
  row.names = NULL
)
write.csv(or_table, file.path(out_dir, "GLM_odds_ratios.csv"), row.names = FALSE)

dat$predicted_probability <- predict(model, type = "response")
p3 <- ggplot(dat, aes(predicted_probability, lichen_presence,
                      colour = site_id)) +
  geom_jitter(height = 0.05, width = 0, alpha = 0.65) +
  labs(title = "Modelled probability of lichen occurrence",
       x = "Predicted probability", y = "Observed occurrence") +
  theme_minimal()
ggsave(file.path(out_dir, "03_predicted_probability.png"), p3,
       width = 7, height = 5, dpi = 300)

# 5. Exploratory spatial representation -----------------------------------
# x_local/y_local are arbitrary local-grid coordinates, NOT georeferenced.
p4 <- ggplot(dat, aes(x_local, y_local, colour = factor(lichen_presence),
                      size = substrate_moisture_index)) +
  geom_point(alpha = 0.85) +
  facet_wrap(~site_id) +
  coord_equal() +
  labs(title = "Illustrative within-site sampling layout",
       subtitle = "Synthetic local coordinates; not a geographic map",
       colour = "Lichen presence", size = "Moisture index",
       x = "Local X", y = "Local Y") +
  theme_minimal()
ggsave(file.path(out_dir, "04_local_sampling_layout.png"), p4,
       width = 9, height = 6, dpi = 300)

write.csv(dat, file.path(out_dir, "modelled_dataset.csv"), row.names = FALSE)
cat("\nWorkflow completed. Inspect files in the outputs/ folder.\n")
cat("Reminder: these are synthetic data; coefficients are illustrative only.\n")



# 6. Principal Component Analysis (PCA) -------------------------------

# Export PCA loadings
pca_loadings <- as.data.frame(pca$rotation)
pca_loadings$variable <- rownames(pca_loadings)

write.csv(
  pca_loadings,
  file.path(out_dir, "PCA_loadings.csv"),
  row.names = FALSE
)

# Export explained variance
pca_variance <- summary(pca)$importance
write.csv(
  pca_variance,
  file.path(out_dir, "PCA_explained_variance.csv")
)

# PCA biplot
png(
  file.path(out_dir, "05_PCA_biplot.png"),
  width = 1800, height = 1400, res = 200
)
biplot(pca, scale = 0, main = "ROCK-ECO: Environmental PCA")
dev.off()


# 7. Logistic regression effect estimates ----------------------------

# Calculate odds ratios and 95% profile likelihood confidence intervals
OR <- exp(coef(model))
IC <- exp(confint(model))

or_table <- data.frame(
  variable = names(OR),
  odds_ratio = as.numeric(OR),
  conf_low = IC[, 1],
  conf_high = IC[, 2],
  row.names = NULL
)

# Add p-values
or_table$p_value <- summary(model)$coefficients[, 4]

# Round numeric columns
numeric_columns <- c(
  "odds_ratio", "conf_low", "conf_high", "p_value"
)

or_table[numeric_columns] <- lapply(
  or_table[numeric_columns],
  round,
  digits = 3
)

# Export results
write.csv(
  or_table,
  file.path(out_dir, "GLM_odds_ratios_profile_CI.csv"),
  row.names = FALSE
)

print(or_table)


# 8. Model diagnostics and performance -------------------------------

# Predicted probabilities
prob <- predict(model, type = "response")

# Classification using a 0.5 threshold
pred <- ifelse(prob >= 0.5, 1, 0)

# Confusion matrix
confusion_matrix <- table(
  Observed = dat$lichen_presence,
  Predicted = pred
)

print(confusion_matrix)

# Sensitivity
sensitivity <- sum(
  pred == 1 & dat$lichen_presence == 1
) / sum(dat$lichen_presence == 1)

# Specificity
specificity <- sum(
  pred == 0 & dat$lichen_presence == 0
) / sum(dat$lichen_presence == 0)

# Save performance metrics
performance <- data.frame(
  metric = c("Sensitivity", "Specificity"),
  value = c(sensitivity, specificity)
)

write.csv(
  performance,
  file.path(out_dir, "model_performance.csv"),
  row.names = FALSE
)

print(performance)


# Install pROC if not already installed
if (!requireNamespace("pROC", quietly = TRUE)) {
  install.packages("pROC")
}

library(pROC)

# Generate ROC curve
roc_model <- roc(
  response = dat$lichen_presence,
  predictor = prob
)

# Calculate AUC
auc_value <- auc(roc_model)

print(auc_value)

# Plot ROC curve
png(
  file.path(out_dir, "06_ROC_curve.png"),
  width = 1800,
  height = 1400,
  res = 200
)

plot(
  roc_model,
  main = "ROCK-ECO: ROC Curve",
  col = "steelblue",
  lwd = 2
)

dev.off()


# Model 1: Full model
model_full <- glm(
  lichen_presence ~ substrate_moisture_index +
    substrate_roughness_index +
    surface_temperature_c +
    surface_pH +
    shade_fraction + site_id,
  data = dat,
  family = binomial
)

# Model 2: Environmental variables without site
model_no_site <- glm(
  lichen_presence ~ substrate_moisture_index +
    substrate_roughness_index +
    surface_temperature_c +
    surface_pH +
    shade_fraction,
  data = dat,
  family = binomial
)

# Model 3: Simplified environmental model
model_simple <- glm(
  lichen_presence ~ substrate_moisture_index +
    surface_temperature_c +
    shade_fraction,
  data = dat,
  family = binomial
)

# Compare models
model_comparison <- data.frame(
  Model = c("Full model", "Without site", "Simplified model"),
  AIC = c(
    AIC(model_full),
    AIC(model_no_site),
    AIC(model_simple)
  )
)

model_comparison <- model_comparison[
  order(model_comparison$AIC), ]

print(model_comparison)

write.csv(
  model_comparison,
  file.path(out_dir, "model_comparison.csv"),
  row.names = FALSE
)



# Fit the selected simplified model
model_final <- glm(
  lichen_presence ~ substrate_moisture_index +
    surface_temperature_c + shade_fraction,
  data = dat,
  family = binomial(link = "logit")
)

# Display model summary
summary(model_final)

# Calculate odds ratios and confidence intervals
OR_final <- exp(coef(model_final))
CI_final <- exp(confint(model_final))

final_results <- data.frame(
  Variable = names(OR_final),
  Odds_Ratio = as.numeric(OR_final),
  CI_Lower = CI_final[, 1],
  CI_Upper = CI_final[, 2],
  P_Value = summary(model_final)$coefficients[, 4]
)

# Round numeric columns only
numeric_columns <- c(
  "Odds_Ratio",
  "CI_Lower",
  "CI_Upper",
  "P_Value"
)

final_results[numeric_columns] <- lapply(
  final_results[numeric_columns],
  round,
  digits = 3
)

print(final_results)

# Save results
write.csv(
  final_results,
  file.path(out_dir, "final_model_results.csv"),
  row.names = FALSE
)


library(pROC)

prob_final <- predict(model_final, type = "response")

roc_final <- roc(
  dat$lichen_presence,
  prob_final
)

auc(roc_final)

png(
  file.path(out_dir, "07_Final_model_ROC.png"),
  width = 900,
  height = 700
)

plot(
  roc_final,
  main = "ROC Curve - Simplified Logistic Regression Model"
)

dev.off()

file.exists(
  file.path(out_dir, "07_Final_model_ROC.png")
)

# 9. Workflow completion ----------------------------------------------

cat("\nROCK-ECO analysis workflow completed.\n")
cat("Check the outputs/ directory for generated results.\n")
cat("All input observations are synthetic and illustrative only.\n")

