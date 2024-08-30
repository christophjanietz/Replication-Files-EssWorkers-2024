/*=============================================================================* 
* ANALYSIS - Quarterly EBB-Polis Data
*==============================================================================*
 	Project: Essential Workers & Wage Inequality
	Author: Christoph Janietz (University of Groningen)
	Last update: 04-06-2024
	
	Purpose: Produces estimates for Figure 3 & Table 5 in the manuscript.
	
* ---------------------------------------------------------------------------- *

	INDEX: 
		0.  Settings 
		1. 	Description Average Wages
		2.  DID analysis
		3.  Change in Occupational Structure due to Covid-19
		4.  Close log file
		
* --------------------------------------------------------------------------- */
* 0. SETTINGS 
* ---------------------------------------------------------------------------- * 

*** Settings - run config file
	global dir 			"H:/Christoph/art3"
	do 					"${dir}/06_dofiles/config"
	
*** Open log file
	log using 			"$logfiles/02_analysis_EBB_polis_q.log", replace
	
	
	* Load data
	use "${posted}/EBB_core_q_all", replace
	
	* Define ISCO-08 skill levels
	recode isco1 (1=1) (2=2) (3=3) (4/8=4) (9=5), gen(isco_skill_lvl)
	
* --------------------------------------------------------------------------- */
* 1. DESCRIPTION AVERAGE WAGES
* ---------------------------------------------------------------------------- *

	preserve
	collapse (mean) avg_wage = real_hwage avg_wage_bonus = real_hwage_bonus2 ///
		(semean) se_wage = real_hwage se_wage_bonus = real_hwage_bonus2 [aw=svyw], ///
		by(PUB_YQ crucial)
		
	gen ci_top = avg_wage + 1.96*se_wage
	gen ci_bottom = avg_wage - 1.96*se_wage
	gen ci_top_bonus = avg_wage_bonus + 1.96*se_wage_bonus
	gen ci_bottom_bonus = avg_wage_bonus - 1.96*se_wage_bonus
	
	save "${posted}/avg_wgs_quarterly.dta", replace
	restore
	
	*--> [Figure 3]
	
