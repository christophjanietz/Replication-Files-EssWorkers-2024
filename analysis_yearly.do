/*=============================================================================* 
* ANALYSIS - Yearly EBB-Polis Data
*==============================================================================*
 	Project: Essential Workers & Wage Inequality
	Author: Christoph Janietz (University of Groningen)
	Last update: 04-06-2024
	
	Purpose: Produces estimates for Table 1-4 & Figure 1-2 in the manuscript.
	
* ---------------------------------------------------------------------------- *

	INDEX: 
		0.  Settings 
		1. 	Descriptives
		2.  Wage distribution (by sector)
		3.  Wage regressions
		4.  Wage regressions by different strata
		5.  Wage decomposition 
		6.  Robustness analyses with tenure measure
		7.  Robustness analyses with care work indicator
		8.  Close log file
		
* --------------------------------------------------------------------------- */
* 0. SETTINGS 
* ---------------------------------------------------------------------------- * 

*** Settings - run config file
	global dir 			"H:/Christoph/art3"
	do 					"${dir}/06_dofiles/config"
	
*** Open log file
	log using 			"$logfiles/02_analysis_EBB_polis_y.log", replace
	
	
	* Load data
	use "${posted}/EBB_core_y_all", replace
	keep if ebbafljaar<=2019
	
	* Define ISCO-08 skill levels
	recode isco1 (1=1) (2=2) (3=3) (4/8=4) (9=5), gen(isco_skill_lvl)
	
	* Define care work jobs 
	do coding_carework_occupations
	
* --------------------------------------------------------------------------- */
* 1. DESCRIPTIVES
* ---------------------------------------------------------------------------- *
	
	*Table 1

*** Report differences in the demographic composition

* % of workers in essential occupations by year
	putexcel set "${tables}/descr/yearly/descr_dem_breakdown", sheet("Share Essential") modify
	putexcel A1 = ("year") B1 = ("Share Essential") 
	local row=2
	foreach year of num 2006/2019 {
		putexcel A`row' = (`year')
		sum crucial [aw=svyw] if ebbafljaar==`year'
		putexcel B`row' = (r(mean))
		local ++row
	}
	*
	
* Hourly wages by group by year
	putexcel set "${tables}/descr/yearly/descr_dem_breakdown", ///
		sheet("Real Hourly Wages") modify
	putexcel B1 = ("Real Hourly Wage") F1 = ("+ Bonus") 
	putexcel B2 = ("Essential == 0") D2 = ("Essential == 1") F2 = ("Essential == 0") ///
		H2 = ("Essential == 1") 
	putexcel A3 = ("year") B3 = ("Average") C3 = ("Sd") D3 = ("Average") E3 = ("Sd") ///
		 F3 = ("Average") G3 = ("Sd") H3 = ("Average") I3 = ("Sd")
	local row=4
	foreach year of num 2006/2019 {
		putexcel A`row' = (`year')
		sum real_hwage [aw=svyw] if ebbafljaar==`year' & crucial==0
		putexcel B`row' = (r(mean)) C`row' = (r(sd))
		sum real_hwage [aw=svyw] if ebbafljaar==`year' & crucial==1
		putexcel D`row' = (r(mean)) E`row' = (r(sd))
		sum real_hwage_bonus2 [aw=svyw] if ebbafljaar==`year' & crucial==0
		putexcel F`row' = (r(mean)) G`row' = (r(sd))
		sum real_hwage_bonus2 [aw=svyw] if ebbafljaar==`year' & crucial==1
		putexcel H`row' = (r(mean)) I`row' = (r(sd))
		local ++row
	}
	*
	
