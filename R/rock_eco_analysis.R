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
write.csv(summary(dat), file.path(out_dir, "data_summary.csv"))

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
