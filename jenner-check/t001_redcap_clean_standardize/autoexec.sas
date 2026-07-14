/* cap input rows for the captured run */
options obs=100 nodate nonumber;

/* Macro variables normally set at the top of Analysis Q3 2025.sas by the
   %time macro and the start/end-date DATA _NULL_ steps. Fixed here so the
   captured run is reproducible instead of keyed off today(). */
%let quarter=3;
%let year=2025;
%let startdate=%sysfunc(mdy(1,1,2024));
%let enddate=%sysfunc(mdy(9,30,2025));
%let currentquarter=&year Q&quarter;

/* Stand-in for the external `redcap` dataset the program %includes from an
   H:\ REDCap export. Minimal column shape the cleaning DATA step reads:
   census/beds, survey completion flag, faclic (facility license), and the
   adm/in antibiotic counts the arrays standardize. Values are synthetic. */
data redcap;
  length facname $30;
  input record_id faclic census beds surveydate :yymmdd10. survey_of_antibiotic_v_1 nhsn_id anyabx
        amoxicillin_adm amoxicillin_in cef_adm cef_in metro_adm metro_in nitro_adm nitro_in
        vanco_adm vanco_in facname $;
  amoxicillin_total=.; cef_total=.; metro_total=.; nitro_total=.; vanco_total=.;
  format surveydate yymmdd10.;
  datalines;
2 168 88 106 2025-08-15 1 999 3 2 1 1 0 0 0 1 0 1 0 Knollwood
40 100 94 100 2025-07-20 1 999 2 1 0 1 1 0 0 0 0 0 1 Heritage
336 290 76 90 2025-09-01 1 999 1 0 0 0 0 1 0 0 0 1 0 Agape
5 363 70 106 2025-08-05 1 999 4 2 1 1 1 0 0 1 1 1 1 Farragut
7 999 55 60 2025-06-30 1 999 0 0 0 0 0 0 0 0 0 0 0 OtherFac
;
run;
