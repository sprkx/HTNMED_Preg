option compress=yes;
/*options symbolgen mlogic mprint;*/
/*options nosymbolgen nomlogic nomprint;*/

%let path_work=E:\DataAnalysis\HTNMED_Preg;
/*%let path_work=\\Client\E$\DataAnalysis\DiscSod;*/

libname cprd "E:\Data\CPRD_GOLD_202307";
libname a "&path_work.\Input"; *Input;
libname b "E:\Data\Resources"; *Dictionary, Sources;
libname x "&path_work.\Temp"; *Temporary Data;
libname y "&path_work.\Save"; *Data Set for Further Analysis;
libname z "&path_work.\Output"; *Save Results for Export;

/********************************************/
/* Run the macro code (SAS_MACRO.sas) first */
/********************************************/

/***************************/
/* Disease, drug code list */
/***************************/

/* Dictionary */
*GOLD;
%IMPORT_TXT (
path=E:\Data\Resources\Dictionary\CPRD_CodeBrowser_202212_GOLD
, filename=product
, lib=work
, data_name=gold
, var_name_list=prodcode	dmdcode	gemscriptcode	therapyevents	productname	ingredient	strength	formulation	routeofadministration	bnfchapter	bnftext	
, var_format_list=$8. $32. $32. best32. $148. $148. $22. $23. $49. $17. $50. $13. $32.
, delimiter='09'x
);
data b.dict_rx_gold; set gold; run;

data dict_1;
set gold;
prod=lowcase(productname);
ingr=lowcase(ingredient);
keep prodcode productname ingredient prod ingr;
run;
data dict_2_1 (keep=prodcode prod) dict_2_2 (keep=prodcode ingr);
set dict_1;
run;
data dict_3;
set dict_2_1 (rename=(prod=term)) dict_2_2(rename=(ingr=term));
run;
data b.dict_rx_comb_gold; set dict_3; run;

data split; set b.dict_rx_comb_gold; run;
%split (indata=split, outdata=split, symbol=" ", col_name=term, keep_var_list=prodcode);
%split (indata=split, outdata=split, symbol="(", col_name=term, keep_var_list=prodcode);
%split (indata=split, outdata=split, symbol=")", col_name=term, keep_var_list=prodcode);
%split (indata=split, outdata=split, symbol="/", col_name=term, keep_var_list=prodcode);
%split (indata=split, outdata=split, symbol=",", col_name=term, keep_var_list=prodcode);
%split (indata=split, outdata=split, symbol=".", col_name=term, keep_var_list=prodcode);
data b.dict_rx_split_gold; set split; run;

%IMPORT_TXT (
path=E:\Data\Resources\Dictionary\CPRD_CodeBrowser_202212_GOLD
, filename=medical_name
, lib=work
, data_name=gold_dx
, var_name_list=medcode	readcode	ClinicalEvents	ReferralEvents	TestEvents	ImmunisationEvents	ReadTerm	DatabaseBuild
, var_format_list=$20. $7. best32. best32. best32. best32. $128. $32.
, delimiter='09'x
);
data b.dict_dx_gold; set gold_dx; run;

%IMPORT_TXT (
path=E:\Data\Resources\GOLD_2307_Lookups
, filename=common_dosages
, lib=work
, data_name=dosage
, var_name_list=dosageid	dosage_text	daily_dose	dose_number	dose_unit	dose_frequency	dose_interval	choice_of_dose	dose_max_average	change_dose	dose_duration	
, var_format_list=$64. $25. 8. 8. $1. 8. 8. 8. 8. 8. 8.
, delimiter='09'x
);
data b.lookup_rxdosage_gold; set dosage; run;

*Aurum;
%IMPORT_TXT (
path=E:\Data\Resources\Dictionary\CPRD_CodeBrowser_202211_Aurum
, filename=CPRDAurumProduct
, lib=work
, data_name=aurum
, var_name_list=ProdCodeId	dmdid	TermfromEMIS	ProductName	Formulation	RouteOfAdministration	DrugSubstanceName	SubstanceStrength	BNFChapter	DrugIssues
, var_format_list=$18. $19. $67. $47. $22. $11. $126. $159. best32. best32.
, delimiter='09'x
);
data b.dict_rx_aurum; set aurum; run;

data dict_0;
set aurum;
format PRODCODEID 17.;
bnfchapter2=left(bnfchapter);
if length(trim(bnfchapter2))^=8 then do;
if length(trim(bnfchapter2))=7 then bnfchapter3=cat("0",trim(bnfchapter2));
else if length(trim(bnfchapter2))=6 then bnfchapter3=cat("00",trim(bnfchapter2));
else if length(trim(bnfchapter2))=5 then bnfchapter3=cat("000",trim(bnfchapter2));
else if length(trim(bnfchapter2))=4 then bnfchapter3=cat("0000",trim(bnfchapter2)); end;
else bnfchapter3=bnfchapter2;
drop bnfchapter bnfchapter2;
rename bnfchapter3=bnfchapter;
run;
data dict_1;
set dict_0;
term1=lowcase(termfromemis);
term2=lowcase(productname);
term3=lowcase(drugsubstancename);
run;
data dict_2_1 (keep=prodcodeid term1) 
	dict_2_2 (keep=prodcodeid term2)
	dict_2_3 (keep=prodcodeid term3);
