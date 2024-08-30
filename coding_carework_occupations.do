/*=============================================================================* 
* CODING CARE WORK OCCUPATIONS
*==============================================================================*
 	Project: Essential workers & Wage Inequality
	Author: Christoph Janietz (University of Groningen)
	Last update: 04-06-2024
	
	Purpose: Coding scheme to define care work occupations 
		     (following England et al. 2002; Budig & Mizra 2010)
	
* ---------------------------------------------------------------------------- *

	INDEX: 
		1. 	Define care workers based on ISCO-08 occupation codes
		2. 	Narrow done by defining care workers based on industry

		
	LEGEND:
		ISCO = EBBTW1ISCO2008V
		SBI21 = EBBTW1SBI2008V (first level)

* --------------------------------------------------------------------------- */
* 1. Define care workers based on ISCO-08 occupation codes
* ---------------------------------------------------------------------------- * 

gen care = 0
replace care = 1 if ///
	(ISCO==2200 | ISCO==2210 | ISCO==2211 | ISCO==2212 | ISCO==2220 | ISCO==2221 | ///
	ISCO==2222 | ISCO==2230 | ISCO==2240 | ISCO==2250 | ISCO==2260 | ISCO==2261 | ///
	ISCO==2262 | ISCO==2263 | ISCO==2264 | ISCO==2265 | ISCO==2266 | ISCO==2267 | ///
	ISCO==2269 | ISCO==2300 | ISCO==2310 | ISCO==2320 | ISCO==2330 | ISCO==2340 | ///
	ISCO==2341 | ISCO==2342 | ISCO==2350 | ISCO==2351 | ISCO==2352 | ISCO==2353 | ///
	ISCO==2354 | ISCO==2355 | ISCO==2356 | ISCO==2359 | ISCO==2622 | ISCO==2634 | ///
	ISCO==2635 | ISCO==2636 | ISCO==3220 | ISCO==3221 | ISCO==3222 | ISCO==3230 | ///
	ISCO==3240 | ISCO==3251 | ISCO==3253 | ISCO==3254 | ISCO==3255 | ISCO==3256 | ///
	ISCO==3258 | ISCO==3259 | ISCO==3412 | ISCO==3413 | ISCO==5300 | ISCO==5310 | ///
	ISCO==5311 | ISCO==5312 | ISCO==5320 | ISCO==5321 | ISCO==5322 | ISCO==5329 | ///
	ISCO==5411 | ISCO==5412)


* --------------------------------------------------------------------------- */
* 2. Narrow done by defining care workers based on industry
* ---------------------------------------------------------------------------- * 

replace care = 0 if ///
	care==1 & ///
	(SBI21==1 | SBI21==2 | SBI21==3 | SBI21==4 | SBI21==5 | SBI21==6 | SBI21==7 | ///
	SBI21==8 | SBI21==9 | SBI21==10 | SBI21==11 | SBI21==12 | SBI21==13 | SBI21==14 | ///
	SBI21==19)

