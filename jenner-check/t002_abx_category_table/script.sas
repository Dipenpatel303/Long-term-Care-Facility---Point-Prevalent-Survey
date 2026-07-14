/* Antibiotic-category reference table from "Analysis Q3 2025.sas" (the
   `abx2` DATA step and the PROC REPORT that renders it on the report
   cover pages). Reproduced verbatim from the source: a CARDS block read
   with dlm=',' dsd missover so the ragged rows and empty leading cells
   parse into the CDI / Respiratory / SSTI / UTI columns, plus the styled
   PROC REPORT that displays it. */
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

proc report data=abx2 style(header)={font_weight=bold background=gray};
title "Antibiotics Commonly Used For:";
run;
