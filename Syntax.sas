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
, data_name=Preg_gold
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
data a.patient_gold; set patient_1; run; 
%DeleteDataset(lib=work, data_name=patient, n_stt=1, n_end=1);
*Practice;
%IMPORT_N (file_n_stt=1, file_n_end=1, lib_name=work, data_name=Practice
, folder_name=Practice, data_name_infile=Practice
, var_name_list=pracid region lcd uts
, var_format_list=$5. best3. ddmmyy10. ddmmyy10.
);
proc sql;
create table a.practice_gold as
select *
from practice_1
where pracid not in (select gold_pracid from b.prac_migrt)
;quit;
%DeleteDataset(lib=work, data_name=practice, n_stt=1, n_end=1);
*Clinical;
data a.clinical_gold; set x.mom_dx_g_1 - x.mom_dx_g_16; run;
data 
*Additional;
%IMPORT_N (file_n_stt=1, file_n_end=3, lib_name=work, data_name=Additional
, folder_name=Additional, data_name_infile=Additional
, var_name_list=patid enttype adid data1 data2 data3 data4 data5 data6 data7 data8 data9 data10 data11 data12
, var_format_list=$20. best5. $20. $20. $20. $20. $20. $20. $20. $20. $20. $20. $20. $20. $20. 
);
data a.additional_gold; set additional_1 - additional_3; run;
%DeleteDataset(lib=work, data_name=additional, n_stt=1, n_end=3);
*Therapy;
data a.therapy_gold; set x.mom_rx_g_1 - x.mom_rx_g_16; run;

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
data x.bp_gold; set tmp_1; run;

