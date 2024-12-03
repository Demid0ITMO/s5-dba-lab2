-- Все объекты созданные новым пользователем
select relname, spcname as tablespace
from pg_class
    left join pg_tablespace
        on pg_tablespace.oid = reltablespace
where
    relowner = (
    select oid
    from pg_roles
    where rolname = 'test'
    );

-- Все табличные пространства, содержащиеся в них объекты и бд, которые их используют
with db_tablespaces as (
    select t.spcname, d.datname
    from pg_tablespace t
             join pg_database d on d.dattablespace = t.oid
)
select
    t.spcname as Tablespace,
    COALESCE(string_agg(distinct c.relname, E'\n'), 'No objects') as Objects
from
    pg_tablespace t
        left join
    pg_class c on c.reltablespace = t.oid or (c.reltablespace = 0 and t.spcname = 'pg_default')
        left join
    db_tablespaces db on t.spcname = db.spcname
group by
    t.spcname
order by
    t.spcname;