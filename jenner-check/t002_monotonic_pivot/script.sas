/* Structure A pivot via SQL MONOTONIC() from
   utl-pivoting-transposing-wide-using-sas-r-python-sql-macro-language.sas
   Structure A has no primary key (duplicate g1 values), so a running
   sequence number is synthesized with the PROC SQL MONOTONIC() function
   and MOD(seq,3) buckets each group's values into three wide columns.
   Query verbatim from the repo (lines 162-175); the only change is the
   libref: the repo's sd1.dups is shipped here as WORK.dups so the block
   runs standalone. A PROC PRINT shows the pivoted result. */

data dups;
 input g1 vals;
cards4;
1 12
1 37
1 39
2 48
2 53
3 27
3 19
3 19
;;;;
run;quit;

%let seq=0;
proc sql;
create
    table want as
SELECT
    g1
   ,sum(case when mod(seq,3)=1 then vals else . end) as val1
   ,sum(case when mod(seq,3)=2 then vals else . end) as val2
   ,sum(case when mod(seq,3)=0 then vals else . end) as val3
from
   (select g1, vals, monotonic() as seq from dups)
group
   by g1
;quit;

proc print data=want noobs;
run;quit;