set dict_1;
if term1^='' then output dict_2_1;
if term2^='' then output dict_2_2;
if term3^='' then output dict_2_3;
run;
data dict_3;
length term $148;
set dict_2_1(rename=(term1=term)) 
	dict_2_2(rename=(term2=term))
	dict_2_3(rename=(term3=term));
run;
data b.dict_rx_comb_aurum; set dict_3; run;

data split; set b.dict_rx_comb_aurum; run;
%split (indata=split, outdata=split, symbol=" ", col_name=term, keep_var_list=prodcodeid);
%split (indata=split, outdata=split, symbol="(", col_name=term, keep_var_list=prodcodeid);
%split (indata=split, outdata=split, symbol=")", col_name=term, keep_var_list=prodcodeid);
%split (indata=split, outdata=split, symbol="/", col_name=term, keep_var_list=prodcodeid);
%split (indata=split, outdata=split, symbol=",", col_name=term, keep_var_list=prodcodeid);
%split (indata=split, outdata=split, symbol=".", col_name=term, keep_var_list=prodcodeid);
data b.dict_rx_split_aurum; set split; run;

%IMPORT_TXT (
path=E:\Data\Resources\Dictionary\CPRD_CodeBrowser_202211_Aurum
, filename=CPRDAurumMedical
, lib=work
, data_name=aurum_dx
, var_name_list=MedCodeId	Observations	OriginalReadCode	CleansedReadCode	Term	SnomedCTConceptId	SnomedCTDescriptionId	Release	EmisCodeCategoryId
, var_format_list=$18. $32. $32. $32. $128. $32. $32. $32. $32.
, delimiter='09'x
);
data b.dict_dx_aurum; set aurum_dx; run;

/* Disease codes: Read, SNOMED, ICD10 */
*Import: hypertension (gold);
%IMPORT_TXT (
path=&path_work.\Input 
, filename=GOLD_HTN
, lib=work
, data_name=tmp_1
, var_name_list=code code_attributes 
, var_format_list=$5. $256.
, delimiter='09'x
);
*Import: hypertension (aurum);
%IMPORT_TXT (
path=&path_work.\Input
, filename=Aurum_HTN
, lib=work
, data_name=tmp_2
, var_name_list=medcodeid term hypertens
, var_format_list=$20. $256. $1.
, delimiter=','
);

*Gold;
proc sql;
create table tmp_3 as 
select distinct "HTN" as type_id, "Hypertension" as info, a.code length=32, b.readterm as term, "gold" as code_sys length=5
from tmp_1 as a
left join b.dict_dx_gold as b on a.code=b.medcode;
quit;
* Aurum;
proc sql;
create table tmp_4 as 
select distinct "HTN" as type_id, "Hypertension" as info, a.medcodeid as code length=32, b.term as term, "aurum" as code_sys length=5
	from tmp_2 as a
	left join b.dict_dx_aurum as b on a.medcodeid=b.medcodeid;
quit;
data x.list_dx_htn; set tmp_3 tmp_4; run;

/* Drug (product) codes*/
*Import: others;
%IMPORT_XLSX (
path=&path_work.\Input
, filename=Table shells
, lib=work
, data_name=tmp
, sheet=Code
);
data tmp_1;
set tmp;
drop f ;
if substr(type_id,1,4)="HMED";
ingr=lowcase(compress(detail));
rename type_name=info;
run;

*Gold;
proc sql;
create table tmp_2 as
select distinct a.type_id, a.exp_id, a.info, a.ingr, b.prodcode as code length=32, b.term as term, "gold" as code_sys length=5
from tmp_1 as a
left join b.dict_rx_split_gold as b on a.ingr=b.term;
quit;
* Aurum;
proc sql;
create table tmp_3 as
select distinct a.type_id, a.exp_id, a.info, a.ingr, b.prodcodeid as code length=32, b.term as term, "aurum" as code_sys length=5
from tmp_1 as a
left join b.dict_rx_split_aurum as b on a.ingr=b.term
;quit;

** Put together (Gold/Aurum);
data x.list_rx; set tmp_2 tmp_3; run;


/********************************/
/* Import: GOLD, Aurum, linkage */
/********************************/

/*Gold*/
*PregRegister;
%IMPORT_TXT (path=E:\Data\Pregnancy\Gold_MBlink
, filename=21_000464_PregReg
, lib=a
, data_name=gold_preg
, var_name_list=patid pregid babypatid pregnumber pregstart startsource pregend outcome
, var_format_list=$20. $20. $20. $2. ddmmyy10. $1. ddmmyy10. $2. 
, delimiter='09'x);

%let path_in=E:\Data\Pregnancy\Gold_mother;
%let file_num_form=Z3.; *Format of Number in File (e.g., Zw. or w.);
%let file_name_form=Test02_Extract_&data_name_infile._&file_num_infile.; *Format of Filename, using &file_num_infile. and &data_name_infile.;

