***********************************************************************************
***********************************************************************************
                                             Tennessee Department of Health
             CEDEP / Healthcare Associated Infections and Antimicrobial Stewardship Program
***********************************************************************************
***********************************************************************************
       Project: Long Term Care Hospitals Point Prevalence Survey     

Programmer: Dipen Patel

       Version:

***********************************************************************************
***********************************************************************************
Description :

***********************************************************************************
***********************************************************************************
Notes: This program is ran on a quarterly basis. All macros variables MUST be updated first  

***********************************************************************************
***********************************************************************************;

/* Setting System Options */
options nodate nonumber  mcompilenote=all mprint mlogic symbolgen ps=max;
ods escapechar='~';

/*Defining macro variables*/
                        *Automatic setting of year and quarter variables;;
%macro time ; 
%global quarter;
%global year;

data _null_;
call symputx ('quarter', qtr(intnx('qtr',today(),-1)));
run;

%if &quarter=4 %then %do;

data _null_;
call symputx ('year', year (today())-1);
run;
                                          %end;

                                  %else %do;

data _null_;
call symputx ('year', year (today()));
run;

                                           %end;
%mend;

%time;

%put &quarter &year;

*Automatic setting of start and end date;
data _null_;
x=intnx ('day',today(),-60);
call symputx ('enddate', intnx('month',x, 0, 'E'));
call symputx ('startdate', intnx ('qtr',x,-5, 'B'));
run;


*Other macro variables;
%Let currentquarter=&year Q&quarter;

%put &quarter &year &currentquarter;

/* Importing external SAS file */

%Let path=%str(H:\NHSN\Antimicrobial Stewardship\Antibiotic Use Survey Data\LTCF AU Survey\20180618\&year-Q&quarter Analysis);
%Let file=LTCFAntimicrobialUse_SAS_2025-11-19_1036;*UPDATE SAS File name;
%Include "&path./SAS code/&file..sas" / SOURCE2;



*Creating format for quarter variable later;

 proc format;
 picture mydate 
     low-high='%Y-Q%q ' (datatype=date);
	 run;


/*Partitioning dataset into Current quarter  vs All quarters  + Cleaning */

	   /** ATTENTION: After the below data step, Run a proc freq or print of "facname" and "faclic" to detect any new reporting facility and standardize their 'name' and 'hospname' in the
	            'if-then-else' codes of the data step below :  See Greened code below this data step **/

data redcap_current_quarter  redcap_all_quarter;
set redcap (drop=redcap_survey_identifier survey_of_antibiotic_v_0 datacollector contactphone contactemail );
*Delete incomplete surveys;
where survey_of_antibiotic_v_1 ne 0;
 *cleaning typo in Heritage center record 2 + other cleanings + Other Data entry errors cleansing;
 if record_id=2 then  do;
                                       levo_in=0;
                                       piptazo_in=0;
									   metro_in=0;
						    end;
if record_id=40 then census=94;
if record_id=336 then census=76;
if faclic=363 then beds=106;
if  faclic=358 then beds=120;

*Standardizing Total Molecules metrics;
array total {*} amoxicillin_total amoxiclav_total  azithro_total cef_total cephalexin_total cipro_total clinda_total dapto_total doxy_total erta_total fluc_total levo_total
linezolid_total  metro_total moxi_total nitro_total piptazo_total methsulf_total vanco_total vancopo_total;
array adm {*} amoxicillin_adm  amoxiclav_adm  azithro_adm cef_adm cephalexin_adm cipro_adm clinda_adm dapto_adm doxy_adm erta_adm fluc_adm levo_adm linezolid_adm  metro_adm 
moxi_adm nitro_adm piptazo_adm methsulf_adm vanco_adm vancopo_adm;
array in {*} amoxicillin_in amoxiclav_in  azithro_in cef_in cephalexin_in cipro_in clinda_in dapto_in doxy_in erta_in fluc_in levo_in linezolid_in metro_in moxi_in nitro_in 
piptazo_in methsulf_in vanco_in vancopo_in;
do i=1 to dim(total);
if missing(adm{i}) then adm{i}=0;
if missing(in{i}) then in{i}=0;
total{i}=sum(adm{i}, in{i});
end;

*Renaming LTC facilities;    

