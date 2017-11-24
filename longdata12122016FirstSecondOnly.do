/*set more off
do D:\Silverstein\Summer Project\08202016\datacleaning01
do D:\Silverstein\Summer Project\08202016\datacleaning02
*/
/*In the former version, I made a mistake by identifying birth order after
deleting the obs who do not have children under 16. These people are those 
the first and the second child who have children under 16 instead of the first
and the second child in the family. I fixed it in this version.*/
set more off
use "H:\Silverstein\09112016\stata sets in process\datacleaning02.dta", clear
capture log close
log using "H:\Silverstein\FirstSecond\longdata10202016.log", replace

keep qno pmarri pnmall pnmchildren page pfemale plnincome plnremittance plngrandchexp pedu pagri phealth pADLIADL pagri pcaregivall first16 ///
second16 firstallboy firstnmboy secondallboy secondnmboy firstmixed secondmixed chage* chfemale* chagri* chmigrant* chmarri* chedu* chedu02* chyoungest* choldest* chnmchildren* chcaregiv* chlnremittance* ///
pnmson16 pnmdaughter16 death* x427* x428* x429* chabove16* x431* chdescribmarri* chlngrandchexp*

drop x431*02

*x4041-x4049 Gender of the children
reshape long death x427 x428 x429 x431 chmigrant chabove16 chfemale chagri ///
chmarri chedu chedu02 chyoungest choldest chage chnmchildren chcaregiv chdescribmarri chlngrandchexp chlnremittance,i(qno) j(m)

*Keep the valid observations by children's gender
count/*8100*/
order qno m chage
sort qno m
drop if chfemale==.
count/*3008*/

*Check whehter the children in the data set are ordered by their birth order. 
destring qno, gen(qno02)
list qno qno02 in 1/10 
count if qno02==qno02[_n+1] & chage<chage[_n+1] //8 observations
list qno02 chage m if qno02==qno02[_n+1] & chage<chage[_n+1]
list qno02 chage m if qno02==12144 | qno02==21546 | qno02==31319 | qno02==41112 | ///
qno02==41142 | qno02==41511 | qno02==41511 | qno02==51333, sepby(qno02)
*Yes, chidlren are orderd by their birth order. 

*Drop the observations who passed away
tab1 death x427 x428 x429 chmigrant chfemale chagri chmarri chedu chedu02 chyoungest choldest chnmchildren,m 
tab death,m 
drop if death==2
count /*2998*/
tab chyoungest,m 

***[The First Child and the Second Child]***************************************
*Restrict the sample to the children who have children aged 16 or below and who 
*are the first or the second child of the family. 
tab m,m
count if chyoungest<=16 /*1784*/
keep if chyoungest<=16 & (m==1 | m==2)
count /*916*/
*********************The Number of Children Under 16****************************
gen chunder16=.
sort qno m 
list m chnmchildren chyoungest choldest in 1/10
gen chbirthorder=m
tab chbirthorder m,m 
*1.Having only one child who is under 16. 
count if chnmchildren==1 /*472*/
replace chunder16=1 if chnmchildren==1 & chyoungest<=16
tab chunder16,m 
*2.Oldest child is under 16. 
count if choldest<=16 /*247*/
tab chnmchildren if choldest<=16
replace chunder16=chnmchildren if choldest<=16
tab chunder16,m
*3.Having two children, the younger children is 16 or below, and the older children is older than 16. 
replace chunder16=1 if chnmchildren==2 & chyoungest<=16 & choldest>16 & choldest~=. 
tab chunder16,m 
*4.Being the first or the second children. 
count if chunder16~=second16 & m==2
count if chunder16~=first16 & m==1
list chunder16 m qno chyoungest choldest chnmchildren first16  if chunder16~=first16  & m==1
list chunder16 m qno chyoungest choldest chnmchildren second16 if chunder16~=second16 & m==2

replace chunder16=first16  if m==1 & chunder16==. /*11*/
replace chunder16=second16 if m==2 & chunder16==. /*7*/
tab chunder16,m /*0 missing*/
count if chunder16~=first16   & m==1
count if chunder16~=second16  & m==2

*Check the wrong record. The respondent is supposed to have only one children aged 16. 
list chunder16 m qno chyoungest choldest chnmchildren first16  if chunder16~=first16  & m==1

****Allboys*********************************************************************
gen challboys=.
replace challboys=firstallboy  if m==1
replace challboys=secondallboy if m==2
tab challboys,m 
gen chnmboys=.
replace chnmboys=firstnmboy  if m==1
replace chnmboys=secondnmboy if m==2
tab chnmboys,m 
gen chmixed=.
replace chmixed= firstmixed if m==1
replace chmixed=secondmixed if m==2
tab chmixed,m 

