/* 

   TITLE: ORN Tally - ROOM vs DATE
   VERSION: 1
   PURPOSE: used for creating a grid of occupancy per room on every day of the month
   LAST UPDATED BY: GREJ
   LAST MODIFIED DATE: 27/11/2016
   
   LAST MODIFICATION NOTE: data should be raw occupancy from Suaib.
   
   COMMENTS:
   
*/

************************************************************************************************************************************************************
************************************************************************************************************************************************************
************************************************************************************************************************************************************

clear all
drop _all
scalar drop _all
capture log close

import excel "/Users/Grejell/Desktop/JWMMD occupancy Oct 2016 .xlsx", sheet("Sheet1") firstrow case(lower) clear

gen day = day(date)

drop if excluded == 1

drop if room < 70700
drop if room > 87010

bys room date:  gen dup1 = cond(_N==1,0,_n)
drop if dup1 > 1

* flag transactions based on day*
forvalues i=1/31{

  gen day0`i' = 1 if day == `i'

}

*
forvalues i=1/31{

  bys room: egen day_`i' = total(day0`i')

}

*
forvalues i=1/31{

  replace day_`i' = 1 if day_`i' > 0

}


*
quietly by room:  gen dup = cond(_N==1,0,_n)
drop if dup>1

sort room

keep room day_1 	day_2 	day_3 	day_4 	day_5 	day_6 	day_7 	day_8 	day_9 	day_10 	day_11 	day_12 	day_13 	day_14 	day_15 	day_16 	day_17 	day_18 	day_19 	day_20 	day_21 	day_22 	day_23 	day_24 	day_25 	day_26 	day_27 	day_28 	day_29 	day_30 	day_31 