length hospname $50 name $20;
if faclic=168 then do; name="TN_ZA"; hospname='Knollwood Manor'; end;
else if faclic=100 then do; name="TN_ZB";hospname='The Heritage Center'; end;
else if faclic=290 then do; name="TN_ZD";hospname='Agape Nursing & Rehabilitation'; end;
else if faclic=358 then do; name="TN_ZE";hospname='AHC Savannah Senior Living and Rehabilitation'; end;
else if faclic=7440201  then do; name="TN_ZF";hospname='Weakley County Rehab and Nursing Center '; end;
else if faclic=363 then do; name="TN_ZG";hospname='NHC Farragut'; end;
else if faclic=112 then do; name="TN_ZH";hospname='NHC Chattanooga'; end;
else if faclic=445491 then do; name='TN_ZI';hospname='MV HCC'; end;
else if faclic=201 then do; name='TN_ZJ';hospname='Perry County Nursing Home'; end;
else if faclic=405 then do; name='TN_ZK';hospname='Regional One Health Subacute Care'; end;
else if faclic=1346213642 then do; name='TN_ZM'; hospname='Tennova Convalescent Center'; end;
else if faclic=87 then do; name='TN_ZN';hospname='Humboldt Nursing and Rehabilitation Center'; end;
else if faclic=10 then do; name="TN_ZO"; hospname="Asbury Place Maryville"; end;
else if faclic=31 then do; name="TN_ZP"; hospname="Life Care Center of Tullahoma"; end;
else if faclic=113 then do; name="TN_ZQ"; hospname="Saint Barnabas at Siskin Hospital"; end;
else  if faclic=379 then do; name="TN_ZL"; hospname="Bethesda Healthcare"; end;
else  if faclic=45 then do; name="TN_ZR"; hospname="West Meade Place"; end;
else  if faclic=122 then do; name="TN_ZS"; hospname="AHC Crestview"; end;
else  if faclic=118 then do; name="TN_ZT"; hospname="Harbert Hills Academy Nursing Home"; end;
else  if faclic=119 then do; name="TN_ZU"; hospname="HMC Health and Rehab"; end;
else  if faclic=324 then do; name="TN_ZV"; hospname="AHC Covington Care"; end;
else  if faclic=621355415 then do; name="TN_ZW"; hospname="AHC Cumberland"; end;
else  if faclic=158 then do; name="TN_ZZ"; hospname="AHC Lewis County"; end;
else  if faclic=445429 then do; name="TN_ZAA"; hospname="AHC of Mckenzie"; end;
else  if faclic=74 then do; name="TN_ZAB"; hospname="AHC Dyersburg"; end;
else  if faclic=92 then do; name="TN_ZAC"; hospname="AHC Meadowbrook"; end;
else  if faclic=445207 then do; name="TN_ZX"; hospname="Wexford House"; end;
else  if faclic=103 then do; name="TN_ZY"; hospname="Health Care at Standifer Place"; end;
else  if faclic=24 then do; name="TN_ZAD"; hospname="Christian Care Center of McKenzie"; end;
else  if faclic=275 then do; name="TN_ZAE"; hospname="Christian Care Center of Unicoi County"; end;
else  if faclic=399 then do; name="TN_ZAF"; hospname="Christian Care Center of Memphis"; end;
else  if faclic=409 then do; name="TN_ZAG"; hospname="Christian Care Center of Bristol"; end;
else  if faclic=25 then do; name="TN_ZAH"; hospname="Ivy Hall Nursing Home"; end;
else  if faclic=187 then do; name="TN_ZAI"; hospname="Sweetwater Nursing Center"; end;
else  if faclic=202 then do; name="TN_ZAJ"; hospname="Pickett Care and Rehabilitation Center"; end;
else  if faclic=289 then do; name="TN_ZAK"; hospname="Cornerstone Village"; end;
else  if faclic=151 then do; name="TN_ZAL"; hospname="Reelfoot Manor Health and Rehab"; end;
else  if faclic=1194781955 then do; name="TN_ZAM"; hospname="Northside Senior Living and Rehabilitation"; end;
else  if faclic=38 then do; name="TN_ZAN"; hospname="Tristate Health and Rehabilitation"; end;
else  if faclic=384 then do; name="TN_ZAO"; hospname="The Village at Germantown"; end;
else  if faclic=310 then do; name="TN_ZAP"; hospname="Durham-Hensley Health & Rehab"; end;
else  if faclic=17 then do; name="TN_ZAQ"; hospname="Beech Tree Post Acute Health and Rehabilitation"; end;
else  if faclic=90 then do; name="TN_ZAR"; hospname="Trenton Health and Rehabilitation Center"; end;
else  if faclic=278 then do; name="TN_ZAS"; hospname="Waynesboro Health and Rehabilitation"; end;
else  if faclic=445331 then do; name="TN_ZAT"; hospname="Graceland Rehab and Nursing Center"; end;
else  if faclic=41 then do; name="TN_ZAU"; hospname="Henderson Health and Rehabilitation"; end;
else  if faclic=71 then do; name="TN_ZAV"; hospname="NHC Healthcare Smithville"; end;
else  if faclic=200 then do; name="TN_ZAW"; hospname="Overton County Health and Rehab"; end;
else  if faclic=354 then do; name="TN_ZAV"; hospname="Generations Center of Spencer"; end;
else if faclic=274 then do; name="TN_ZBA"; hospname="Erwin Healthcare Center"; end;
else if faclic=316 or faclic=56853 then do; name="TN_ZBB"; hospname="Millington Health Care Center"; end;
else if faclic=326 then do; name="TN_ZBC"; hospname="Graceland Rehabilitation and Nursing Center";end;
else if faclic=445397 then do; name="TN_ZBD"; hospname="Adamsville Healthcare and Rehab"; end;
else if faclic=94 then do; name="TN_ZBE"; hospname="Ridgeview Terrace of Life Care"; end;
else if faclic=1043763592 then do; name="TN_ZBF"; hospname="Lakebridge, A Waters Community"; end;
else if faclic=445471 then do; name="TN_ZBG"; hospname="Henderson Health and Rehab"; end;
else if faclic=2 then do; name="TN_ZBH"; hospname="Diversicare of Oak Ridge"; end;
else if faclic=445310 then do; name="TN_ZBI"; hospname="Life Care Center of Copper Basin"; end;
else if faclic=209 then do; name="TN_ZBJ"; hospname="LifeCare Center of Rhea County"; end;
else if faclic=0000000291 then do; name="TN_ZJC"; hospname="NHC HealthCare Johnson City"; end;
else if faclic=445408 then do; name="TN_ZSD"; hospname="Soddy-Daisy Healthcare Center"; end;
else if faclic in (232 445490) then do; name="TN_ZAM"; hospname="Ave Maria Home"; end;
else if faclic=445130 then do; name="TN_ZNS"; hospname="NHC Healthcare Sparta"; end;
else if faclic=115 then do; name="TN_ZHM"; hospname="Hancock Manor Health & Rehab"; end;
else if faclic=445224 then do; name="TN_ZCA"; hospname="Henry County Healthcare Center"; end;
else if faclic=1013281161 then do; name="TN_ZCB"; hospname="Wharton Nursing home"; end;


else name=facname;

if nhsn_id=57437 or faclic=57437 or faclic=149 or faclic=471022 or faclic=14370 or faclic=7440177 then do; name="TN_ZC"; hospname="Serene Manor Medical Center"; end;

label name="Facility name"; 

*Other cleanings;
if name="TN_ZC" then beds=79;
if name="TN_ZO" then census=90;
drop  nhsn_id survey_of_antibiotic_v_1 i;
*Re-compute the 'Anyabx' variable for the TN_ZN facility;

if name in ('TN_ZN' "TN_ZQ") then anyabx=sum(amoxicillin_total, amoxiclav_total, azithro_total, cef_total, cephalexin_total, cipro_total,clinda_total, dapto_total, doxy_total, erta_total, fluc_total, levo_total,
linezolid_total, metro_total,moxi_total,nitro_total,piptazo_total, methsulf_total, vanco_total,vancopo_total);