* % essential by industry & ISCO major groups
	foreach j of var SBI21 isco1 {
		putexcel set "${tables}/descr/yearly/descr_dem_breakdown", sheet("%_in_`j'") modify
		putexcel A1 = ("`j'") B1 = ("%") 
		local row=2
		levelsof `j', local(lvls)
		foreach i of local lvls {
			putexcel A`row' = ("`i'")
			sum crucial [aw=svyw] if `j'==`i'
			putexcel B`row' = (r(mean))  
			local ++row
		}
		*
	}
	*
	
	* Breakdown of demographics by essential (2006-2019 pooled)
	foreach var of var gender migback edu child jobpos_rough ///
		spolisdienstverband ssoortbaan sector emplsize isco1 SBI21 care cao {
		putexcel set "${tables}/descr/yearly/descr_dem_breakdown", sheet("`var'") modify
		putexcel A1 = ("Essential") A2 = ("Category") A3 = ("%")
		putexcel B1=0 C1=1 D1=0 E1=1 F1=0 G1=1 H1=0 I1=1 J1=0 K1=1 L1=0 M1=1 
		putexcel B2=1 C2=1 D2=2 E2=2 F2=3 G2=3 H2=4 I2=4 J2=5 K2=5 L2=6 M2=6 
		
		*Calculate shares & test for significant proportion difference between groups
		svyset [pw=svyw]
		svy: prop `var', over (crucial)
		putexcel B3 = matrix(e(b)) 
		
		levelsof `var', local(nr)
		display `nr'
		foreach i of local nr {
			capture noisily lincom _b[`i'.`var'@1.crucial]-_b[`i'.`var'@0.crucial]
		}
		*
		svyset, clear	
	}
	*
	
	foreach var of var real_hwage real_hwage_bonus2 age {
		putexcel set "${tables}/descr/yearly/descr_dem_breakdown", sheet("`var'") modify
		putexcel A1 = ("`var'") B1 = ("Essential==0") E1 = ("Essential==1")
		sum `var' [aw=svyw] if crucial==0
		putexcel B2 = (r(mean)) C2 = (r(sd))
		sum `var' [aw=svyw] if crucial==1
		putexcel E2 = (r(mean)) F2 = (r(sd))
	}
	*
	
	* Additional analysis: % Female essential & other by major occ group 
	* --> [Supplementary Material S3]
	
	bys isco1: tab crucial gender [aw=svyw], row
	bys isco_skill_lvl: tab crucial gender [aw=svyw], row
	
	tab isco1 gender [aw=svyw], row
	tab isco_skill_lvl gender [aw=svyw], row
	
	* Additional analysis: % centralized CLA over time
	* --> [Supplementary Material S5]
	tab year cao [aw=svyw], row
	tab year cao if crucial==0 [aw=svyw], row
	tab year cao if crucial==1 [aw=svyw], row

* --------------------------------------------------------------------------- */
* 2. WAGE DISTRIBUTION (BY SECTOR)
* ---------------------------------------------------------------------------- *

	* Figure 1
	
	preserve
	// Keep only required variables
	keep svyw real_hwage real_hwage_bonus crucial sector isco1
	
	save "${posted}/real_hwage_dist_sector.dta", replace
	
	restore
	
* --------------------------------------------------------------------------- */
* 3. WAGE REGRESSIONS
* ---------------------------------------------------------------------------- *

	* Table 2 (& Supplementary material S6)

