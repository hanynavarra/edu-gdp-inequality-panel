# Panel Diagnostics
 
## Unit root tests (IPS / `plm::purtest`)
 
### log_gdp_pc 
``` 
 	Im-Pesaran-Shin Unit-Root Test (ex. var.: Individual Intercepts and 	Trend)  data:  pdf[[v]] Wtbar = NA, p-value = NA alternative hypothesis: stationarity  
```
 
### sec_enroll_gross 
``` 
 	Im-Pesaran-Shin Unit-Root Test (ex. var.: Individual Intercepts and 	Trend)  data:  pdf[[v]] Wtbar = NA, p-value = NA alternative hypothesis: stationarity  
```
 
## Multicollinearity (VIF)
 
VIF from pooled OLS: 
``` 
sec_enroll_gross             gini          1.033847         1.033847  
```
 
## Cross-sectional dependence (`plm::pcdtest`)
 
``` 
 	Pesaran CD test for cross-sectional dependence in panels  data:  log_gdp_pc ~ sec_enroll_gross + gini z = 5.1716, p-value = 2.321e-07 alternative hypothesis: cross-sectional dependence  
```
 
## Serial correlation (`plm::pbgtest`)
 
``` 
 	Breusch-Godfrey/Wooldridge test for serial correlation in panel models  data:  log_gdp_pc ~ sec_enroll_gross + gini chisq = 99.753, df = 25, p-value = 6.904e-11 alternative hypothesis: serial correlation in idiosyncratic errors  
```
 
## Heteroskedasticity (`lmtest::bptest`)
 
``` 
 	studentized Breusch-Pagan test  data:  pool_mod BP = 71.753, df = 30, p-value = 2.817e-05  
```
 
## Residual vs Fitted (FE model)
 
Saved: `outputs/fe_resid_vs_fitted.png`
 