*Patient;
%IMPORT_N (file_n_stt=1, file_n_end=1, lib_name=work, data_name=Patient
, folder_name=Patient, data_name_infile=Patient
, var_name_list=patid vmid gender yob mob marital famnum chsreg chsdate prescr capsup frd crd regstat reggap internal tod toreason deathdate accept
, var_format_list=$20. $20. best1. best4. best2. best3. best20. best1. ddmmyy10. best3. best3. ddmmyy10. ddmmyy10. best2. best5. best2. ddmmyy10. best3. ddmmyy10. $1.
);
data a.gold_patient; set patient_1; run; 
%DeleteDataset(lib=work, data_name=patient, n_stt=1, n_end=1);
*Practice;
%IMPORT_N (file_n_stt=1, file_n_end=1, lib_name=work, data_name=Practice
, folder_name=Practice, data_name_infile=Practice
, var_name_list=pracid region lcd uts
, var_format_list=$5. best3. ddmmyy10. ddmmyy10.
);
proc sql;
create table a.gold_practice as
select *
from practice_1
where pracid not in (select gold_pracid from b.prac_migrt)
;quit;
%DeleteDataset(lib=work, data_name=practice, n_stt=1, n_end=1);
*Clinical;
data a.gold_clinical; set x.mom_dx_g_1 - x.mom_dx_g_16; run;
data 
*Additional;
%IMPORT_N (file_n_stt=1, file_n_end=3, lib_name=work, data_name=Additional
, folder_name=Additional, data_name_infile=Additional
, var_name_list=patid enttype adid data1 data2 data3 data4 data5 data6 data7 data8 data9 data10 data11 data12
, var_format_list=$20. best5. $20. $20. $20. $20. $20. $20. $20. $20. $20. $20. $20. $20. $20. 
);
data a.gold_additional; set additional_1 - additional_3; run;
%DeleteDataset(lib=work, data_name=additional, n_stt=1, n_end=3);
*Therapy;
data a.gold_therapy; set x.mom_rx_g_1 - x.mom_rx_g_16; run;

proc sql;
create table tmp as
select distinct a.patid, a.eventdate, a.enttype, b.* 
from a.clinical_gold as a
left join a.additional_gold as b on a.patid=b.patid and a.adid=b.adid
where a.enttype in ("1")
;quit;
data tmp_1; 
set tmp; 
drop enttype adid data3 -- data12; 
rename data1=DBP data2=SBP;
run;
data x.gold_bp; set tmp_1; run;

/*Aurum*/
*PregRegister;
%IMPORT_TXT (
path=E:\Data\Pregnancy\Aurum_MBlink\23_002937_Type1_data, 
filename=aurum_pregnancy_register_2022_05
, lib=a, data_name=aurum_preg
, var_name_list=patid	pregstart	pregend
, var_format_list=$20. ddmmyy10. ddmmyy10.
, delimiter='09'x
);

%let path_in=E:\Data\Pregnancy\Aurum_mother;
%let file_num_form=Z3.; *Format of Number in File (e.g., Zw. or w.);
%let file_name_form=aurum_mother_Extract_&data_name_infile._&file_num_infile.; *Format of Filename, using &file_num_infile. and &data_name_infile.;
*Patient;
%IMPORT_N (file_n_stt=1, file_n_end=1, lib_name=work, data_name=Patient
, folder_name=Patient, data_name_infile=Patient
, var_name_list=patid	pracid	usualgpstaffid	gender	yob	mob	emis_ddate	regstartdate	patienttypeid	regenddate	acceptable	cprd_ddate
, var_format_list=$20. $5. $10. 3. 4. 2. ddmmyy10. ddmmyy10. $5. ddmmyy10. 1. ddmmyy10.
);
data a.aurum_patient; set patient_1; run; 
%DeleteDataset(lib=work, data_name=patient, n_stt=1, n_end=1);
*Practice;
%IMPORT_N (file_n_stt=1, file_n_end=1, lib_name=work, data_name=Practice
, folder_name=Practice, data_name_infile=Practice
, var_name_list=pracid	lcd	uts	region
, var_format_list=$5. ddmmyy10. ddmmyy10. 5.
);
data a.aurum_practice; set practice_1; run;
%DeleteDataset(lib=work, data_name=practice, n_stt=1, n_end=1);
*Observation;
%IMPORT_N (file_n_stt=1, file_n_end=89, lib_name=work, data_name=observation
, folder_name=aurum_mother_Extract_Observation, data_name_infile=Observation
, var_name_list=patid	consid	pracid	obsid	obsdate	enterdate	staffid	parentobsid	medcodeid	value	numunitid	obstypeid	numrangelow	numrangehigh	probobsid
, var_format_list=$20. $20. $5. $20. ddmmyy10. ddmmyy10. $20. $20. $20. 19.3 $10. $5. 19.3 19.3 $20.
);
data a.aurum_observation; set observation_1 - observation_89; run;
%DeleteDataset(lib=work, data_name=observation, n_stt=1, n_end=89);
*DrugIssue;
%IMPORT_N (file_n_stt=1, file_n_end=29, lib_name=work, data_name=drug
, folder_name=aurum_mother_Extract_DrugIssue, data_name_infile=DrugIssue
, var_name_list=patid	issueid	pracid	probobsid	drugrecid	issuedate	enterdate	staffid	prodcodeid	dosageid	quantity	quantunitid	duration	estnhscost
, var_format_list=$20. $20. $5. $20. $20. ddmmyy10. ddmmyy10. $10. $20. $64. 9.3 $2. 10. 10.4
);
data a.aurum_drug; set drug_1 - drug_29; run;
%DeleteDataset(lib=work, data_name=drug, n_stt=1, n_end=29);

