\pset pager off

show temp_tablespaces;
create schema library;

create table library.authors (
    author_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    birth_date date
);

create table library.books (
    book_id serial primary key,
    title varchar(100),
    author_id integer references library.authors(author_id),
    publication_year integer,
    genre varchar(50)
);

create table library.readers (
    reader_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    registration_date date
);

create temp table temp_book_loans (
    loan_id serial primary key,
    book_id integer,
    reader_id integer,
    loan_date date,
    return_date date
);

create temp table temp_book_statistics (
    book_id integer,
    times_loaned integer
);

insert into library.authors (first_name, last_name, birth_date)
values
    ('Лев', 'Толстой', '1828-09-09'),
    ('Федор', 'Достоевский', '1821-11-11'),
    ('Антон', 'Чехов', '1860-01-29'),
    ('Марина', 'Цветаева', '1892-10-26'),
    ('Александр', 'Пушкин', '1799-06-06');

insert into library.books (title, author_id, publication_year, genre)
values
    ('Война и мир', 1, 1869, 'Роман'),
    ('Преступление и наказание', 2, 1866, 'Роман'),
    ('Человек в футляре', 3, 1898, 'Повесть'),
    ('Поэмы', 4, 1920, 'Поэзия'),
    ('Евгений Онегин', 5, 1833, 'Поэзия');

insert into library.readers (first_name, last_name, registration_date)
values
    ('Иван', 'Иванов', '2023-01-01'),
    ('Мария', 'Петрова', '2023-01-05'),
    ('Сергей', 'Сидоров', '2023-01-10'),
    ('Анна', 'Кузнецова', '2023-01-15'),
    ('Дмитрий', 'Смирнов', '2023-01-20');

insert into temp_book_loans (book_id, reader_id, loan_date, return_date)
values
    (1, 1, '2023-02-01', '2023-02-15'),
    (2, 2, '2023-02-02', '2023-02-16'),
    (3, 3, '2023-02-03', '2023-02-17'),
    (4, 4, '2023-02-04', '2023-02-18'),
    (5, 5, '2023-02-05', '2023-02-19');

insert into temp_book_statistics (book_id, times_loaned)
values
    (1, 5),
    (2, 3),
    (3, 2),
    (4, 4),
    (5, 6);

with db_tablespaces as (
    select t.spcname, d.datname
    from pg_tablespace t
        join pg_database d on d.dattablespace = t.oid
)
select
    t.spcname as Tablespace,
    COALESCE(string_agg(distinct c.relname, E'\n'), 'No objects') as Objects,
    db.datname
from
    pg_tablespace t
        left join
    pg_class c on c.reltablespace = t.oid or (c.reltablespace = 0 and t.spcname = 'pg_default')
        left join
    db_tablespaces db on t.spcname = db.spcname
group by
    t.spcname, db.datname
order by
    t.spcname;