*percentages calculations: Bed filled and Any Abx;
perc_bedfilled=census/beds ; 
perc_anyRxused=anyabx/census;
*Sum and percentages Rx at admin calculations ;
 sum_adm=sum(amoxicillin_adm, amoxiclav_adm, azithro_adm, cef_adm, cephalexin_adm, cipro_adm,clinda_adm, dapto_adm, doxy_adm, erta_adm, fluc_adm, levo_adm, linezolid_adm, metro_adm,
moxi_adm,nitro_adm,piptazo_adm, methsulf_adm, vanco_adm,vancopo_adm); 
if sum_adm=. then sum_adm=0;
perc_Rxadm=sum_adm/census;
*Sum  and percentages Rx Initiated;
sum_in=sum(amoxicillin_in, amoxiclav_in, azithro_in, cef_in, cephalexin_in, cipro_in,clinda_in, dapto_in, doxy_in, erta_in, fluc_in, levo_in, linezolid_in, metro_in,moxi_in,nitro_in,
piptazo_in, methsulf_in, vanco_in,vancopo_in);
if sum_in=. then sum_in=0;
perc_Rxin=sum_in/census;
*Sum and percentages Rx  Total;
sum_total=sum(amoxicillin_total, amoxiclav_total, azithro_total, cef_total, cephalexin_total, cipro_total,clinda_total, dapto_total, doxy_total, erta_total, fluc_total, levo_total,
linezolid_total, metro_total,moxi_total,nitro_total,piptazo_total, methsulf_total, vanco_total,vancopo_total);
if sum_total=. then sum_total=0;
 perc_Rxtotal=sum_total/census;
 *Creating quarter variable;                  
 quarter=put(surveydate, mydate.);
 *Output data for current quarter and past six quarters;
if  &startdate<=surveydate<=&enddate Then output   redcap_all_quarter;
if qtr (surveydate)=&quarter and year(surveydate)=&year then output redcap_current_quarter; 
 run;



/*   *Run this code to check for new facilities ;*/
proc freq data=redcap_current_quarter;
tables name facname hospname ;
run;*/





 ****************************************************************************************************************
 *                                                                    DATA VISUALIZATION                                                                                                                                         *
 ****************************************************************************************************************;


 /* Creating table with the desired statistics */
proc sql;
create table output  as 
 select name, beds, count(name) as numb label="Frequency of reporting", avg(census)as av_census label="Average Census" format=6.1, (calculated av_census)/beds as filled_bed label="Beds filled" 
format=percent10.1, avg (anyabx) as n_rx label="Average number of Abx reported" format=5.1,(calculated n_rx)/(calculated av_census) as rx_used label="Percentage of pts on abx" format=percent10.1, 
avg (sum_adm) as Adm_rx label="Average number of Abx present on admission" format=4.1, (calculated adm_rx)/(calculated av_census) as rx_at_admin label="Patients with abx since admission" format=percent10.1,
avg (sum_in) as in_rx label="Average number of Abx initiated in facility" format=4.1, (calculated in_rx)/(calculated av_census) as rx_init label="Patients with abx initiated in facility" format=percent10.1, 
avg (sum_total) as tot_rx label="Sum of Rx Total" format=4.1, (calculated tot_rx)/(calculated av_census) as rx_tot_pres label="Total abx prescribed" format=percent10.1
 from redcap_current_quarter 
 group by 1,2
 order by 1;
/* title "Summary of collaborative result";
select *
from output;*/
 quit;
title;


/* ADMISSION-INITIATED PERCENT GRAPH */

proc sql;
*subsetting Percentage of Abx at Admission ONLY;
create table admission as
select name, rx_at_admin
from output /*the data OUTPUT is querried from the Analysis Qx 201x SAS file*/
order by 1;
*subsetting Percentage of Abx initiated in facility ONLY;
create table initiated as
select name,  rx_init
from output
order by 1;
quit;

data interweaved;*Interleaving the  two datasets created above;
set admission initiated;
by name;
length Type $ 22;
if first.name then Type ='On admission';
if last.name then Type='Initiated in facility';
label type='Antimicrobials';
run;

proc sql;*Coalescing 'rx_init' and 'rx_at_admin' in ONE VARIABLE;
create table coalesced as 
select name, type, coalesce (rx_init, rx_at_admin) as percentage format=percent10.1
from interweaved;
quit;


************************************************************************************
*                          COLLAB vs FACILITY SPECIFIC REPORT TABLES                                                                           *
************************************************************************************;


/* Get the median, mean, min, max of each Abx */

proc sql;
create table redcap2 as  /* creating "Average" percentage of each molecule (Admission, Initiated and Total) per reporting facility within the quarter*/
select  name, sum (amoxicillin_adm)/ sum(census) as amx_adm,  sum (amoxiclav_adm)/ sum(census) as amxcl_adm, sum (azithro_adm)/ sum(census) as azit_adm,  
 sum (cef_adm)/ sum(census) as ceftri_adm, sum (cephalexin_adm)/ sum(census) as cephal_adm, sum (cipro_adm)/ sum(census) as cip_adm, sum (clinda_adm)/ sum(census) as clind_adm, sum (dapto_adm)/ sum(census) as dap_adm, 
 sum (doxy_adm)/ sum(census) as dox_adm, sum (erta_adm)/ sum(census) as ert_adm, sum (fluc_adm)/ sum(census) as flu_adm, sum (levo_adm)/ sum(census) as lev_adm, sum (linezolid_adm)/ sum(census) as linezo_adm, 
 sum (metro_adm)/ sum(census) as met_adm, sum (moxi_adm)/ sum(census) as mox_adm, sum (nitro_adm)/ sum(census) as nitr_adm, sum (vanco_adm)/ sum(census) as vanc_adm, sum (vancopo_adm)/ sum(census) as vancop_adm,
  sum (piptazo_adm)/ sum(census) as pipta_adm, sum (methsulf_adm)/sum(census) as methsu_adm,
 sum (amoxicillin_in)/ sum(census) as amx_in,  sum (amoxiclav_in)/ sum(census) as amxcl_in, sum (azithro_in)/ sum(census) as azit_in,  
 sum (cef_in)/ sum(census) as ceftri_in, sum (cephalexin_in)/ sum(census) as cephal_in, sum (cipro_in)/ sum(census) as cip_in, sum (clinda_in)/ sum(census) as clind_in, sum (dapto_in)/ sum(census) as dap_in, 
 sum (doxy_in)/ sum(census) as dox_in, sum (erta_in)/ sum(census) as ert_in, sum (fluc_in)/ sum(census) as flu_in, sum (levo_in)/ sum(census) as lev_in, sum (linezolid_in)/ sum(census) as linezo_in, 
 sum (metro_in)/ sum(census) as met_in, sum (moxi_in)/ sum(census) as mox_in, sum (nitro_in)/ sum(census) as nitr_in, sum (vanco_in)/ sum(census) as vanc_in, sum (vancopo_in)/ sum(census) as vancop_in,
  sum (piptazo_in)/ sum(census) as pipta_in, sum (methsulf_in)/ sum(census) as methsu_in,
