/*=============================================================================* 
* CONFIGURATIONS - SETTINGS 
*==============================================================================*
 	Project: Essential workers & Wage Inequality
	Author: Christoph Janietz (University of Groningen)
	Last update: 05-04-2023
* ---------------------------------------------------------------------------- */

*** General settings
	version 16
	set more off, perm 
	cap log close
	set seed 12345 // take the same random sample every time
	set scheme plotplain, perm // set scheme graphs
	set matsize 11000, perm 
	set maxvar 32767, perm
	matrix drop _all

*** Set paths to folders
	// to folders 
	global dir 			"H:/Christoph/art3"
	global data			"$dir/01_data" 		// (S)POLIS/BEID FILES (reduced)
	global posted		"$dir/02_posted"	// ANALYSIS FILES
	global logfiles		"$dir/03_logfiles"
	global tables		"$dir/04_tables"
	global figures		"$dir/05_figures"
	global dofiles 		"$dir/06_dofiles"
	
	// to microdata files (use converted files when possible)
	global ebbnw2006 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2006V4.dta"
	global ebbnw2007 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2007V4.dta"
	global ebbnw2008 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2008V4.dta" 
	global ebbnw2009 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2009V4.dta"
	global ebbnw2010 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2010V4.dta"
	global ebbnw2011 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2011V4.dta"
	global ebbnw2012 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2012V4.dta"
	global ebbnw2013 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2013V4.dta"
	global ebbnw2014 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2014V4.dta"
	global ebbnw2015 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2015V4.dta"
	global ebbnw2016 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2016V4.dta"
	global ebbnw2017 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2017V4.dta"
	global ebbnw2018 "G:\Arbeid\EBBnw\geconverteerde data\EBBNW2018V4.dta"
	global ebbnw2019 "H:\Christoph\art3\01_data\EBBnw2019V4.dta"
	global ebbnw2020 "H:\Christoph\art3\01_data\EBBnw2020V2.dta"
	global ebbnw2021 "H:\Christoph\art3\01_data\EBBnw2021V2.dta"
	
	// For quarterly analysis: setup sample with consistent weights due to 
	// new data collection procedure of CBS
	global ebbnwq2017 "H:\Christoph\art3\01_data\EBBnw2017V7.dta"
	global ebbnwq2018 "H:\Christoph\art3\01_data\EBBnw2018V7.dta"
	global ebbnwq2019 "H:\Christoph\art3\01_data\EBBnw2019V6.dta"
	global ebbnwq2020 "H:\Christoph\art3\01_data\EBBnw2020V4.dta"
	global ebbnwq2021 "H:\Christoph\art3\01_data\EBBnw2021V5.dta"
	global ebbnwq2022 "H:\Christoph\art3\01_data\EBBnw2022V6.dta"
	
	global ebb2006 "G:\Arbeid\EBB\2006\geconverteerde data\EBB 2006V8.DTA"
	global ebb2007 "G:\Arbeid\EBB\2007\geconverteerde data\EBB 2007V7.DTA"
	global ebb2008 "G:\Arbeid\EBB\2008\geconverteerde data\EBB 2008V7.DTA" 
	global ebb2009 "G:\Arbeid\EBB\2009\geconverteerde data\EBB 2009V7.DTA"
	global ebb2010 "G:\Arbeid\EBB\2010\geconverteerde data\EBB 2010V10.DTA"
	global ebb2011 "G:\Arbeid\EBB\2011\geconverteerde data\EBB 2011V8.DTA"
	global ebb2012 "G:\Arbeid\EBB\2012\geconverteerde data\EBB2012V11.DTA"
	global ebb2013 "G:\Arbeid\EBB\2013\geconverteerde data\EBB2013V9.DTA"
	global ebb2014 "G:\Arbeid\EBB\2014\geconverteerde data\EBB2014V5.DTA"
	global ebb2015 "G:\Arbeid\EBB\2015\geconverteerde data\EBB2015V5.DTA"
	global ebb2016 "G:\Arbeid\EBB\2016\geconverteerde data\EBB2016V3.DTA"
	global ebb2017 "G:\Arbeid\EBB\2017\geconverteerde data\EBB2017V2.DTA"
	global ebb2018 "G:\Arbeid\EBB\2018\geconverteerde data\EBB2018V1.DTA"
	
	global polis2006 "G:\Polis\POLISBUS\2006\geconverteerde data\POLISBUS 2006V1.DTA"
	global polis2007 "G:\Polis\POLISBUS\2007\geconverteerde data\POLISBUS 2007V1.DTA"
	global polis2008 "G:\Polis\POLISBUS\2008\geconverteerde data\POLISBUS 2008V1.DTA"
	global polis2009 "G:\Polis\POLISBUS\2009\geconverteerde data\POLISBUS 2009V1.DTA"
	
	global spolis2010 "G:\Spolis\SPOLISBUS\2010\geconverteerde data\SPOLISBUS 2010V1.DTA"
	global spolis2011 "G:\Spolis\SPOLISBUS\2011\geconverteerde data\SPOLISBUS 2011V1.DTA"
	global spolis2012 "G:\Spolis\SPOLISBUS\2012\geconverteerde data\SPOLISBUS 2012V1.dta"
	global spolis2013 "G:\Spolis\SPOLISBUS\2013\geconverteerde data\SPOLISBUS2013V3.DTA"
	global spolis2014 "G:\Spolis\SPOLISBUS\2014\geconverteerde data\SPOLISBUS 2014V1.DTA"
	global spolis2015 "G:\Spolis\SPOLISBUS\2015\geconverteerde data\SPOLISBUS 2015V3.DTA"
	global spolis2016 "G:\Spolis\SPOLISBUS\2016\geconverteerde data\SPOLISBUS2016V3.DTA"
	global spolis2017 "G:\Spolis\SPOLISBUS\2017\geconverteerde data\SPOLISBUS2017V2.DTA"
	global spolis2018 "G:\Spolis\SPOLISBUS\2018\geconverteerde data\SPOLISBUS2018V5.DTA"
	global spolis2019 "G:\Spolis\SPOLISBUS\2019\geconverteerde data\SPOLISBUS2019V6.DTA"
	global spolis2020 "G:\Spolis\SPOLISBUS\2020\geconverteerde data\SPOLISBUS2020V5.DTA"
	global spolis2021 "G:\Spolis\SPOLISBUS\2021\geconverteerde data\SPOLISBUS2021V5.DTA"
	global spolis2022 "G:\Spolis\SPOLISBUS\2022\geconverteerde data\SPOLISBUS2022V5.DTA"
	
	global betab2006 "G:\Arbeid\BETAB\2006\geconverteerde data\140707 BETAB 2006V1.DTA" 
	global betab2007 "G:\Arbeid\BETAB\2007\geconverteerde data\140707 BETAB 2007V1.DTA" 
	global betab2008 "G:\Arbeid\BETAB\2008\geconverteerde data\140707 BETAB 2008V1.DTA"
	global betab2009 "G:\Arbeid\BETAB\2009\geconverteerde data\140707 BETAB 2009V1.DTA" 
	global betab2010 "G:\Arbeid\BETAB\2010\geconverteerde data\140707 BETAB 2010V1.DTA" 
	global betab2011 "G:\Arbeid\BETAB\2011\geconverteerde data\140707 BETAB 2011V1.DTA" 
	global betab2012 "G:\Arbeid\BETAB\2012\geconverteerde data\140707 BETAB 2012V1.DTA" 
	global betab2013 "G:\Arbeid\BETAB\2013\geconverteerde data\141215 BETAB 2013V1.DTA" 
	global betab2014 "G:\Arbeid\BETAB\2014\geconverteerde data\BE2014TABV2.dta" 
	global betab2015 "G:\Arbeid\BETAB\2015\geconverteerde data\BE2015TABV125.DTA" 
	global betab2016 "G:\Arbeid\BETAB\2016\geconverteerde data\BE2016TABV124.DTA" 
	global betab2017 "G:\Arbeid\BETAB\2017\geconverteerde data\BE2017TABV124.DTA"
	global betab2018 "G:\Arbeid\BETAB\2018\geconverteerde data\BE2018TABV124.DTA"
	global betab2019 "G:\Arbeid\BETAB\2019\geconverteerde data\BE2019TABV124.DTA"
	global betab2020 "G:\Arbeid\BETAB\2020\geconverteerde data\BE2020TABV124.DTA"
	global betab2021 "G:\Arbeid\BETAB\2021\geconverteerde data\BE2021TABV124.DTA"
	global betab2022 "H:\Christoph\art3\01_data\BE2022TABV124.DTA"
	
	global hoogsteopl2006 "G:\Onderwijs\HOOGSTEOPLTAB\2006\geconverteerde data\120619 HOOGSTEOPLTAB 2006V1.dta"
	global hoogsteopl2007 "G:\Onderwijs\HOOGSTEOPLTAB\2007\geconverteerde data\120619 HOOGSTEOPLTAB 2007V1.dta"
	global hoogsteopl2008 "G:\Onderwijs\HOOGSTEOPLTAB\2008\geconverteerde data\120619 HOOGSTEOPLTAB 2008V1.dta"
	global hoogsteopl2009 "G:\Onderwijs\HOOGSTEOPLTAB\2009\geconverteerde data\120619 HOOGSTEOPLTAB 2009V1.dta"
	global hoogsteopl2010 "G:\Onderwijs\HOOGSTEOPLTAB\2010\geconverteerde data\120918 HOOGSTEOPLTAB 2010V1.dta"
	global hoogsteopl2011 "G:\Onderwijs\HOOGSTEOPLTAB\2011\geconverteerde data\130924 HOOGSTEOPLTAB 2011V1.dta"
	global hoogsteopl2012 "G:\Onderwijs\HOOGSTEOPLTAB\2012\geconverteerde data\141020 HOOGSTEOPLTAB 2012V1.dta"
	global hoogsteopl2013 "G:\Onderwijs\HOOGSTEOPLTAB\2013\geconverteerde data\HOOGSTEOPL2013TABV2.dta"
	global hoogsteopl2014 "G:\Onderwijs\HOOGSTEOPLTAB\2014\geconverteerde data\HOOGSTEOPL2014TABV2.dta"
	global hoogsteopl2015 "G:\Onderwijs\HOOGSTEOPLTAB\2015\geconverteerde data\HOOGSTEOPL2015TABV2.DTA" 
	global hoogsteopl2016 "G:\Onderwijs\HOOGSTEOPLTAB\2016\geconverteerde data\HOOGSTEOPLTAB2016V1.DTA"
	global hoogsteopl2017 "G:\Onderwijs\HOOGSTEOPLTAB\2017\geconverteerde data\HOOGSTEOPLTAB2017V1.dta" 
	global hoogsteopl2018 "G:\Onderwijs\HOOGSTEOPLTAB\2017\geconverteerde data\HOOGSTEOPLTAB2017V1.dta"
	
	global GBAPERSOON2009 "G:\Bevolking\GBAPERSOONTAB\2009\geconverteerde data\GBAPERSOON2009TABV1.DTA"
	// CBS recommends to use GBAPERSOONTAB2009 for years prior 2009
	global GBAPERSOON2018 "G:\Bevolking\GBAPERSOONTAB\2018\geconverteerde data\GBAPERSOON2018TABV1.dta"
	
	global CTO "K:\Utilities\Code_Listings\SSBreferentiebestanden\Geconverteerde data\CTOREFV8.dta"

	global KOPPELBAANID "G:\Arbeid\KOPPELTABELIKVIDBAANRUGIDTAB\geconverteerde data\KOPPELTABELIKVIDBAANRUGID2010TABV4.DTA"
	