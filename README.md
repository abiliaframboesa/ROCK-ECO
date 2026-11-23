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