sum (amoxicillin_total)/ sum(census) as amx_total,  sum (amoxiclav_total)/sum(census) as amxcl_total, sum (azithro_total)/ sum(census) as azit_total,  
 sum (cef_total)/ sum(census) as ceftri_total, sum (cephalexin_total)/ sum(census) as cephal_total, sum (cipro_total)/ sum(census) as cip_total, sum (clinda_total)/ sum(census) as clind_total, sum (dapto_total)/ sum(census) as dap_total, 
 sum (doxy_total)/ sum(census) as dox_total, sum (erta_total)/ sum(census) as ert_total, sum (fluc_total)/ sum(census)as flu_total, sum (levo_total)/ sum(census) as lev_total, sum (linezolid_total)/ sum(census) as linezo_total, 
 sum (metro_total)/ sum(census) as met_total, sum (moxi_total)/ sum(census) as mox_total, sum (nitro_total)/ sum(census) as nitr_total, sum (vanco_total)/ sum(census) as vanc_total, sum (vancopo_total)/ sum(census) as vancop_total,
  sum (piptazo_total)/ sum(census) as pipta_total, sum (methsulf_total)/ sum(census) as methsu_total
from redcap_current_quarter  
group by name ;
quit;


/*Macro definition for the collab-wide results */
 
%macro collab_stat (type1, type,num );

/* Collaborative wide statistics for &type1 Abx prescribed*/

proc means data=redcap2  noprint;  
title "Collaborative results for &type1 Abx for &quarter  ";
var amx_&type. amxcl_&type. azit_&type. ceftri_&type. cephal_&type. cip_&type. clind_&type. dap_&type. dox_&type. ert_&type. flu_&type. lev_&type. mox_&type. linezo_&type.
       met_&type.   nitr_&type. pipta_&type. vanc_&type. vancop_&type.  methsu_&type.;
output out=stats&num. (drop=_type_ _freq_) median=amx_adm1 amxcl_adm1 azit_adm1 ceftri_adm1 cephal_adm1 cip_adm1 clind_adm1 dap_adm1 dox_adm1 ert_adm1 flu_adm1 lev_adm1 mox_adm1 linezo_adm1
                                                met_adm1   nitr_adm1 pipta_adm1 vanc_adm1 vancop_adm1  methsu_adm1
                                 min=amx_adm2 amxcl_adm2 azit_adm2 ceftri_adm2 cephal_adm2 cip_adm2 clind_adm2 dap_adm2 dox_adm2 ert_adm2 flu_adm2 lev_adm2 mox_adm2 linezo_adm2
                                            met_adm2   nitr_adm2 pipta_adm2 vanc_adm2 vancop_adm2  methsu_adm2
                                  max=amx_adm3 amxcl_adm3 azit_adm3 ceftri_adm3 cephal_adm3 cip_adm3 clind_adm3 dap_adm3 dox_adm3 ert_adm3 flu_adm3 lev_adm3 mox_adm3 linezo_adm3
                                             met_adm3   nitr_adm3 pipta_adm3 vanc_adm3 vancop_adm3  methsu_adm3;
run;

proc transpose data=stats&num. out=trans&num.;
run;
data median&num. (rename=(_name_=molecule col1=median) ) min&num. (drop=_name_ rename=(col1=minimum)) max&num. (drop=_name_ rename=(col1=maximum)) ;
set trans&num. ;
if _n_ le 20 then output median&num.;
else if 21 <= _n_<=40 then output min&num.;
else if _n_>40 then output max&num.;
run;

data combined_&type. ;
set median&num. ;
set min&num. ;
set max&num.;
run;

*ABSOLUTE  SUM of &type1 specific Abx ;

proc means data=redcap_all_quarter noprint; 
title "Collaborative-wide average number for &type1 specific Abx for &quarter";
class name quarter;
var amoxicillin_&type. amoxiclav_&type. azithro_&type. cef_&type. cephalexin_&type. cipro_&type. clinda_&type. dapto_&type. doxy_&type. erta_&type. fluc_&type. levo_&type.
moxi_&type. linezolid_&type. metro_&type.  nitro_&type. piptazo_&type. vanco_&type. vancopo_&type. methsulf_&type.;
output out=&type. (drop= _freq_) sum= amoxicillin_adm amoxiclav_adm azithro_adm cef_adm cephalexin_adm cipro_adm clinda_adm dapto_adm doxy_adm erta_adm  fluc_adm levo_adm moxi_adm linezolid_adm  metro_adm 
 nitro_adm piptazo_adm  vanco_adm vancopo_adm methsulf_adm;
run;

data &type&num.  (drop=_type_ );
set &type.;
where  _TYPE_>2;
run;

proc sort data=&type&num.;
by name quarter;
proc transpose data=&type&num. out=&type.final (drop=_LABEL_ rename=(col1=sum)); 
by name quarter;
run;

%mend ;

*Calling Macro for Collaborative wide statistics for Abx at Admission, Initiated in facility and Total Abx;
%collab_stat (Admission, adm,1)
%collab_stat (Initiated, in,2)
%collab_stat (Total, total,3);



*Format for the antibiotics name;

proc format;
value  $molecul
                         'amx_adm1'='Amoxicillin'
						 'amxcl_adm1'='Amoxicillin/Clavulanic Acid'
						 'azit_adm1'='Azithromycin or Clarithromycin'
						 'ceftri_adm1'='Ceftriaxone'
						 'cephal_adm1'='Cephalexin'
						 'cip_adm1'='Ciprofloxacin'
						 'clind_adm1'='Clindamycin'
						 'dap_adm1'='Daptomycin'
						 'dox_adm1'='Doxycycline'
						 'ert_adm1'='Ertapenem'
						 'flu_adm1'='Fluconazole'
						 'lev_adm1'='Levofloxacin'
						 'mox_adm1'='Moxifloxacin'
						 'linezo_adm1'='Linezolid'
						 'met_adm1'='Metronidazole'
						 'nitr_adm1'='Nitrofurantoin'
						 'pipta_adm1'='Piperacillin/tazobactam'
						 'vanc_adm1'='Vancomycin'
						 'vancop_adm1'='Vancomycin PO'
						 'methsu_adm1'='Sulfamethoxazole/trimethoprim';
			run;



***************************************************************************************
*                                               BAR LINE GRAPH                                                                                                               *
***************************************************************************************;



/* Creating table with the desired statistics */

 proc sql;;
