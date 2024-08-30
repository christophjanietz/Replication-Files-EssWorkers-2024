/*=============================================================================* 
* DATA PREPARATIONS - EBB Sample & Polis
*==============================================================================*
 	Project: Essential workers & Wage Inequality
	Author: Christoph Janietz (University of Groningen)
	Last update: 04-06-2024
	
	Purpose: Preparation of quarterly data for analysis.
	
* ---------------------------------------------------------------------------- *

	INDEX: 
		0.  Settings 
		1. 	Appending EBBnw 2006-2022
		2. 	Selecting EBB sample (one unique RIN per calendar year)
		3.  Prepare EBBnw variables
		4.  Merge (S)polis
		5.  Keep main job; drop non-covered jobs; calculate caly job summary
		6.  Merge BETAB variables
		7.  Append quarterly files
		8.  Collapse jobs in same organization 
		9.  Prepare (S)POLIS variables
		10. Merge EBBnw core and wage data from (S)POLIS
		11. Identify essential occupations
		12. Preparation of final sample
		13. Merge CLA status
		14. Close log file
		
* --------------------------------------------------------------------------- */
* 0. SETTINGS 
* ---------------------------------------------------------------------------- * 

*** Settings - run config file
	global dir 			"H:/Christoph/art3"
	do 					"${dir}/06_dofiles/config"
	
*** Open log file
	log using 			"$logfiles/01_ebbsample_q.log", replace

* --------------------------------------------------------------------------- */
* 1. APPENDING EBBnw 2017-2022
* ---------------------------------------------------------------------------- *

