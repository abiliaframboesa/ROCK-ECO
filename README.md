# ROCK-ECO
## Ecological modelling of biological colonisation on stone surfaces

**Purpose.** A reproducible pilot workflow inspired by the BIOPOLIS/CIBIO BIOPOLIS 2026-59 role and its focus on ecological modelling, spatial analysis, environmental information and biological communities associated with stone surfaces and built heritage.

### Scientific question
How do microclimatic conditions and substrate properties relate to the probability of lichen occurrence on stone surfaces?

### Data status — read this carefully
The included dataset is **synthetic** (simulated for software/workflow demonstration). It is not collected from monuments, is not a published dataset, and cannot support empirical claims about Portuguese heritage. The local X/Y coordinates are arbitrary sampling-grid coordinates, not real geographic coordinates.

### Variables
- `site_id`, `sample_id`: synthetic sampling identifiers
- `surface_temperature_c`: surface temperature (°C)
- `relative_humidity_pct`: relative humidity (%)
- `substrate_moisture_index`: illustrative moisture index (unitless)
- `substrate_roughness_index`: illustrative roughness index (unitless)
- `surface_pH`: surface pH
- `shade_fraction`: fraction from 0 to 1
- `x_local`, `y_local`: arbitrary within-site grid coordinates
- `lichen_presence`: binary response (0/1)
- `lichen_cover_pct`: illustrative cover percentage

### Workflow
1. Data checks and exploratory analysis
2. PCA of standardised environmental predictors
3. Binomial logistic GLM for lichen occurrence, with site as a fixed effect
4. Odds ratios and confidence intervals
5. Predicted probabilities and an illustrative within-site sampling layout

### Run
From the project root in R or RStudio:

```r
source("R/rock_eco_analysis.R")
```

The script uses base R plus `ggplot2`. It creates figures and tables in `outputs/`.

### Interpretation and limitations
This is a methods demonstrator, not a validated ecological model. Synthetic data can be used to test code and explain an analytical workflow, but not to infer real ecological relationships. The model does not yet account for spatial autocorrelation, imperfect detection, repeated measurements, species identity, substrate lithology classes, or temporal microclimate variation. Before applying it to real data, inspect collinearity, sample design, model fit, calibration, residuals and spatial dependence; consider mixed-effects models if sampling is hierarchical.

### Next step for a research-grade version
Replace the synthetic data with documented field observations or an openly licensed, traceable dataset relevant to stone-associated biota. Record sampling protocol, date, coordinates, substrate lithology, microclimate sensor metadata, taxonomic identification and observer/detection information. Use real georeferenced coordinates and QGIS only after verifying coordinate reference systems and data provenance.

### Suggested CV wording (only after running and reviewing the workflow)
**ROCK-ECO — Ecological Modelling Pilot (independent portfolio project, 2026)**
- Built a reproducible R workflow for quality-checking and analysing ecological and environmental data.
- Applied PCA to explore environmental gradients and a binomial GLM to model simulated lichen occurrence as a function of microclimatic and substrate predictors.
- Produced model summaries, odds-ratio tables and exploratory visualisations; documented data provenance, assumptions and limitations.
- Designed a workflow that can be extended to georeferenced field data and GIS-based analysis.

Do not describe this as fieldwork, validated species-distribution modelling, or analysis of real heritage sites.

# ROCK-ECO
## Ecological Modelling of Stone–Biodiversity Interactions

### 1. Project overview

ROCK-ECO is a portfolio project demonstrating an ecological data analysis workflow focused on the relationship between environmental conditions, stone substrate characteristics and lichen occurrence.

The project uses a synthetic dataset to illustrate how statistical analysis, exploratory data analysis, Principal Component Analysis (PCA) and Generalized Linear Models (GLMs) can be integrated into an ecological modelling workflow.

The analysis was developed using R and includes data quality checks, data visualization, model fitting, model comparison and the generation of graphical outputs.

**Important:** All data used in this project are synthetic and were generated for demonstration purposes. They do not represent field observations, real sampling locations, or empirical ecological findings.

### 2. Objectives

The main objectives are to:

- Demonstrate an ecological data analysis workflow using R.
- Explore relationships between environmental variables and simulated lichen occurrence.
- Investigate environmental gradients using Principal Component Analysis.
- Model simulated lichen presence using binomial logistic regression.
- Compare alternative statistical models using the Akaike Information Criterion (AIC).
- Evaluate model discrimination using Receiver Operating Characteristic (ROC) curves and the Area Under the Curve (AUC).
- Produce reproducible figures and statistical outputs.

### 3. Dataset

The synthetic dataset contains 150 observations distributed across five simulated sites.

The response variable is binary:

- `lichen_presence = 1`: simulated lichen presence.
- `lichen_presence = 0`: simulated lichen absence.

The environmental variables include:

