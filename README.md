NHANES 2017–2018 (SAS Base): Adult Obesity Prevalence

Goal. Estimate the weighted prevalence of adult obesity (BMI ≥ 30) overall and by sex and race/ethnicity using only Base SAS tools (DATA step, PROC COPY/CONTENTS/SORT/FREQ/MEANS, PROC FORMAT).
Why this matters. It shows real public-health data wrangling and correct use of NHANES weights—without jumping into SURVEY procedures yet.

Data

DEMO_J.XPT (Demographics: weights, age, sex, race/ethnicity, income-to-poverty ratio)

BMX_J.XPT (Body measures: BMI)

Source: NHANES 2017–2018 public files (CDC). Data are public domain.

Variables used

Join key: SEQN

Design/weight: WTMEC2YR (exam/MEC weight for 2-year cycle)

Demographics: RIDAGEYR (age), RIAGENDR (sex: 1=Male, 2=Female), RIDRETH3 (race/ethnicity), INDFMPIR (income-to-poverty ratio)

Outcome: BMXBMI (kg/m²)

Methods (Base SAS only)

Adults: RIDAGEYR ≥ 20

Obesity flag: obeseN = (BMXBMI ≥ 30) (0/1)

Weighted point estimates:

PROC FREQ with WEIGHT WTMEC2YR → weighted percentages

PROC MEANS on 0/1 indicator with WEIGHT WTMEC2YR → prevalence as a mean

No design-correct SEs/CIs in this v1 (keeps it SAS 1/2-friendly). See Upgrades for SURVEY version.

Repo layout
nhanes-obesity-sas/
├─ code/
│  └─ 01_nhanes1718_obesity_base.sas
├─ data_raw/          # XPTs (or fetch via PROC HTTP in v2)
├─ outputs/
│  ├─ prev_by_sex.csv
│  ├─ prev_by_race.csv
│  └─ nhanes1718_obesity_results.rtf
└─ docs/
   └─ methods-notes.md

How to run
Option A — Windows desktop SAS

Place XPT files in C:\CDC\ as:

C:\CDC\DEMO_J.xpt
C:\CDC\BMX_J.xpt


Open code/01_nhanes1718_obesity_base.sas and run. Key lines:

libname xptdemo xport "C:\CDC\DEMO_J.xpt" access=readonly;
libname xptbmx  xport "C:\CDC\BMX_J.xpt"  access=readonly;


Outputs write to C:\CDC\ (change paths if you like).

Option B — SAS OnDemand for Academics (cloud)

Upload DEMO_J.XPT and BMX_J.XPT to Files (Home).

Update paths, e.g.:

libname xptdemo xport "/home/<yourid>/DEMO_J.xpt" access=readonly;
libname xptbmx  xport "/home/<yourid>/BMX_J.xpt"  access=readonly;


Run the script.

Expected outputs

RTF: outputs/nhanes1718_obesity_results.rtf (simple table of results)

CSV: prev_by_sex.csv, prev_by_race.csv (weighted prevalence)

Interpretation template (fill these after running)

Overall adult obesity prevalence (weighted): ___ %

By sex (weighted): Male ___ %, Female ___ %

By race/ethnicity (weighted):

Mexican American ___ %

Other Hispanic ___ %

Non-Hispanic White ___ %

Non-Hispanic Black ___ %

Non-Hispanic Asian ___ %

Other/Multiracial ___ %

Notes on weighting

This analysis uses exam (MEC) weight WTMEC2YR because BMI comes from body-measure exams.

It’s a single 2-year cycle (2017–2018). If you later combine two cycles (e.g., 2015–2018), construct multi-year weights (e.g., divide WTMEC2YR by 2) or use CDC’s provided 4-year weights when applicable.

Limitations

Base SAS only: point estimates are weighted, but CIs/SEs aren’t design-correct (no strata/PSU incorporated).

No imputation beyond dropping missing BMI or weight.

Upgrades (nice “v2” commits later)

Swap PROC FREQ/MEANS for PROC SURVEYFREQ/SURVEYMEANS using SDMVSTRA, SDMVPSU, and WTMEC2YR to add CIs and proper SEs.

Add age-adjustment or combine multiple cycles.

Export publication-style tables via ODS or PROC REPORT.

Reuse

NHANES public data are free to use. Please credit: National Health and Nutrition Examination Survey (NHANES), 2017–2018. National Center for Health Statistics, CDC.