data tmp_2;
set b.dict_dx_aurum;
term1=lowcase(term);
if find(term1, "blood pressure")>0 or find(term1, "bp")>0;
if find(term1, "systolic")>0 or find(term1,"diastolic")>0;
/*if find(term1, "systolic")>0 and find(term1,"diastolic")>0 then delete;*/
if find(term1, "systolic")>0 then type_id="SBP";
else if find(term1, "diastolic")>0 then type_id="DBP";
run;
data tmp_3;
set tmp_2;
drop observations -- emiscodecategoryid;
rename term1=term;
code_sys="aurum";
run;
data x.list_bp; set tmp_3; run;
proc sql;
create table tmp_4 as
select distinct a.patid, a.pracid, a.obsid, a.obsdate, a.medcodeid, a.value, b.term, b.type_id
from a.aurum_observation as a
inner join x.list_bp as b on a.medcodeid=b.medcodeid
;quit;
data x.aurum_bp; set tmp_4; run;

/*********************/
/* Study population  */
/*********************/

/*gold*/
proc sql;
create table tmp_0 as
select distinct a.*, b.gender, b.yob, b.accept, b.deathdate, b.tod, b.frd, c.lcd
from a.gold_preg as a
left join a.gold_patient as b on a.patid=b.patid
left join a.gold_practice as c on (substr(a.patid, length(a.patid)-4, 5))=c.pracid
group by a.patid, a.pregstart
having a.pregend=max(pregend)
;quit;
data tmp_1;
set tmp_0 (drop=babypatid);
if gender=. or yob=. then delete;
if outcome^="13";
if deathdate=. or pregstart+365.25 <= deathdate;
if tod=. or pregstart+365.25 <= tod;
if lcd=. or pregstart+365.25 <= lcd;
if frd <= pregstart+365.25;
if accept="1";
run;*2062345;
data x.gold_incl_0; set tmp_1; run;
proc sql;
create table tmp_2 as
select distinct a.*, b.eventdate, c.info, c.term
from x.gold_incl_0 as a
inner join a.gold_clinical as b on a.patid=b.patid
	and a.pregstart-90 <= b.eventdate and b.eventdate <= a.pregstart
inner join x.list_dx_htn as c on b.medcode=c.code and c.code_sys="gold"
;quit;
proc sql;
create table tmp_3 as
select distinct a.*, b.info
from x.gold_incl_0 as a
left join tmp_2 as b on a.patid=b.patid and a.pregid=b.pregid
;quit;
/*proc freq data=tmp_3; table info; run;*/
data tmp_4;
set tmp_3;
if info^="" then preHTN=1; else preHTN=0;
if mdy(1,1,2001)<=pregstart<=mdy(12,31,2021);
run;*1303919;
data x.gold_cht; set tmp_4; run;

/*aurum*/
proc sql;
create table tmp_5 as
select distinct a.*, b.gender, b.yob, b.acceptable as accept, b.regstartdate, b.regenddate, c.lcd
from a.aurum_preg as a
left join a.aurum_patient as b on a.patid=b.patid
left join a.aurum_practice as c on (substr(a.patid, length(a.patid)-4, 5))=c.pracid
group by a.patid, a.pregstart
having a.pregend=max(pregend)
;quit;
data tmp_6;
set tmp_5;
if gender=. or yob=. then delete;
if regenddate=. or pregstart+365.25 <= regenddate;
if lcd=. or pregstart+365.25 <= lcd;
if regstartdate <= pregstart+365.25;
if accept="1";
run; *3745968;
data x.aurum_incl_0; set tmp_6; run;
proc sql;
create table tmp_7 as
select distinct a.*, b.obsdate as eventdate, c.info, c.term
from x.aurum_incl_0 as a
inner join a.aurum_observation as b on a.patid=b.patid
	and a.pregstart-90 <= b.obsdate and b.obsdate <= a.pregstart
inner join x.list_dx_htn as c on b.medcodeid=c.code and c.code_sys="aurum"
;quit;
proc sql;
create table tmp_8 as
select distinct a.*, b.info
from x.aurum_incl_0 as a
left join tmp_7 as b on a.patid=b.patid and a.pregstart=b.pregstart
;quit;
data tmp_9;
set tmp_8;
if info^="" then preHTN=1; else preHTN=0;
if mdy(1,1,2001)<=pregstart<=mdy(12,31,2021);
run; *2840091;
proc freq data=tmp_9; table prehtn; run;
data x.aurum_cht; set tmp_9; run;

**COV_BP:recent BP (within 180d);
proc sql;
create table bp_1 as
select distinct a.*, b.eventdate, b.dbp, b.sbp
from x.gold_cht as a
left join x.gold_bp as b on a.patid=b.patid 
		and a.pregstart-180 < b.eventdate and b.eventdate <= a.pregstart 
group by a.patid
having max(b.eventdate)=b.eventdate
;quit;
proc sql;
create table bp_2 as 
select distinct patid, pregid, pregnumber,pregstart,pregend,yob,prehtn, eventdate, mean(input(dbp,5.)) as DBP, mean(input(SBP,5.)) as SBP
from bp_1
group by patid, eventdate
;quit;
data bp_3; 
set bp_2;
if SBP < 120 and DBP < 80 then BP=1; *normal;
if (120 <= SBP and SBP < 130) and DBP < 80 then BP=2; *elevated;
	if (130 <= SBP and SBP < 140) or (80 <= DBP and DBP < 90) then BP=3;*high BP stage 1;