*****************************
*** APPENDING EBBnw 2017-2022
*****************************

	*Note: Migration background and marriage status are missing in newer versions.
	* Proceed without them for quarterly analysis.

	foreach year of num 2017/2018 {
		use RINPERSOONS RINPERSOON SLEUTELEBB EBBSTKPEILINGNUMMER EBBAFLJAAR ///
		EBBAFLKWARTAAL EBBGEWKWARTAALGEWICHTA EBBHHBGESLACHT ///
		EBBAFLLFT EBBPB2POSHH EBBAFLLFTJNGJR EBBAFLBBINT ///
		EBBAFLAANTWERK EBBAFLPOSWRKFLEXZZP1 EBBPB1POSWRKFLEX1 EBBAFLANCIENMND ///
		EBBTW1ISCO2008V BRC2014BEROEPSGROEP EBBTW1SBI2008V SBI2008VPBL21 ///
		OPLNIVSOI2016AGG3HB OPLNIVSOI2016AGG1HB ISCED2011LEVELHB ///
		ISCEDF2013RICHTINGPUBLICATIEINDN INPPERSPRIM ///
		using "${ebbnwq`year'}"
		rename RINPERSOONS RINPERSOON SLEUTELEBB EBBSTKPEILINGNUMMER EBBAFLJAAR ///
		EBBAFLKWARTAAL EBBGEWKWARTAALGEWICHTA EBBHHBGESLACHT EBBAFLLFT ///
		EBBAFLLFTJNGJR EBBAFLBBINT EBBAFLAANTWERK EBBAFLANCIENMND ///
		INPPERSPRIM, lower
		
		tempfile temp`year'
		save "`temp`year''"
	}
	*
	
	foreach year of num 2019/2021 {
		use RINPERSOONS RINPERSOON SLEUTELEBB EBBSTKPEILINGNUMMER EBBAFLJAAR ///
		EBBAFLKWARTAAL EBBGEWKWARTAALGEWICHTA EBBHHBGESLACHT ///
		EBBAFLLFT EBBPB2POSHH EBBAFLLFTJNGJR EBBAFLBBINT ///
		EBBAFLAANTWERK EBBAFLPOSWRKFLEXZZP1 EBBPB1POSWRKFLEX1 EBBAFLANCIENMND ///
		EBBTW1ISCO2008V BRC2014BEROEPSGROEP EBBTW1SBI2008V SBI2008VPBL21 ///
		OPLNIVSOI2016AGG3HB OPLNIVSOI2016AGG1HB ISCED2011LEVELHB ///
		ISCEDF2013RICHTINGPUBLICATIEINDN INPPERSPRIM ///
		using "${ebbnwq`year'}"
		rename RINPERSOONS RINPERSOON SLEUTELEBB EBBSTKPEILINGNUMMER EBBAFLJAAR ///
		EBBAFLKWARTAAL EBBGEWKWARTAALGEWICHTA EBBHHBGESLACHT EBBAFLLFT ///
		EBBAFLLFTJNGJR EBBAFLBBINT EBBAFLAANTWERK EBBAFLANCIENMND ///
		INPPERSPRIM, lower
		
		tempfile temp`year'
		save "`temp`year''"
	}
	*
	
		foreach year of num 2022 {
		use "${ebbnwq`year'}"
		keep rinpersoons rinpersoon sleutelebb ebbstkpeilingnummer ebbafljaar ///
		ebbaflkwartaal ebbgewkwartaalgewichta ebbhhbgeslacht ebbafllft ///
		EBBPB2POSHH ebbafllftjngjr ebbaflbbint ebbaflaantwerk EBBPB1POSWRKFLEXZZP1 ///
		ebbaflancienmnd EBBTW1ISCO2008V BRC2014BEROEPSGROEP EBBTW1SBI2008V ///
		SBI2008VPBL21 OPLNIVSOI2016AGG3HB OPLNIVSOI2016AGG1HB ISCED2011LEVELHB ///
		ISCEDF2013RICHTINGPUBLICATIEINDN inppersprim
		
		tempfile temp`year'
		save "`temp`year''"
	}
	*

	append using "`temp2017'" "`temp2018'" "`temp2019'" "`temp2020'" "`temp2021'"
	sort ebbafljaar rinpersoons rinpersoon


************************
*** VARIABLE ADJUSTMENTS
************************

	*Create Combi-RINPERSOON
	gen RIN = rinpersoons+rinpersoon
	order RIN, before(rinpersoons)

	// Date variables
	*SURVEY
	gen SURVEY_YMD = date(sleutelebb, "YMD") 
	format SURVEY_YMD %d
	lab var SURVEY_YMD "Exact Date of Survey"
	
	gen SURVEY_Y = year(SURVEY_YMD)
	lab var SURVEY_Y "Year of Survey"
	
	gen SURVEY_Q = quarter(SURVEY_YMD)
	lab var SURVEY_Q "Quarter of Survey"
	
	gen SURVEY_YQ = yq(SURVEY_Y, SURVEY_Q)
	format SURVEY_YQ %tq
	lab var SURVEY_YQ "Quarter/Year of Survey"
	
	order SURVEY_YMD SURVEY_Y SURVEY_Q  SURVEY_YQ, after(sleutelebb)

	*PUBLICATION
	destring ebbafljaar ebbaflkwartaal, replace
	gen PUB_YQ = yq(ebbafljaar, ebbaflkwartaal)
	format PUB_YQ %tq
	lab var PUB_YQ "Quarter / Year of Publication"
	order PUB_YQ, after(ebbaflkwartaal)

	
* --------------------------------------------------------------------------- */
* 2. SELECTING EBB SAMPLE (ONE UNIQUE RIN PER CALENDAR YEAR)
* ---------------------------------------------------------------------------- *

*****************************
*** CREATE SAMPLE
*****************************

*** Restrict to working population
	keep if ebbaflbbint=="1"
	
*** Restrict to respondents that are registered in GBA
	keep if rinpersoons=="R"
	
*** Restrict to age 16-65
	rename ebbafllft age
	keep if age>=16 & age<=65
	
	drop ebbstkpeilingnummer ebbaflbbint
		
*****************************
*** CLEAN DUPLICATES (quarterly)
*****************************

*** RIN + Survey Quarter/Year
* After core sample selection 88 duplicate pairs remain in the data.
* I select one observation of each pair based on the earliest survey timing

	sort SURVEY_YQ rinpersoons rinpersoon
	duplicates tag SURVEY_YQ rinpersoons rinpersoon, gen (dupl)
	tab dupl
	
	sort SURVEY_YQ rinpersoons rinpersoon SURVEY_YMD

	bys SURVEY_YQ rinpersoons rinpersoon: gen n = _n
	gen select = 0
	replace select = 1 if n==1
	keep if select==1
	tab dupl
	drop select dupl n
	
*** RIN + Publication Quarter/Year
	
	sort PUB_YQ rinpersoons rinpersoon
	duplicates tag PUB_YQ rinpersoons rinpersoon, gen (dupl)
	tab dupl
	
	gen tag = 1 if dupl==1 & (SURVEY_YQ!=PUB_YQ)
	drop if tag==1
	drop tag dupl 
	
	save "${data}/EBB_core_q", replace
	
* --------------------------------------------------------------------------- */
* 3. EBBnw VARIABLE PREPARATION
* ---------------------------------------------------------------------------- *
	
**********************************
*** Decoding & Labelling variables
**********************************
	
	* Gender
	rename ebbhhbgeslacht gender
	
	destring gender, replace
	
	lab def gndr_lbl 1 "Male" 2 " Female"
	lab val  gender gndr_lbl
	
	/* Migback
	rename ebbaflgeneratie migback
	
	destring migback, replace
	
	recode migback (3 9 = .) (7 = 0)
	
	lab def mgbck_lbl 0 "no migback" 1 "1st gen" 2 "2nd gen"
	lab val migback mgbck_lbl */
	
	/* Marriage
	rename ebbhhbburgst marriage
	
	destring marriage, replace
	
	recode marriage (8 9 = .)
	
	lab def marr_lbl 1 "married" 2 "divorced" 3 "widowed" 4 "never married"
	lab val marriage marr_lbl */
	
	* Household position
	rename EBBPB2POSHH hhpos
	
	destring hhpos, replace
	
	recode hhpos (9 = .)
	
	lab def hhpos_lbl 1"Eenpersonshuishouden" 2 "Alleenstaande ouder" ///
		3 "Lid van een ouderpaar" 4 "Lid van een paar (geen ouder)" ///
		5 "Overig"
	lab val hhpos hhpos_lbl
	
	* Child 
	rename ebbafllftjngjr hhchild
	
	destring hhchild, replace
	
	lab def hhchild_lbl 97 "no child in household"
	lab val hhchild hhchild_lbl
	
	* Nr. of jobs
	rename ebbaflaantwerk nrjobs
	
	destring nrjobs, replace
	
	recode nrjobs (3 = 2)
	
	lab def nrj_lbl 1 " 1 job" 2 " 2+ jobs"
	lab val nrjobs nrj_lbl 
	
	* Job position (detailed)
	rename EBBAFLPOSWRKFLEXZZP1 jobpos_detail
	
	destring jobpos_detail, replace
	
	recode jobpos_detail (99 = .)
	
	lab def jpos1_lbl 1 "regular contract, regular hours" ///
		2 "prospective regular contract, fixed hours" ///
		3 "multi year temporary contract, fixed hours" ///
		4 "other temporary contract, fixed hours" 5 "Temp agency worker" ///
		6 "On-call worker" 7 "regular contract, flexible hours" ///
		8 "temporary contract, flexible hours" 9 "ZZP own work" ///
		10 "ZZP product" 11 "Self-employed with employees" ///
		12 "self-employed, co-working" 13 " self-employed, other"
	lab val jobpos_detail jpos1_lbl
	
	* Job position (rough)
	rename EBBPB1POSWRKFLEX1 jobpos_rough 
	
	destring jobpos_rough, replace
	
	recode jobpos_rough (9 = .)
	
	lab def jpos2_lbl 1 "Standard" 2 "Flexibel" 3 "Self-employed"
	lab val jobpos_rough jpos2_lbl
	
	* Tenure
	rename ebbaflancienmnd tenure
	
	destring tenure, replace
	
	recode tenure (9998 9999 = .)
	
	* ISCO2008
	rename EBBTW1ISCO2008V ISCO
	
	destring ISCO, replace
	
	recode ISCO (9997 9999 = .)
	
	* BRC
	rename BRC2014BEROEPSGROEP BRC
	
	destring BRC, replace
	
	* SBI detailed
	rename EBBTW1SBI2008V SBI
	replace SBI = "84110" if SBI=="8411g" | SBI=="8411p" | SBI=="8411r"
	
	destring SBI, replace
	
	recode SBI (99999 = .)
	
	* SBI 21
	rename SBI2008VPBL21 SBI21
	destring SBI21, replace
	
	recode SBI21 (99 = .)
	
	lab def SBI21_lbl 1	"A Landbouw, bosbouw en visserij" ///
		2 "B Delfstoffenwinning" 3 "C Industrie" 4 "D Energievoorziening" ///
		5 "E Waterbedrijven en afvalbeheer" 6 "F Bouwnijverheid" 7 "G Handel" ///
		8 "H Vervoer en opslag" 9 "I Horeca" 10 "J Informatie en communicatie" ///
		11 "K Financiële dienstverlening" 12 "L Verhuur en handel van onroerend goed" ///
		13 "M Specialistische zakelijke diensten" 14 "N Verhuur en overige zakelijke diensten" ///
		15 "O Openbaar bestuur en overheidsdiensten" 16 "P Onderwijs" ///
		17 "Q Gezondheids- en welzijnszorg" 18 "R Cultuur, sport en recreatie" ///
		19 "S Overige dienstverlening" 20 "T Huishoudens" 21 "U Extraterritoriale organisaties"
	lab val SBI21 SBI21_lbl
	
	* Edu cat 8
	rename OPLNIVSOI2016AGG3HB edu_cat8
	
	destring edu_cat8, replace
	
	recode edu_cat8 (999 = .)
	
	lab def edu_cat8_lbl 111 "Basisonderwijs" 121 "Vmbo-b/k, mbo1" ///
		122 "Vmbo-g/t, havo-vwo-onderbouw" 211 "Mbo2 en mbo3" 212 "Mbo4" ///
		213 "Havo, vwo" 311 "Hbo-, wo-bachelor" 321 "Hbo-, wo-master, doctor"
	lab val edu_cat8 edu_cat8_lbl
	
	* Edu cat 3
	rename OPLNIVSOI2016AGG1HB edu
	destring edu, replace
	
	recode edu (9 = .)
	
	lab def edu_cat3_lbl 1 "Low" 2 "Middle" 3 "High" 
	lab val edu edu_cat3_lbl
	
	* ISCED LEVEL
	rename ISCED2011LEVELHB ISCED_lvl 
	
	destring ISCED_lvl, replace
	
	recode ISCED_lvl (9 = .)
	
	lab def lvl_lbl 0 "less than primary" 1 "primary" 2 "lower secondary" ///
		3 "upper secondary" 4 "post-secondary non-tertiary" 5 "short cycle tertiary" ///
		6 "bachelor or equivalent" 7 "master or equivalent" 8 "doctoral or equivalent" 
	lab val ISCED_lvl lvl_lbl
	
	* ISCED FIELD
	rename ISCEDF2013RICHTINGPUBLICATIEINDN ISCED_fld
	
	destring ISCED_fld, replace
	
	recode ISCED_fld (9999 = .)
	
	lab def fld_lbl 0 "algemeen" 100 "onderwijs" 200 "vormgeving, kunst, taken, en geschiednis" ///
		300 "journalistik, gedrag en maatschappij" ///
		400 "recht, administratie, handel en zakelijke dienstverlening" ///
		500 "wiskunde, naturwetenschappen" 600 "informatica" ///
		700 "techniek, industrie, en bouwkunde" 800 "landbouw, diergeneeskunde en -verzorging" ///
		900 "gezondheidszorg en welzijn" 1000 "dienstverlening"
	lab val ISCED_fld fld_lbl
	
	* Personal Income
	rename inppersprim persinc
	
	recode persinc (9999999999 = .)
	
	* Save
	
	save "${data}/EBB_core_q.dta", replace
	
* --------------------------------------------------------------------------- */
* 4. MERGE (S)POLIS
* ---------------------------------------------------------------------------- *

******************
*** MERGE (S)POLIS
******************

	/*
	1:m - The persons-quarter/year combis are unique, but multiple jobs might be in the data.
	--> Adjustments can be made post-merge
	
	First, I split the EBB data into quarterly chunks. Second, I merge the Polis
	data for the overall calendar year. Third, I keep the POLIS observations of
	jobs only inside the quarter (1st: 01.01-31.03; 2nd: 01.04.-30.06; 
	3rd: 01.07-30.09; 4th: 01.10-31.12)
	*/


*** 2017-2022: SPOLIS
	foreach year of num 2017/2022 {
		foreach quarter of num 1/4 {
			use "${data}/EBB_core_q.dta", replace
			keep if SURVEY_Y == `year' 
			keep if SURVEY_Q == `quarter' 
			sort rinpersoons rinpersoon
			save "${data}/EBB_core_q_`year'_`quarter'.dta", replace

			use rinpersoons rinpersoon ikvid sdatumaanvangiko sdatumeindeiko ///
				sbaandagen sbasisloon sbasisuren sbijzonderebeloning sextrsal ///
				sincidentsal slningld slnowrk soverwerkuren ///
				sreisk svakbsl svoltijddagen scontractsoort spolisdienstverband ///
				sbeid scaosector sdatumaanvangikv sdatumeindeikv ///
				ssoortbaan if rinpersoons=="R" using "${spolis`year'}", replace 
			sort rinpersoons rinpersoon
			merge m:1 rinpersoons rinpersoon using "${data}/EBB_core_q_`year'_`quarter'.dta",  ///
				keep(using match)
			drop if _merge==2 //Check lost EBB
			drop _merge
		
			*Prepare date indicators
			gen job_start_exact = date(sdatumaanvangiko, "YMD")
			gen job_end_exact = date(sdatumeindeiko, "YMD")
			gen job_start_caly = date(sdatumaanvangikv, "YMD")
			gen job_end_caly = date(sdatumeindeikv, "YMD")
			format job_start_exact job_end_exact job_start_caly job_end_caly %d
		
			*Recast string for 2016-2018 to enable merge
			recast str32 ikvid
			
			* Reduce wage observations to respective quarter
			gen month = month(job_end_exact)
			
			gen select = .
			replace select = 1 if month<=3 & SURVEY_Q==1
			replace select = 1 if (month>= 4 & month<=6) & SURVEY_Q==2
			replace select = 1 if (month>= 7 & month<=9) & SURVEY_Q==3
			replace select = 1 if (month>= 10 & month<=12)  & SURVEY_Q==4
			keep if select==1
			
			drop month select
		
			order RIN, before(rinpersoons)
			order sleutelebb-persinc, after(rinpersoon)
			order job_start_exact-job_end_caly, after(ikvid)
			save "${data}/EBB_core_q_`year'_`quarter'.dta", replace 
		}
		*
	}
	*

* --------------------------------------------------------------------------- */
* 5. KEEP MAIN JOB; DROP NON-COVERED JOBS; CALCULATE CALENDAR YEAR JOB SUMMARY
* ---------------------------------------------------------------------------- *
	
*** Loops for SPOLIS (2017-2022)
	foreach year of num 2017/2022 {
		foreach quarter of num 1/4 {
		
		use "${data}/EBB_core_q_`year'_`quarter'.dta", replace
		
		
		************************************************************************
		// SELECTION 1 - Use only Job IDs that exist at the time of the survey
		************************************************************************
		*Drop jobs that do not coincide with the timing of the EBB survey
		keep if (SURVEY_YMD >= job_start_caly) & (SURVEY_YMD<= job_end_caly)
		
		
		************************************************************************
		// SELECTION 2 - 1ste werkring = Beid affiliation with highest overall 
		// hours in calender year based on existing jobs at the time of the survey
		************************************************************************
		
		*Summarize total basic hours per person - establishment (defines main job)
		bys rinpersoons rinpersoon sbeid: egen sbasisuren_quart_beid = total(sbasisuren)
		bys rinpersoons rinpersoon: egen max_sbasisuren_quart_beid = max(sbasisuren_quart_beid)
		
		keep if (sbasisuren_quart_beid==max_sbasisuren_quart_beid)
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
		drop max_sbasisuren_quart_beid
		
		************************************************************************
		// JOB Summary statistics for whole calendar year (all obs per unique job ID)
		************************************************************************
		foreach var of var sbaandagen-svoltijddagen {
			bys ikvid: egen `var'_quart = total(`var')
		}
		*	
		
		************************************************************************
		*Create Tags for exact observation matching Survey date
		************************************************************************
		// Patchy jobs are sublemented with exact observation of up to 4 weeks earlier
		sort rinpersoons rinpersoon ikvid sdatumeindeiko
		gen exact_match = 0
		replace exact_match = 1 if (SURVEY_YMD >= job_start_exact) & (SURVEY_YMD<= job_end_exact) //tag exact survey-polis overlaps
		bys rinpersoons rinpersoon ikvid: egen exact_match_job = total(exact_match) //tag all obs per respective job
		gen close_match = 0
		gen dist_s_p = SURVEY_YMD - job_end_exact //distance survey date - end polis obs (in days)
		replace close_match = 1 if exact_match_job==0 & dist_s_p<=28 & dist_s_p>=0 // if no exact match for a job & tag polis obs within 28 days prior
		bys rinpersoons rinpersoon ikvid: egen close_match_job = total(close_match) // number close matches in jobs
		bys rinpersoons rinpersoon ikvid: replace close_match = 0 if close_match_job>1 & close_match[_n+1]==1 // untag earlier polis obs in case of multiple close matches
		gen far_match = 0
		replace far_match = 1 if exact_match_job==0 & close_match_job==0 & dist_s_p>28 // if no exact / close match for a job -> tag earlier polis obs
		bys rinpersoons rinpersoon ikvid: egen far_match_job = total(far_match) // number far matches in jobs
		bys rinpersoons rinpersoon ikvid: replace far_match = 0 if far_match_job>1 & far_match[_n+1]==1 // untag earlier polis obs in case of multiple far matches
	
		drop exact_match_job close_match_job far_match_job dist_s_p
		keep if exact_match==1 | close_match==1
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
	
		*Generate auxiliary variables
		gen patchy = .
		replace patchy=0 if exact_match==1
		replace patchy=1 if close_match==1
	
		drop exact_match close_match far_match
	
		gen YEAR = `year'
		order YEAR, after(rinpersoon)
	
		bys rinpersoons rinpersoon: gen nr_job = _N
	
		sort rinpersoons rinpersoon ikvid sdatumaanvangiko
	
		save "${data}/EBB_core_q_`year'_`quarter'.dta", replace	
		}
		*
	}
	*

* --------------------------------------------------------------------------- */
* 6. MERGE BETAB VARIABLES
* ---------------------------------------------------------------------------- * 

***************
*** MERGE BETAB
***************
	foreach year of num 2017/2018 {
		foreach quarter of num 1/4 {
			use "${data}/EBB_core_q_`year'_`quarter'.dta", replace
			rename sbeid beid
			sort beid
		
			merge m:1 beid using "${betab`year'}", keepusing (SBI2008VJJJJ gksbs gemhvjjjj) ///
				keep(master match) nogen
			order SBI2008VJJJJ gksbs gemhvjjjj, after(beid)
			rename beid sbeid
	
			sort rinpersoons rinpersoon ikvid sdatumaanvangiko
	
			save "${data}/EBB_core_q_`year'_`quarter'.dta", replace
		}
		*
	}
	*	
	
	foreach year of num 2019/2022 {
		foreach quarter of num 1/4 {
			use "${data}/EBB_core_q_`year'_`quarter'.dta", replace
			rename sbeid beid
			sort beid
		
			merge m:1 beid using "${betab`year'}", keepusing (sbi2008vjjjj gksbs gemhvjjjj) ///
				keep(master match) nogen
			order sbi2008vjjjj gksbs gemhvjjjj, after(beid)
			rename beid sbeid
			rename sbi2008vjjjj SBI2008VJJJJ 
	
			sort rinpersoons rinpersoon ikvid sdatumaanvangiko
	
			save "${data}/EBB_core_q_`year'_`quarter'.dta", replace
		}
		*
	}
	*
	
	
* --------------------------------------------------------------------------- */
* 7. APPEND QUARTERLY FILES
* ---------------------------------------------------------------------------- *

***************************
*** APPEND QUARTERLY FILES
***************************

	use "${data}/EBB_core_q_2022_4.dta", replace
	foreach year of num 2017/2021 {
		foreach quarter of num 1/4 {
			append using "${data}/EBB_core_q_`year'_`quarter'.dta"
		}
		*
	}
	*
	
	foreach quarter of num 1/3 {
		append using "${data}/EBB_core_q_2022_`quarter'.dta"
	}
	*
	
	sort YEAR SURVEY_Q rinpersoons rinpersoon

*************************
*** VARIABLE DESCRIPTIONS
*************************

	lab var RIN 				"Combined unique person ID"
	lab var YEAR 				"Reference year (Year of survey participation) - caly"

	lab var job_start_exact 	"Date (sdatumaanvangiko)"
	lab var job_end_exact 		"Date (sdatumeindeiko)"
	lab var job_start_caly 		"Date (sdatumaanvangikv)"
	lab var job_end_caly 		"Date (sdatumeindeikv)"

	lab var patchy 				"Indicator Polis-EBB match"
	lab def patchy_lbl 			0 "Exact match" 1 "Close match (<28 days)" 
	lab val patchy patchy_lbl
	lab var nr_job 				"Number of (POLIS) jobs hold by the respondent at the time of the EBB survey"

	destring spolisdienstverband gksbs scaosector ssoortbaan, replace

	lab def spolisdienstverband_lbl 1 "Volltijd" 2 "Deeltijd" 
	lab val spolisdienstverband spolisdienstverband_lbl

	lab def gksbs_lbl 0 "0 werkzame personen" 10 "1 werkzame personen" 21 "2 werkzame personen" ///
		22 "3-4 werkzame personen" 30 "5-9 werkzame personen" 40 "10-19 werkzame personen" ///
		50 "20-49 werkzame personen" 60 "50-99 werkzame personen" 71 "100-149 werkzame personen" ///
		72 "150-199 werkzame personen" 81 "200-249 werkzame personen" 82 "250-499 werkzame personen" ///
		91 "500-999 werkzame personen" 92 "1000-1999 werkzame personen" 93 ">=2000 werkzame personen"
	lab val gksbs gksbs_lbl

	lab def scaosector_lbl 1000 "Particuliere bedrijven" 2000 "Gesubsidieerde sector" ///
		3000 "Overheid (totaal)" 3100 "Rijksoverheid" 3200 "Onderwijs (totaal)" ///
		3210 "Funderend onderwijs" 3211 "Primair onderwijs" ///
		3212 "Voortgezet onderwijs (exclusief BVE)" 3213 "BVE onderwijs" ///
		3220 "Hoger beroepsonderwijs" 3230 "Universiteiten" 3240 "Academische ziekenhuizen" ///
		3250 "Onderzoeksinstellingen" 3290 "Restgroep onderwijs" 3300 "Defensie" ///
		3310 "Burgerpersoneel" 3320 "Militair personeel" 3400 "Politie" ///
		3500 "Rechterlijke macht" 3600 "Gemeenten" 3700 "Provincies" 3800 "Waterschappen"
	lab val scaosector scaosector_lbl

	lab def ssoortbaan_lbl 1 "Directeur groot aandeelhouder" 2 "Stagiare" 3 "WSW-er" ///
		4 "Uitzendkracht" 5 "Oproepkracht" 9 "Rest"
	lab val ssoortbaan ssoortbaan_lbl

	encode scontractsoort, gen(scontractsoort_new)
	drop scontractsoort
	rename scontractsoort_new scontractsoort
	order scontractsoort, after(ssoortbaan)

	recode scontractsoort (4=3)
	lab def scontractsoort_lbl 1 "Bepaalde tijd" 2 "Niet van toepassing" 3 "Onbepaalde tijd" 
	lab val scontractsoort scontractsoort_lbl
	
*** Merge CPI
	merge m:1 YEAR using "${data}/CPI.dta", nogen keep(matched)

* --------------------------------------------------------------------------- */
* 8. COLLAPSE JOBS IN SAME ORGANIZATION
* ---------------------------------------------------------------------------- *	

*************************************
*** SUM JOB IDs in SAME BEID + REDUCE
*************************************

*** Sum all establishment earnings of the same person
*  (if multiple job IDs exist at the time of the survey)
	foreach var of var sbaandagen_quart-sbasisloon_quart sbijzonderebeloning_quart-svoltijddagen_quart {
		bys YEAR SURVEY_Q rinpersoons rinpersoon sbeid: egen `var'_beid = total(`var')
	}
	*

	order sbasisuren_quart_beid, after(CPI) // already generated
	gen ft_factor = svoltijddagen_quart_beid/sbaandagen_quart_beid
	
	bys YEAR SURVEY_Q rinpersoons rinpersoon sbeid: egen job_start_quart_beid = min(job_start_caly)
	bys YEAR SURVEY_Q rinpersoons rinpersoon sbeid: egen job_end_quart_beid = max(job_end_caly)
	format job_start_quart_beid job_end_quart_beid %d

*** Keep only one observation per person-beid combination (JOB ID with most basic hours)
	bys YEAR SURVEY_Q rinpersoons rinpersoon sbeid: egen max_sbasisuren_quart = max(sbasisuren_quart)
	keep if (sbasisuren_quart==max_sbasisuren_quart)
	drop max_sbasisuren_quart
	// Some Job-IDs in same Beid have equivalent hours
	egen select = tag(YEAR SURVEY_Q rinpersoons rinpersoon sbeid)
	keep if select == 1
	drop select
	// Some workers remain duplicated as they register similar hours in different 
	// organizations in same Beid have equivalent hours
	sort SURVEY_YQ rinpersoons rinpersoon
	egen select = tag(SURVEY_YQ rinpersoons rinpersoon)
	keep if select == 1
	drop select

* --------------------------------------------------------------------------- */
* 9. PREPARE (S)POLIS VARIABLES
* ---------------------------------------------------------------------------- *

*** Generate hourly wage measures
	// Basis
	gen hwage = sbasisloon_quart_beid / sbasisuren_quart_beid
	// With Boni
	gen hwage_bonus = (slningld_quart_beid - slnowrk_quart_beid) / sbasisuren_quart_beid
	gen hwage_bonus2 = (sbasisloon_quart_beid + sbijzonderebeloning_quart_beid) / sbasisuren_quart_beid

*** Adjust for inflation (2015 prices)
	gen real_hwage = hwage/CPI
	gen real_hwage_bonus = hwage_bonus/CPI
	gen real_hwage_bonus2 = hwage_bonus2/CPI
	
*** Employer size
	gen emplsize = gksbs
	drop gksbs
	recode emplsize (10 = 1) (21 22 = 2) (30 = 3) (40 = 4) ///
		(50 = 5) (60 = 6) (71 72 = 7) (81 82 = 8) (91 92 = 9) (93 = 10)
		
	lab def size_lbl 0 "0 employees" 1 "1 employees" 2 "2-4 employees" ///
		3 "5-9 employees" 4 "10-19 employees" 5 "20-49 employees" ///
		6 "50-99 employees" 7 "100-199 employees" 8 "200-499 employees" ///
		9 "500-1999 employees" 10 ">=2000 employees"
	lab val emplsize size_lbl
	
*** Sector
	recode scaosector (1000 = 1) (2000 = 2) (3000/3800 = 3)
	gen sector = scaosector
	drop scaosector
		
	lab def sector_lbl 1"Private" 2 "Subsidized" 3 "State"
	lab val sector sector_lbl
	
*** SBI from Spolis
	rename SBI2008VJJJJ SBI_polis
	
	destring SBI_polis, replace
	
	recode SBI_polis (99999 = .)
	
*** Variable labels
	lab var ft_factor "FT factor (0-1)"
	lab var emplsize "Size of the organization"
	lab var sector "CAO sector"
	
	lab var hwage "Basisloon / Basisuren"
	lab var hwage_bonus "(Fullloon-Overwerkloon)/Basisuren"
	lab var hwage_bonus2 "(Basisloon+Bijzonderebeloning)/Basisuren"
	lab var real_hwage "Basisloon / Basisuren DEFLATED"
	lab var real_hwage_bonus "(Fullloon-Overwerkloon)/Basisuren DEFLATED"
	lab var real_hwage_bonus2 "(Basisloon+Bijzonderebeloning)/Basisuren DEFLATED"
	
	lab var job_start_quart_beid "Starting Date of job within calendar year"
	lab var job_end_quart_beid "Ending Date of job within calendar year"
	
	lab var sbasisuren_quart_beid "Total basic hours worked"
	lab var sbaandagen_quart_beid "Total days of job existence"
	lab var sbasisloon_quart_beid "Total basic wage"
	lab var sbijzonderebeloning_quart_beid "Total bonus wage"
	lab var slningld_quart_beid "Total money received (Basis+Bijzonder+Overwork)"
	lab var slnowrk_quart_beid "Total overwork wage"
	lab var soverwerkuren_quart_beid "Total overwork hours worked" 
	lab var svoltijddagen_quart_beid "Total ft-equivalent working days"
	
	
*** Order
	order ft_factor, after(spolisdienstverband)
	order ssoortbaan scontractsoort nr_job, after(ft_factor)
	order emplsize sector, after(sbeid)
	
	
	*Drop intermediate variables (not further required)
	drop sdatumaanvangiko-svoltijddagen sdatumaanvangikv sdatumeindeikv ///
		sbaandagen_quart-patchy
		
	*Sort & save wage file
	sort PUB_YQ rinpersoons rinpersoon
	
	save "${data}/EBB_core_wages_q", replace
	
	* Erase yearly/quarterly datasets from disc
	foreach year of num 2017/2022 {
		foreach quarter of num 1/4 {
			erase "${data}/EBB_core_q_`year'_`quarter'.dta"
		}
		*
	}
	*
	
* --------------------------------------------------------------------------- */
* 10. MERGE EBBnw CORE AND WAGE DATA FROM (S)POLIS
* ---------------------------------------------------------------------------- *

	use "${data}/EBB_core_q", replace
	
	sort PUB_YQ rinpersoons rinpersoon
	
	merge 1:1 PUB_YQ rinpersoons rinpersoon using "${data}/EBB_core_wages_q.dta", ///
		keepusing(spolisdienstverband ft_factor ssoortbaan scontractsoort sbeid ///
		emplsize sector SBI_polis gemhvjjjj CPI sbasisuren_quart_beid sbaandagen_quart_beid ///
		sbasisloon_quart_beid sbijzonderebeloning_quart_beid slningld_quart_beid ///
		slnowrk_quart_beid soverwerkuren_quart_beid svoltijddagen_quart_beid ///
		job_start_quart_beid job_end_quart_beid hwage hwage_bonus hwage_bonus2 ///
		real_hwage real_hwage_bonus real_hwage_bonus2) nogen
		
	save "${data}/EBB_core_q_all", replace
	
	
* --------------------------------------------------------------------------- */
* 11. IDENTIFY ESSENTIAL OCCUPATIONS
* ---------------------------------------------------------------------------- *

	* Replace SBI code from Polis data if missing in EBB
	replace SBI = SBI_polis if SBI==. & SBI_polis!=.
	
	* Do the same for SBI21
	gen SBI_polis2 = .
	recode SBI_polis2 (1110/3220 = 1) (6100/9100 = 2) (10110/33290 = 3) ///
		(35111/35140 = 4) (36000/39000 = 5) (41100/43999 = 6) (45111/47999 = 7) ///
		(49100/53202 = 8) (55101/56300 = 9) (58110/63990 = 10) ///
		(64110/66300 = 11) (68100/68320 = 12) (69101/75000 = 13) (77111/82999 = 14) ///
		(84110/84300=15) (85201/85600 = 16) (86101/88999 = 17) (90011/93299 = 18) ///
		(94110/96090 = 19) (97000 = 20) (99000 = 21)
		
	replace SBI21 = SBI_polis2 if SBI21==. & SBI_polis2!=.
	
	drop SBI_polis SBI_polis2
	
	* Run classification code
	do "${dir}/06_dofiles/coding_essential_occupations"
	
	
	save "${data}/EBB_core_q_all", replace
	
* --------------------------------------------------------------------------- */
* 12. PREPARATION OF FINAL SAMPLE
* ---------------------------------------------------------------------------- *

	*Keep only observations with valid wage observation
	keep if hwage!=. & hwage_bonus!=. & hwage_bonus2!=. 
	
	* Remove remaining self-employed in 1ste werkring
	drop if jobpos_rough==3
	
	* Remove cases that are classified to work in "0 employee organizations"
	drop if emplsize==0
	
	* Remove cases with missing identifier of crucial occupations (missing ISCO)
	drop if crucial==.
	
	* Remove the occupation "Armed Forces" & the industry "Extraterritorial Organizations"
	drop if ISCO<999 | SBI21==21
	
	* Remove Directeuren / Groote Andeelhouders; Stagiare; and WSW-er
	drop if ssoortbaan<=3
	
	* Listwise deletion based on covariate missings
	drop if edu==. | emplsize==.
	
	* Set boundaries (=1) for low wages (upper boundary now removed)
	foreach var of var hwage hwage_bonus hwage_bonus2 {
		replace `var'=1  if `var'<1
		replace real_`var'=1  if real_`var'<1
	}
	*

	// Wage variable
	* Calculate Log
	gen log_hwage = log(hwage)
	gen log_hwage_bonus = log(hwage_bonus)
	gen log_hwage_bonus2 = log(hwage_bonus2)
	
	gen log_real_hwage = log(real_hwage)
	gen log_real_hwage_bonus = log(real_hwage_bonus)
	gen log_real_hwage_bonus2 = log(real_hwage_bonus2)
	
	// Flexwerk variable
	gen flex = jobpos_rough-1
	
	// Child variable
	gen child = hhchild
	recode child (0/18 = 1) (19/97 = 0)
	
	// ISCO major groups
	gen isco1 = ISCO
	recode isco1 (0/999 = 0) (1000/1999=1) (2000/2999=2) (3000/3999=3) ///
		(4000/4999=4) (5000/5999=5) (6000/6999=6) (7000/7999=7) (8000/8999=8) ///
		(9000/9629=9)
	lab def isco1_lbl 0 "Armed Forces" 1 "Managers" 2 "Professionals" ///
		3 "Technicians and Associate Professionals" 4 "Clerical Support Workers" ///
		5 "Services and Sales Workers" 6 "Skilled Agricultural, Forestry and Fishery Workers" ///
		7 "Craft and Related Trades Workers" 8 "Plant and Machine Operators and Assemblers" /// 
		9 "Elementary Occupations"
	lab val isco1 isco1_lbl
	
	// Listwise deletion of missing industry identifiers
	drop if SBI21==.
	
*** Preparation of SURVEY Weights (all survey weights of a specific year sum up to 1)
***	(Use here EbbAflJaar - the reporting year on which the EBB weights are based)
	*svyw - sums one for each quarter
	bys PUB_YQ: egen sum_svyw = sum(ebbgewkwartaalgewichta)
	gen svyw = (ebbgewkwartaalgewichta/sum_svyw)
	bys PUB_YQ: egen chk_svywgt = sum(svyw)
	bys PUB_YQ: assert round(chk_svywgt)==1
	drop sum_svyw chk_svywgt
	

*** Calcuate Reweighting Factor based on Changing Occupational Structure
	
	// Pandemic time indicator
	gen covid = 0 
	replace covid = 1 if ebbafljaar==2020 & ebbaflkwartaal!=1 
	replace covid = 1 if ebbafljaar==2021 | ebbafljaar==2022
	
	// Quarter variable (Time)
	egen quarter = group(PUB_YQ)
	replace quarter = quarter-1
	
	* Create Occupation-Industry cells
	egen occind = group(isco1 SBI21)
	
	* Create detailed occupation cells
	gen isco3= int(ISCO/10)
	
	
	// Prepare adjusted weight to preserve pre-pandemic occupational empl. share
	*Calculate the adjustment factor based on employment shares of detailed occupations
	
	preserve
	collapse (count) n=hwage [pw=svyw], by(isco3 covid)
	
	*Calculate relative size of occind before / during pandemic
	bys covid: egen N =total(n)
	gen p= n/N
	
	* Reshape to wide
	reshape wide n N p, i(isco3) j(covid)
	
	*Calculate change in relative employment share
	gen adj_fct = p0/p1
	// The small number of individuals whose occupation disappears or appears 
	// between time periods are set to remain unchanged
	replace adj_fct = 1 if adj_fct==.
	
	keep isco3 adj_fct p0 p1
	sort isco3
	
	save "${posted}/w_adj_occ", replace
	restore
	
	sort isco3
	
	merge m:1 isco3 using "${posted}/w_adj_occ", nogen keepusing(adj_fct)
	
	*Apply adjustment factor only to cases during the pandemic
	* Cases before the pandemic remain unchanged
	replace adj_fct = 1 if covid==0
	
	*Compute new weight
	gen svyw_occ = svyw*adj_fct
	
	sort PUB_YQ rinpersoons rinpersoon
	
	save "${posted}/EBB_core_q_all", replace

	
* --------------------------------------------------------------------------- */
* 13. MERGE CLA STATUS
* ---------------------------------------------------------------------------- *	
	
	// Retrieve CLA data from SPOLIS
	foreach year of num 2017/2022 {
		use rinpersoons rinpersoon sbeid BedrijfstakCAO if rinpersoons=="R" ///
			using "${spolis`year'}", replace
		destring BedrijfstakCAO, gen(cao)
		recode cao (1/9997 = 1) (0 9998 9999 = 0)
	
		gegen max = max(cao), by(rinpersoons rinpersoon sbeid)
		gegen tag = tag(rinpersoons rinpersoon sbeid)
		keep if tag==1
		drop tag cao
		rename max cao
		gen SURVEY_Y = `year'
		order SURVEY_Y, before(rinpersoons)
		
		save "${data}/spolis_cao_`year'", replace
	}
	*
	
	append using "${data}/spolis_cao_2017" "${data}/spolis_cao_2018" ///
		"${data}/spolis_cao_2019" "${data}/spolis_cao_2020" ///
		"${data}/spolis_cao_2021" 
		
	sort SURVEY_Y rinpersoons rinpersoon sbeid
	save "${data}/spolis_cao_1722", replace
	
	foreach year of num 2017/2022 {
		erase "${data}/spolis_cao_`year'"
	}
	*
	
	// Merge to analysis dataset
	use "${posted}/EBB_core_q_all", replace
	
	sort SURVEY_Y rinpersoons rinpersoon sbeid
	merge m:1 SURVEY_Y rinpersoons rinpersoon sbeid using "${data}/spolis_cao_1722", ///
		keep(master match) keepusing(cao BedrijfstakCAO) nogen
	
	sort PUB_YQ rinpersoons rinpersoon
	save "${posted}/EBB_core_q_all", replace
	
* --------------------------------------------------------------------------- */
* 14. CLOSE LOG FILE
* ---------------------------------------------------------------------------- *

	log close
