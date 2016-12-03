clear 
use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_final.dta", clear
*keep  booking_id date control ORN bkid_orn code_outlet winamount excluded
*drop _merge
keep if excluded==2
gsort code_outlet control -winamount
duplicates drop 
summarize ORN
gen ORNTOT=r(min) + r(max) 
save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_outlier.dta" , replace

clear
foreach outlet in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16{	
use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_outlier.dta"
keep if code_outlet==`outlet'

**** total average compution
bys code_outlet : egen totalamount= total(winamount)
gen totavg=totalamount/ORNTOT
replace totavg =round(totavg,.01)

**** Control spend per ORN
by control , sort: egen sum=total(winamount)
gen totperORN= sum/ORN
replace totperORN =round(totperORN,.01)
capture quietly summarize totperORN if(control==1)
capture generate _totdc=r(mean) 

**** Sweetbeam spend per ORN
capture quietly summarize totperORN if(control==2)
capture generate _totdsb=r(mean)
gen tag_big=1 if _totdsb < _totdc & control==1
gen tag_small=1 if _totdsb > _totdc & control==2
gen tagall=1 if (_totdsb > totavg & control==2| _totdc > totavg & control==1)
egen maxamt=max(amount_bkid_outlet)


**** If SB spend per ORN is higher than total average reduce the SB spend per ORN untill it is less than total average
while _totdsb > totavg {
summarize amount_bkid_outlet if code_outlet==`outlet' & tagall==1 & control==2
drop if amount_bkid_outlet== r(max) & control==2
drop sum totperORN _totdsb

bys control : egen sum= total(winamount)
gen totperORN= sum/ORN
replace totperORN =round(totperORN,.01)

capture quietly summarize totperORN if(control==2)
capture generate _totdsb=r(mean)
replace tagall=1 if _totdsb > totavg & control==2
}


**** If control spend per ORN is higher than total average reduce the control spend per ORN untill it is less than total average

while _totdc > totavg {
summarize amount_bkid_outlet if code_outlet==`outlet' & tagall==1 & control==1
drop if amount_bkid_outlet== r(max) & control==1  
drop sum totperORN _totdc

bys control : egen sum= total(winamount)
gen totperORN= sum/ORN
replace totperORN =round(totperORN,.01)

capture quietly summarize totperORN if(control==1)
capture generate _totdc=r(mean)
replace tagall=1 if _totdc > totavg & control==1
}

/**** If control spend per ORN is higher than SB spend per ORN reduce the control spend per ORN untill it is less than SB spend per ORN 

while _totdc > _totdsb {
summarize amount_bkid_outlet if code_outlet==`outlet' & tag_big==1 & control==1
drop if amount_bkid_outlet== r(max) & control==1 
drop sum _totdc _totdsb
bys control : egen sum= total(winamount)
replace totperORN= sum/ORN
replace totperORN =round(totperORN,.01)

capture quietly summarize totperORN if(control==1)
capture generate _totdc=r(mean)

capture quietly summarize totperORN if(control==2)
capture generate _totdsb=r(mean)

replace tag_big=1 if _totdc > _totdsb

}
*/

capture drop sum totperORN _totdc _totdsb tag_big tag_small maxamt tagall
gen excluded1=2
save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_outlier_`outlet'.dta" , replace
}

clear
foreach outlet in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16{	
	append using "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_outlier_`outlet'.dta"
	save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_outlier_.dta", replace
	sort date time room booking_id trx_code description amount rate_code market_code  
		save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_outlier_.dta", replace

}
use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_final.dta", clear /****/

*drop _merge
merge m:1 date time room booking_id trx_code description amount folio excluded using "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_outlier_.dta"
*bro if excluded==2 & excluded1==.
replace excluded=1 if excluded==2 & excluded1==.

*** apply only when bracketing is needed
replace excluded = 1 if code_outlet ==4 & amount_bkid_outlet > 1000
replace excluded = 1 if code_outlet ==7 & amount_bkid_outlet > 3000
replace excluded = 1 if code_outlet ==8 & amount_bkid_outlet > 3000
replace excluded = 1 if code_outlet ==13 & amount_bkid_outlet > 2000
replace excluded = 1 if code_outlet ==16 & control == 2 & amount_bkid_outlet > 1000 /* bracketing */
**/

replace code_outlet=. if(excluded==1)
replace code_topic ="" if(excluded==1)
replace code_type ="" if(excluded==1)
replace category ="" if(excluded==1)
replace code_all=. if(excluded==1)
tab1 code_outlet code_topic code_type code_all
replace amount_bkid_outlet=. if excluded==1
save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_final5.dta", replace

use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_final5.dta", clear
keep date time room booking_id trx_code description rate_code market_code folio control excluded code_outlet code_topic code_type amount ORN
bys control : egen total_amount_control= total (amount) if excluded==2

replace total_amount_control= . if excluded==1
*drop if excluded ==1 /// not included as requested by JW, will be included on the next run - November analysis
gsort -excluded control date room time

order date time room booking_id trx_code description rate_code market_code folio control excluded code_outlet code_topic code_type amount ORN total_amount_control, first

outsheet date time room booking_id trx_code description rate_code market_code folio control excluded code_outlet code_topic code_type amount ORN total_amount_control using "/Users/Grejell/Desktop/JWMMD 2016_10 nooutliers FlatFile_2.csv", comma replace