if (140 <= SBP) or (90 <= DBP) then BP=4; *high BP stage 2;
if SBP=. or DBP=. then BP=9; *missing;
age=year(pregstart)-yob;
run;
/*proc freq data=bp_3; table bp*prehtn; run;*/

proc sql;
create table bp_4 as
select distinct a.*, b.obsdate as eventdate, b.value, b.type_id
from x.aurum_cht as a
left join x.aurum_bp as b on a.patid=b.patid 
		and a.pregstart-180 < b.obsdate and b.obsdate <= a.pregstart 
group by a.patid
having max(b.obsdate)=b.obsdate
;quit;
proc sql;
create table bp_5 as 
select distinct patid, pregstart, pregend, yob, prehtn, eventdate, mean(value) as value, type_id
from bp_4
group by patid, eventdate, type_id
;quit;
proc sql;
create table bp_6 as
select distinct patid, pregstart, pregend, yob, prehtn, eventdate
	, max(case when type_id="DBP" then value else . end) as DBP
	, max(case when type_id="SBP" then value else . end) as SBP
from bp_5
group by patid, eventdate
;quit;
data bp_7; 
set bp_6;
if SBP < 120 and DBP < 80 then BP=1; *normal;
if (120 <= SBP and SBP < 130) and DBP < 80 then BP=2; *elevated;
	if (130 <= SBP and SBP < 140) or (80 <= DBP and DBP < 90) then BP=3;*high BP stage 1;
if (140 <= SBP) or (90 <= DBP) then BP=4; *high BP stage 2;
if SBP=. or DBP=. then BP=9; *missing;
age=year(pregstart)-yob;
run;
/*proc freq data=bp_7; table bp*prehtn; run;*/

data tmp_1;
set bp_7;
db="aurum";
run;
data tmp_2;
set bp_3;
db="gold";
drop pregid pregnumber;
run;
data x.cht_char1; set tmp_1 tmp_2; run;

/**************************/
/* Antihypertensive drugs */
/**************************/

proc sql;
create table x.gold_rx_htnmed as
select a.*, b.*
from a.gold_therapy as a
inner join x.list_rx as b on a.prodcode=b.code and b.code_sys="gold"
;quit;
proc sql;
create table x.aurum_rx_htnmed as
select a.*, b.*
from a.aurum_drug as a
inner join x.list_rx as b on a.prodcodeid=b.code and b.code_sys="aurum"
;quit;

proc sql;
create table tmp as
select a.*, COALESCE(b.eventdate,c.issuedate) as rx_dt format yymmdd10.
	, COALESCE(b.type_id, c.type_id) as type_id
	, COALESCE(b.exp_id, c.exp_id) as exp_id
	, COALESCE(b.info, c.info) as info
	, COALESCE(b.ingr, c.ingr) as ingr
from x.cht_char1 as a
left join x.gold_rx_htnmed as b on a.patid=b.patid
	and a.pregstart-365 <= b.eventdate and b.eventdate <= a.pregend+365
	and a.db="gold"
left join x.aurum_rx_htnmed as c on a.patid=c.patid
	and a.pregstart-365 <= c.issuedate and c.issuedate <= a.pregend+365
	and a.db="aurum"
;quit;
data x.rx_cht_htnmed; set tmp; run;

data tmp;
set x.rx_cht_htnmed;
format rx_dt yymmdd10.;
if pregstart-90 <= rx_dt and rx_dt <= pregstart-1 then pre_HTNMED=1; else pre_HTNMED=0;
if pregstart <= rx_dt and rx_dt <= pregend then preg_HTNMED=1; else preg_HTNMED=0;
if pregend+1 <= rx_dt and rx_dt <= pregend+90 then post_HTNMED=1; else post_HTNMED=0;
run;
%MACRO XXX;
data tmp_1;
set tmp;
if pregstart-90 <= rx_dt and rx_dt <= pregstart then do;
%do a=1 %to 11;
	if type_id="HMED_&a." then pre_HMED_&a.=1; else pre_HMED_&a.=0;
%end; end;
if pregstart+1 <= rx_dt and rx_dt <= pregend then do;
%do b=1 %to 11;
	if type_id="HMED_&b." then preg_HMED_&b.=1; else preg_HMED_&b.=0;
%end; 
	if exp_id="EXP_1" then preg_EXP_1=1; else preg_EXP_1=0;
	if exp_id="EXP_2" then preg_EXP_2=1; else preg_EXP_2=0;
	if exp_id="EXP_3" then preg_EXP_3=1; else preg_EXP_3=0;
	if exp_id="EXP_4" then preg_EXP_4=1; else preg_EXP_4=0;
	if exp_id="EXP_9" then preg_EXP_9=1; else preg_EXP_9=0;
end;
if pregend+1  <= rx_dt and rx_dt <= pregend+90 then do;
%do c=1 %to 11;
	if type_id="HMED_&c." then post_HMED_&c.=1; else post_HMED_&c.=0;
%end; end;
run;
%MEND; %XXX;
%MACRO XXX;
data tmp_2;
set tmp_1;
if pregstart+1 <= rx_dt and rx_dt <= pregend then do;

