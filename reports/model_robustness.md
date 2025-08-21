# Model robustness & comparisons

Models: Pooled OLS, FE (country), FE (two-way), RE.

## Coefficients under different SE corrections

term = predictor; estimate = coefficient; se = standard error; p = p-value.

```text
model term estimate se t p
Pooled OLS (clustered) sec_enroll_gross 0.0104893933190678 0.00440254020091755 2.38257752124141 0.0187363268093989
Pooled OLS (clustered) gini 0.0299551595867793 0.0397903160117434 0.752825375348577 0.453005060298355
FE (country) clustered sec_enroll_gross 0.01291773200926 0.00578741874169718 2.23203686925059 0.0275002585446709
FE (country) clustered gini -0.0188449530831143 0.021177817998982 -0.889843943508256 0.37536026967786
FE (country) Driscoll-Kraay sec_enroll_gross 0.01291773200926 0.00220302279710823 5.86363973455756 4.21342431941832e-08
FE (country) Driscoll-Kraay gini -0.0188449530831143 0.00426393571766917 -4.41961472473034 2.20939906703802e-05
FE (two-way) Driscoll-Kraay sec_enroll_gross -0.00220136849002692 0.000626313905334927 -3.51480059962859 0.000678998312291695
FE (two-way) Driscoll-Kraay gini 0.0161985519481152 0.00303879029258153 5.33059223851676 6.70245118234006e-07
RE (clustered) sec_enroll_gross 0.012927499270375 0.00576015507957819 2.24429708780022 0.0266159650800764
RE (clustered) gini -0.01828914677956 0.0210321384090646 -0.869580944355024 0.386237081122763
```

## Specification tests

### LM test (RE vs pooled)

```text

	Lagrange Multiplier Test - (Breusch-Pagan)

data:  log_gdp_pc ~ sec_enroll_gross + gini
chisq = 958.16, df = 1, p-value < 2.2e-16
alternative hypothesis: significant effects

```

### Hausman test (FE vs RE)

```text

	Hausman Test

data:  log_gdp_pc ~ sec_enroll_gross + gini
chisq = 0.35654, df = 2, p-value = 0.8367
alternative hypothesis: one model is inconsistent

```

### F-test: need country FE

```text

	F test for individual effects

data:  log_gdp_pc ~ sec_enroll_gross + gini
F = 194.53, df1 = 4, df2 = 118, p-value < 2.2e-16
alternative hypothesis: significant effects

```

### F-test: need time FE

```text

	F test for time effects

data:  log_gdp_pc ~ sec_enroll_gross + gini
F = 1.3072, df1 = 24, df2 = 98, p-value = 0.1801
alternative hypothesis: significant effects

```

