# Education, GDP, and Inequality Panel Dataset

## Overview
This project collects, cleans, and analyzes household- and country-level panel data for six ASEAN countries.  
The focus is on the relationships between **education**, **GDP per capita**, and **income inequality**.

## Project Structure
## How to Run
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/edu-gdp-inequality-panel.git

## Figures
![GDP per capita](outputs/gdp_pc_lines.png)
![Secondary enrollment](outputs/sec_enroll_lines.png)
![Gini index](outputs/gini_lines.png)

## Panel Summary
See `reports/panel_summary.md` for missingness and balanced-years info.

## Figures
![GDP per capita](outputs/gdp_pc_lines.png)
![Secondary enrollment](outputs/sec_enroll_lines.png)
![Gini index](outputs/gini_lines.png)
![Correlation](outputs/corr_heatmap.png)
![GDP vs Enrollment](outputs/scatter_gdp_vs_enroll.png)
![GDP vs Gini](outputs/scatter_gdp_vs_gini.png)

## Diagnostics
See `reports/diagnostics.md` for:
- Unit roots (IPS)
- Multicollinearity (VIF)
- Cross-sectional dependence (Pesaran CD)
- Serial correlation (panel BG)
- Heteroskedasticity (Breusch–Pagan)

![FE Residuals vs Fitted](outputs/fe_resid_vs_fitted.png)

## Fixed-Effects Regression
We estimated a country FE model:

log(GDP per capita) ~ Secondary enrollment + Gini

- Three SE corrections: Clustered, Arellano, Driscoll–Kraay  
- See `reports/fe_model.md` for details

![FE coefficients](outputs/fe_model_coefs.png)

## Robustness
See `reports/model_robustness.md` for:
- Coefficients across Pooled / FE / Two-way FE / RE
- LM test (RE vs pooled), Hausman (FE vs RE)
- F-tests for country and time fixed effects

## Figures
![GDP per capita](outputs/gdp_pc_lines.png)
![Secondary enrollment](outputs/sec_enroll_lines.png)
![Gini index](outputs/gini_lines.png)
![Correlation](outputs/corr_heatmap.png)
![GDP vs Enrollment](outputs/scatter_gdp_vs_enroll.png)
![GDP vs Gini](outputs/scatter_gdp_vs_gini.png)