if pregstart+1 <= rx_dt and rx_dt <= pregstart+90 then do; TM1_HMED=1;
%do a=1 %to 11;	if type_id="HMED_&a." then TM1_HMED_&a.=1; else TM1_HMED_&a.=0; %end; 
%do b=1 %to 4; if exp_id="EXP_&b." then TM1_EXP_&b.=1; else TM1_EXP_&b.=0; %end;
if exp_id="EXP_9" then TM1_EXP_9=1; else TM1_EXP_9=0;
end;
else TM1_HMED=0;

if pregstart+91 <= rx_dt and rx_dt <= pregstart+180 then do; TM2_HMED=1;
%do a=1 %to 11;	if type_id="HMED_&a." then TM2_HMED_&a.=1; else TM2_HMED_&a.=0; %end; 
%do b=1 %to 4; if exp_id="EXP_&b." then TM2_EXP_&b.=1; else TM2_EXP_&b.=0; %end;
if exp_id="EXP_9" then TM2_EXP_9=1; else TM2_EXP_9=0;
end;
else TM2_HMED=0;


if pregstart+181 <= rx_dt and rx_dt <= pregend then do; TM3_HMED=1;
%do a=1 %to 11;	if type_id="HMED_&a." then TM3_HMED_&a.=1; else TM3_HMED_&a.=0; %end; 
%do b=1 %to 4; if exp_id="EXP_&b." then TM3_EXP_&b.=1; else TM3_EXP_&b.=0; %end;
if exp_id="EXP_9" then TM3_EXP_9=1; else TM3_EXP_9=0;
end;
else TM3_HMED=0;

end;
run;
%MEND; %XXX;

%MACRO XXX;
proc sql;
create table tmp_3 as
select distinct patid, pregstart, pregend, yob, prehtn, bp, age, db
	, max(pre_htnmed) as pre_hmed, max(preg_htnmed) as preg_hmed, max(post_htnmed) as post_hmed
	, max(tm1_hmed) as tm1_hmed, max(tm2_hmed) as tm2_hmed, max(tm3_hmed) as tm3_hmed
%do a=1 %to 11;
	, max(pre_HMED_&a.) as pre_HMED_&a., max(preg_HMED_&a.) as preg_HMED_&a., max(post_HMED_&a.) as post_HMED_&a.
	, max(TM1_HMED_&a.) as TM1_HMED_&a., max(TM2_HMED_&a.) as TM2_HMED_&a., max(TM3_HMED_&a.) as TM3_HMED_&a.
%end;
%do B=1 %to 4;
	, max(TM1_EXP_&B.) as TM1_EXP_&B., max(TM2_EXP_&B.) as TM2_EXP_&B., max(TM3_EXP_&B.) as TM3_EXP_&B.
%end;
from tmp_2
group by patid, pregstart, db
;quit;
%MEND; %XXX;
proc stdize data=tmp_3  out=tmp_4 reponly missing=0; run;
data x.cht_char2; set tmp_4; run;

proc tabulate data=x.cht_char2;
var age;
class preg_hmed prehtn bp pre_hmed tm1_hmed tm2_hmed tm3_hmed post_hmed pre_hmed_1 pre_hmed_2 pre_hmed_3 pre_hmed_4 pre_hmed_5 pre_hmed_6 pre_hmed_7 pre_hmed_8 pre_hmed_9 pre_hmed_10 pre_hmed_11;
table 
(all)*N
(age)*(mean std median q1 q3)
(bp prehtn pre_hmed tm1_hmed tm2_hmed tm3_hmed post_hmed pre_hmed_1 pre_hmed_2 pre_hmed_3 pre_hmed_4 pre_hmed_5 pre_hmed_6 pre_hmed_7 pre_hmed_8 pre_hmed_9 pre_hmed_10 pre_hmed_11)*N
, (all preg_hmed);
run;

proc tabulate data=x.cht_char2;
var preg_hmed pre_hmed tm1_hmed tm2_hmed tm3_hmed post_hmed 
	pre_hmed_1 pre_hmed_2 pre_hmed_3 pre_hmed_4 pre_hmed_5 pre_hmed_6 pre_hmed_7 pre_hmed_8 pre_hmed_9 pre_hmed_10 pre_hmed_11
	tm1_hmed_1 tm1_hmed_2 tm1_hmed_3 tm1_hmed_4 tm1_hmed_5 tm1_hmed_6 tm1_hmed_7 tm1_hmed_8 tm1_hmed_9 tm1_hmed_10 tm1_hmed_11
	tm2_hmed_1 tm2_hmed_2 tm2_hmed_3 tm2_hmed_4 tm2_hmed_5 tm2_hmed_6 tm2_hmed_7 tm2_hmed_8 tm2_hmed_9 tm2_hmed_10 tm2_hmed_11
	tm3_hmed_1 tm3_hmed_2 tm3_hmed_3 tm3_hmed_4 tm3_hmed_5 tm3_hmed_6 tm3_hmed_7 tm3_hmed_8 tm3_hmed_9 tm3_hmed_10 tm3_hmed_11
	post_hmed_1 post_hmed_2 post_hmed_3 post_hmed_4 post_hmed_5 post_hmed_6 post_hmed_7 post_hmed_8 post_hmed_9 post_hmed_10 post_hmed_11
