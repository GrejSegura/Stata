clear all
drop _all
scalar drop _all
capture log close

use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_final.dta"

********************************************************************************
*************************** OUTLET GUESTS' SPENDING ****************************
********************************************************************************

keep if excluded==2


drop if code_outlet > 16


sort code_outlet control amount_bkid_outlet

su code_outlet, meanonly

/*
forvalues o = 1/`r(max)' {
	noi list booking_id code_outlet amount_bkid_outlet control if (code_outlet==`o' & tag_bkid_outlet==1)
}
*/

by bkid_outlet, sort: generate number_trn=_N if(excluded ==2)
	label variable number_trn "booking_id transactions"
sort booking_id room 
egen bkid_room=group(booking_id room)

sort booking_id room code_outlet
egen bkid_room_outlet=group(booking_id room code_outlet) 

bys booking_id  	: egen total_amount_bkid		= total (amount) if excluded==2
bys room			: egen total_amount_room		= total (amount) if excluded==2
bys bkid_room 		: egen amount_bkid_room			= total (amount) if excluded==2
bys bkid_room_outlet: egen amount_bkid_room_outlet	= total (amount) if excluded==2
bys code_outlet control:egen amount_control_outlet	= total (amount) if excluded==2
save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10 RAW bkidS OUTLET TOTAL.dta", replace
clear
use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10 RAW bkidS OUTLET TOTAL.dta", clear
egen tag_bkid_room_outlet = tag (booking_id room code_outlet)
keep if tag_bkid_room_outlet==1
*egen tag_amt_bkid_outlet = tag(booking_id amount_bkid_outlet)
*keep if tag_amt_bkid_outlet==1
keep  room booking_id control ORN bkid_orn room_orn code_outlet tag_bkid_outlet number_trn amount_bkid_room_outlet amount_bkid_outlet total_amount_bkid total_amount_room amount_bkid_room amount_control_outlet amount excluded
gen spend_bkid_rn= total_amount_bkid/bkid_orn
format total_amount_bkid total_amount_room amount_bkid_room amount_bkid_room_outlet amount_bkid_outlet spend_bkid_rn %12.0fc
gsort booking_id -total_amount_bkid -amount_bkid_room
egen tag_bkid = tag(booking_id)
order  room booking_id control ORN bkid_orn room_orn code_outlet tag_bkid_outlet number_trn amount_bkid_room_outlet amount_bkid_outlet amount_bkid_room total_amount_bkid total_amount_room amount_control_outlet

gsort code_outlet control -amount_bkid_outlet booking_id
*percentage contribution of bookingid in the outlet.
gen percontribution=amount_bkid_outlet/amount_control_outlet
gsort code_outlet control -amount_bkid_outlet booking_id
save "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_bkidtotal.dta", replace
outsheet using "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_bkid_room_outlet.csv", c replace


*To identify long stay least spender booking_id
contract spend_bkid_rn
sort spend_bkid_rn
quietly su spend_bkid_rn , d
scalar per25=r(p25)
scalar per75=r(p75)
scalar list
drop _all
label drop _all

clear 
append using "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_bkidtotal.dta"
gen firstq = per25
gen fourthq = per75
gen tag_lsg = 1 if (bkid_orn > 20 & spend_bkid_rn < firstq )
tab booking_id if tag_lsg==1
tab booking_id bkid_orn if bkid_orn>=30
/*
su spend_bkid_rn, d
gen tag_high = 1 if spend_bkid_rn >r(p95) 

save "/Users/jomelpatulot/Desktop/ICCAN/ICCAN 2016_06_08/Dta/ICCAN 2016_06_08_RAW_z1.dta", replace

keep if excluded==2

 egen SD = sd(spend_bkid_rn)
summarize spend_bkid_rn

gen mean_score = r(mean)

gen z = (spend_bkid_rn - mean_score)/SD
summarize z
su z , d
scalar per25z=r(p25)
scalar per99z=r(p99)

egen total_SD = sd(total_amount_bkid)
summarize total_amount_bkid
gen mean_total = r(mean)
gen total_z = (total_amount_bkid - mean_total)/total_SD
summarize total_z
 su z , d
scalar per25tz=r(p25)
scalar per99tz=r(p99)
gen tag_hsg= 1 if (z > per99z & total_z > per99tz)
tab booking_id if tag_hsg==1
save "/Users/jomelpatulot/Desktop/ICCAN/ICCAN 2016_06_08/Dta/ICCAN 2016_06_08_RAW_z2.dta", replace


*/
/*
regress bkid_orn spend_bkid_rn 

lvr2plot, mlabel(booking_id)

predict d1, cooksd

predict student, rstudent

predict lev, hat
*/
