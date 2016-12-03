clear all
drop _all
capture log close

odbc load,exec ("exec sp_drop_table 'JWMMD_20161001_20161031'") clear dsn(odbc_export) u(odbc_export) p(StataExport!!)

********************************************************************************
********************* ***** *** CONFIGURATION *** ***** ************************
********************************************************************************
*use "/Users/jomelpatulot/Desktop/JWMMD/JWMMD 2016/JWMMD 2016_10/Dta/JWMMD 2016_10_RAW_final.dta", clear
*use "/Users/jomelpatulot/Desktop/JWMMD/JWMMD 2016/JWMMD 2016_10/Dta/JWMMD 2016_10_RAW_final2.dta", clear
use "/Users/Grejell/Desktop/Data Analysis/JWMMD/Reports/Data/JWMMD 2016_10_RAW_final5.dta", clear

decode code_outlet , gen(code_outlet_)


drop code_outlet  
rename code_outlet_ code_outlet


gen amount_new = amount
drop amount

keep row_hash_pk excluded code_outlet code_topic code_type excluded_package amount_new
rename amount_new amount

odbc insert, dsn("odbc_export") table("JWMMD_20161001_20161031") create u(odbc_export) p(StataExport!!) 
odbc load, exec ("exec sp_generate_Dashboard 'JWMMD_20161001_20161031', ''") sqlshow lowercase clear dsn(odbc_export) u(odbc_export) p(StataExport!!)