;
table 
(all)*N
(pre_hmed tm1_hmed tm2_hmed tm3_hmed post_hmed 
	pre_hmed_1 pre_hmed_2 pre_hmed_3 pre_hmed_4 pre_hmed_5 pre_hmed_6 pre_hmed_7 pre_hmed_8 pre_hmed_9 pre_hmed_10 pre_hmed_11
	tm1_hmed_1 tm1_hmed_2 tm1_hmed_3 tm1_hmed_4 tm1_hmed_5 tm1_hmed_6 tm1_hmed_7 tm1_hmed_8 tm1_hmed_9 tm1_hmed_10 tm1_hmed_11
	tm2_hmed_1 tm2_hmed_2 tm2_hmed_3 tm2_hmed_4 tm2_hmed_5 tm2_hmed_6 tm2_hmed_7 tm2_hmed_8 tm2_hmed_9 tm2_hmed_10 tm2_hmed_11
	tm3_hmed_1 tm3_hmed_2 tm3_hmed_3 tm3_hmed_4 tm3_hmed_5 tm3_hmed_6 tm3_hmed_7 tm3_hmed_8 tm3_hmed_9 tm3_hmed_10 tm3_hmed_11
	post_hmed_1 post_hmed_2 post_hmed_3 post_hmed_4 post_hmed_5 post_hmed_6 post_hmed_7 post_hmed_8 post_hmed_9 post_hmed_10 post_hmed_11
)*(sum)
, (all);
run;

/*proc sql;*/
/*create table tmp_1 as*/
/*select distinct a.patid, a.pregstart, a.pregend, a.db, b.rx_dt, b.type_id, b.exp_id, b.ingr*/
/*from x.cht_char2 as a*/
/*left join x.rx_cht_htnmed as b on a.patid=b.patid and a.pregstart=b.pregstart and a.db=b.db*/
/*where a.pre_hmed=1*/
/*;quit;*/

proc sql;
create table tmp_2 as
select distinct a.patid, a.pregstart, a.pregend, a.db
	, b.type_id as pre_class, b.ingr as pre_ingr
from x.cht_char2 as a
left join x.rx_cht_htnmed as b on a.patid=b.patid and a.pregstart=b.pregstart and a.db=b.db
	and a.pregstart-90 <= b.rx_dt and b.rx_dt <= a.pregstart
where a.pre_hmed=1
group by a.patid, a.pregstart, a.db
having b.rx_dt=max(b.rx_dt)
;quit;
proc sql;
create table tmp_3 as
select distinct *, count(distinct pre_class) as pre_n_class
from tmp_2
group by patid, pregstart, db
order by patid, pregstart, db, pre_class
;quit;
proc sql;
create table tmp_4 as
select distinct a.*
	, b.type_id as tm1_class, b.exp_id as tm1_intrx, b.ingr as tm1_ingr
	, c.type_id as check_class, c.ingr as check_ingr
from tmp_3 as a
left join x.rx_cht_htnmed as b on a.patid=b.patid and a.pregstart=b.pregstart and a.db=b.db
	and a.pregstart+1 <= b.rx_dt and b.rx_dt <= a.pregstart+90
left join x.rx_cht_htnmed as C on a.patid=C.patid and a.pregstart=C.pregstart and a.db=C.db
	and c.rx_dt= b.rx_dt and a.pre_class=C.type_id
group by a.patid, a.pregstart, a.db
having b.rx_dt=max(b.rx_dt)
order by a.patid, a.pregstart, a.db, a.pre_class
;quit;
proc sql;
create table tmp_5 as
select distinct *, count(distinct tm1_class) as tm1_n_class, count(distinct check_class) as check_n_class
from tmp_4
group by patid, pregstart, db
;quit;
/*data test;*/
/*set tmp_5;*/
/*if tm1_n_class^=check_n_class;*/
/*run;*/
data tmp_6;
set tmp_5;
if tm1_intrx="EXP_1" then labe=1; else labe=0;
if tm1_intrx="EXP_2" then nife=1; else nife=0;
if tm1_intrx="EXP_3" then meth=1; else meth=0;
if tm1_intrx="EXP_4" then hydr=1; else hydr=0;
if tm1_n_class=0 then patt_trt=2;
else if tm1_n_class^=pre_n_class then patt_trt=3;
else if tm1_n_class=pre_n_class then do;
	if pre_n_class=check_n_class then patt_trt=1;
	else patt_trt=3;
end;
run;
proc sql;
create table tmp_7 as
select distinct a.patid, a.pregstart, a.pregend, a.db 
	, b.pre_class, b.pre_ingr, b.pre_n_class
	, b.patt_trt as tm1_patt, labe, nife, meth, hydr
from x.cht_char2 as a
left join tmp_6 as b on a.patid=b.patid and a.pregstart=b.pregstart and a.db=b.db
where a.pre_hmed=1
;quit;
data tmp_8;
set tmp_7;
if tm1_patt=3 then do;
if labe=1 then tm1_labe=1; else tm1_labe=0;
if nife=1 then tm1_nife=1; else tm1_nife=0;
if meth=1 then tm1_meth=1; else tm1_meth=0;
if hydr=1 then tm1_hydr=1; else tm1_hydr=0;
if max(tm1_labe, tm1_nife, tm1_meth, tm1_hydr)=0 then tm1_oth=1; else tm1_oth=0;
drop labe nife meth hydr;
end;
run;

proc sql;
create table tmp_9 as
select distinct a.*
	, b.type_id as tm2_class, b.exp_id as tm2_intrx, b.ingr as tm2_ingr
	, c.type_id as check_class, c.ingr as check_ingr
