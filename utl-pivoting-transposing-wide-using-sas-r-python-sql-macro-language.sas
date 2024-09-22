%let pgm=utl-pivoting-transposing-wide-using-sas-r-python-sql-macro-language;

Pivoting transposing wider using r python and sas sql and macro variables

Closing the gap betwwen procedural languages like sas datastep, fortran, cobol .. and SQL
Sequential processing in SQL

Relational database expect a primary key

   CONTENTS

      1 Statement of problem
      2 4 sas techniques
      3 r and python
      4 easy case

Thanks Ted
tc <ted.j.conway@gmail.com>
https://support.sas.com/resources/papers/proceedings/pdfs/sgf2008/089-2008.pdf

github
https://tinyurl.com/bamkukjj
https://github.com/rogerjdeangelis/utl-pivoting-transposing-wide-using-sas-r-python-sql-macro-language

/*      _        _                            _           __                   _     _
/ | ___| |_ __ _| |_ ___ _ __ ___   ___ _ __ | |_   ___  / _|  _ __  _ __ ___ | |__ | | ___ _ __ ___
| |/ __| __/ _` | __/ _ \ `_ ` _ \ / _ \ `_ \| __| / _ \| |_  | `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |\__ \ || (_| | ||  __/ | | | | |  __/ | | | |_ | (_) |  _| | |_) | | | (_) | |_) | |  __/ | | | | |
|_||___/\__\__,_|\__\___|_| |_| |_|\___|_| |_|\__| \___/|_|   | .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
                                                              |_|
*/

*/
Note SQL is often faster than other languages due to built in parellization.

Data structure A cannot be easly pivoted using sql,
because a relational database expects a primary key.
Solving this problem leads to methods for sequential
processing in SQL, ie first.dot, last.dot, pivoting, moding,lagging ...

DATA STRUCTURE A  (CANNOT BE EASILY PIVIOTED)

   G1    VALS

    1     12
    1     37
    1     39
    2     48
    2     53
    3     27
    3     19
    3     19

Below are three technques to pivot the data structure above.
Also a Python and R technique are given.



Data Structure B e can be eqasily pivoted

DATA STRUCTURE B (EASILY PIVIOTED)


 TEAM    MEDAL     SCORE

  SP     bronze      5
  SP     gold        8
  SP     silver      7
  UK     gold        9
  UK     silver      7
  US     bronze      6
  US     gold        8
  US     silver      7

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

  TEAM    GOLD    SILVER    BRONZE

   SP       8        7         5
   UK       9        7         .
   US       8        7         6

/*___    _  _                     _            _           _
|___ \  | || |    ___  __ _ ___  | |_ ___  ___| |__  _ __ (_) __ _ _   _  ___  ___
  __) | | || |_  / __|/ _` / __| | __/ _ \/ __| `_ \| `_ \| |/ _` | | | |/ _ \/ __|
 / __/  |__   _| \__ \ (_| \__ \ | ||  __/ (__| | | | | | | | (_| | |_| |  __/\__ \
|_____|    |_|   |___/\__,_|___/  \__\___|\___|_| |_|_| |_|_|\__, |\__,_|\___||___/
 _                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/
data sd1.dups;
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

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  G1    VALS                                                                                                            */
/*                                                                                                                        */
/*   1     12                                                                                                             */
/*   1     37                                                                                                             */
/*   1     39                                                                                                             */
/*   2     48                                                                                                             */
/*   2     53                                                                                                             */
/*   3     27                                                                                                             */
/*   3     19                                                                                                             */
/*   3     19                                                                                                             */
/**************************************************************************************************************************/

%let seq=0;
proc sql;
create
    table tst as
SELECT
       g1
      ,tmp
      ,sum(case when seq = '1' then vals else . end) as val1
      ,sum(case when seq = '2' then vals else . end) as val2
      ,sum(case when seq = '0' then vals else . end) as val3
from
   (
     select
        g1
       ,vals
       ,resolve('%let seq=%sysfunc(mod(%eval(&seq+1),3));') as tmp
       ,symget('seq') as seq
     from
        sd1.dups
     group
        by g1
   )
