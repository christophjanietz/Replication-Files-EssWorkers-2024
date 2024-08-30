/*=============================================================================* 
* CODING ESSENTIAL OCCUPATIONS
*==============================================================================*
 	Project: Essential workers & Wage Inequality
	Author: Christoph Janietz (University of Groningen)
	Last update: 25-08-2020
	
	Purpose: Coding scheme to define essential occupations (following the CBS method)
	
* ---------------------------------------------------------------------------- *

	INDEX: 
		1. 	Rough classification based on BRC (First Version)
		2. 	Classification revisions made by CBS (Revised Version)

		
	LEGEND:
		BRC = BRC2014BEROEPSGROEP
		ISCO = EBBTW1ISCO2008V
		SBI = EBBTW1SBI2008V


* --------------------------------------------------------------------------- */
* 1. ROUGH CLASSIFICATION BASED ON BRC (FIRST VERSION) 
* ---------------------------------------------------------------------------- * 

gen crucial = 0
replace crucial = 1 if ///
	(BRC== 112 | BRC== 113 | BRC== 114 | BRC== 131 | BRC== 435 | BRC== 621 | ///
	BRC== 631 | BRC== 632 | BRC== 633 | BRC== 634 | BRC== 751 | BRC== 752 | ///
	BRC== 1011 | BRC== 1012 | BRC== 1013 | BRC== 1021 | BRC== 1022 | BRC== 1031 | ///
	BRC== 1032 | BRC== 1033 | BRC== 1034 | BRC== 1035 | BRC== 1041 | BRC== 1051 | ///
	BRC== 1213 | BRC== 1214 | BRC== 1215 | BRC== 1221 | BRC== 1222)
	
* --------------------------------------------------------------------------- */
* 2. CLASSIFICATION REVISIONS MADE BY CBS (REVISED VERSION) 
* ---------------------------------------------------------------------------- * 

*Step 1
replace crucial = 1 if (SBI >= 86000 & SBI < 88000)

*Step 2
replace crucial = 0 if ///
	(ISCO== 2250 | ISCO== 2266 | ISCO== 2636 | ISCO== 2632 | ISCO== 2633 | ///
	ISCO== 3240 | ISCO== 3411 | ISCO== 3413 | ISCO== 2230) 
	
*Step 3
replace crucial = 0 if ///
	(ISCO== 8300 | ISCO== 8340 | ISCO== 8341 | ISCO== 8342 | ISCO== 8343 | ///
	ISCO== 8344 | ISCO== 8350) 
	
*Step 4
replace crucial = 1 if ///
	(ISCO== 6110 | ISCO== 6111 | ISCO== 6112 | ISCO== 6113 | ISCO== 6120 | ///
	ISCO== 6121 | ISCO== 6122 | ISCO== 6123 | ISCO== 6130 | ISCO== 6221 | ///
	ISCO== 6222 | ISCO== 9211 | ISCO== 9212 | ISCO== 9213 | ISCO== 9214 | ///
	ISCO== 9215 | ISCO== 9216)
	
*Step 5
replace crucial = 1 if ///
	(BRC== 331 | BRC== 332 | BRC== 333) & ///
	(SBI== 47110 | SBI== 47730 | SBI== 47740 | SBI== 47741 | SBI== 47742) 
	
*Step 6
replace crucial = 1 if ///
	(BRC== 1222) & ///
	(ISCO== 9611 | ISCO== 9612)
	
replace crucial = 0 if ///
	(BRC== 1222) & ///
	(ISCO== 9510 | ISCO== 9520 | ISCO== 9613 | ISCO== 9621 | ISCO== 9622 | /// 
	ISCO== 9623 | ISCO== 9629)  

*Step 7
replace crucial = 0 if ///
	(ISCO== 2611 | ISCO== 2612 | ISCO== 2619)

*Step 8
replace crucial = 1 if ///
	(SBI>= 84000 & SBI< 85000) & (ISCO== 4223)
	
replace crucial = 1 if ///
	(SBI== 84300 | SBI== 99000)

replace crucial = 1 if ///
	(ISCO== 2654 | ISCO== 2656 | ISCO== 2642)
	
replace crucial = 1 if ///
	(SBI>= 35000 & SBI< 36000)
	
replace crucial = 1 if ///
	(SBI>= 6000 & SBI< 7000)
	
replace crucial = 1 if ///
	(SBI== 19100 | SBI== 19201)
	
replace crucial = 1 if ///
	(ISCO== 3511 | ISCO== 3512 | ISCO== 3513)
	
replace crucial = 1 if ///
	(SBI>= 61100 & SBI< 61900)


* Set missings
replace crucial = . if BRC==. | ISCO==. | SBI==.

lab var crucial "Essential occupations (as defined by rijksoverheid; CBS)"	

	