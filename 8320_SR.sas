/*
 This file is auto-generated by the statrep package.
 Do not edit this file or your changes will be lost.
 Edit the LaTeX file instead.
 
 See the statrep package documentation and the file
 statrep.cfg for information on these settings.
 */
 
 
%include "./8320_SR_preamble.sas" /nosource;
/* Remove all output files. */
%cleandir(., tex, tex);
%cleandir(., png, png);
%cleandir(., lst, lst);


/* Start program with a null title. */
title;

%write(profile,store=class,type=graphic) 

%write(nlinpara,store=class,type=listing) 

%write(h5re11,store=class,type=listing) 

%write(h5re12,store=class,type=listing) 

%output(class)
libname da2 'C:\Users\psy6b\Desktop\8320 datasets';
ods graphics on;
options ls=70 ps=35;

/*To reading the data*/
data da2.h5q31;
   infile 'C:\Users\psy6b\Desktop\8320 datasets\ssttornado532001.dat';
   retain ss1-ss49;
   array ss{49} ss1-ss49;
   if _N_=1 then do;
      input ss1-ss49;
   end;
   loc+1;
   drop ss1-ss49;
   do t=1 to 49;
      sst=ss{t};
      input torn @;
      output;
   end;
run;
data da2.h5q32;
   infile 'C:\Users\psy6b\Desktop\8320 datasets\MOtornlatlon.dat';
   loc+1;
   input lat lon;
   run;
proc sql;
   create table da2.h5q3
   as select * from da2.h5q31 as a, da2.h5q32 as b
   where a.loc=b.loc;
   run;
quit;

/*Fitting different models*/
proc genmod data=da2.h5q3;
   class loc;
   model torn = sst sst*loc / dist=poisson link=log;
   output out=h5q3out1 resraw=Residual pred=Predicted lower=Lower
      upper=Upper;
run;
proc glimmix data=da2.h5q3 noitprint;
   class loc;
   model torn = sst sst*loc / dist=poisson link=log ddfm=betwithin
      solution;
   random intercept / subject=loc type=sp(exp)(lon lat);
   nloptions tech=newrap;
   covtest 'Random Int.' indep;
   output out=h5q3out2 pred(ilink)=predicted lcl(ilink)=lower
      ucl(ilink)=upper residual(ilink)=Residual;
run;
proc glimmix data=da2.h5q3 noitprint;
   class loc;
   model torn = sst sst*loc / dist=poisson link=log ddfm=betwithin
      solution;
   random sst / subject=loc type=sp(exp)(lon lat);
   nloptions tech=newrap;
   covtest 'Random Coef.' indep;
   output out=h5q3out3 pred(ilink)=predicted lcl(ilink)=lower
      ucl(ilink)=upper residual(ilink)=Residual;
run;
proc glimmix data=da2.h5q3 noitprint;
   class loc;
   model torn = sst sst*loc / dist=poisson link=log ddfm=betwithin
      solution;
   random intercept sst / subject=loc type=sp(exp)(lon lat);
   nloptions tech=newrap;
   covtest 'Random Int. & Coef.' indep;
   output out=h5q3out4 pred(ilink)=predicted lcl(ilink)=lower
      ucl(ilink)=upper residual(ilink)=Residual;
run;


/*Processing output*/
proc sort data=h5q3out1;
   by loc;
run;
data h5q3eval1;
   set h5q3out1;
   by loc;
   keep loc torn predicted residual lat lon;
   retain sumtorn sumpred sumres;
   if first.loc then do;
      sumtorn=0;
      sumpred=0;
      sumres=0;
   end;
   sumtorn+torn;
   sumpred+predicted;
   sumres+residual;
   if last.loc then do;
      torn=sumtorn;
      predicted=sumpred;
      residual=sumres;
      output;
   end;
run;
proc sort data=h5q3out2;
   by loc;
