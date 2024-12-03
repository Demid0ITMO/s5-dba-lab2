export PGDATA=$HOME/hgv34
export WALDIR=$HOME/rrx19/pg_wal
export LANG=ru_RU.ISO8859-5
export MM_CHARSET=ISO_8859_5
export LC_ALL=ru_RU.ISO8859-5

mkdir -p $PGDATA $WALDIR
chmod 700 $WALDIR

initdb --waldir=$WALDIR

cp $HOME/tmp/postgresql.conf $PGDATA/postgresql.conf
cp $HOME/tmp/pg_hba.conf $PGDATA/pg_hba.conf

pg_ctl start

PG_TEMP_DIRS=("swm74" "qva60")
PORT=9594
new_db="fakeblackmom"
new_role="test"
new_role_password="test"

createdb -p $PORT -T template0 $new_db

psql -p $PORT -d $new_db -c "create user $new_role with password '$new_role_password';"

for dir in "${PG_TEMP_DIRS[@]}";
do
  mkdir -p "$HOME/$dir"
  psql -p $PORT -d postgres -c "create tablespace $dir location '$HOME/$dir';"
  psql -p $PORT -d postgres -c "grant create on tablespace $dir to $new_role;"
done

dbs=('fakeblackmom' 'postgres')

for db in "${dbs[@]}";
do
  psql -p $PORT -d $db -c "grant connect, create on database $db to $new_role;"
done