create table BARLINE  as 
 select quarter, name, sum (sum_total)/ sum(census) as rx_used label="Percent of patients on antimicrobials" format=percent10.1
 from redcap_all_quarter
 group by 1,2
 order by 1,2 ;
/* title "Summary of collaborative result";
select *
from barline;*/
 quit;
title;

  /* Collaborative wide statistics*/
proc means data=barline mean maxdec=3 noprint ; 
title "Collaborative results for any Abx";
var rx_used;
class quarter;
output out=collab(where=(_type_>0)) mean=Collab_mean;
run;

/*Joining tables of collab and facility-wide*/
proc sql;
create table joined (drop=_type_ _freq_ ) as 
select *
from  barline b inner join collab c 
on b.quarter=c.quarter;
/*select * from joined;*/
quit;


 /* Adding missing values for facilities that did not report in any of  the past 6 quarters   */

proc sql noprint;
select name into: hospLT6 separated by  "/" 
from (select name, count (quarter) as count
            from joined where name in (select distinct name from Redcap_current_quarter )
           group by 1)
where count<6;
select count( distinct name) into: counthosp
from (select name, count (quarter) as count
            from joined where name in (select distinct name from Redcap_current_quarter )
           group by 1)
where count<6;
quit;
%put %bquote(&hospLT6) &counthosp;

* Template from Merged;
proc sql;
create table temp as
select distinct quarter, Collab_mean
from joined;
quit;

data temp;
set temp;
rx_used=.; 
run;

* Macro to process Missing values;


%macro missing;
%do i=1 %to &counthosp;
  *Adding the missing hospname variable ;

data temp&i;
set temp;
length name $ 20;
name="%scan(%bquote(&hospLT6), &i, /)";
run;
 
   *Update the new data with their existing values in the merged;
data updated&i;
update temp&i joined (where=(name="%scan(%bquote(&hospLT6), &i, /)"));
by quarter name;
run;
    *Concatenate the upadated facility data with the big set 'Merged';
data joined ;
set joined updated&i;
run; 
%end;
%mend ;

*Execute the macro program;
%missing;

*Delete duplicated rows;

proc sort data=joined nodup;
by quarter name;
run;


********************************************************************************************************
*                                     STACKED BAR GRAPHS for ABX GROUPS                                                                                                                        *
********************************************************************************************************;

/* Grouping Abx by categories : UTI, CDI and RESP */

data redcap3;
set redcap_current_quarter;
*groups of Abx at admission;
uti_adm=sum(cef_adm , cephalexin_adm, nitro_adm, methsulf_adm);
cdi_adm=sum (metro_adm, vancopo_adm);
resp_adm=sum (amoxicillin_adm, amoxiclav_adm, azithro_adm , cef_adm, levo_adm, moxi_adm);
ssti_adm=sum(cephalexin_adm, clinda_adm, dapto_adm, doxy_adm, fluc_adm, linezolid_adm, vanco_adm, methsulf_adm);
*groups of Abx initiated;
uti_in=sum(cef_in , cephalexin_in, nitro_in, methsulf_in);
cdi_in=sum (metro_in, vancopo_in);
resp_in=sum (amoxicillin_in, amoxiclav_in, azithro_in , cef_in, levo_in, moxi_in);
ssti_in=sum(cephalexin_in, clinda_in, dapto_in, doxy_in, fluc_in, linezolid_in, vanco_in, methsulf_in);
*groups of total Abx prescribed;
uti_total=sum(cef_total , cephalexin_total, nitro_total, methsulf_total);
cdi_total=sum (metro_total, vancopo_total);
resp_total=sum (amoxicillin_total, amoxiclav_total, azithro_total , cef_total, levo_total, moxi_total);
ssti_total=sum(cephalexin_total, clinda_total, dapto_total, doxy_total, fluc_total, linezolid_total, vanco_total, methsulf_total);
run;

proc sql; /* Calculating percentages of Abx groups at admission, initiated and total prescribed*/
create table redcap3_bis as 
select  name, sum (uti_adm)/ sum(anyabx) as utia_adm format=percent10.1 label="% UTI Abx at admission",  sum (uti_in)/ sum(anyabx) as utii_in format=percent10.1 label="% UTI Abx initiated",sum (uti_total)/ sum(anyabx) as utit_total format=percent10.1 label="% total UTI Abx ",
sum (cdi_adm)/ sum(anyabx) as cdia_adm format=percent10.1 label=" % CDI Abx at admission",    sum (cdi_in)/ sum(anyabx) as cdii_in format=percent10.1 label="% CDI Abx initiated",sum (cdi_total)/ sum(anyabx) as cdit_total format=percent10.1 label="% total CDI Abx ",
sum (resp_adm)/ sum(anyabx) as respa_adm format=percent10.1 label="% Respirapory Abx at admission",  sum (resp_in)/ sum(anyabx) as respi_in format=percent10.1 label="% Respirapory Abx initiated",    sum (resp_total)/ sum(anyabx) as respt_total format=percent10.1 label="% Total respirapory Abx",
sum (ssti_adm)/ sum(anyabx) as sstia_adm format=percent10.1 label=" % SSTI Abx at admission",    sum (ssti_in)/ sum(anyabx) as sstii_in format=percent10.1 label="% SSTI Abx initiated",sum (ssti_total)/ sum(anyabx) as sstit_total format=percent10.1 label="% total SSTI Abx "
from redcap3
group by name ;
title "Groups of Abx for Q&quarter &year, by facility ";
select * from redcap3_bis;
quit;

/* Stacked bars For each facility: For GROUPED ABX */

proc transpose data=redcap3_bis out=transposed;
id name;
var utia_adm utii_in cdia_adm cdii_in respa_adm respi_in sstia_adm sstii_in;
by name;
run;

data transposed2 (drop=_label_ _name_);
set transposed;
length Group $ 11;
if _name_ in ('cdia_adm', 'cdii_in') then Group='CDI';
else if _name_ in ('respa_adm', 'respi_in') then Group='Respiratory';
else if _name_ in ('sstia_adm', 'sstii_in') then Group='SSTI';
else Group='UTI';
run;


/* Table */

data abx2;
infile cards dlm=',' dsd missover;
length CDI  Respiratory  SSTI  UTI $ 30;
input CDI $ Respiratory $ SSTI $ UTI $;
label SSTI='Skin and Soft Tissue Infection';
cards;
Metronidazole, Amoxicillin, Cephalexin, Ceftriaxone
Vancomycine (PO), Amoxicillin/Clavulanic acid, Clindamycin, Ciprofloxacin
, Azithromycin, Daptomycin, Nitrofurantoin
, Ceftriaxone, Doxycyclin, Sulfamethoxazole/Trimethoprim
, Levofloxacin, Fluconazole,
,Moxifloxacin, Linezolid,
, , Vancomycin,
, , Sulfamethoxazole/Trimethoprim,
;
run;