run;
data h5q3eval2;
   set h5q3out2;
   by loc;
   keep loc torn predicted residual lat lon;
   retain sumtorn sumpred sumres;
   if first.loc then do;
      sumtorn=0;
      sumpred=0;
      sumres=0;
   end;
   sumtorn+torn;
   sumpred+predicted;
   sumres+residual;
   if last.loc then do;
      torn=sumtorn;
      predicted=sumpred;
      residual=sumres;
      output;
   end;
run;
proc sort data=h5q3out3;
   by loc;
run;
data h5q3eval3;
   set h5q3out3;
   by loc;
   keep loc torn predicted residual lat lon;
   retain sumtorn sumpred sumres;
   if first.loc then do;
      sumtorn=0;
      sumpred=0;
      sumres=0;
   end;
   sumtorn+torn;
   sumpred+predicted;
   sumres+residual;
   if last.loc then do;
      torn=sumtorn;
      predicted=sumpred;
      residual=sumres;
      output;
   end;
run;
proc sort data=h5q3out4;
   by loc;
run;
data h5q3eval4;
   set h5q3out4;
   by loc;
   keep loc torn predicted residual lat lon;
   retain sumtorn sumpred sumres;
   if first.loc then do;
      sumtorn=0;
      sumpred=0;
      sumres=0;
   end;
   sumtorn+torn;
   sumpred+predicted;
   sumres+residual;
   if last.loc then do;
      torn=sumtorn;
      predicted=sumpred;
      residual=sumres;
      output;
   end;
run;
data h5q3eval;
   set h5q3eval1(in=a) h5q3eval2(in=b) h5q3eval3(in=c)
      h5q3eval4(in=d);
   length model $23;
   if a then do;
      model='Independent';
   end;
   if b then do;
      model='Random Int.';
   end;
   if c then do;
      model='Random Coef.';
   end;
   if d then do;
      model='Random Int. & Coef.';
   end;
   label torn='Actual Measurements';
run;



/*Evaluating models*/
proc sort data=h5q3eval;
   by torn;
run;
proc sgpanel data=h5q3eval noautolegend;
   panelby model/columns=2 rows=2 spacing=5;
   scatter x=torn y=predicted/ datalabel=loc;
   series x=torn y=torn;
   keyword "Observations" "Reference Line";
run;
proc sql;
   title 'Model Comparation';
   select model,sum(residual*residual) label='Model Type' as SSR
      label='Sum of Squared Residual'
   from h5q3eval
   group by model;
quit;

/*Plotting the profile*/
data panelplot2;
   set h5q3out2;
   length type $20;
   keep loc t type resp;
   t=t+1952;
   type='measurement';
   resp=torn;
   output;
   type='cluster-specific';
   resp=predicted;
   output;
   type='lower bound';
   resp=lower;
   output;
   type='upper bound';
   resp=upper;
   output;
   run;
proc sgpanel data=panelplot2;
   where loc le 4 and loc ge 1;
   panelby loc/rows=2 columns=2 spacing=5;
   vline t/response=resp group=type;
   colaxis fitpolicy=thin alternate;
   rowaxis alternate;
run;
proc sgpanel data=panelplot2;
   where loc le 8 and loc ge 5;
   panelby loc/rows=2 columns=2 spacing=5;
   vline t/response=resp group=type;
   colaxis fitpolicy=thin alternate;
   rowaxis alternate;
run;
proc sgpanel data=panelplot2;
   where loc le 12 and loc ge 9;
   panelby loc/rows=2 columns=2 spacing=5;
   vline t/response=resp group=type;
   colaxis fitpolicy=thin alternate;
   rowaxis alternate;
run;
proc sgpanel data=panelplot2;
   where loc le 16 and loc ge 13;
   panelby loc/rows=2 columns=2 spacing=5;
   vline t/response=resp group=type;
   colaxis fitpolicy=thin alternate;
   rowaxis alternate;
run;
proc sgpanel data=panelplot2;
   where loc le 20 and loc ge 17;
   panelby loc/rows=2 columns=2 spacing=5;
   vline t/response=resp group=type;
   colaxis fitpolicy=thin alternate;
   rowaxis alternate;
run;

%endoutput(class)

