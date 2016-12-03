clear all
drop _all
scalar drop _all
capture log close

use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10.dta", clear

****************************************
* CREATION AND FORMATTING OF VARIABLES *
rename day weekday
*destring booking_id, replace force
drop code_outlet
* Time Format *
split time, parse(:)
destring time1, replace force
rename time1 hour
destring time2, replace force
rename time2 minute
destring time3, replace force
rename time3 second
gen time_new = hms(hour,minute,second)
format time_new %tcHH:MM:SS
drop time
rename time_new time
* if you do not wish to keep this variable 
drop hour minute second

*Format Date
split date, parse(/)
generate date_new= date3+"-"+ date2+"-"+date1
generate date_n = date(date_new, "DM20Y")
format date_n %td
drop date date1 date2 date3 date_new
rename date_n date
notes date: Date variable "DMY" with %td format
label variable date "Date"
tab date
gen day = day(date)
gen month = month(date)
*drop if day >12 & day<25 /*Cannes Film festival 13th May - 24th May*/
*Format amount

sum amount

*Format trx_code
tab trx_code
destring trx_code, replace force
drop if(trx_code ==.)
tab trx_code
egen trxdesc = concat (trx_code description)
sort trxdesc
*Eliminate missing data
tab room
misstable sum room
destring room, replace force
drop if(room ==.)


order date time room booking_id trx_code description amount rate_code market_code  , first

*******************************************
************ Excluded variable ************
*******************************************

replace excluded=1 if(amount==0)
replace excluded=2 if(excluded==.)
label variable excluded "Excluding"
label define excluded 1"Excluded" 2"In Analysis"
label values excluded excluded

replace excluded=1 if(control==.)

tab excluded

save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_v1.dta", replace
********************************************************************************
***************************** trx_code *************************************
********************************************************************************

import excel "/Users/Grejell/Desktop/Data Analysis/JWMMD/JWMMD_Transaction_codes.xlsx",sheet("Transaction codes") firstrow case(lower) clear
drop if trx_code == .
sort code_outlet
destring trx_code,replace force
tab code_outlet
****************** Casual Dining
gen outlet = 1 if code_outlet =="La Farine"
replace outlet = 2 if code_outlet == "Kitchen 6"
replace outlet = 3 if code_outlet == "Tong Thai"
replace outlet = 4 if code_outlet == "Positano"
replace outlet = 5 if code_outlet == "Izakaya"
replace outlet = 6 if code_outlet == "Gardens"
****************** Fine Dining
replace outlet = 7 if code_outlet == "Prime 68"
replace outlet = 8 if code_outlet == "Rang Mahal"
****************** Bar & Lounge
replace outlet = 9 if code_outlet == "Lobby Lounge"
replace outlet = 10 if code_outlet == "Aqua pool & Grill"
replace outlet = 11 if code_outlet == "Vault"
replace outlet = 12 if code_outlet == "Velocity"
****************** In Room
replace outlet = 13 if code_outlet == "Room Service"
replace outlet = 14 if code_outlet == "Minibar"
****************** Spa
replace outlet = 15 if code_outlet == "Spa"
****************** Services
replace outlet = 16 if code_outlet == "Laundry"
replace outlet = 17 if code_outlet == "Amro Salon"
replace outlet = 18 if code_outlet == "Telephone"
****************** Package Exclusion
replace outlet = 19 if code_outlet == "Presold F&B"
replace outlet = 20 if code_outlet == "Spa Package"
replace outlet = 21 if code_outlet == "Laundry Package"
****************** Others
replace outlet = 22 if code_outlet == "Accommodation"
replace outlet = 23 if code_outlet == "Banquet"


gen outlet_order = outlet
*labmask outlet, values(code_outlet)
drop code_outlet
rename outlet code_outlet

order trx_code description code_outlet code_topic code_type 

save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD transaction codes.dta", replace

use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_v1.dta", clear
merge m:1 trx_code description using "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD transaction codes.dta"

*drop unidentified transaction*
drop if _merge==2
tab trxdesc if _merge==1
tab trxdesc if code_outlet==.

***************************** Package exclusions ************************
replace code_outlet = . if (trx_code == 29356| trx_code == 38103| trx_code == 38104| trx_code ==38105| trx_code == 38106|trx_code ==39100| trx_code == 39101|trx_code ==39102| trx_code == 39103|trx_code == 39104|trx_code == 39105|trx_code ==67100| trx_code == 67120|trx_code ==70001| trx_code == 70002)


gen excluded_package = .


bys booking_id : gen flag =1 if (trx_code ==29356)
bys booking_id :egen flagtot = sum(flag)
replace excluded_package = 1 if (flagtot > 0 & code_outlet ==4 )
replace code_outlet = 19 if (excluded_package == 1 & code_outlet == 4)