group
   by g1
;quit;


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
   (select g1, vals, monotonic() as seq from sd1.dups)
group
   by g1
;quit;


proc sql;
create
    table tst as
SELECT
    g1
   ,sum(case when partition=1 then vals else . end) as val1
   ,sum(case when partition=2 then vals else . end) as val2
   ,sum(case when partition=3 then vals else . end) as val3
from
   %sqlpartition(sd1.dups,by=g1)
group
   by g1
;quit;

%let seq=0;
proc sql;
create
    table tst as
SELECT
       g1
      ,tmp
      ,sum(case when seq = '1' then vals else . end) as val1
      ,sum(case when seq = '2' then vals else . end) as val2
      ,sum(case when seq = '0' then vals else . end) as val3
from
   (
     select
        g1
       ,vals
       ,resolve('%let seq=%sysfunc(mod(%eval(&seq+1),3));') as tmp
       ,symget('seq') as seq
     from
        sd1.dups
     group
        by g1
   )
group
   by g1
;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  WORK.TST total obs=3 22SEP2024:16:29:53                                                                               */
/*                                                                                                                        */
/*  Obs    G1    TMP    VAL1    VAL2    VAL3                                                                              */
/*                                                                                                                        */
/*   1      1            12      37      39                                                                               */
/*   2      2            48      53       .                                                                               */
/*   3      3            19      19      27                                                                               */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____         ___                 _   _
|___ / _ __   ( _ )    _ __  _   _| |_| |__   ___  _ __
  |_ \| `__|  / _ \/\ | `_ \| | | | __| `_ \ / _ \| `_ \
 ___) | |    | (_>  < | |_) | |_| | |_| | | | (_) | | | |
|____/|_|     \___/\/ | .__/ \__, |\__|_| |_|\___/|_| |_|
                      |_|    |___/
*/

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
dups<-read_sas("d:/sd1/dups.sas7bdat")
want<-sqldf('
  select
       g1
      ,sum(case when partition = 1 then vals else null end) as val1
      ,sum(case when partition = 2 then vals else null end) as val2
      ,sum(case when partition = 3 then vals else null end) as val3
  from
      (select g1, vals, row_number() over (partition by g1) as partition from dups )
  group
      by g1
  order
      by g1
');
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="rwant"
     )
;;;;
%utl_rendx;


%utl_pybeginx;
parmcards4;
exec(open('c:/oto/fn_python.py').read())
dups, meta = ps.read_sas7bdat('d:/sd1/dups.sas7bdat')
want=pdsql('''
select
       g1
      ,sum(case when partition = 1 then vals else null end) as val1
      ,sum(case when partition = 2 then vals else null end) as val2
      ,sum(case when partition = 3 then vals else null end) as val3
from
      ( select g1, vals, row_number() over (partition by g1) as partition from dups )
group
      by g1
order
      by g1
   ''')
print(want)
fn_tosas9x(want,outlib='d:/sd1/',outdsn='pywant',timeest=3)
;;;;
%utl_pyendx;


proc print data=sd1.pywant;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*         R                      PYTHON                                                                                  */
/*                                                                                                                        */
/*  > want                                                                                                                */
/*    g1 val1 val2 val3         g1  val1  val2  val3                                                                      */
/*  1  1   12   37   39     0  1.0  12.0  37.0  39.0                                                                      */
/*  2  2   48   53   NA     1  2.0  48.0  53.0   NaN                                                                      */
/*  3  3   27   19   19     2  3.0  27.0  19.0  19.0                                                                      */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*  _
| || |     ___  __ _ ___ _   _    ___ __ _ ___  ___
| || |_   / _ \/ _` / __| | | |  / __/ _` / __|/ _ \
|__   _| |  __/ (_| \__ \ |_| | | (_| (_| \__ \  __/
   |_|    \___|\__,_|___/\__, |  \___\__,_|___/\___|
                         |___/
*/
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

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  TEAM    GOLD    SILVER    BRONZE                                                                                      */
/*                                                                                                                        */
/*   SP       8        7         5                                                                                        */
/*   UK       9        7         .                                                                                        */
/*   US       8        7         6                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
