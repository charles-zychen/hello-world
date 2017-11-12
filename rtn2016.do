clear
capture log close
set more off
cd "D:\copy\2016 Spring\RA_CKGSB\IRR Project\Value loss new"

use stockrtn.dta, clear
keep code year annumcumrtn
sort code year
by code: gen num=_n
by code: egen maxnum=max(num)
keep if maxnum==num
codebook code
drop num maxnum
save temp1.dta, replace

use mktcap.dta, clear
keep code year mktcap
replace mktcap=mktcap*10^8
sort code year
by code: gen num=_n
by code: egen maxnum=max(num)
keep if maxnum==num
codebook code
drop num maxnum
merge 1:1 code year using temp1.dta
drop _merge
save temp2.dta, replace

clear
import excel "irrmat_zhou.xlsx", sheet("Sheet1")
rename A code
rename B irr_z
save irrmat_zhou.dta, replace

use irrmat_micheal.dta, clear
rename irr irr_m
keep if year==2016
codebook code
drop year
merge 1:1 code using irrmat_zhou.dta
drop _merge
merge 1:1 code using temp2.dta
drop _merge
merge 1:1 code using ipoinfo.dta
keep if _merge==3
drop _merge ipoamount

merge 1:1 code using delistinfo.dta
drop _merge delistprice
replace delist=0 if delist==.
tab delist

drop if mktcap==.
keep if ipoyear<=2014
codebook code

save rtn2016.dta, replace
export excel using "stockrtn.xlsx", replace

erase temp1.dta
erase temp2.dta

clear
import excel "stkcfpanel.xlsx", sheet("Sheet1")
rename A code
rename B year
rename C cashinflow
rename D cashoutflow
rename E netcashflow
merge m:1 code using ipoinfo
keep if _merge==3
drop _merge ipoamount
keep if ipoyear<=2014
codebook code
export excel using "stkcfpanel_new.xlsx", replace

sort year code
by year: gen num=_n
by year: egen totalinflow=total(cashinflow)
by year: egen totaloutflow=total(cashoutflow)
by year: egen totalnetflow=total(netcashflow)
keep if num==1
keep year totalinflow totaloutflow totalnetflow
save mktcfpanel.dta, replace
export excel using "mktcfpanel.xlsx", replace

