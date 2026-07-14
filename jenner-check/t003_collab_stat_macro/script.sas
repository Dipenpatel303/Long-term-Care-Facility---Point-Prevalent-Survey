/* The %collab_stat macro from "Analysis Q3 2025.sas", reproduced verbatim,
   and invoked for the Admission (adm) antibiotic type. The macro computes
   collaborative-wide median/min/max per molecule with PROC MEANS, transposes
   the wide summary into one row per molecule, splits the transposed stream
   into median/min/max sub-tables by _n_, recombines them, and produces the
   per-facility per-quarter admission sums. Two PROC PRINTs display the two
   datasets the macro builds so the run has visible output. */
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

*Calling Macro for Collaborative wide statistics for Abx at Admission;
%collab_stat (Admission, adm,1)

proc print data=combined_adm; title "combined_adm (median/min/max per molecule)"; run;
proc print data=admfinal (obs=15); title "admfinal (per facility per quarter sums)"; run;