drop flag flagtot
bys booking_id : gen flag =1 if (trx_code ==38103| trx_code == 38104)
bys booking_id :egen flagtot = sum(flag)
replace excluded_package = 2 if (flagtot > 0 & code_outlet == 1 )
replace code_outlet = 19 if (excluded_package == 2 & code_outlet == 1 & code_topic == "Lunch")


drop flag flagtot
bys booking_id : gen flag =1 if (trx_code ==38105| trx_code == 38106)
bys booking_id :egen flagtot = sum(flag)
replace excluded_package = 3 if (flagtot > 0 & code_outlet == 1 )
replace code_outlet = 19 if (excluded_package == 3 & code_outlet == 1 & code_topic == "Dinner")



drop flag flagtot
bys booking_id : gen flag =1 if (trx_code ==39100| trx_code == 39101)
bys booking_id :egen flagtot = sum(flag)
replace excluded_package = 4 if (flagtot > 0 & code_outlet == 2 )
replace code_outlet = 19 if (excluded_package == 4 & code_outlet == 2 & code_topic == "Breakfast")


drop flag flagtot
bys booking_id : gen flag =1 if (trx_code ==39102| trx_code == 39103)
bys booking_id :egen flagtot = sum(flag)
replace excluded_package = 5 if (flagtot > 0 & code_outlet == 2 )
replace code_outlet = 19 if (excluded_package == 5 & code_outlet == 2 & code_topic == "Lunch")


drop flag flagtot
bys booking_id : gen flag =1 if (trx_code ==39104| trx_code == 39105)
bys booking_id :egen flagtot = sum(flag)
replace excluded_package = 5 if (flagtot > 0 & code_outlet == 2 )
replace code_outlet = 19 if (excluded_package == 5 & code_outlet == 2 & code_topic == "Dinner")


drop flag flagtot
bys booking_id : gen flag =1 if (trx_code ==67100| trx_code == 67120)
bys booking_id :egen flagtot = sum(flag)
replace excluded_package = 6 if (flagtot > 0 & code_outlet == 15 )
replace code_outlet = 20 if (excluded_package == 6 & code_outlet == 15 )


drop flag flagtot
bys booking_id : gen flag =1 if (trx_code ==70001| trx_code == 70002)
bys booking_id :egen flagtot = sum(flag)
replace excluded_package = 7 if (flagtot > 0 & code_outlet == 16)
replace code_outlet = 21 if (excluded_package == 7 & code_outlet == 16)



gen code_all = .
replace code_all = 1 if code_outlet != . & excluded == 2
replace code_all = 2 if (code_outlet == 18| code_outlet == 19| code_outlet == 20)

label variable code_all "Added or Excluded due to"
label define code_all 1"In analysis" 2"Package Exclusions" 3"Outlier Exclusion" 4"Bracket Exclusions"
label values code_all code_all


**************************************************************************************
************************ Spending per booking_id per outlet **************************
**************************************************************************************

egen bkid_outlet = group(booking_id code_outlet)
egen tag_bkid_outlet = tag(booking_id code_outlet bkid_outlet)
bys bkid_outlet : egen amount_bkid_outlet = sum (amount) if (excluded==2)
replace amount_bkid_outlet = . if excluded ==1

*******************************************
********** ALL room analysis ***************
********************************************

gen winamount=amount if excluded==2
sum winamount amount
sum winamount amount if excluded_package!=.

gen date_considered = date


su date_considered, meanonly
local min = r(min)
local max = r(max)

qui {
log using "/Users/jomelpatulot/Desktop/JWMMD/JWMMD 2016/JWMMD 2016_10/Dta/JWMMD 2016_10 raw.smcl", replace
noi di	" "
noi di	"****************************************************************************************"
noi di	"**************************************** FATPJ ****************************************"
noi di	"****************************************************************************************"
noi di	" "
noi di	"****************************************************************************************"
noi di  "NORI IN TRANSACTIONS & ORN COUNT"
noi di	%tdd/N/CY `min' " to " %tdd/N/CY `max'
noi di	"****************************************************************************************"
noi di	" "
log off
}

*******MEAN VALUE PER TRANSACTION

