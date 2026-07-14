/* Core cleaning + standardization DATA step from "Analysis Q3 2025.sas".
   Partitions the survey data into current-quarter vs all-quarter sets,
   fixes known data-entry errors by record_id/faclic, standardizes the
   antibiotic "total" molecule metrics with parallel arrays, maps each
   facility license number to a coded facility name, and computes the
   bed-filled and Rx-at-admission percentages. The molecule array is
   trimmed to the columns carried by the sample data; the surrounding
   logic (array pattern, faclic->name mapping, output routing) is
   unchanged from the source. */
data redcap_current_quarter redcap_all_quarter;
set redcap;
where survey_of_antibiotic_v_1 ne 0;
 if record_id=2 then do; levo_in=0; piptazo_in=0; metro_in=0; end;
if record_id=40 then census=94;
if record_id=336 then census=76;
if faclic=363 then beds=106;
if faclic=358 then beds=120;

array total {*} amoxicillin_total cef_total metro_total nitro_total vanco_total;
array adm {*} amoxicillin_adm cef_adm metro_adm nitro_adm vanco_adm;
array in {*} amoxicillin_in cef_in metro_in nitro_in vanco_in;
do i=1 to dim(total);
 if missing(adm{i}) then adm{i}=0;
 if missing(in{i}) then in{i}=0;
 total{i}=sum(adm{i}, in{i});
end;

length hospname $50 name $20;
if faclic=168 then do; name="TN_ZA"; hospname='Knollwood Manor'; end;
else if faclic=100 then do; name="TN_ZB"; hospname='The Heritage Center'; end;
else if faclic=290 then do; name="TN_ZD"; hospname='Agape Nursing & Rehabilitation'; end;
else if faclic=363 then do; name="TN_ZG"; hospname='NHC Farragut'; end;
else name=facname;
label name="Facility name";

perc_bedfilled=census/beds;
sum_adm=sum(of adm{*});
if sum_adm=. then sum_adm=0;
perc_Rxadm=sum_adm/census;

drop i;
if &startdate<=surveydate<=&enddate then output redcap_all_quarter;
if qtr(surveydate)=&quarter and year(surveydate)=&year then output redcap_current_quarter;
run;

proc print data=redcap_current_quarter (obs=10);
var name hospname faclic census beds sum_adm perc_bedfilled;
title "Current quarter cleaned rows";
run;