tab chmixed challboys,m 
tab chmixed chnmboys,m 
tab chmixed chunder16,m

*******************Missing Values in Other Variables****************************
mark cgood if !mi(chmigrant,chagri,chmarri,chedu02,chcaregiv,chage,chunder16,chlnremittance,challboys,chfemale, ///
chlngrandchexp)
tab cgood,m 

local B chage chfemale chmarri chmigrant chedu chedu02 chyoungest chagri ///
chunder16 chnmchildren chdescribmarri chcaregiv chlngrandchexp chlnremittance
foreach i of local B {
tab `i',m 
}
count /*916*/

*************************Drop the Missing Values********************************
mark pgood if !mi(page,pfemale,pmarri,pedu,pagri,pcaregivall,plnincome, ///
pADLIADL,phealth)

tab pgood,m /*13 observations have missing values in one or more of the analytic variables. 30 of them have
missing values in the expenditure on grandchildren.*/

local A page page pfemale pmarri pedu pagri pcaregivall plnincome  ///
pADLIADL phealth plngrandchexp
foreach i of local A {
tab `i',m 
}
***************************
***************************                   
drop if pgood==0 /*13 observations deleted*/
***************************
***************************
count /*903*/

**************************
**************************
drop if cgood==0 /*33 observations deleted.*/
**************************
**************************
count/*870*/

save "H:\Silverstein\09112016\stata sets in process\RestrictModels.dta", replace
********************************************************************************

use "H:\Silverstein\09112016\stata sets in process\RestrictModels.dta", clear
capture log close
log using H:\Silverstein\FirstSecond\12122016TowPartModel\12122016.log, replace

cd "H:\Silverstein\FirstSecond\12122016TowPartModel"

***Generate a new variable indicating the birthorder of the children in the analytic sample:survivm***
bysort qno02: gen survivm=_n
bysort qno02: gen survivmtotal=_N
order qno02 m survivm survivmtotal


bysort qno02 (survivm): gen famnm=_n
bysort qno02 (survivm): gen famsize=_N


*****12122016*******Three binary variables and three two-way interactions*******
gen chmale=(chfemale==0)
tab chmale chfemale,m 
*First son (=1)
gen firstson=(chmale==1 & m==1)
bysort m: tab firstson chmale,m 
*Second son (=1)
gen secondson=(chmale==1 & m==2)
bysort m: tab secondson chmale,m 
*First daughter (=1)
gen firstdau=(chmale==0 & m==1)
bysort m: tab firstdau chmale,m 
*Second daughter (=1)
gen seconddau=(chmale==0 & m==2)
bysort m: tab seconddau chmale,m 



*The Chart 
gen genderbirth=.
*Oldest son
replace genderbirth=1 if firstson==1
*Oldest Daughter
replace genderbirth=2 if firstdau==1
*Other Son
replace genderbirth=3 if secondson==1
*Other Daughter
replace genderbirth=4 if seconddau==1
gen shouldbe1=firstson+firstdau+secondson+seconddau
tab shouldbe1,m 

*Two-part Model with robust standard error
*Raw value of money given to grandchildren
gen chgrandchexpraw=exp(chlngrandchexp)
replace chgrandchexpraw=0 if chgrandchexpraw==1
list chgrandchexpraw chlngrandchexp in 1/20

twopm chgrandchexpraw page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson i.secondson i.firstdau, firstpart(logit) secondpart(regress,log) cluster(qno02)
est store in1,title(Model1)

twopm chgrandchexpraw page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson i.secondson i.firstdau ///
i.challboys#i.firstson i.challboys#i.secondson i.challboys#i.firstdau,firstpart(logit) secondpart(regress,log) cluster(qno02)
est store in2,title(Model1)


esttab in1 in2


*************************************Test***************************************
********************************************************************************
********************************************************************************
*For Table 5, I am trying to massage the results to get p<.05 for the coefficient below. 
*An alternative assessment  recommended in the literature is to use a log likelihood 
*difference test between main effects and interaction models  (actually -2ll) 
*Another possibility is to compare “GC all sons” to the all other groups combined.  

*Take out pcargivall. Compare “GC all sons” to the all other groups combined.

twopm chgrandchexpraw page i.(pfemale pmarri pedu pagri) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson, firstpart(logit) secondpart(regress,log) cluster(qno02)
est store in1,title(Model1)

twopm chgrandchexpraw page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson ///
i.challboys#i.firstson ,firstpart(logit) secondpart(regress,log) cluster(qno02)
est store in2,title(Model1)

esttab in1 in2

*Take out pcargivall. referrence group first daughter. 
twopm chgrandchexpraw page i.(pfemale pmarri pedu pagri) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson i.secondson i.seconddau, firstpart(logit) secondpart(regress,log) cluster(qno02)
est store in1,title(Model1)