******************************************************************************
*                                                    Macro For Reports                                                                                       *
******************************************************************************;
*Macro to select unique quarter names;
proc sql noprint;
select distinct quarter 
           into: qt separated by '/' 
from Redcap_all_quarter
order by 1 desc;
select distinct  substr(quarter,1,4)
           into: yr separated by '/'
from Redcap_all_quarter
order by 1 desc;
quit;
%put &yr &qt;

*Tables Macro Program to be nested  in the PDF Macro Program;

%macro pr_table ; *Proc report table;

%if &quarter=1 %then %do;

proc report data=all_&type   split="#" nowindows spanrows
  style(report)=[fontfamily="Calibri" borderwidth=2 bordercolor=black textalign=c]
  style(header)=[color=black  fontfamily="Calibri" fontsize=2 fontweight=bold  backgroundcolor=lightgrey foreground=Black borderwidth=3  textalign=c]
  style(column)=[color=black  fontfamily="Calibri" fontsize=2 fontweight=medium borderwidth=3 textalign=c]  
  style(lines)=[color=black   fontfamily="Arial" fontsize=1 fontweight=bold backgroundcolor=lightgrey textalign=c  ]
  style(summary)=[color=black fontfamily="Arial" fontsize=1 fontweight=bold backgroundcolor=lightgrey textalign=c];

	title "&title";  
  column  ((molecule ("Collaborative Wide Results of &currentquarter " median minimum maximum)) 
                   ("Facility &fac" ("%scan(&yr,1,/)" sumq6 ) ("%scan(&yr,2,/)" sumq5 sumq4 sumq3  sumq2 ) ("%scan(&yr,3,/)" sumq1   )) ); 		

  DEFINE molecule/DISPLAY  FORMAT=$molecul. STYLE(COLUMN) = [JUST=left width=2.0in] "Antibiotic";
  DEFINE median/DISPLAY FORMAT=percent7.1  "Median";
  DEFINE minimum/DISPLAY FORMAT=percent7.1  "Minimum";
  DEFINE maximum  /DISPLAY FORMAT=percent7.1 "Maximum" ;
  DEFINE sumq6  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,1,/),7,1)" ;
  DEFINE sumq5  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,2,/),7,1)" ;
  DEFINE sumq4  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,3,/),7,1)" ;
  DEFINE sumq3  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,4,/),7,1)" ;
  DEFINE sumq2 /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,5,/),7,1)";
  DEFINE sumq1/DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,6,/),7,1)";
  RUN;
                                         %end;

%else %if &quarter=2 %then %do;

proc report data=all_&type   split="#" nowindows spanrows
  style(report)=[fontfamily="Calibri" borderwidth=2 bordercolor=black textalign=c]
  style(header)=[color=black  fontfamily="Calibri" fontsize=2 fontweight=bold  backgroundcolor=lightgrey foreground=Black borderwidth=3  textalign=c]
  style(column)=[color=black  fontfamily="Calibri" fontsize=2 fontweight=medium borderwidth=3 textalign=c]  
  style(lines)=[color=black   fontfamily="Arial" fontsize=1 fontweight=bold backgroundcolor=lightgrey textalign=c  ]
  style(summary)=[color=black fontfamily="Arial" fontsize=1 fontweight=bold backgroundcolor=lightgrey textalign=c];

	title "&title";  
  column  ((molecule ("Collaborative Wide Results of &currentquarter " median minimum maximum)) 
                   ("Facility &fac" ("%scan(&yr,1,/)" sumq6 sumq5 ) ("%scan(&yr,2,/)"  sumq4 sumq3  sumq2 sumq1 ) ) ); 		

  DEFINE molecule/DISPLAY  FORMAT=$molecul. STYLE(COLUMN) = [JUST=left width=2.0in] "Antibiotic";
  DEFINE median/DISPLAY FORMAT=percent7.1  "Median";
  DEFINE minimum/DISPLAY FORMAT=percent7.1  "Minimum";
  DEFINE maximum  /DISPLAY FORMAT=percent7.1 "Maximum" ;
  DEFINE sumq6  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,1,/),7,1)" ;
  DEFINE sumq5  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,2,/),7,1)" ;
  DEFINE sumq4  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,3,/),7,1)" ;
  DEFINE sumq3  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,4,/),7,1)" ;
  DEFINE sumq2 /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,5,/),7,1)";
  DEFINE sumq1/DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,6,/),7,1)";
  RUN;
                                                     %end; 

%else %if &quarter=3 %then %do;

proc report data=all_&type   split="#" nowindows spanrows
  style(report)=[fontfamily="Calibri" borderwidth=2 bordercolor=black textalign=c]
  style(header)=[color=black  fontfamily="Calibri" fontsize=2 fontweight=bold  backgroundcolor=lightgrey foreground=Black borderwidth=3  textalign=c]
  style(column)=[color=black  fontfamily="Calibri" fontsize=2 fontweight=medium borderwidth=3 textalign=c]  
  style(lines)=[color=black   fontfamily="Arial" fontsize=1 fontweight=bold backgroundcolor=lightgrey textalign=c  ]
  style(summary)=[color=black fontfamily="Arial" fontsize=1 fontweight=bold backgroundcolor=lightgrey textalign=c];

	title "&title";  
  column  ((molecule ("Collaborative Wide Results of &currentquarter " median minimum maximum)) 
                   ("Facility &fac" ("%scan(&yr,1,/)" sumq6 sumq5 sumq4  ) ("%scan(&yr,2,/)"  sumq3  sumq2 sumq1 ) ) ); 		

  DEFINE molecule/DISPLAY  FORMAT=$molecul. STYLE(COLUMN) = [JUST=left width=2.0in] "Antibiotic";
  DEFINE median/DISPLAY FORMAT=percent7.1  "Median";
  DEFINE minimum/DISPLAY FORMAT=percent7.1  "Minimum";
  DEFINE maximum  /DISPLAY FORMAT=percent7.1 "Maximum" ;
  DEFINE sumq6  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,1,/),7,1)" ;
  DEFINE sumq5  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,2,/),7,1)" ;
  DEFINE sumq4  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,3,/),7,1)" ;
  DEFINE sumq3  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,4,/),7,1)" ;
  DEFINE sumq2 /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,5,/),7,1)";
  DEFINE sumq1/DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,6,/),7,1)";
  RUN;
                                                     %end; 

