/* === 0) Read local XPORT files === */
libname xptdemo xport "C:\CDC\DEMO_J.xpt" access=readonly;
libname xptbmx  xport "C:\CDC\BMX_J.xpt"  access=readonly;

/* Convert to WORK */
proc copy in=xptdemo out=work; run;
proc copy in=xptbmx  out=work; run;

proc contents data=work.demo_j; title "DEMO_J variables"; run;
proc contents data=work.bmx_j;  title "BMX_J variables";  run;

/* === 1) Prep variables with DATA step & FORMATS === */
proc sort data=DEMO_J; by SEQN; run;
proc sort data=BMX_J;  by SEQN; run;

proc format;
  value sexfmt 1='Male' 2='Female';
  value racefmt
    1='Mexican American'
    2='Other Hispanic'
    3='Non-Hispanic White'
    4='Non-Hispanic Black'
    6='Non-Hispanic Asian'
    7='Other/Multiracial';
  value agegrp
    20-39 = '20-39'
    40-59 = '40-59'
    60-high = '60+';
run;

data nhanes1718_base;
  merge DEMO_J(keep=SEQN WTMEC2YR RIDAGEYR RIAGENDR RIDRETH3 INDFMPIR)
        BMX_J (keep=SEQN BMXBMI);
  by SEQN;

  /* analysis flags */
  adult  = (RIDAGEYR >= 20);
  obeseN = (not missing(BMXBMI) and BMXBMI>=30);  /* numeric 0/1 for PROC MEANS */
  length obese $3;
  obese = ifc(obeseN=1,'Yes','No');

  /* convenience */
  age_cat = RIDAGEYR; format age_cat agegrp.;
  format RIAGENDR sexfmt. RIDRETH3 racefmt.;
run;

/* Keep adults with non-missing weight & BMI */
data nhanes_adults;
  set nhanes1718_base;
  if adult=1 and not missing(WTMEC2YR) and not missing(BMXBMI);
run;

/* === 2) Weighted prevalence tables (PROC FREQ + WEIGHT) === */
/* Prints weighted %; good for portfolio-level point estimates */
title "Adult Obesity (BMI>=30) — Overall (Weighted)";
proc freq data=nhanes_adults;
  weight WTMEC2YR;
  tables obese / nocum;
run;

title "Adult Obesity — By Sex (Row % are weighted)";
proc freq data=nhanes_adults;
  weight WTMEC2YR;
  tables RIAGENDR*obese / norow nocol nopercent;  /* print default weighted percent */
run;

title "Adult Obesity — By Race/Ethnicity (Weighted)";
proc freq data=nhanes_adults;
  weight WTMEC2YR;
  tables RIDRETH3*obese;
run;

title "Adult Obesity — By Age Group (Weighted)";
proc freq data=nhanes_adults;
  weight WTMEC2YR;
  tables age_cat*obese;
run;

/* === 3) Weighted mean of a 0/1 to get prevalence === */
title "Prevalence via Weighted Mean of 0/1 Indicator";
proc means data=nhanes_adults mean maxdec=2;
  weight WTMEC2YR;
  var obeseN; /* mean(obeseN) = prevalence */
run;

title "Prevalence by Sex (Weighted Mean of 0/1)";
proc means data=nhanes_adults mean maxdec=2;
  class RIAGENDR;
  weight WTMEC2YR;
  var obeseN;
run;

title "Prevalence by Race/Ethnicity (Weighted Mean of 0/1)";
proc means data=nhanes_adults mean maxdec=2;
  class RIDRETH3;
  weight WTMEC2YR;
  var obeseN;
run;

/* === 4) Optional: export simple outputs === */
/* Capture PROC MEANS output to a dataset with ODS OUTPUT, then export */
ods output Summary=prev_by_sex;
proc means data=nhanes_adults mean maxdec=4;
  class RIAGENDR;
  weight WTMEC2YR;
  var obeseN;
run;

ods output Summary=prev_by_race;
proc means data=nhanes_adults mean maxdec=4;
  class RIDRETH3;
  weight WTMEC2YR;
  var obeseN;
run;

proc export data=prev_by_sex
  outfile="C:\CDC\prev_by_sex.csv" dbms=csv replace;
run;

proc export data=prev_by_race
  outfile="C:\CDC\prev_by_race.csv" dbms=csv replace;
run;

/* Clean titles */
title;
