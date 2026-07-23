/* Structure B pivot (the "easy case") from
   utl-pivoting-transposing-wide-using-sas-r-python-sql-macro-language.sas
   Long medals table -> one row per team, one column per medal, via a
   conditional SUM(CASE WHEN ...) in PROC SQL. Data and query verbatim
   from the repo (lines 312-338). A PROC PRINT is added so the pivoted
   result appears in the listing. */

data medals;
 input team$ medal$ score;
cards4;
US  gold      8
US  silver    7
US  bronze    6
UK  gold      9
UK  silver    7
SP  gold      8
SP  silver    7
SP  bronze    5
;;;;
run;quit;

proc sql;
  create
     table want as
  select
      team
      ,sum(case when  medal='gold'   then score else . end) as gold
      ,sum(case when  medal='silver' then score else . end) as silver
      ,sum(case when  medal='bronze' then score else . end) as bronze
  from
      medals
   group
      by team
;quit;

proc print data=want noobs;
run;quit;