* --------------------------------------------------------------------------- */
* 2. DID ANALYSIS
* ---------------------------------------------------------------------------- *
	
	// DID estimator
	
	* Real hourly wage
	*M1 - Time FE
	eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter [pw=svyw], ///
		vce(cluster RIN)
	*M2 - Within Major Occupation Group
	eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		[pw=svyw], vce(cluster RIN)
	*M3 - Within Industry
	eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		ib3.SBI21 [pw=svyw], vce(cluster RIN)
	*M4 - Within Industry + Heterogenous Industry Time Trend
	eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		ib3.SBI21 ib3.SBI21#c.quarter [pw=svyw], vce(cluster RIN)
	*M5 - Reweighted occupational structure
	eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		[pw=svyw_occ], vce(cluster RIN)
	*M6 - Reweighted occupational structure + Within Industry + Heterogenous Industry Time Trend
	eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		ib3.SBI21 ib3.SBI21#c.quarter [pw=svyw_occ], vce(cluster RIN)
	
	esttab using "${tables}/regression/quarterly/wages/reg_wages_did.csv", ///
		replace se r2 ar2 nobaselevels 
	est clear
	
	* Real hourly wage + bonus
	*M1 - Time FE
	eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter [pw=svyw], ///
		vce(cluster RIN)
	*M2 - Within Major Occupation Group
	eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		[pw=svyw], vce(cluster RIN)
	*M3 - Within Industry
	eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		ib3.SBI21 [pw=svyw], vce(cluster RIN)
	*M4 - Within Industry + Heterogenous Industry Time Trend
	eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		ib3.SBI21 ib3.SBI21#c.quarter [pw=svyw], vce(cluster RIN) 
	*M5 - Reweighted occupational structure
	eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		[pw=svyw_occ], vce(cluster RIN)
	*M6 - Reweighted occupational structure + Within Industry + Heterogenous Industry Time Trend
	eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
		ib3.SBI21 ib3.SBI21#c.quarter [pw=svyw_occ], vce(cluster RIN)
		
	esttab using "${tables}/regression/quarterly/wages/reg_wages_bonus_did.csv", ///
		replace se r2 ar2 nobaselevels 
	est clear
	
	// By collective agreement status
	
	foreach cao of num 0/1 {
		preserve
		keep if crucial==0 | (crucial==1 & cao==`cao')
		
		* Real hourly wage
		*M1 - Time FE
		eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter [pw=svyw], ///
			vce(cluster RIN)
		*M2 - Within Major Occupation Group
		eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			[pw=svyw], vce(cluster RIN)
		*M3 - Within Industry
		eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			ib3.SBI21 [pw=svyw], vce(cluster RIN)
		*M4 - Within Industry + Heterogenous Industry Time Trend
		eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			ib3.SBI21 ib3.SBI21#c.quarter [pw=svyw], vce(cluster RIN)
		*M5 - Reweighted occupational structure
		eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			[pw=svyw_occ], vce(cluster RIN)
		*M6 - Reweighted occupational structure + Within Industry + Heterogenous Industry Time Trend
		eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			ib3.SBI21 ib3.SBI21#c.quarter [pw=svyw_occ], vce(cluster RIN)
	
		* Real hourly wage + bonus
		*M1 - Time FE
		eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter [pw=svyw], ///
			vce(cluster RIN)
		*M2 - Within Major Occupation Group
		eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			[pw=svyw], vce(cluster RIN)
		*M3 - Within Industry
		eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			ib3.SBI21 [pw=svyw], vce(cluster RIN)
		*M4 - Within Industry + Heterogenous Industry Time Trend
		eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			ib3.SBI21 ib3.SBI21#c.quarter [pw=svyw], vce(cluster RIN) 
		*M5 - Reweighted occupational structure
		eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			[pw=svyw_occ], vce(cluster RIN)
		*M6 - Reweighted occupational structure + Within Industry + Heterogenous Industry Time Trend
		eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
			ib3.SBI21 ib3.SBI21#c.quarter [pw=svyw_occ], vce(cluster RIN)
		restore
	}
	*
		
	esttab using "${tables}/regression/quarterly/wages/reg_cao_did.csv", ///
		replace se r2 ar2 nobaselevels 
	est clear
	
	* --> [Table 5; S12-14]
	
	
	/////////////////////////////////////////
	// Robustness: Event Study Plot
	////////////////////////////////////////
	
	* DiD-Model with full controls (Workers covered by sector-level CLA)
	preserve
	
	keep if crucial==0 | (crucial==1 & cao==1)
	
	egen q = group(PUB_YQ)

	gen time_to_treat = q-14
	replace time_to_treat = 0 if crucial==0
	
	sum time_to_treat
	gen shifted_ttt = time_to_treat-r(min)
	sum shifted_ttt if time_to_treat==-1
	local true_neg1 = r(mean)
	reghdfe log_real_hwage ib`true_neg1'.shifted_ttt##i.crucial [pw=svyw_occ], ///
		absorb(i.q i.isco_skill_lvl i.SBI21 i.SBI21#c.q)
	
	gen coef = .
	gen se = .
	
	levelsof shifted_ttt, l(times)
	foreach t in `times' {
		replace coef = _b[`t'.shifted_ttt] if shifted_ttt==`t'
		replace se = _se[`t'.shifted_ttt] if shifted_ttt==`t'
	}

	gen ci_top = coef+1.96*se
	gen ci_bottom = coef - 1.96*se
	
	keep time_to_treat coef se ci_*
	duplicates drop
	
	sort time_to_treat
	
	sum ci_top
	local top_range = r(max)
	sum ci_bottom
	local bottom_range = r(min)
	
	twoway (scatter coef time_to_treat, connect(line)) ///
				(rcap ci_top ci_bottom time_to_treat) ///
				(function y = 0, range(time_to_treat)) ///
				(function y = 0, range(`bottom_range' `top_range') horiz), ///
				xtitle("Time to Treatment") ytitle("Treatment Effect") ///
				caption("95% Confidence Intervals Shown")
				
	save "${posted}/event_study.dta", replace
	restore
	
	* --> [Supplementary material S16]
	
	///////////////////////////////////////////////////////////////////////
	// Robustness: Effect heterogeneity by industry ('danger wages')
	///////////////////////////////////////////////////////////////////////
	
	// By industry
	foreach ind of num 7 8 15 16 17 {
		preserve
			iscogen isco2 = submajor(ISCO)
			keep if crucial==0 | (crucial==1 & SBI21==`ind')
	
			* (Real) hourly wage
			*M1 - Time FE
			eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter [pw=svyw], ///
				vce(cluster RIN)
			*M2 - Within ISCO-08 skill level
			eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
				[pw=svyw], vce(cluster RIN)
			*M3 - Within Industry
			eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter ib3.SBI21 ///
				[pw=svyw], vce(cluster RIN)
			*M4 - Reweighted occupational structure
			eststo: reg log_real_hwage i.crucial##i.covid ib0.quarter [pw=svyw_occ], ///
				vce(cluster RIN)
	
			* (Real) hourly wage + bonus
			*M1 - Time FE
			eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter [pw=svyw], ///
				vce(cluster RIN)
			*M2 - Within ISCO-08 skill level
			eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib2.isco_skill_lvl ///
				[pw=svyw], vce(cluster RIN)
			*M3 - Within Industry
			eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter ib3.SBI21 ///
				[pw=svyw], vce(cluster RIN)
			*M4 - Reweighted occupational structure
			eststo: reg log_real_hwage_bonus2 i.crucial##i.covid ib0.quarter [pw=svyw_occ], ///
				vce(cluster RIN)
		restore
	}
	*
		
	esttab using "${tables}/regression/quarterly/wages/reg_byind_did.csv", ///
	replace se r2 ar2 nobaselevels 
	est clear
	
	* --> [Supplementary material S17]

* --------------------------------------------------------------------------- */
* 3. CHANGE IN OCCUPATIONAL STRUCTURE DUE TO COVID-19
* ---------------------------------------------------------------------------- *
	
	// DETAILED OCCUPATION
	
	preserve
	
	*Collapse by occind and corona indicator
	collapse (mean) hwage = hwage essential = crucial (count) N = hwage, by(isco3 covid)
	
	* Reshape to wide
	reshape wide hwage essential N, i(isco3) j(covid)
	
	*Merge p
	merge 1:1 isco3 using "${posted}/w_adj_occ", nogen keepusing(p0 p1)
	
	*Drop low groups
	drop if N0<10 | N1<10
	
	*Calculate change in relative employment share
	gen empl_chng = p1-p0
	drop if empl_chng==.
	*Adjust to percentage points
	replace empl_chng = 100*(empl_chng)
	
	*Calculate change in relative size
	gen empl_chng_rel = p1/p0
	*Adjust to percentage 
	replace empl_chng_rel = 100*(empl_chng_rel)
	
	*Calculate wage rank order
	sort hwage0
	gen r_hwage = _n
	
	*Predominance within occind (essential or other?)
	gen ess = 0
	replace ess = 1 if essential0>=0.5 & essential0!=.
	
	save "${posted}/emplchng_occ_detail.dta", replace
		
	restore
	
	* --> [Supplementary material S15]
	
* --------------------------------------------------------------------------- */
* 4. CLOSE LOG FILE
* ---------------------------------------------------------------------------- *

	log close