%else %if &quarter=4 %then %do;

proc report data=all_&type   split="#" nowindows spanrows
  style(report)=[fontfamily="Calibri" borderwidth=2 bordercolor=black textalign=c]
  style(header)=[color=black  fontfamily="Calibri" fontsize=2 fontweight=bold  backgroundcolor=lightgrey foreground=Black borderwidth=3  textalign=c]
  style(column)=[color=black  fontfamily="Calibri" fontsize=2 fontweight=medium borderwidth=3 textalign=c]  
  style(lines)=[color=black   fontfamily="Arial" fontsize=1 fontweight=bold backgroundcolor=lightgrey textalign=c  ]
  style(summary)=[color=black fontfamily="Arial" fontsize=1 fontweight=bold backgroundcolor=lightgrey textalign=c];

	title "&title";  
  column  ((molecule ("Collaborative Wide Results of &currentquarter " median minimum maximum)) 
                   ("Facility &fac" ("%scan(&yr,1,/)" sumq6 sumq5 sumq4 sumq3) ("%scan(&yr,2,/)"    sumq2 sumq1 ) ) ); 		

  DEFINE molecule/DISPLAY  FORMAT=$molecul. STYLE(COLUMN) = [JUST=left width=2.0in] "Antibiotic";
  DEFINE median/DISPLAY FORMAT=percent7.1  "Median";
  DEFINE minimum/DISPLAY FORMAT=percent7.1  "Minimum";
  DEFINE maximum  /DISPLAY FORMAT=percent7.1 "Maximum" ;
  DEFINE sumq6  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,1,/),7,1)" ;
  DEFINE sumq5  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,2,/),7,1)" ;
  DEFINE sumq4  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,3,/),7,1)" ;
  DEFINE sumq3  /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,4,/),7,1)" ;
  DEFINE sumq2 /DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,5,/),7,1)";
  DEFINE sumq1/DISPLAY FORMAT=2. "Quarter %substr(%scan(&qt,6,/),7,1)";
  RUN;
                                                     %end; 

 %mend;

%macro table (type, title) ;

Data q6 q5 q4 q3 q2 q1;
set &type.final;
where name="&fac";
drop name quarter _NAME_;
if quarter="%scan(&qt,1,/)" then output q6;
else if quarter="%scan(&qt,2,/)" then output q5;
else if quarter="%scan(&qt,3,/)" then output q4;
else if quarter="%scan(&qt,4,/)" then output q3;
else if quarter="%scan(&qt,5,/)" then output q2;
else if quarter="%scan(&qt,6,/)" then output q1;
run;

proc sql noprint;
    select nobs into: nobsq1
	from dictionary.tables
	where libname="WORK" and memname="Q1";
	select nobs into: nobsq2
	from dictionary.tables
	where libname="WORK" and memname="Q2";
	select nobs into: nobsq3
	from dictionary.tables
	where libname="WORK" and memname="Q3";
	select nobs into: nobsq4
	from dictionary.tables
	where libname="WORK" and memname="Q4";
	select nobs into: nobsq5
	from dictionary.tables
	where libname="WORK" and memname="Q5";
	quit;


data all_&type;
set combined_&type;
set q6 (rename=(sum=sumq6));
%if %eval(&nobsq5 eq 0)   %then %do;
                                                sumq5=.;
												%end;
                                                %else  %do;
set q5(rename=(sum=sumq5));
                                                 %end;
%if %eval(&nobsq4 eq 0)   %then %do;
                                                sumq4=.;
												%end;
                                                %else  %do;
set q4(rename=(sum=sumq4));
                                                 %end;
%if %eval(&nobsq3 eq 0)   %then %do;
                                                sumq3=.;
												%end;
                                                %else  %do;
set q3(rename=(sum=sumq3));
                                               %end;
%if %eval(&nobsq2 eq 0)   %then %do;
                                                sumq2=.;
												%end;
                                                %else  %do;
set q2 (rename=(sum=sumq2));
                                                 %end;
%if %eval(&nobsq1 eq 0)   %then %do;
                                                sumq1=.;
												%end;
                                                %else  %do;
set q1 (rename=(sum=sumq1));
                                                   %end;
run;

%pr_table;

  %mend;


options nodate papersize=standard orientation=portrait 
		topmargin=.1in bottommargin=0in leftmargin=.2in rightmargin=.1in;
title;
%macro pdf (fac,facility, percentage);
ods pdf file="&path.\Packets\&facility..pdf" notoc startpage=never dpi=300;
title;

                   *Defining the Cover Page;

ods layout start width=7in height=10in ;  *Page #1 starts here;

ods region x=0.3in y=0.1in  ;

ods pdf text='~S={preimage="H:\NHSN\Antimicrobial Stewardship\TDH Logo.png" just=c}';
ods pdf text=" ";
ods pdf text=" ";
ods pdf text="~S={font_weight=bold textalign=c font_size=18pt  font_face='Arial Black' color=black textdecoration=underline}Antimicrobial Use Survey Report for &currentquarter";
ods pdf text=" ";
ods region x=0.5in y=5in  ;
ods pdf text="~S={font_weight=bold textalign=c font_size=16pt  font_face='Arial Black' color=black} &facility. ";

ods layout end;

              *starting the new page;
ods startpage=now;*Page 2;         

ods region width=6in  height=0.3in x=0.3in  y=0.3in;

ods pdf text="~S={font_weight=bold textalign=c font_size=16pt  font_face='Arial Black' color=black} Average Census by Facility for &currentquarter. "; 

ods region width=6in height=6in x=0.5  y=1.8in;

data out;
 set output;
 if name="&fac" then highlight='Y';
 else highlight='N';
 run;
proc sgplot data=out;
styleattrs datacolors=(blue  steel) datacontrastcolors=(none);
 title "Average Census by Facility for &currentquarter";
 vbar name/  response=av_census datalabel  group=highlight datalabelattrs=(weight=Bold size=8 style=italic) ;
 yaxis grid ;
 keylegend 'none';
 run;
 title;

 
ods layout end;
 ods startpage=now;/* Page #3 starts here */

ods region width=6.5in  height=2in x=0.3in y=0.3in;

proc report data=abx2  style(header)={font_weight=bold  background=gray};
title "~S={font_weight=bold font_size=12pt color=black textdecoration=underline}Antibiotics Commonly Used For:";
run;
footnote;

