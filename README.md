# Лабораторная работа 2, Вариант 438594 

### Соединение с узлом с пробросом портов для проверки подключения по TCP/IP: 
```shell
ssh -J s367522@helios.cs.ifmo.ru:2222 postgres0@pg179 -L 5433:localhost:9594
```
### Копирование файлов скриптов и конфигов на узел
```shell
scp -J s367522@helios.cs.ifmo.ru:2222 scripts/*_cluster.sh conf/p* postgres0@pg179:~/tmp
```
### Подключение после проброса портов и инициализации БД 
```shell
psql -h localhost -U test -p 5433 -d fakeblackmom
```

## Инициализация кластера БД

bash:
```shell
scp -J s367522@helios.cs.ifmo.ru:2222 scripts/*_cluster.sh conf/p* postgres0@pg179:~/tmp
ssh -J s367522@helios.cs.ifmo.ru:2222 postgres0@pg179 -L 5433:localhost:9594
./tmp/init_cluster.sh
```

init_cluster.sh:
```shell
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
```

## Наполнение базы

input_test_tables.sh:
```shell
dbs=('fakeblackmom' 'postgres')

for db in "${dbs[@]}";
do
  psql -h localhost -U test -p 5433 -d $db -f ./scripts/fill_tables.sql
done
```
**NOTE**: во втором терминале должна быть выполнена команда ```ssh -J s367522@helios.cs.ifmo.ru:2222 postgres0@pg179 -L 5433:localhost:9594```

## Конфигурация

pg_hba.conf:
```
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
host    all             all             0.0.0.0/0               reject
host    all             all             ::/0                    reject
```

