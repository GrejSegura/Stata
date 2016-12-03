clear all
drop _all
capture log close

********************************************************************************
********************* ***** *** CONFIGURATION *** ***** ************************
********************************************************************************

*Standard Hotel ID
local hotel_id "JWMMD"

*Start date of the analysis
local start_date "2016-10-01"

*End date of the analysis
local end_date "2016-10-31"

*The Path in which the data has to be stored.
local dtafolder "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_11-27.dta"

********************************************************************************
************************ ***** *** SAMPLING *** ***** **************************
********************************************************************************
*odbc exec ("exec warehouse..Sp_exclude_offline_dates_from_orn_and_trx @Hotel_ID = '`hotel_id'',@start_date = '2015-05-13', @End_Date = '2015-05-24',@reset_flag = 1"), dsn(odbc_import) u(odbc_import) p(StataImport!!)
*Exclude Booking_IDs from ORN - LSL & LSLSG
odbc exec ("exec warehouse..sp_exclude_booking_id_from_orn @Hotel_ID = '`hotel_id'', @Booking_IDs = '5824731|5809980|5710130|5835355|5858154',@start_date = '`start_date'', @End_Date = '`end_date''"), dsn(odbc_import) u(odbc_import) p(StataImport!!)
*Exclude Rooms from ORN
odbc exec ("exec warehouse..sp_exclude_rooms_from_orn @Hotel_ID = '`hotel_id'', @rooms = '',@start_date = '`start_date'', @End_Date = '`end_date''"), dsn(odbc_import) u(odbc_import) p(StataImport!!)

*Get list of rooms from DW occupancy data. This will have all rooms in the hotel
odbc load, exec ("exec Get_Room_List @Hotel_ID = '`hotel_id'',@start_date = '`start_date'', @End_Date = '`end_date''") sqlshow lowercase clear dsn(odbc_import) u(odbc_import) p(StataImport!!)

*Creating a duplicate variable control_dup for updating the sample in the datawarehouse
clonevar control_dup = control

*For updating datawarehouse
gen sample_start_date ="2016-10-01"

*Eliminate missing data
tab room
misstable sum room
destring room, replace force
drop if(room ==.)

***** Control rooms for the month (sorted and checked as per server ) ******
replace control=.
replace control=1 if (room == 70705|	room == 70706|	room == 70708|	room == 71005|	room == 71006|	room == 71208|	room == 71503|	room == 71504|	room == 71512|	room == 71513|	room == 71612|	room == 71613|	room == 71805|	room == 71806|	room == 72003|	room == 72004|	room == 72607|	room == 72714|	room == 72805|	room == 72806|	room == 73310|	room == 73311|	room == 73406|	room == 73407|	room == 73901|	room == 73903|	room == 73904|	room == 73908|	room == 73914|	room == 74101|	room == 74312|	room == 74313|	room == 74601|	room == 74910|	room == 74911|	room == 75103|	room == 75106|	room == 75202|	room == 75209|	room == 75508|	room == 75603|	room == 75604|	room == 76105|	room == 76303|	room == 76304|	room == 76406|	room == 76410|	room == 76607|	room == 76610|	room == 76705|	room == 80710|	room == 80714|	room == 80804|	room == 80901|	room == 80903|	room == 81401|	room == 81514|	room == 81604|	room == 81608|	room == 81714|	room == 81801|	room == 81905|	room == 81906|	room == 82106|	room == 82107|	room == 82410|	room == 82411|	room == 82606|	room == 82607|	room == 82903|	room == 82904|	room == 83010|	room == 83011|	room == 83105|	room == 83106|	room == 83210|	room == 83211|	room == 83510|	room == 83511|	room == 84008|	room == 84209|	room == 84308|	room == 84414|	room == 84503|	room == 84504|	room == 84701|	room == 84709|	room == 85202|	room == 85209|	room == 85210|	room == 85410|	room == 85609|	room == 85901|	room == 85910|	room == 85911|	room == 86009|	room == 86405|	room == 86408|	room == 86606|	room == 87001)
drop if (room == 87003| room == 87006| room == 77003| room == 77006)
replace control=2 if control==.
drop if room < 70700
drop if room > 87010

* Guv'nor & suite
 
count if control != control_dup

if r(N) > 0 {

	*Load the sample to the datawarehouse
	odbc insert hotel_id room control sample_start_date , table(Stata_Room_Sample) dsn(odbc_export) u(odbc_export) p(StataExport!!) sqlshow as("Hotel_ID Room_No Control From_Date") 
	
	*Run datawarehouse package for updating the sample.
	odbc exec ("exec Run_Package_Update_Sample @Hotel_ID = '`hotel_id'', @Start_Date = '`start_date'', @End_Date = '`end_date''"), dsn(odbc_import) u(odbc_import) p(StataImport!!)
}

drop control_dup

********************************************************************************
*************** ***** *** Getting ORN and Trx Data *** ***** *******************
********************************************************************************

odbc load, exec ("exec Get_ORN_From_DW @Hotel_ID = '`hotel_id'', @Start_Date = '`start_date'', @End_Date = '`end_date''")  sqlshow lowercase clear dsn(odbc_import) u(odbc_import) p(StataImport!!)

list occupancy_date ctrl_orn 

summarize ctrl_orn 

scalar ctrl_orn = r(sum)

list occupancy_date sb_orn

summarize sb_orn
 
scalar sb_orn = r(sum)

scalar list

odbc load, exec ("exec sp_transactions @Hotel_ID = '`hotel_id'' , @start_date = '`start_date'' , @end_date = '`end_date''") sqlshow lowercase clear dsn(odbc_import) u(odbc_import) p(StataImport!!)

label variable control "Sample setting"
label define control 1"Control" 2"SweetBeam"
label values control control
tab control

gen ORN = ctrl_orn if control  == 1
replace ORN = sb_orn if control == 2
label variable ORN "ORN for analysis"

save "`dtafolder'", replace