twopm chgrandchexpraw page i.(pfemale pmarri pedu pagri) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson i.secondson i.seconddau ///
i.challboys#i.firstson i.challboys#i.secondson i.challboys#i.seconddau,firstpart(logit) secondpart(regress,log) cluster(qno02)
est store in2,title(Model1)

esttab in1 in2


***********************************Effect Coding******************************
igenerate genderbirth,gen(genbir_E_) coding(effect) omit(4)
list genderbirth firstson secondson seconddau firstdau genbir_E_* in 1/50
igenerate challboys,gen(challboys_E_) coding(effect) omit(0)
list challboys challboys_E_* in 1/10
*Interaction Terms
tab firstson genbir_E_1,m
tab firstdau genbir_E_1,m
tab firstdau genbir_E_2,m
tab genderbirth,m 
tab secondson genbir_E_3,m 

gen chall_firson=challboys_E_2*genbir_E_1
gen chall_firdau=challboys_E_2*genbir_E_2
gen chall_secson=challboys_E_2*genbir_E_3

order challboys firstson firstdau secondson seconddau challboys_E_2 genbir_E_1 genbir_E_2 genbir_E_3 chall_firson chall_firdau chall_secson


twopm chgrandchexpraw page i.(pfemale pmarri pedu pagri) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance challboys_E_2 genbir_E_1 genbir_E_2 genbir_E_3 ///
chall_firson chall_firdau chall_secson,firstpart(logit) secondpart(regress,log) cluster(qno02)
est store in2,title(Model1)

esttab in1 in2
*Add new code
*add new pig









*Could you make a figure showing the predicted marginal probabilities for the 4*2 =8 
*combinations of gender/birth order categories by all boys (yes vs. no)? 
gen giveany=0
replace giveany=1 if chgrandchexpraw>0
list giveany chgrandchexp in 1/20

logit giveany page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys ib4.genderbirth ///
ib4.genderbirth#i.challboys,cluster(qno02)
est store in2,title(Model1)
margins ib4.genderbirth i.challboys ib4.genderbirth#i.challboys,atmeans


*Do some test for logit interactions. 
*M1
*margins
logit giveany page pfemale ///
chlnremittance i.challboys ib4.genderbirth ///
ib4.genderbirth#i.challboys
margins ib4.genderbirth i.challboys ib4.genderbirth#i.challboys,atmeans
*by hand
*M2
logit giveany page pfemale ///
chlnremittance challboys firstson secondson firstdau ///
dx1 dx2 dx3,cluster(qno02)

egen mpage=mean(page)
egen mpfemale=mean(pfemale)
egen mremit=mean(chlnremittance)
gen dx1=firstson*challboys
gen dx2=secondson*challboys
gen dx3=firstdau*challboys

*firstson allboys
dis _b[_cons]+_b[page]*mpage+_b[pfemale]*mpfemale+_b[chlnremittance]*mremit+_b[firstson]+_b[challboys]+_b[dx1]
dis exp(.10913425)/(1+exp(.10913425)) //0.527
*secondson allboys
dis _b[_cons]+_b[page]*mpage+_b[pfemale]*mpfemale+_b[chlnremittance]*mremit+_b[secondson]+_b[challboys]+_b[dx2]
dis exp(-.26792404)/(1+exp(-.26792404)) //0.433
*firstdau allboys
dis _b[_cons]+_b[page]*mpage+_b[pfemale]*mpfemale+_b[chlnremittance]*mremit+_b[firstdau]+_b[challboys]+_b[dx3]
dis exp(-.79131611)/(1+exp(-.79131611)) //0.312
*seconddau allboys
dis _b[_cons]+_b[page]*mpage+_b[pfemale]*mpfemale+_b[chlnremittance]*mremit+_b[challboys]
dis exp(-.57809346)/(1+exp(-.57809346)) //0.3594
*seconddau somegirls
dis _b[_cons]+_b[page]*mpage+_b[pfemale]*mpfemale+_b[chlnremittance]*mremit
dis exp(-.4957837)/(1+exp(-.4957837)) //0.3785

*********************The Margins worked!!!!





xtreg chlngrandchexp chmigrant chcaregiv chage dx,re
*care and migrant 00
dis _b[_cons]+_b[chage]*mage
*care and migrant 01
dis _b[_cons]+_b[chmigrant]+_b[chage]*mage
*care and migrant 10
dis _b[_cons]+_b[chcaregiv]+_b[chage]*mage
*care and migrant 11
dis _b[_cons]+_b[dx]+_b[chcaregiv]+_b[chmigrant]+_b[chage]*mage




esttab in1 in2 using 12122016FirstSecond.csv, b(2) not unstack compress noobs replace star(+ 0.1 * 0.05 ** 0.01 *** 0.001) nolz