from tmp_8 as a
left join x.rx_cht_htnmed as b on a.patid=b.patid and a.pregstart=b.pregstart and a.db=b.db
	and a.pregstart+91 <= b.rx_dt and b.rx_dt <= a.pregstart+180
left join x.rx_cht_htnmed as C on a.patid=C.patid and a.pregstart=C.pregstart and a.db=C.db
	and c.rx_dt= b.rx_dt and a.pre_class=C.type_id

group by a.patid, a.pregstart, a.db
having b.rx_dt=max(b.rx_dt)
order by a.patid, a.pregstart, a.db, a.pre_class
;quit;
proc sql;
create table tmp_10 as
select distinct *, count(distinct tm2_class) as tm2_n_class
	, count(distinct check_class) as check_n_class
from tmp_9
group by patid, pregstart, db
;quit;
data tmp_11;
set tmp_10;
if tm2_intrx="EXP_1" then labe=1; else labe=0;
if tm2_intrx="EXP_2" then nife=1; else nife=0;
if tm2_intrx="EXP_3" then meth=1; else meth=0;
if tm2_intrx="EXP_4" then hydr=1; else hydr=0;
if tm2_n_class=0 then patt_trt=2;
else if tm2_n_class^=pre_n_class then patt_trt=3;
else if tm2_n_class=pre_n_class then do;
	if pre_n_class=check_n_class then patt_trt=1;
	else patt_trt=3;
end;
run;
proc sql;
create table tmp_12 as
select distinct a.patid, a.pregstart, a.pregend, a.db
	, b.pre_class, b.pre_ingr, b.pre_n_class, tm1_patt, tm1_labe, tm1_nife, tm1_meth, tm1_hydr, tm1_oth
	, b.patt_trt as tm2_patt, labe, nife, meth, hydr
from x.cht_char2 as a
left join tmp_11 as b on a.patid=b.patid and a.pregstart=b.pregstart and a.db=b.db
where a.pre_hmed=1
;quit;
data tmp_13;
set tmp_12;
if tm2_patt=3 then do;
if labe=1 then tm2_labe=1; else tm2_labe=0;
if nife=1 then tm2_nife=1; else tm2_nife=0;
if meth=1 then tm2_meth=1; else tm2_meth=0;
if hydr=1 then tm2_hydr=1; else tm2_hydr=0;
if max(tm2_labe, tm2_nife, tm2_meth, tm2_hydr)=0 then tm2_oth=1; else tm2_oth=0;
drop labe nife meth hydr;
end;
run;
proc stdize data=tmp_13 out=tmp_14 reponly missing=0; run;

proc sql;
create table tmp_15 as
select distinct patid, pregstart, pregend, db, tm1_patt
	, max(tm1_labe) as tm1_labe 
	, max(tm1_nife) as tm1_nife
	, max(tm1_meth) as tm1_meth 
	, max(tm1_hydr) as tm1_hydr
	, max(tm1_oth) as tm1_oth
	, tm2_patt
	, max(tm2_labe) as tm2_labe 
	, max(tm2_nife) as tm2_nife
	, max(tm2_meth) as tm2_meth 
	, max(tm2_hydr) as tm2_hydr
	, max(tm2_oth) as tm2_oth
from tmp_14
group by patid, pregstart, db
;quit; *52404;
data tmp_16;
set tmp_15;
tm1_int_comb=sum(tm1_labe,tm1_nife,tm1_meth,tm1_hydr);
tm2_int_comb=sum(tm2_labe,tm2_nife,tm2_meth,tm2_hydr);
run;
data x.cht_char3; set tmp_16; run;

proc tabulate data=x.cht_char3;
class tm1_patt tm1_labe tm1_nife tm1_meth tm1_hydr tm1_oth tm1_int_comb 
	tm2_patt tm2_labe tm2_nife tm2_meth tm2_hydr tm2_oth tm2_int_comb;
table (all tm1_patt tm1_labe tm1_nife tm1_meth tm1_hydr tm1_oth tm1_int_comb
	tm2_patt tm2_labe tm2_nife tm2_meth tm2_hydr tm2_oth tm2_int_comb)*(N), all;
run;


proc sql;
create table tmp_17 as
select distinct a.patid, a.pregstart, a.pregend, a.db
	, b.type_id as pre_class
	, c.*
from x.cht_char2 as a
left join x.rx_cht_htnmed as b on a.patid=b.patid and a.pregstart=b.pregstart and a.db=b.db
	and a.pregstart-90 <= b.rx_dt and b.rx_dt <= a.pregstart
left join x.cht_char3 as c on a.patid=c.patid and a.pregstart=c.pregstart and a.db=c.db
where a.pre_hmed=1
group by a.patid, a.pregstart, a.db
having b.rx_dt=max(b.rx_dt)
;quit;

proc tabulate data=tmp_17;
class pre_class tm1_patt tm1_labe tm1_nife tm1_meth tm1_hydr tm1_oth tm1_int_comb 
	tm2_patt tm2_labe tm2_nife tm2_meth tm2_hydr tm2_oth tm2_int_comb;
table (all tm1_patt tm1_labe tm1_nife tm1_meth tm1_hydr tm1_oth tm1_int_comb
	tm2_patt tm2_labe tm2_nife tm2_meth tm2_hydr tm2_oth tm2_int_comb)*(N), (all pre_class);
run;


*);*/;/*'*/ /*"*/; %MEND;run;quit;;;;;
