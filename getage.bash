#!/usr/bin/env bash
sed 's/_/ /' txt/subj_date.txt  | while read s d; do psql -h arnold.wpic.upmc.edu lncddb lncd -AF$'\t' -qtc  "select lunaid,ymd,age from visits_view where lunaid like '$s' and ymd like '$d'";  done | tee txt/subj_date_age.txt
