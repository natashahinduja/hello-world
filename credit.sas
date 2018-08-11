libname credit '/home/natashahnd970/credit';
/*importing data*/
proc import datafile = '/home/natashahnd970/credit/trainingch.csv'
 out = credit.trainingch
 dbms = CSV
 ;
run;

proc import datafile = '/home/natashahnd970/credit/testch.csv'
 out = credit.test
 dbms = CSV
 ;
run;
/*mean of target is 0.0668*/
proc means data=credit.trainingch;
	var seriousdlqin2yrs;
run;

/*data must be oversampled*/
data credit.over;
	set credit.trainingch;
	if seriousdlqin2yrs then output credit.over;
run;

/*10026 have value 1 for seriousdlqin2yrs*/

/*putting all rows that have seriousdlqin2yrs=0 in a dataset credit.over2*/
data credit.over2;
	set credit.trainingch;
	if seriousdlqin2yrs=0 then output credit.over2;
run;

/*selecting 20000 rows from credit.over2 to merge with credit.over, so mean of target will be 
0.33*/
data credit.over3;
	set credit.over2(obs=20000);
run;

/*concat the two datasets*/
data credit.trainover;
	set credit.over3 credit.over;
	by var1;
run;	

/*data is oversampled with mean of target being 0.3339106*/
proc means data=credit.trainover;
	var seriousdlqin2yrs;
run;


/*divide data into traing and test*/
proc surveyselect data=credit.trainover samprate=0.6 out=credit.train seed=6654 outall;
run;

data credit.trainingnew credit.testnew;
	set credit.train;
	if selected then output credit.trainingnew;
	else output credit.testnew;
run;

/*missing value indicator variables*/
data credit.training1;
	set credit.trainingnew;
	array mi{*} mimonthlyincome midependents;
	array var{*} monthlyincome numberofdependents;
	do i=1 to dim(mi);
		mi{i}=(var{i}=.);
	end;
	drop i selected;
run;

/*median imputation */
proc stdize data=credit.training1 reponly method=median out=work.training;
	var numberofdependents monthlyincome;
run;

data credit.training;
	set work.training;
run;


/*imputing test data with median from training data*/

proc means data=credit.training median;
	var monthlyincome numberofdependents;
run;

data credit.testnew;
	set credit.testnew;
	if monthlyincome=. then monthlyincome=5083;
	if numberofdependents=. then numberofdependents=0;
run;
/*redundancy in variable detection*/
ods output clusterquality=cluster
			rsquare(match_all)=ncl;
proc varclus data=credit.training maxeigen=0.7 hi;
	var revolvingutilizationofunsecuredl age numberofdependents MonthlyIncome
	NumberOfTime60_89DaysPastDueNotW NumberOfTimes90DaysLate NumberRealEstateLoansOrLines
	DebtRatio NumberOfTime30_59DaysPastDueNotW NumberOfOpenCreditLinesAndLoans mimonthlyincome
	midependents;
run;

data _null_;
	set cluster;
	call symput('nclval',compress(numberofclusters-1));
run;

proc print data=ncl&nclval;
run;
/*auc=0.699*/
proc logistic data=credit.training desc;
	model SeriousDlqin2yrs= age numberofdependents
	MonthlyIncome
	NumberOfTime60_89DaysPastDueNotW 
	NumberOfTimes90DaysLate
	NumberRealEstateLoansOrLines 
	NumberOfTime30_59DaysPastDueNotW 
	NumberOfOpenCreditLinesAndLoans
	DebtRatio
	RevolvingUtilizationOfUnsecuredL/
	selection=backward sls=0.001;
	score data=credit.testnew out=scored outroc=roc;
run;