| Variable | Description |
|---|---|
| `site_id` | Simulated sampling site identifier |
| `sample_id` | Unique sample identifier |
| `surface_temperature_c` | Surface temperature (°C) |
| `relative_humidity_pct` | Relative humidity (%) |
| `substrate_moisture_index` | Substrate moisture index |
| `substrate_roughness_index` | Substrate roughness index |
| `surface_pH` | Surface pH |
| `shade_fraction` | Proportion of the surface under shade |
| `x_local` | Illustrative local X-coordinate |
| `y_local` | Illustrative local Y-coordinate |
| `lichen_presence` | Binary simulated occurrence variable |
| `lichen_cover_pct` | Simulated lichen cover (%) |

The local coordinates are illustrative and are not geographically referenced.

### 4. Methodology

The workflow consists of the following stages:

**4.1. Data quality assessment**

Initial checks include dataset dimensions, missing values, number of sites and occurrence frequency.

**4.2. Exploratory Data Analysis**

Environmental variables and their relationships with simulated lichen occurrence are explored through graphical representations.

**4.3. Principal Component Analysis**

PCA is performed using `prcomp()` with centering and scaling enabled:

`prcomp(env, center = TRUE, scale. = TRUE)`

This approach standardizes environmental variables before identifying the main gradients of environmental variation.

**4.4. Logistic regression**

Binomial Generalized Linear Models (GLMs) with a logit link are used to explore associations between environmental predictors and simulated lichen presence.

Two main models are considered:

- Full model: includes substrate moisture, substrate roughness, surface temperature, surface pH, shade fraction and site identity.
- Simplified model: includes substrate moisture, surface temperature and shade fraction.

**4.5. Model comparison and evaluation**

Alternative models are compared using AIC.

Model discrimination is assessed using ROC curves and AUC values. These metrics are calculated using the same dataset used for model fitting and should therefore be interpreted as apparent, rather than independently validated, performance.

### 5. Main results

The PCA indicates that the first two principal components explain approximately 47.1% of the total environmental variance, while the first four components explain approximately 80.4%.

The simplified logistic regression model has the lowest AIC among the three compared models (AIC = 162.853).

In the simplified model:

- Substrate moisture shows a positive association with simulated lichen occurrence, although this relationship is not statistically significant at the 5% level (p = 0.072).
- Surface temperature shows a statistically significant negative association (p = 0.034).
- Shade fraction shows a statistically significant positive association (p = 0.031).

The simplified model has an apparent AUC of approximately 0.683.

These results illustrate the interpretation of ecological statistical models using synthetic data. They should not be interpreted as evidence of real ecological relationships.

### 6. Project structure

The project is organized into the following directories:

```text
ROCK-ECO/
│
├── data/
│   └── Synthetic dataset
│
├── R/
│   └── Main R analysis script
│
├── outputs/
│   ├── 01_moisture_occurrence.png
│   ├── 02_environmental_PCA.png
│   ├── 03_predicted_probability.png
│   ├── 04_local_sampling_layout.png
│   ├── 05_PCA_biplot.png
│   ├── 06_ROC_curve.png
│   ├── 07_Final_model_ROC.png
│   ├── PCA_loadings.csv
│   ├── PCA_explained_variance.csv
│   └── Additional statistical outputs
│
└── README.md
```

### 7. Requirements

The analysis was developed in R.

The main R packages used are:

- `ggplot2` – data visualization.
- `pROC` – ROC curve and AUC analysis.

The script includes package installation checks where necessary.

### 8. How to run the analysis

1. Download or clone the project repository.
2. Open the project directory in RStudio.
3. Ensure that the required dataset is available in the `data/` directory.
4. Open the main R script in the `R/` directory.
5. Run the script.

The analysis generates graphical and statistical outputs in the `outputs/` directory.

### 9. Limitations

This project is intended as a methodological demonstration rather than an empirical ecological study.

Its main limitations are:

- The dataset is entirely synthetic.
- Sampling locations and coordinates are illustrative.
- Model performance is evaluated using the data used for model fitting.
- No independent validation dataset is available.
- Statistical associations do not establish causal relationships.
- Results cannot be extrapolated to real species, sites or stone surfaces.

### 10. Skills demonstrated

This project demonstrates practical experience with:

- Ecological data analysis.
- R programming and reproducible workflows.
- Data quality assessment and exploratory analysis.
- Data visualization.
- Principal Component Analysis.
- Generalized Linear Models and logistic regression.
- Odds ratios and confidence intervals.
- Model selection using AIC.
- ROC curves and AUC interpretation.
- Interpretation and communication of statistical results.

### 11. Final note

ROCK-ECO was developed as a compact portfolio project to demonstrate how quantitative ecological methods can be applied to questions concerning environmental conditions and biodiversity associated with stone substrates.

The workflow provides a reproducible example of data processing, statistical modelling and visualization that could be adapted to future empirical datasets.