postgresql.conf:
- [listen_addresses](https://postgrespro.ru/docs/postgresql/16/runtime-config-connection#GUC-LISTEN-ADDRESSES) = '*'
- [port](https://postgrespro.ru/docs/postgresql/16/runtime-config-connection#GUC-PORT) = 9594
- [log_destination](https://postgrespro.ru/docs/postgresql/16/runtime-config-logging#GUC-LOG-DESTINATION) = 'stderr'
- [logging_collector](https://postgrespro.ru/docs/postgresql/16/runtime-config-logging#GUC-LOGGING-COLLECTOR) = on
- [log_directory](https://postgrespro.ru/docs/postgresql/16/runtime-config-logging#GUC-LOG-DIRECTORY) = 'log'
- [log_min_messages](https://postgrespro.ru/docs/postgresql/16/runtime-config-logging#GUC-LOG-MIN-MESSAGES) = notice
- [log_connections](https://postgrespro.ru/docs/postgresql/16/runtime-config-logging#GUC-LOG-CONNECTIONS) = on
- [log_disconnections](https://postgrespro.ru/docs/postgresql/16/runtime-config-logging#GUC-LOG-DISCONNECTIONS) = on
- [log_filename](https://postgrespro.ru/docs/postgresql/16/runtime-config-logging#GUC-LOG-FILENAME) = 'postgresql-%Y-%m-%d_%H%M%S.log'
- [max_connections](https://postgrespro.ru/docs/postgresql/16/runtime-config-connection#GUC-MAX-CONNECTIONS) = 1500
- [max_prepared_transactions](https://postgrespro.ru/docs/postgresql/16/runtime-config-resource#GUC-MAX-PREPARED-TRANSACTIONS) = 1500
- [shared_buffers](https://postgrespro.ru/docs/postgresql/16/runtime-config-resource#GUC-SHARED-BUFFERS) = 2GB
- [temp_buffers](https://postgrespro.ru/docs/postgresql/16/runtime-config-resource#GUC-TEMP-BUFFERS) = 48MB
- [work_mem](https://postgrespro.ru/docs/postgresql/16/runtime-config-resource#GUC-WORK-MEM) = 48MB
- [checkpoint_timeout](https://postgrespro.ru/docs/postgresql/16/runtime-config-wal#GUC-CHECKPOINT-TIMEOUT) = 5min
- [effective_cache_size](https://postgrespro.ru/docs/postgresql/16/runtime-config-query#GUC-EFFECTIVE-CACHE-SIZE) = 2GB
- [fsync](https://postgrespro.ru/docs/postgresql/16/runtime-config-wal#GUC-FSYNC) = on
- [commit_delay](https://postgrespro.ru/docs/postgresql/16/runtime-config-wal#GUC-COMMIT-DELAY) = 50
- [temp_tablespaces](https://postgrespro.ru/docs/postgresql/16/runtime-config-client#GUC-TEMP-TABLESPACES) = 'qva60, swm74'
- [password_encryption](https://postgrespro.ru/docs/postgresql/16/runtime-config-connection#GUC-PASSWORD-ENCRYPTION) = md5

## Список всех табличных пространств кластера и содержащиеся в них объекты

Вывод выполнения [commands.sql](scripts/commands.sql)

```
        relname        | tablespace 
-----------------------+------------
 authors_author_id_seq | 
 authors_pkey          | 
 books_book_id_seq     | 
 books_pkey            | 
 authors               | 
 books                 | 
 readers_reader_id_seq | 
 readers               | 
 readers_pkey          | 
(9 строк)

```

```
 tablespace |                    objects                     
------------+------------------------------------------------
 pg_default | _pg_foreign_data_wrappers                     +
            | _pg_foreign_servers                           +
            | _pg_foreign_table_columns                     +
            | _pg_foreign_tables                            +
            | _pg_user_mappings                             +
            | administrable_role_authorizations             +
            | applicable_roles                              +
            | attributes                                    +
            | authors                                       +
            | authors_author_id_seq                         +
            | authors_pkey                                  +
            | books                                         +
            | books_book_id_seq                             +
            | books_pkey                                    +
            | character_sets                                +
            | check_constraint_routine_usage                +
            | check_constraints                             +
            | collation_character_set_applicability         +
            | collations                                    +
            | column_column_usage                           +
            | column_domain_usage                           +
            | column_options                                +
            | column_privileges                             +
            | column_udt_usage                              +
            | columns                                       +
            | constraint_column_usage                       +
            | constraint_table_usage                        +
            | data_type_privileges                          +
            | domain_constraints                            +
            | domain_udt_usage                              +
            | domains                                       +
            | element_types                                 +
            | enabled_roles                                 +
            | foreign_data_wrapper_options                  +
            | foreign_data_wrappers                         +
            | foreign_server_options                        +
            | foreign_servers                               +
            | foreign_table_options                         +
            | foreign_tables                                +
            | information_schema_catalog_name               +
            | key_column_usage                              +
            | parameters                                    +
            | pg_aggregate                                  +
            | pg_aggregate_fnoid_index                      +
            | pg_am                                         +
            | pg_am_name_index                              +
            | pg_am_oid_index                               +
            | pg_amop                                       +
            | pg_amop_fam_strat_index                       +
            | pg_amop_oid_index                             +
            | pg_amop_opr_fam_index                         +
            | pg_amproc                                     +
            | pg_amproc_fam_proc_index                      +
            | pg_amproc_oid_index                           +
            | pg_attrdef                                    +
            | pg_attrdef_adrelid_adnum_index                +
            | pg_attrdef_oid_index                          +
            | pg_attribute                                  +
            | pg_attribute_relid_attnam_index               +
            | pg_attribute_relid_attnum_index               +
            | pg_available_extension_versions               +
            | pg_available_extensions                       +
            | pg_backend_memory_contexts                    +
            | pg_cast                                       +
            | pg_cast_oid_index                             +
            | pg_cast_source_target_index                   +
            | pg_class                                      +
            | pg_class_oid_index                            +
            | pg_class_relname_nsp_index                    +
            | pg_class_tblspc_relfilenode_index             +
            | pg_collation                                  +
            | pg_collation_name_enc_nsp_index               +
            | pg_collation_oid_index                        +
            | pg_config                                     +
            | pg_constraint                                 +
            | pg_constraint_conname_nsp_index               +
            | pg_constraint_conparentid_index               +
            | pg_constraint_conrelid_contypid_conname_index +
            | pg_constraint_contypid_index                  +
            | pg_constraint_oid_index                       +
            | pg_conversion                                 +
            | pg_conversion_default_index                   +
            | pg_conversion_name_nsp_index                  +
            | pg_conversion_oid_index                       +
            | pg_cursors                                    +
            | pg_default_acl                                +
            | pg_default_acl_oid_index                      +
            | pg_default_acl_role_nsp_obj_index             +
            | pg_depend                                     +
            | pg_depend_depender_index                      +
            | pg_depend_reference_index                     +
            | pg_description                                +
            | pg_description_o_c_o_index                    +
            | pg_enum                                       +
            | pg_enum_oid_index                             +
            | pg_enum_typid_label_index                     +
            | pg_enum_typid_sortorder_index                 +
            | pg_event_trigger                              +
            | pg_event_trigger_evtname_index                +
            | pg_event_trigger_oid_index                    +
            | pg_extension                                  +
            | pg_extension_name_index                       +
            | pg_extension_oid_index                        +
            | pg_file_settings                              +
            | pg_foreign_data_wrapper                       +
            | pg_foreign_data_wrapper_name_index            +
            | pg_foreign_data_wrapper_oid_index             +
            | pg_foreign_server                             +
            | pg_foreign_server_name_index                  +
            | pg_foreign_server_oid_index                   +
            | pg_foreign_table                              +
            | pg_foreign_table_relid_index                  +
            | pg_group                                      +
            | pg_hba_file_rules                             +
            | pg_ident_file_mappings                        +
            | pg_index                                      +
            | pg_index_indexrelid_index                     +
            | pg_index_indrelid_index                       +
            | pg_indexes                                    +
            | pg_inherits                                   +
            | pg_inherits_parent_index                      +
            | pg_inherits_relid_seqno_index                 +
            | pg_init_privs                                 +
            | pg_init_privs_o_c_o_index                     +
            | pg_language                                   +
            | pg_language_name_index                        +
            | pg_language_oid_index                         +
            | pg_largeobject                                +
            | pg_largeobject_loid_pn_index                  +
            | pg_largeobject_metadata                       +
            | pg_largeobject_metadata_oid_index             +
            | pg_locks                                      +
            | pg_matviews                                   +
            | pg_namespace                                  +
            | pg_namespace_nspname_index                    +
            | pg_namespace_oid_index                        +
            | pg_opclass                                    +
            | pg_opclass_am_name_nsp_index                  +
            | pg_opclass_oid_index                          +
            | pg_operator                                   +
            | pg_operator_oid_index                         +
            | pg_operator_oprname_l_r_n_index               +
            | pg_opfamily                                   +
            | pg_opfamily_am_name_nsp_index                 +
            | pg_opfamily_oid_index                         +
            | pg_partitioned_table                          +
            | pg_partitioned_table_partrelid_index          +
            | pg_policies                                   +
            | pg_policy                                     +
            | pg_policy_oid_index                           +
            | pg_policy_polrelid_polname_index              +
            | pg_prepared_statements                        +
            | pg_prepared_xacts                             +
            | pg_proc                                       +
            | pg_proc_oid_index                             +
            | pg_proc_proname_args_nsp_index                +
            | pg_publication                                +
            | pg_publication_namespace                      +
            | pg_publication_namespace_oid_index            +
            | pg_publication_namespace_pnnspid_pnpubid_index+
            | pg_publication_oid_index                      +
            | pg_publication_pubname_index                  +
            | pg_publication_rel                            +
            | pg_publication_rel_oid_index                  +
            | pg_publication_rel_prpubid_index              +
            | pg_publication_rel_prrelid_prpubid_index      +
            | pg_publication_tables                         +
            | pg_range                                      +
            | pg_range_rngmultitypid_index                  +
            | pg_range_rngtypid_index                       +
            | pg_replication_origin_status                  +
            | pg_replication_slots                          +
            | pg_rewrite                                    +
            | pg_rewrite_oid_index                          +
            | pg_rewrite_rel_rulename_index                 +
            | pg_roles                                      +
            | pg_rules                                      +
            | pg_seclabel                                   +
            | pg_seclabel_object_index                      +
            | pg_seclabels                                  +
            | pg_sequence                                   +
            | pg_sequence_seqrelid_index                    +
            | pg_sequences                                  +
            | pg_settings                                   +
            | pg_shadow                                     +
            | pg_shmem_allocations                          +
            | pg_stat_activity                              +
            | pg_stat_all_indexes                           +
            | pg_stat_all_tables                            +
            | pg_stat_archiver                              +
            | pg_stat_bgwriter                              +
            | pg_stat_database                              +
            | pg_stat_database_conflicts                    +
            | pg_stat_gssapi                                +
            | pg_stat_io                                    +
            | pg_stat_progress_analyze                      +
            | pg_stat_progress_basebackup                   +
            | pg_stat_progress_cluster                      +
            | pg_stat_progress_copy                         +
            | pg_stat_progress_create_index                 +
            | pg_stat_progress_vacuum                       +
            | pg_stat_recovery_prefetch                     +
            | pg_stat_replication                           +
            | pg_stat_replication_slots                     +
            | pg_stat_slru                                  +
            | pg_stat_ssl                                   +
            | pg_stat_subscription                          +
            | pg_stat_subscription_stats                    +
            | pg_stat_sys_indexes                           +
            | pg_stat_sys_tables                            +
            | pg_stat_user_functions                        +
            | pg_stat_user_indexes                          +
            | pg_stat_user_tables                           +
            | pg_stat_wal                                   +
            | pg_stat_wal_receiver                          +
            | pg_stat_xact_all_tables                       +
            | pg_stat_xact_sys_tables                       +
            | pg_stat_xact_user_functions                   +
            | pg_stat_xact_user_tables                      +
            | pg_statio_all_indexes                         +
            | pg_statio_all_sequences                       +
            | pg_statio_all_tables                          +
            | pg_statio_sys_indexes                         +
            | pg_statio_sys_sequences                       +
            | pg_statio_sys_tables                          +
            | pg_statio_user_indexes                        +
            | pg_statio_user_sequences                      +
            | pg_statio_user_tables                         +
            | pg_statistic                                  +
            | pg_statistic_ext                              +
            | pg_statistic_ext_data                         +
            | pg_statistic_ext_data_stxoid_inh_index        +
            | pg_statistic_ext_name_index                   +
            | pg_statistic_ext_oid_index                    +
            | pg_statistic_ext_relid_index                  +
            | pg_statistic_relid_att_inh_index              +
            | pg_stats                                      +
            | pg_stats_ext                                  +
            | pg_stats_ext_exprs                            +
            | pg_subscription_rel                           +
            | pg_subscription_rel_srrelid_srsubid_index     +
            | pg_tables                                     +
            | pg_timezone_abbrevs                           +
            | pg_timezone_names                             +
            | pg_toast_1247                                 +
            | pg_toast_1247_index                           +
            | pg_toast_1255                                 +
            | pg_toast_1255_index                           +
            | pg_toast_13800                                +
            | pg_toast_13800_index                          +
            | pg_toast_13805                                +
            | pg_toast_13805_index                          +
            | pg_toast_13810                                +
            | pg_toast_13810_index                          +
            | pg_toast_13815                                +
            | pg_toast_13815_index                          +
            | pg_toast_1417                                 +
            | pg_toast_1417_index                           +
            | pg_toast_1418                                 +
            | pg_toast_1418_index                           +
            | pg_toast_2328                                 +
            | pg_toast_2328_index                           +
            | pg_toast_2600                                 +
            | pg_toast_2600_index                           +
            | pg_toast_2604                                 +
            | pg_toast_2604_index                           +
            | pg_toast_2606                                 +
            | pg_toast_2606_index                           +
            | pg_toast_2609                                 +
            | pg_toast_2609_index                           +
            | pg_toast_2612                                 +
            | pg_toast_2612_index                           +
            | pg_toast_2615                                 +
            | pg_toast_2615_index                           +
            | pg_toast_2618                                 +
            | pg_toast_2618_index                           +
            | pg_toast_2619                                 +
            | pg_toast_2619_index                           +
            | pg_toast_2620                                 +
            | pg_toast_2620_index                           +
            | pg_toast_3079                                 +
            | pg_toast_3079_index                           +
            | pg_toast_3118                                 +
            | pg_toast_3118_index                           +
            | pg_toast_3256                                 +
            | pg_toast_3256_index                           +
            | pg_toast_3350                                 +
            | pg_toast_3350_index                           +
            | pg_toast_3381                                 +
            | pg_toast_3381_index                           +
            | pg_toast_3394                                 +
            | pg_toast_3394_index                           +
            | pg_toast_3429                                 +
            | pg_toast_3429_index                           +
            | pg_toast_3456                                 +
            | pg_toast_3456_index                           +
            | pg_toast_3466                                 +
            | pg_toast_3466_index                           +
            | pg_toast_3596                                 +
            | pg_toast_3596_index                           +
            | pg_toast_3600                                 +
            | pg_toast_3600_index                           +
            | pg_toast_6106                                 +
            | pg_toast_6106_index                           +
            | pg_toast_826                                  +
            | pg_toast_826_index                            +
            | pg_transform                                  +
            | pg_transform_oid_index                        +
            | pg_transform_type_lang_index                  +
            | pg_trigger                                    +
            | pg_trigger_oid_index                          +
            | pg_trigger_tgconstraint_index                 +
            | pg_trigger_tgrelid_tgname_index               +
            | pg_ts_config                                  +
            | pg_ts_config_cfgname_index                    +
            | pg_ts_config_map                              +
            | pg_ts_config_map_index                        +
            | pg_ts_config_oid_index                        +
            | pg_ts_dict                                    +
            | pg_ts_dict_dictname_index                     +
            | pg_ts_dict_oid_index                          +
            | pg_ts_parser                                  +
            | pg_ts_parser_oid_index                        +
            | pg_ts_parser_prsname_index                    +
            | pg_ts_template                                +
            | pg_ts_template_oid_index                      +
            | pg_ts_template_tmplname_index                 +
            | pg_type                                       +
            | pg_type_oid_index                             +
            | pg_type_typname_nsp_index                     +
            | pg_user                                       +
            | pg_user_mapping                               +
            | pg_user_mapping_oid_index                     +
            | pg_user_mapping_user_server_index             +
            | pg_user_mappings                              +
            | pg_views                                      +
            | readers                                       +
            | readers_pkey                                  +
            | readers_reader_id_seq                         +
            | referential_constraints                       +
            | role_column_grants                            +
            | role_routine_grants                           +
            | role_table_grants                             +
            | role_udt_grants                               +
            | role_usage_grants                             +
            | routine_column_usage                          +
            | routine_privileges                            +
            | routine_routine_usage                         +
            | routine_sequence_usage                        +
            | routine_table_usage                           +
            | routines                                      +
            | schemata                                      +
            | sequences                                     +
            | sql_features                                  +
            | sql_implementation_info                       +
            | sql_parts                                     +
            | sql_sizing                                    +
            | table_constraints                             +
            | table_privileges                              +
            | tables                                        +
            | transforms                                    +
            | triggered_update_columns                      +
            | triggers                                      +
            | udt_privileges                                +
            | usage_privileges                              +
            | user_defined_types                            +
            | user_mapping_options                          +
            | user_mappings                                 +
            | view_column_usage                             +
            | view_routine_usage                            +
            | view_table_usage                              +
            | views
 pg_global  | pg_auth_members                               +
            | pg_auth_members_grantor_index                 +
            | pg_auth_members_member_role_index             +
            | pg_auth_members_oid_index                     +
            | pg_auth_members_role_member_index             +
            | pg_authid                                     +
            | pg_authid_oid_index                           +
            | pg_authid_rolname_index                       +
            | pg_database                                   +
            | pg_database_datname_index                     +
            | pg_database_oid_index                         +
            | pg_db_role_setting                            +
            | pg_db_role_setting_databaseid_rol_index       +
            | pg_parameter_acl                              +
            | pg_parameter_acl_oid_index                    +
            | pg_parameter_acl_parname_index                +
            | pg_replication_origin                         +
            | pg_replication_origin_roiident_index          +
            | pg_replication_origin_roname_index            +
            | pg_shdepend                                   +
            | pg_shdepend_depender_index                    +
            | pg_shdepend_reference_index                   +
            | pg_shdescription                              +
            | pg_shdescription_o_c_index                    +
            | pg_shseclabel                                 +
            | pg_shseclabel_object_index                    +
            | pg_subscription                               +
            | pg_subscription_oid_index                     +
            | pg_subscription_subname_index                 +
            | pg_tablespace                                 +
            | pg_tablespace_oid_index                       +
            | pg_tablespace_spcname_index                   +
            | pg_toast_1213                                 +
            | pg_toast_1213_index                           +
            | pg_toast_1260                                 +
            | pg_toast_1260_index                           +
            | pg_toast_1262                                 +
            | pg_toast_1262_index                           +
            | pg_toast_2396                                 +
            | pg_toast_2396_index                           +
            | pg_toast_2964                                 +
            | pg_toast_2964_index                           +
            | pg_toast_3592                                 +
            | pg_toast_3592_index                           +
            | pg_toast_6000                                 +
            | pg_toast_6000_index                           +
            | pg_toast_6100                                 +
            | pg_toast_6100_index                           +
            | pg_toast_6243                                 +
            | pg_toast_6243_index
 qva60      | No objects
 swm74      | No objects
(4 строки)

```