* Estimating yearly marginal effects of essential occupation on wages
* --> M1:  Baseline effect
* --> M2:  + Education & Age
* --> M3:  + Gender
* --> M4:  + Motherhood + Migration background (Full Demographics)
* --> M5:  + Sector
* --> M6:  + Industry
* --> M7a: + Occupation skill level
* --> M7b: + Occupation class
* --> M8:  + Industry * Occupation

	* M1: Predicting wages with essential occupation & time trend
		eststo: reg log_real_hwage i.crucial i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix a = r(table)

	* M2: + Education & Age
		eststo: reg log_real_hwage i.crucial c.age##c.age ib2.edu i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix b = r(table)
		
	* M3: + Gender
		eststo: reg log_real_hwage i.crucial c.age##c.age ib2.edu i.gender ///
			i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix c = r(table)
		
	* M4: + Motherhood & Migration background (Full demographics)
		eststo: reg log_real_hwage i.crucial c.age##c.age ib2.edu /// 
			i.gender##i.child i.migback##i.gender i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix d = r(table)
	
	* M5: + Sector
		eststo: reg log_real_hwage i.crucial c.age##c.age ib2.edu ///
			i.gender##i.child i.migback##i.gender i.sector i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix e = r(table)
		
	* M6: + ISCO skill level
		eststo: reg log_real_hwage i.crucial c.age##c.age ib2.edu /// 
			i.gender##i.child i.migback##i.gender ib2.isco1 i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix f = r(table)
		
	* M7a: + Industry (not in final manuscript)
		eststo: reg log_real_hwage i.crucial c.age##c.age ib2.edu /// 
			i.gender##i.child i.migback##i.gender ib3.SBI21 i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix g = r(table)
		
	* M7b: + ISCO Major Groups (not in final manuscript)
		eststo: reg log_real_hwage i.crucial c.age##c.age ib2.edu /// 
			i.gender##i.child i.migback##i.gender ib2.isco_skill_lvl i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix h = r(table)
		
	* M8: + Industry * ISCO Major Groups (not in final manuscript)
		eststo: reg log_real_hwage i.crucial c.age##c.age ib2.edu /// 
			i.gender##i.child i.migback##i.gender ib3.SBI21##ib2.isco1 i.year [pw=svyw]
		
		margins, dydx(crucial)
		matrix i = r(table)
		
	* Save margin estimates
		foreach mat in a b c d e f g h i {
			putexcel set "${tables}/margins/yearly/wages/margins_baseline", ///
				sheet("`mat'") modify
			putexcel A1 = matrix(`mat'), names
		}
		*
		
		esttab using "${tables}/regression/yearly/wages/reg_wages_baseline.csv", /// 
			replace se r2 ar2 nobaselevels 
		est clear
	
* --------------------------------------------------------------------------- */
* 4. WAGE REGRESSIONS BY DIFFERENT STRATA
* ---------------------------------------------------------------------------- *	

	// Not used in final manuscript
	
* --- WITHIN MAJOR OCCUPATION GROUPS ---

	* Occ_A: Interaction Essential # Major Occupation Group
	* Unadjusted *
		eststo: reg log_real_hwage i.crucial##ib2.isco1 ///
			i.year [pw=svyw]
	*--> Trace heterogeneity of essential occ gaps across major ISCO groups
	
		margins, dydx(crucial) over(isco1)
		matrix a = r(table)

	* Occ_B: Interaction Essential # Major Occupation Group
	* Human Capital only *
		eststo: reg log_real_hwage i.crucial##ib2.isco1 ///
			c.age##c.age ib2.edu i.year [pw=svyw]
	
		margins, dydx(crucial) over(isco1)
		matrix b = r(table)
		
	* Occ_C: Interaction + Human Capital + Gender
		eststo: reg log_real_hwage i.crucial##ib2.isco1 ///
			c.age##c.age ib2.edu i.gender i.gender#ib2.isco1 i.year [pw=svyw]
	
		margins, dydx(crucial) over(isco1)
		matrix c = r(table)
		
	* Occ_D: Interaction + HC + Sector
		eststo: reg log_real_hwage i.crucial##ib2.isco1 ///
			c.age##c.age ib2.edu i.sector i.sector#ib2.isco1 i.year [pw=svyw]
	
		margins, dydx(crucial) over(isco1)
		matrix d = r(table)
		
	* Occ_E: Interaction + HC + Gender + Sector
		eststo: reg log_real_hwage i.crucial##ib2.isco1 ///
			c.age##c.age ib2.edu i.gender i.gender#ib2.isco1  ///
			i.sector i.sector#ib2.isco1 i.year [pw=svyw]
	
		margins, dydx(crucial) over(isco1)
		matrix e = r(table)
		
	* Occ_F: Interaction + Full Demographics
		eststo: reg log_real_hwage i.crucial##ib2.isco1 ///
			c.age##c.age ib2.edu i.gender##i.child i.migback##i.gender ///
			i.gender#ib2.isco1 i.year [pw=svyw]
	
		margins, dydx(crucial) over(isco1)
		matrix f = r(table)
	
	* Occ_G: Interaction + Full Demographics + SBI21
		eststo: reg log_real_hwage i.crucial##ib2.isco1 ///
			c.age##c.age ib2.edu i.gender##i.child i.migback##i.gender ///
			i.gender#ib2.isco1 ib3.SBI21 i.year [pw=svyw]
	*--> Gaps explained by Industry composition?
	
		margins, dydx(crucial) over(isco1)
		matrix g = r(table)
	
		* Save margin estimates
		foreach mat in a b c d e f g {
			putexcel set "${tables}/margins/yearly/wages/margins_occ", ///
				sheet("`mat'") modify
			putexcel A1 = matrix(`mat'), names
		}
		*
 
		esttab using "${tables}/regression/yearly/wages/reg_wages_occ.csv", ///
			replace se r2 ar2 nobaselevels 
		est clear

		
* --- WITHIN INDUSTRIES ---

	* Ind_A: Interaction Essential # Industry 
	* Unadjusted*
		eststo: reg log_real_hwage i.crucial##ib3.SBI21 ///
			i.year [pw=svyw]
	
		margins, dydx(crucial) over(SBI21)
		matrix a = r(table)

	* Ind_B: Interaction Essential # Industry 
	* Human Capital only *
		eststo: reg log_real_hwage i.crucial##ib3.SBI21 ///
			c.age##c.age ib2.edu i.year [pw=svyw]
	
		margins, dydx(crucial) over(SBI21)
		matrix b = r(table)
		
	* Ind_C: Interaction + HC + Gender
		eststo: reg log_real_hwage i.crucial##ib3.SBI21 ///
			c.age##c.age ib2.edu i.gender i.gender#ib3.SBI21 i.year [pw=svyw]
	
		margins, dydx(crucial) over(SBI21)
		matrix c = r(table)
		
	* Ind_D: Interaction + HC + Sector
		eststo: reg log_real_hwage i.crucial##ib3.SBI21 ///
			c.age##c.age ib2.edu i.sector i.sector#ib3.SBI21 i.year [pw=svyw]
	
		margins, dydx(crucial) over(SBI21)
		matrix d = r(table)
		
	* Ind_E: Interaction + HC + Gender + Sector
		eststo: reg log_real_hwage i.crucial##ib3.SBI21 ///
			c.age##c.age ib2.edu i.gender i.gender#ib3.SBI21 ///
			i.sector i.sector#ib3.SBI21 i.year [pw=svyw]
	
		margins, dydx(crucial) over(SBI21)
		matrix e = r(table)
		
	* Ind_F: Interaction + Full Demographics
		eststo: reg log_real_hwage i.crucial##ib3.SBI21 ///
			c.age##c.age ib2.edu i.gender##i.child i.migback##i.gender ///
			i.gender#ib3.SBI21 i.year [pw=svyw]
	
		margins, dydx(crucial) over(SBI21)
		matrix f = r(table)

	* Ind_G: Interaction + Full Demographics + ISCO1
		eststo: reg log_real_hwage i.crucial##ib3.SBI21 ///
			c.age##c.age ib2.edu i.gender##i.child i.migback##i.gender ///
			i.gender#ib3.SBI21 ib2.isco1 i.year [pw=svyw]
	*--> Gaps partially explained by ISCO groups?
	
		margins, dydx(crucial) over(SBI21)
		matrix g = r(table)
	
	* Save margin estimates
		foreach mat in a b c d e f g {
			putexcel set "${tables}/margins/yearly/wages/margins_ind", ///
				sheet("`mat'") modify
			putexcel A1 = matrix(`mat'), names
		}
		*
 
		esttab using "${tables}/regression/yearly/wages/reg_wages_ind.csv", ///
			replace se r2 ar2 nobaselevels 
		est clear
		
* --------------------------------------------------------------------------- */
* 5. WAGE DECOMPOSITION
* ---------------------------------------------------------------------------- *

	*Table 3-4; Figure 2; S7-11

	// Decomposition

	tab edu, gen(edu)
	gen age2 = age*age
	tab gender, gen(gender)
	tab migback, gen(mb)
	tab child, gen(child)
	tab sector, gen(sect)
	tab SURVEY_Y, gen(year)
	tab SBI21, gen(ind)
	
	* Regression models underlying decompositions
	*Full sample
	foreach ess of num 0/1 {
		eststo: reg log_real_hwage ib2.edu c.age##c.age i.gender i.child2 ///
			i.migback i.sector ib3.SBI21 i.year [pw=svyw] ///
			if crucial==`ess'
	}
	*
	*By ISCO-08 major group
	foreach occ of num 1/9 {
		foreach ess of num 0/1 {
			eststo: reg log_real_hwage ib2.edu c.age##c.age i.gender i.child2 ///
				i.migback i.sector ib3.SBI21 i.year [pw=svyw] ///
				if crucial==`ess' & isco1==`occ'
		}
	}
	*
	*By ISCO-08 skill levels
	foreach occ of num 1/5 {
		foreach ess of num 0/1 {
			eststo: reg log_real_hwage ib2.edu c.age##c.age i.gender i.child2 ///
				i.migback i.sector ib3.SBI21 i.year [pw=svyw] ///
				if crucial==`ess' & isco_skill_lvl==`occ'
		}
	}
	*
	
	esttab using "${tables}/regression/yearly/wages/reg_oaxaca.csv", ///
		replace se r2 ar2 nobaselevels 
	est clear
	
	// Mean decomposition
	
	* Mean Decomposition - all (twofold) [Table 3; S7]
	eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
		(gender: normalize(b.gender1 gender2)) ///
		(child: normalize(b.child1 child2)) ///
		(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
		(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
		[pw=svyw], by(crucial) rif(mean) relax swap weight(1)
	
	esttab using "${tables}/regression/yearly/wages/oaxaca_decomposition_mean_twofold.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	* Mean Decomposition - by ISCO-08 skill level (twofold) [Table 3; S7]
	foreach group of num 1/5 {
		preserve
		keep if isco_skill_lvl==`group'
		display "ISCO-08 skill level: `group'"
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) ///
			(child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(industry: normalize(ind1-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(crucial) rif(mean) relax swap weight(1)
		restore
	}
	*
	esttab using "${tables}/regression/yearly/wages/oaxaca_decomposition_mean_skilllevel.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	* Alternative Mean Decomposition - by occupation major group (twofold) [S9]
	foreach group of num 1/9 {
		preserve
		keep if isco1==`group'
		display "ISCO: `group'"
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) ///
			(child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(industry: normalize(ind1-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(crucial) rif(mean) relax swap weight(1)
		restore
	}
	*
	
	esttab using "${tables}/regression/yearly/wages/oaxaca_decomposition_mean_majorgrp.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	
	// Decomposition RIF
	
	* Quantile RIF Decomposition - all [S8]
	* (25-50-75)
	foreach x of num 25 50 75 {
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) (child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(crucial) rif(q(`x')) relax swap wgt(1) 
	}
	*
	
	esttab using "${tables}/regression/yearly/wages/oaxaca_decomposition_rif.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	* Detailed Quantile RIF Decomposition - all [Figure 2; S11]
	* (10-20-30-40-50-60-70-80-90)
	foreach x of num 10(10)90 {
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) (child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(crucial) rif(q(`x')) relax swap wgt(1) 
	}
	*
	
	esttab using "${tables}/regression/yearly/wages/oaxaca_decomposition_rif_detailed.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	* Quantile RIF Decomposition - by ISCO-08 skill level [Table 4; S8 (cont.)]
	foreach group of num 1/5 {
	foreach x of num 25 50 75 {
		preserve
		keep if isco_skill_lvl==`group'
		display "ISCO skill level: `group'"
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) (child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(crucial) rif(q(`x')) relax swap wgt(1) 
		restore
	}
	}
	*
	
	esttab using "${tables}/regression/yearly/wages/oaxaca_decomposition_rif_skilllvl.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	* Alternative quantile RIF Decomposition - by major occupation group [S10]
	foreach group of num 1/9 {
	foreach x of num 25 50 75 {
		preserve
		keep if isco1==`group'
		display "ISCO: `group'"
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) (child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(crucial) rif(q(`x')) relax swap wgt(1) 
		restore
	}
	}
	*
	
	esttab using "${tables}/regression/yearly/wages/oaxaca_decomposition_rif_majorgrp.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
* --------------------------------------------------------------------------- */
* 6. ROBUSTNESS ANALYSES WITH TENURE MEASURE
* ---------------------------------------------------------------------------- *
	
	* Construct tenure measure in years
	gen tenure_y=tenure/12
	
	* Set implausible cases as missing (starting age <13)
	gen start= age-tenure_y
	replace tenure_y=. if start<13
	drop start
	
	* Number of cases with tenure observation
	count if tenure_y!=. & svyw!=0
	* Compare average tenure essential & other workers
	sum tenure_y [aw=svyw] if crucial==0
	sum tenure_y [aw=svyw] if crucial==1
	
	// Decomposition including tenure
	* Mean Decomposition (twofold)
	eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
		(gender: normalize(b.gender1 gender2)) ///
		(child: normalize(b.child1 child2)) ///
		(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
		(tenure: tenure_y) ///
		(industry: normalize(ind1-ind20)) (year: normalize(year1-year14)) ///
		[pw=svyw], by(crucial) rif(mean) relax swap weight(1)
	
	* Mean Decomposition - by ISCO-08 skill level (twofold)
	foreach group of num 1/5 {
		preserve
		keep if isco_skill_lvl==`group'
		display "ISCO-08 skill level: `group'"
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) ///
			(child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(tenure: tenure_y) ///
			(industry: normalize(ind1-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(crucial) rif(mean) relax swap weight(1)
		restore
	}
	*
	esttab using "${tables}/regression/yearly/wages/robustness_tenure_decomposition_Mean_skilllevel.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	* --> [Supplementary Material S22]

	
* --------------------------------------------------------------------------- */
* 7. ROBUSTNESS ANALYSES WITH CARE WORK INDICATOR
* ---------------------------------------------------------------------------- *


	* Cross-classification essential work & care work 
	tab crucial care [aw=svyw], cell
	* --> [Supplementary Material S19]
	
	// Decomposition by care work
	* Mean Decomposition - care work (twofold)
	eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
		(gender: normalize(b.gender1 gender2)) ///
		(child: normalize(b.child1 child2)) ///
		(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
		(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
		[pw=svyw], by(care) rif(mean) relax swap weight(1)
	* Mean Decomposition - by ISCO-08 skill level (twofold)
	foreach group of num 2 3 4 {
		preserve
		keep if isco_skill_lvl==`group'
		display "ISCO-08 skill level: `group'"
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) ///
			(child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(care) rif(mean) relax swap weight(1)
		restore
	}
	*
	esttab using "${tables}/regression/yearly/wages/robustness_carework_decomposition_twofold.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	* --> [Supplementary Material S20]
	
	// Decomposition by care work within essential work
	keep if crucial==1
	
	eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
		(gender: normalize(b.gender1 gender2)) ///
		(child: normalize(b.child1 child2)) ///
		(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
		(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
		[pw=svyw], by(care) rif(mean) relax swap weight(1)
	* Mean Decomposition - by occupation major group (twofold)
	foreach group of num 2 3 4 {
		preserve
		keep if isco_skill_lvl==`group'
		display "ISCO-08 skill level: `group'"
		eststo: oaxaca_rif log_real_hwage (hc: normalize(edu1 b.edu2 edu3) age age2) ///
			(gender: normalize(b.gender1 gender2)) ///
			(child: normalize(b.child1 child2)) ///
			(migback: normalize(mb1-mb3)) (sector: normalize(b.sect1 sect2 sect3)) ///
			(industry: normalize(ind1 ind2 b.ind3 ind4-ind20)) (year: normalize(year1-year14)) ///
			[pw=svyw], by(care) rif(mean) relax swap weight(1)
		restore
	}
	*
	esttab using "${tables}/regression/yearly/wages/robustness_careworkwithinessential_decomposition_twofold.csv", ///
		replace se r2 ar2 nobaselevels
	est clear
	
	* --> [Supplementary Material S21]
		
* --------------------------------------------------------------------------- */
* 8. CLOSE LOG FILE
* ---------------------------------------------------------------------------- *

	log close