/*Aurum*/
*PregRegister;
%IMPORT_TXT (
path=E:\Data\Pregnancy\Aurum_MBlink\23_002937_Type1_data, 
filename=aurum_pregnancy_register_2022_05
, lib=a, data_name=preg_aurum
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
data a.patient_aurum; set patient_1; run; 
%DeleteDataset(lib=work, data_name=patient, n_stt=1, n_end=1);
*Practice;
%IMPORT_N (file_n_stt=1, file_n_end=1, lib_name=work, data_name=Practice
, folder_name=Practice, data_name_infile=Practice
, var_name_list=pracid	lcd	uts	region
, var_format_list=$5. ddmmyy10. ddmmyy10. 5.
);
data a.practice_aurum; set practice_1; run;
%DeleteDataset(lib=work, data_name=practice, n_stt=1, n_end=1);
*Observation;
%IMPORT_N (file_n_stt=1, file_n_end=89, lib_name=work, data_name=observation
, folder_name=aurum_mother_Extract_Observation, data_name_infile=Observation
, var_name_list=patid	consid	pracid	obsid	obsdate	enterdate	staffid	parentobsid	medcodeid	value	numunitid	obstypeid	numrangelow	numrangehigh	probobsid
, var_format_list=$20. $20. $5. $20. ddmmyy10. ddmmyy10. $20. $20. $20. 19.3 $10. $5. 19.3 19.3 $20.
);
data a.observation_aurum; set observation_1 - observation_89; run;
%DeleteDataset(lib=work, data_name=observation, n_stt=1, n_end=89);
*DrugIssue;
%IMPORT_N (file_n_stt=1, file_n_end=29, lib_name=work, data_name=drug
, folder_name=aurum_mother_Extract_DrugIssue, data_name_infile=DrugIssue
, var_name_list=patid	issueid	pracid	probobsid	drugrecid	issuedate	enterdate	staffid	prodcodeid	dosageid	quantity	quantunitid	duration	estnhscost
, var_format_list=$20. $20. $5. $20. $20. ddmmyy10. ddmmyy10. $10. $20. $64. 9.3 $2. 10. 10.4
);
data a.drug_aurum; set drug_1 - drug_29; run;
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
from a.observation_aurum as a
inner join x.list_bp as b on a.medcodeid=b.medcodeid
;quit;
data x.bp_aurum; set tmp_4; run;

/*********************/
/* Study population  */
/*********************/

/*gold*/
proc sql;
create table tmp_0 as
select distinct a.*, b.gender, b.yob, b.accept, b.deathdate, b.tod, b.frd, c.lcd
from a.preg_gold as a
left join a.patient_gold as b on a.patid=b.patid
left join a.practice_gold as c on (substr(a.patid, length(a.patid)-4, 5))=c.pracid
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
run; *2095018;
data x.incl_gold_0; set tmp_1; run;
proc sql;
create table tmp_2 as
select distinct a.*, b.eventdate, c.info, c.term
from x.incl_gold_0 as a
inner join a.clinical_gold as b on a.patid=b.patid
	and a.pregstart-90 <= b.eventdate and b.eventdate <= a.pregstart
inner join x.list_dx_htn as c on b.medcode=c.code and c.code_sys="gold"
;quit;
proc sql;
create table tmp_3 as
select distinct a.*, b.info
from x.incl_gold_0 as a
left join tmp_2 as b on a.patid=b.patid and a.pregid=b.pregid
;quit;
/*proc freq data=tmp_3; table info; run;*/
data tmp_4;
set tmp_3;
if info^="" then preHTN=1; else preHTN=0;
if mdy(1,1,2001)<=pregstart<=mdy(12,31,2021);
run;*1327247;
data x.cht_gold; set tmp_4; run;

/*aurum*/
proc sql;
create table tmp_5 as
select distinct a.*, b.gender, b.yob, b.acceptable as accept, b.regstartdate, b.regenddate, c.lcd
from a.preg_aurum as a
left join a.patient_aurum as b on a.patid=b.patid
left join a.practice_aurum as c on (substr(a.patid, length(a.patid)-4, 5))=c.pracid
;quit;
data tmp_6;
set tmp_5;
if gender=. or yob=. then delete;
if regenddate=. or pregstart+365.25 <= regenddate;
if lcd=. or pregstart+365.25 <= lcd;
if regstartdate <= pregstart+365.25;
if accept="1";
run; *3779781;
data x.incl_aurum_0; set tmp_6; run;
proc sql;
create table tmp_7 as
select distinct a.*, b.obsdate as eventdate, c.info, c.term
from x.incl_aurum_0 as a
inner join a.observation_aurum as b on a.patid=b.patid
	and a.pregstart-90 <= b.obsdate and b.obsdate <= a.pregstart
inner join x.list_dx_htn as c on b.medcodeid=c.code and c.code_sys="aurum"
;quit;
proc sql;
create table tmp_8 as
select distinct a.*, b.info
from x.incl_aurum_0 as a
left join tmp_7 as b on a.patid=b.patid and a.pregstart=b.pregstart
;quit;
data tmp_9;
set tmp_8;
if info^="" then preHTN=1; else preHTN=0;
if mdy(1,1,2001)<=pregstart<=mdy(12,31,2021);
run; *2864928;
proc freq data=tmp_9; table prehtn; run;
data x.cht_aurum; set tmp_9; run;

**COV_BP:recent BP (within 180d);
proc sql;
create table bp_1 as
select distinct a.*, b.eventdate, b.dbp, b.sbp
from x.cht_gold as a
left join x.bp_gold as b on a.patid=b.patid 
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
proc freq data=bp_3; table bp*prehtn; run;
data x.cht_bp_gold; set bp_3; run;

proc sql;
create table bp_4 as
select distinct a.*, b.obsdate as eventdate, b.value, b.type_id
from x.cht_aurum as a
left join x.bp_aurum as b on a.patid=b.patid 
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
proc freq data=bp_7; table bp*prehtn; run;
data x.cht_bp_aurum; set bp_7; run;

/**************************/
/* Antihypertensive drugs */
/**************************/

proc sql;
create table x.rx_htnmed_gold as
select a.*, b.*
from a.therapy_gold as a
inner join x.list_rx as b on a.prodcode=b.code and b.code_sys="gold"
;quit;
proc sql;
create table x.rx_htnmed_aurum as
select a.*, b.*
from a.drug_aurum as a
inner join x.list_rx as b on a.prodcodeid=b.code and b.code_sys="aurum"
;quit;

data tmp_1;
set x.cht_bp_gold;
format pre_stt_dt pre_end_dt tm1_stt_dt tm1_end_dt tm2_stt_dt tm2_end_dt tm3_stt_dt tm3_end_dt post_stt_dt post_end_dt yymmdd10.; 
pre_stt_dt=pregstart-90;
pre_end_dt=pregstart;
tm1_stt_dt=pregstart+1;
tm1_end_dt=pregstart+90;
tm2_stt_dt=pregstart+91;
tm2_end_dt=pregstart+180;
tm3_stt_dt=pregstart+181;
tm3_end_dt=pregend;
post_stt_dt=pregend+1;
post_end_dt=pregend+90;
run;
data tmp_2;
set x.cht_bp_aurum;
format pre_stt_dt pre_end_dt tm1_stt_dt tm1_end_dt tm2_stt_dt tm2_end_dt tm3_stt_dt tm3_end_dt post_stt_dt post_end_dt yymmdd10.; 
pre_stt_dt=pregstart-90;
pre_end_dt=pregstart;
tm1_stt_dt=pregstart+1;
tm1_end_dt=pregstart+90;
tm2_stt_dt=pregstart+91;
tm2_end_dt=pregstart+180;
tm3_stt_dt=pregstart+181;
tm3_end_dt=pregend;
post_stt_dt=pregend+1;
post_end_dt=pregend+90;
run;
proc sql;
create table x.cht_htnmed_gold as
select a.*, b.eventdate as rx_dt, b.type_id, b.exp_id, b.info, b.ingr
from tmp_1 as a
left join x.rx_htnmed_gold as b on a.patid=b.patid
	and a.pre_stt_dt <= b.eventdate and b.eventdate <= a.post_end_dt
;quit;
proc sql;
create table x.cht_htnmed_aurum as
select a.*, b.issuedate as rx_dt, b.type_id, b.exp_id, b.info, b.ingr
from tmp_2 as a
left join x.rx_htnmed_aurum as b on a.patid=b.patid
	and a.pre_stt_dt <= b.issuedate and b.issuedate <= a.post_end_dt
;quit;





*);*/;/*'*/ /*"*/; %MEND;run;quit;;;;;