ods region width=6.5in  height=6in x=0.5in y=4.5in ;

data final;
set transposed2;
where name="&fac";
proc sort data=final;
by group;
data final2;
set final;
by group;
if first.group then Type='Admission';
else if last.group then Type='Initiated';

proc sgplot data=final2; 
title "Proportion of Antimicrobial Prescribed &currentquarter";
styleattrs datacolors=(bigb salmon) ;
format &percentage percent10.1;
vbar group/response=&percentage group=type groupdisplay=stack seglabel seglabelattrs=(weight=bold size=8) nostatlabel ;
yaxis grid  label='Percent';
xaxis discreteorder=data;
run;
quit;

ods layout end;

ods startpage=now; /* Page #4 starts here */
ods region width=6.5in height=10in x=0.3in y=0.6in;

%table (adm, Antibiotics Present on Admission);

ods layout end;

ods startpage=now;/* Page #5 starts here */
ods region width=6.5in height=10in x=0.3in y=0.3in;

%table (in, Antibiotics Initiated in Facility);

ods layout end;

ods startpage=now; /* Page #6 starts here */
ods region width=6.5in height=10in x=0.3in y=0.6in;

%table (total, Total Antibiotics Used);

ods layout end;

ods startpage=now;/* Page #7 starts here */
ods region width=6in height=5in x=0.5in y=0.6in;

proc sgplot data=joined;
styleattrs backcolor=liggr;
where name="&fac";
title "Average Antimicrobials Prescribed versus Collaborative-wide";
vbar quarter/response=rx_used  nostatlabel fillattrs=(color=bigb) datalabel legendlabel='Facility' barwidth=0.5;
vline quarter / response=collab_mean markers markerattrs=(symbol=diamondfilled color=black size=3mm) lineattrs=(color=red thickness=1.5mm) legendlabel='Collaborative';
yaxis grid label='Percent';
xaxis label='Quarters';
run;

ods region width=6in  height=5in x=0.5 y=5.3in;

proc sgplot data=coalesced; 
title "Percent of Residents on Antimicrobials &currentquarter";
styleattrs datacolors=(bigb salmon) datacontrastcolors=(CHARCOAL) ;
vbar name/response=percentage group=type groupdisplay=stack seglabel seglabelattrs= (size=3) nostatlabel;
yaxis grid  label='Percent';
xaxis discreteorder=data;
run;
ods region width=6in  height=0.25in x=0.7 y=10in;
ods pdf text="~S={font_weight=bold font_size=8pt textalign=c font_face='Arial Black' color=black}Your Facility Code is : &fac. ";
ods layout end;
ods pdf close;
title;
%mend;



%macro Output;

proc sql noprint;
select distinct name, hospname, count (distinct name) into : name_mac separated by ' / ' ,
                                                                                                       :hospname_mac separated by ' / ' , 
                                                                                                       :n
from redcap_current_quarter
order by 1;
%put &name_mac &hospname_mac &n;
quit;

%do i=1 %to &n;

%pdf (%scan (&name_mac,&i,/), %scan(&hospname_mac,&i, /),%scan (&name_mac,&i,/) );

%end;

%mend;

   *The below macro call will generate the output;
%output
Clear Log Window ;
 DM "log; clear; ";


/*Code for current quarter list download*/

 proc sql; 
create table LTCF_current as 
select distinct  name 'Facility Code',hospname 'Facility Name',quarter 'Quarter', Propcase (datacollector) as Recepient, contactphone, contactemail
from (select a.*, b.datacollector, b.contactphone, b.contactemail
         from Redcap_all_quarter a, redcap b
        where a.facname=b.facname and a.surveydate=b.surveydate)
where quarter = "&year-Q&quarter"
order by 1;
quit;

proc export data=LTCF_current outfile="&path.\Packets\LTCFs PP Survey Participating Facs &year-Q&quarter..xlsx"
   dbms=excel replace; run;

/*Send Auto email */

%let attach=&path\Packets;

filename outbox email emailid="Microsoft Outlook";

     *email;
data _null_;
       file outbox 
             
	         to=('Cullen.Adre@tn.gov')
/*	         cc=('dipen.patel@tn.gov')*/
             subject="LTCF PP &currentquarter";
                        * Body of email ;
                              put "Cullen,";
                              put ' ';
							  put "The LTCF PP survey report &currentquarter available in following path.";
                              put "&attach";
							  put ' ';	
							  put "Let me know if you have any questions.";
							  put 'Best,';
                              put 'Dipen Patel';
							  put " ";
                              put 'Note: This email was automatically sent from SAS Software 9.4';
                  
                              put '!EM_SEND!';    *Sends email;                  
                         
                              put '!EM_NEWMSG!';    * Clear the message attributes;               
                         
                              put '!EM_ABORT!'; * Aborts the message before the RUN statement causes it to be sent again;
run; 
/*  *Code  To output reporting progress;

proc sql; 
create table progress as 
select distinct  name 'Facility Code',hospname 'Facility Name',quarter 'Quarter', Propcase (datacollector) as Recepient, contactphone, contactemail
from (select a.*, b.datacollector, b.contactphone, b.contactemail
         from Redcap_all_quarter a, redcap b
        where a.facname=b.facname and a.surveydate=b.surveydate)
order by 1;
quit;

proc sql;
create table progress2 as
select quarter, count (distinct name) as number_report_current_quarter 'Number of Reporting LTCFs', (select count(distinct name) from (select a.*, b.datacollector, b.contactphone, b.contactemail
                                                                                                                             from Redcap_all_quarter a, redcap b
        where a.facname=b.facname and a.surveydate=b.surveydate)  a where a.quarter<=b.quarter) as  cumulative_number_reporter 'Number of Ever Reporting LTCFs'
from (select a.*, b.datacollector, b.contactphone, b.contactemail
         from Redcap_all_quarter a, redcap b
        where a.facname=b.facname and a.surveydate=b.surveydate)  b
group by 1
order by 1;
quit; 

proc export data=progress outfile="H:\NHSN\Antimicrobial Stewardship\Antibiotic Use Survey Data\LTCF AU Survey\LTCFs PP Survey Participating Facs Names and Contacts &sysdate..xlsx"
   dbms=excel replace; run;

proc export data=progress2 outfile="H:\NHSN\Antimicrobial Stewardship\Antibiotic Use Survey Data\LTCF AU Survey\LTCFs PP Survey Reporting Tracker &sysdate..xlsx"
   dbms=excel replace; run;  */

