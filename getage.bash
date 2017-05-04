#!/usr/bin/env bash
sed 's/_/ /' txt/subj_date.txt  | 
while read s d; do
  psql -h arnold.wpic.upmc.edu lncddb lncd -AF$'\t' -qtc  "select lunaid,ymd,age from visits_view where lunaid like '$s' and ymd like '$d'"

  if [ "$d" == 20151118 -a "$s" == 11462 ]; then
   # missing this subject b/c visit date is 2 days later
   # age will be under by ~ 2/365
   echo -e "11462\t20151116\t14.7104722792608"|sed 's/20151116/20151118/' 
  fi
done | tee txt/subj_date_age.txt