foreach var of varlist code_all code_outlet  code_topic code_type category {
egen group=group(`var') if(winamount!=.)
quietly summarize group
	foreach i of numlist 1/`r(max)' {
	capture quietly summarize winamount if(group==`i' & control==1)
	capture generate _meanc=r(mean) if(group==`i')
	capture replace _meanc=0 if(_meanc==. & group==`i')
	capture quietly summarize winamount if(group==`i' & control==2)
	capture generate _meansb=r(mean) if(group==`i')
	capture replace _meansb=0 if(_meanc==. & group==`i')
	capture generate meandiff`i'=_meansb - _meanc if(group==`i' & control==1)
	capture generate meandiffper`i'=(meandiff`i'/_meanc)*100 if(group==`i' & control==1)
	capture drop _meanc _meansb
	}
	generate meanDiff=.
	generate meanDiffper=.
	quietly summarize group
	foreach i of numlist 1/`r(max)' {
	capture replace meanDiff=meandiff`i' if(meandiff`i' !=0 & meanDiff==.)
	capture replace meanDiffper=meandiffper`i' if(meandiffper`i' !=0 & meanDiffper==.)
	}
	drop meandiff* meandiffper*
	rename meanDiff meandiff
	rename meanDiffper meandiffper
	replace meandiff=round(meandiff,.01)
	replace meandiffper=round(meandiffper,.01)
	generate meandiffperstr = string(meandiffper) +"%" if(meandiffper !=.)
	drop meandiffper
	rename meandiffperstr meandiffper
	label variable meandiff "Mean Diff Value"
	label variable meandiffper "% Mean Diff Value"

	generate winamountS=winamount
	*replace winamountS=. if(on90==.) 
	by control group, sort: egen mean_winamount=mean(winamount)
	label variable mean_winamount "Amount"

	*****SUM OF TOTAL TRANSACTION VALUE
	by group control, sort: egen sum=total(winamount) if(winamount !=.)
	replace sum=round(sum,.01)
	label variable sum "Total Sum"


	*****NUMBER OF TRANSACTIONS
	by group control, sort: generate N=_N if(winamount !=.)
	label variable N "N transactions"


	*****TRANSACTION VALUE PER ORN
	generate totperORN=sum/ORN
	replace totperORN=round(totperORN,.01)
	label variable totperORN "Total per ORN"

	quietly summarize group
	foreach i of numlist 1/`r(max)' {
	capture quietly summarize totperORN if(group==`i' & control==1)
	capture generate _totdc=r(mean) if(group==`i')
	capture replace _totdc =0 if(_totdc ==. & group==`i')
	capture quietly summarize totperORN if(group==`i' & control==2)
	capture generate _totdsb=r(mean) if(group==`i')
	capture replace _totdsb =0 if(_totdsb ==. & group==`i')
	capture generate totdiffORN`i'= _totdsb - _totdc if(group==`i' & control==1)
	capture generate totdiffperORN`i'=(totdiffORN`i'/_totdc)*100 if(group==`i' & control==1)
	capture drop _totdc _totdsb
	}
	generate totDiffORN=.
	generate totDiffperORN=.
	quietly summarize group
	foreach i of numlist 1/`r(max)' {
	capture replace totDiffORN =totdiffORN`i' if(totdiffORN`i' !=0 & totDiffORN==.)
	capture replace totDiffperORN =totdiffperORN`i' if(totdiffperORN`i' !=0 & totDiffperORN==.)	
	}
	drop totdiffORN* totdiffperORN*
	rename totDiffORN totdiffORN
	rename totDiffperORN totdiffperORN
	replace totdiffORN =round(totdiffORN,.01)
	replace totdiffperORN=round(totdiffperORN,.01)
	generate totdiffperORNstr = string(totdiffperORN) +"%" if(totdiffperORN !=.)
	drop totdiffperORN
	rename totdiffperORNstr totdiffperORN
	label variable totdiffORN "Total Diff per ORN"
	label variable totdiffperORN "% Diff per ORN"


	*****NUMBER OF TRANSACTIONS PER ORN
	generate countperORN=N/ORN
	label variable countperORN "Tot count/ORN"

	quietly summarize group
	foreach i of numlist 1/`r(max)' {
	capture quietly summarize countperORN if(group==`i' & control==1)
	capture generate _totdc=r(mean) if(group==`i')
	capture replace _totdc =0 if(_totdc ==. & group==`i')
	capture quietly summarize countperORN if(group==`i' & control==2)
	capture generate _totdsb=r(mean) if(group==`i')
	capture replace _totdsb =0 if(_totdsb ==. & group==`i')
	capture generate countdiffORN`i'= _totdsb - _totdc if(group==`i' & control==1)
	capture generate countdiffperORN`i'=(countdiffORN`i'/_totdc)*100 if(group==`i' & control==1)
	capture drop _totdc _totdsb
	}
	generate countDiffORN =.
	generate countDiffperORN =.
	quietly summarize group
	foreach i of numlist 1/`r(max)' {
	capture replace countDiffORN =countdiffORN`i' if(countdiffORN`i' !=0 & countDiffORN==.)
	capture replace countDiffperORN =countdiffperORN`i' if(countdiffperORN`i' !=0 & countDiffperORN==.)
	}
	drop countdiffORN* countdiffperORN*
	rename countDiffORN countdiffORN
	rename countDiffperORN countdiffperORN
	replace countdiffORN =round(countdiffORN,.0001)
	replace countdiffperORN =round(countdiffperORN,.01)
	generate countdiffperORNstr = string(countdiffperORN) +"%" if(countdiffperORN !=.)
	drop countdiffperORN
	rename countdiffperORNstr countdiffperORN
	label variable countdiffORN "Diff count/ORN"
	label variable countdiffperORN "% Diff count/ORN"
	replace countperORN =round(countperORN,.0001)

	*********TOTAL CONTRIBUTION OF SWEETBEAM ROOMS
	egen date_group=group(date)
	summarize date_group
	generate period=r(max)
	drop date_group
	quietly summarize ORN if(control==2)
	generate ORNsb = r(mean)
	by group, sort: generate totcontrib=totdiffORN * ORNsb
	by group, sort: generate totcontrmonth = (totcontrib/period)*30.5
	replace totcontrmonth=round(totcontrmonth,.01)


	drop period ORNsb
	label variable totcontrib "Revenue SB x period"
	label variable totcontrmonth "Revenue SB x month"

	// looping ensures reports happen by(code_all), by(code_outlet), by(code_topic)

	qui log on
	
	di	"////////////////////////"
	di	"`var'"
	di	"////////////////////////"
	
	
	di	"*****************************************************************************************"
	di	"Occupied Room Nights // Sum of Total transaction Value // Number of Total transactions"
	di	"*****************************************************************************************"

	tabdisp control, cell(ORN sum N) by(`var') center concise 


	di	"*****************************************************************************************"
	di	"Average Check / Difference in Average Check (absolute & proportion)"
	di	"*****************************************************************************************"

	tabdisp control, cell(mean_winamount meandiff meandiffper) by(`var')  center concise


	di	"*****************************************************************************************"
	di	"Value of transactions per ORN // Difference of value per ORN (absolute & proportion)" 
	di	"*****************************************************************************************"

	tabdisp control, cell(totperORN totdiffORN totdiffperORN) by(`var')  center concise


	di	"***************************************************************************************************"
	di  "Number of transactions per ORN // Difference of transaction number per ORN (absolute & proportion)" 
	di	"***************************************************************************************************"

	tabdisp control, cell(countperORN countdiffORN countdiffperORN) by(`var')  center concise


	di	"*****************************************************************************************"
	di	"Total contribution of SweetBeam rooms per month // Per average month"
	di	"*****************************************************************************************"

	tabdisp control, cell(totcontrib totcontrmonth) by(`var') center concise

	qui log off

	capture drop group meandiff meandiffper winamountS mean_winamount sum N totperORN totdiffORN totdiffperORN countperORN countdiffORN countdiffperORN totcontrib totcontrmonth 

	/* -cap- (short for capture) is a dangerous but useful code . 

	It supresses all output, including error messages, and proceeds to the next line regardless of any error. 

	For example:Stata will execute ìdrop varname,î but if varname does not exist, it will suppress the error report 
	ìvariable varname not foundî and continue on to the next line. 

	If you wish to see the error message, type: ìcap noisily drop varnameî */


	}
qui log close

drop feature_list feature_desc_list  trxdesc _merge  
save "/Users/jomelpatulot/Desktop/JWMMD/JWMMD 2016/JWMMD 2016_10/Dta/JWMMD 2016_10_RAW_final.dta", replace

/************************************************ Backup File **********************************************

use "/Users/jomelpatulot/Desktop/JWMMD/JWMMD 2016/JWMMD 2016_10/Dta/JWMMD 2016_10_RAW_final_ML3+Bracktes.dta", clear

drop if code_outlet > 15
drop if excluded == 1

bys control : egen total_amount_control= total (amount) if excluded==2

replace total_amount_control= . if excluded==1
drop if excluded ==1
gsort -excluded control date room time

gen group = ""
replace group = "Without Staytus Marketing" if control == 1
replace group = "With Staytus Marketing" if control == 2


order date time room booking_id trx_code description rate_code market_code folio control group excluded code_outlet code_topic code_type amount ORN total_amount_control, first

outsheet date time room booking_id trx_code description rate_code market_code folio control group excluded code_outlet code_topic code_type amount ORN total_amount_control using "/Users/jomelpatulot/Desktop/JWMMD/JWMMD 2016/JWMMD 2016_10/Reports/JWMMD 2016_10 FlatFile.csv", comma replace


