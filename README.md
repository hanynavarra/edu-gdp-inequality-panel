# Education, GDP, and Inequality Panel Dataset

## Overview
This project collects, cleans, and analyzes household- and country-level panel data for six ASEAN countries.  
The focus is on the relationships between **education**, **GDP per capita**, and **income inequality**.

## Project Structure
## How to Run
1. Clone the repository:
   ```bash
   git clone https://github.com/hanynavarra/edu-gdp-inequality-panel.git

## Figures
![GDP per capita](outputs/gdp_pc_lines.png)

This line graph reveals persistent income gaps within the ASEAN6. **Singapore** stands out with a steep and sustained rise in GDP per capita, reaching over $65,000, far ahead of its neighbors. **Malaysia** shows moderate growth, while **Vietnam**, **Indonesia**, and **the Philippines** exhibit slower but steady increases. These trends reflect both the long-standing development gap and differing levels of industrialization, capital inflows, and economic reform across the region. The widening disparity suggests challenges for regional convergence and shared prosperity goals (World Bank, 2024).


![Secondary enrollment](outputs/sec_enroll_lines.png)

Enrollment rates in secondary education have steadily improved for most ASEAN6 countries. **Thailand** and **Vietnam** maintained consistently high rates above 90%, while **Indonesia** and **the Philippines** made notable gains since 2000. **Malaysia’s** rates remain relatively stagnant, and **Singapore** appears stable but already near saturation. Notably, the 2013-2016 spike in **Thailand** may reflect statistical anomalies or education reforms. Closing the education gap is essential for equitable development and long-term human capital investment (UNESCO, 2023).


![Gini index](outputs/gini_lines.png)

Income inequality is trending downward in most ASEAN countries, though at varying rates. Indonesia shows a sharp improvement post-2010, while Thailand and Philippines also display a declining Gini index. Vietnam and Malaysia remain relatively stable, with high but slightly improving scores. Singapore’s inequality remains high, likely due to its unique economic structure and wealth concentration. Overall, while positive, the pace of inequality reduction may be too slow to match rising aspirations in the region (ADB, 2024).


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

This residual plot assesses the validity of the linear model used to relate GDP per capita with education and inequality. The spread of residuals appears randomly scattered around zero, suggesting that the linear form is appropriate and there is no strong evidence of non-linearity. However, the slight clustering around the center may hint at mild heteroskedasticity, which could warrant further checks like White’s test or robust standard errors. Overall, the model does not show major violations of basic linear regression assumptions.


## Fixed-Effects Regression
We estimated a country FE model:

log(GDP per capita) ~ Secondary enrollment + Gini

- Three SE corrections: Clustered, Arellano, Driscoll–Kraay  
- See `reports/fe_model.md` for details

![FE coefficients](outputs/fe_model_coefs.png)

This coefficient plot visualizes the results from three Fixed Effects models. Across all specifications, secondary education enrollment shows a consistent positive and significant relationship with GDP per capita — supporting the theory that human capital development drives economic growth. On the other hand, the Gini index (inequality) generally shows a negative coefficient, suggesting that higher inequality may dampen growth, although the effect is weaker and less stable across models. The confidence intervals reinforce the robustness of the education effect while highlighting uncertainty around inequality’s role. Together, these results point to education as a more reliable driver of economic growth in the ASEAN context.


## Robustness
See `reports/model_robustness.md` for:
- Coefficients across Pooled / FE / Two-way FE / RE
- LM test (RE vs pooled), Hausman (FE vs RE)
- F-tests for country and time fixed effects

---

## Discussion of Results  

Our panel dataset of six ASEAN countries (2010–2024) shows:  

- **GDP per capita and enrollment** move closely together, indicating that higher economic growth is associated with improved access to education.  
- **GDP per capita and inequality (Gini index)** show weaker correlation, suggesting that growth does not automatically reduce inequality.  
- **Fixed Effects estimation** confirms that, within countries, increases in GDP per capita are significantly associated with higher school enrollment rates, even after accounting for unobserved country-level differences.  
- However, the link between GDP and inequality remains mixed, hinting that redistribution policies may be necessary for growth to translate into more equitable outcomes.  

These results demonstrate how household and country-level panel data can be harmonized and analyzed to uncover meaningful relationships in development economics.  