*Test
reg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson i.secondson i.firstdau if chgrandchexpraw>0, cluster(qno02)



*********Two-Part Model*********************************************************
*The Chart 
gen genderbirth=.
*Oldest son
replace genderbirth=1 if oldestson==1
*Oldest Daughter
replace genderbirth=2 if oldestdau==1
*Other Son
replace genderbirth=3 if otherson==1
*Other Daughter
replace genderbirth=4 if otherdau==1
local B oldestson oldestdau otherson otherdau
foreach i of local B {
tab genderbirth `i',m
}
*Two-part Model with robust standard error
*Raw value of money given to grandchildren
gen chgrandchexpraw=exp(chlngrandchexp)
replace chgrandchexpraw=0 if chgrandchexpraw==1
list chgrandchexpraw chlngrandchexp in 1/20

************
************
************


bysort qno02 (m): gen famnm=_n
bysort qno02 (m): gen famsize=_N
*We just look at one observation for each of the families. 
xtset qno02 famnm



capture log close
log using 10282016.log, replace
xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson i.secondson i.firstdau,re
est store in1,title(Model1)

xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.firstson i.secondson i.firstdau ///
i.challboys#i.firstson i.challboys#i.secondson i.challboys#i.firstdau,re
est store in2,title(Model1)
esttab in1 in2 using 11042016FirstSecond.csv, b(2) not unstack compress noobs replace star(+ 0.1 * 0.05 ** 0.01 *** 0.001) nolz

/*
**********************************Back-ups***************************************
*GLS Models. 
*Dealing with the paternal grandchildren: Drop the number of sons, the number of daughters, and the number of maternal grandchildren. 
recode chnmboys (1 2 3=1), gen(chsomeboys)

*****10182016******change the reference group to maternal some girls.***********

gen chmale=(chfemale==0)
tab chmale chfemale,m 

*00 maternal & some girl  11 paternal & all boys
xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome plnremittance ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.chmale,re
est store in1,title(Model1)

xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome plnremittance ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.chmale i.challboys#i.chmale,re
est store in2,title(Model2)
*margins challboys chmale challboys#chmale, atmeans

*Allgirls  00=maternal,no boys. 11=paternal, some boys
xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome plnremittance ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.chsomeboys i.chmale,re
est store in3,title(Model3)
*margins i.chsomeboys i.chmale i.chsomeboys#i.chmale, atmeans

xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome plnremittance ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.chsomeboys i.chmale i.chsomeboys#i.chmale,re
est store in4,title(Model4)
esttab in1 in2 in3 in4 using 10112016_4.csv, not unstack compress noobs replace

*****10192016*******************************************************************
*Birth Order
recode m (2=0), gen(chfirstch)
tab chfirstch m,m  
xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome plnremittance ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.chmale i.chfirstch,re
est store in1,title(Model1)

xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome plnremittance ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.chmale i.chfirstch i.challboys#i.chfirstch,re
est store in2,title(Model1)
esttab in1 in2 using 10202016_4.csv, not unstack compress noobs replace

****10202016***********Three-way Interaction**********************************************
*Take out financial support from all the children at the parent's level
xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.chmale i.chfirstch,re
est store in1,title(Model1)
*margins i.challboys i.chmale i.chfirstch, atmeans
xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.chmale i.chfirstch i.challboys#i.chfirstch#i.chmale,re
est store in2,title(Model1)
*margins i.challboys i.chmale i.chfirstch i.challboys#i.chfirstch#i.chmale, atmeans
esttab in1 in2 using 10202016_4.csv, b p replace wide noparentheses 

****10242016*******All boys, mixed boys and girls, ref(all girls)***************

tab chmale chmixed,m
gen chmixedbg=(chmixed==2)
gen challgirls=(chmixed==3)
tab challboys chmixed,m
tab challgirls chmixed,m
tab chmixedbg chmixed,m

xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.chmixedbg i.firstson i.secondson i.firstdau,re
est store in1,title(Model1)

xtreg chlngrandchexp page i.(pfemale pmarri pedu pagri pcaregivall) plnincome ///
pADLIADL phealth i.chmigrant chagri chmarri chedu02 i.chcaregiv ///
chage chunder16 chlnremittance i.challboys i.chmixedbg i.firstson i.secondson i.firstdau ///
i.firstson#i.challboys i.secondson#i.challboys i.firstdau#i.challboys i.firstson#i.chmixedbg i.secondson#i.chmixedbg i.firstdau#i.chmixedbg,re
est store in2,title(Model1)
esttab in1 in2 using 10252016_2.csv, b(2) not unstack compress noobs replace star(+ 0.1 * 0.05 ** 0.01 *** 0.001) nolz





















