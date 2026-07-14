/* cap input rows for the captured run */
options obs=100 nodate nonumber mprint;

/* Quarter macro-var normally set by %time */
%let quarter=3;

/* redcap2: per-facility, per-molecule average admission ratios. In the
   source this is built by a large PROC SQL over the cleaned survey data;
   here a small synthetic version supplies the column shape %collab_stat's
   PROC MEANS reads (amx_adm, amxcl_adm, ... methsu_adm). */
data redcap2;
  input name $ amx_adm amxcl_adm azit_adm ceftri_adm cephal_adm cip_adm clind_adm dap_adm dox_adm ert_adm
        flu_adm lev_adm mox_adm linezo_adm met_adm nitr_adm pipta_adm vanc_adm vancop_adm methsu_adm;
  datalines;
TN_ZA 0.10 0.02 0.05 0.03 0.01 0.04 0.00 0.00 0.02 0.00 0.01 0.03 0.00 0.00 0.06 0.05 0.00 0.02 0.00 0.03
TN_ZB 0.08 0.03 0.04 0.02 0.02 0.03 0.01 0.00 0.01 0.00 0.02 0.02 0.01 0.00 0.05 0.04 0.01 0.03 0.00 0.02
TN_ZD 0.12 0.01 0.06 0.04 0.00 0.05 0.00 0.01 0.03 0.00 0.00 0.04 0.00 0.01 0.07 0.06 0.00 0.01 0.01 0.04
;
run;

/* redcap_all_quarter: facility rows with raw admission counts + quarter,
   the input to the macro's second (CLASS name quarter) PROC MEANS. */
data redcap_all_quarter;
  length name $20 quarter $8;
  input name $ quarter $ census amoxicillin_adm amoxiclav_adm azithro_adm cef_adm cephalexin_adm cipro_adm
        clinda_adm dapto_adm doxy_adm erta_adm fluc_adm levo_adm moxi_adm linezolid_adm metro_adm nitro_adm
        piptazo_adm vanco_adm vancopo_adm methsulf_adm;
  datalines;
TN_ZA 2025-Q3 88 3 1 1 1 0 1 0 0 1 0 0 1 0 0 2 1 0 1 0 1
TN_ZB 2025-Q3 94 2 1 1 0 1 1 0 0 0 0 1 0 0 0 1 1 0 1 0 0
TN_ZD 2025-Q3 76 4 0 2 1 0 1 0 0 1 0 0 1 0 0 2 2 0 0 1 1
;
run;
