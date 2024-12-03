dbs=('fakeblackmom' 'postgres')

for db in "${dbs[@]}";
do
  psql -h localhost -U test -p 5433 -d $db -f /home/demid/Desktop/organisation/course3/db-administration/lab-2/scripts/fill_tables.sql
done
