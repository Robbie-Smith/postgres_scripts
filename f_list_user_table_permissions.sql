-- CREATE TABLE IF NOT EXISTS USER_PERMISSIONS
-- (
--     user_name  text,
--     object_type text,
--     can_use      boolean default null,
--     can_create   boolean default null,
--     can_select   boolean default null,
--     can_insert   boolean default null,
--     can_update   boolean default null,
--     can_delete   boolean default null
-- );

-- Requires the above table to be created
CREATE OR REPLACE FUNCTION public.list_user_table_permissions(IN user_name character varying)
  RETURNS SETOF user_permissions AS
$BODY$
SELECT
    u2.usename::text,
    pgt.tablename::text,
    null::bool,
    null::bool,
    has_table_privilege(u2.usename, CONCAT(pgt.schemaname, '.', pgt.tablename), 'SELECT') as can_select,
    has_table_privilege(u2.usename, CONCAT(pgt.schemaname, '.', pgt.tablename), 'INSERT') as can_insert,
    has_table_privilege(u2.usename, CONCAT(pgt.schemaname, '.', pgt.tablename), 'UPDATE') as can_update,
    has_table_privilege(u2.usename, CONCAT(pgt.schemaname, '.', pgt.tablename), 'DELETE') as can_delete
FROM pg_user as u2
cross join
pg_tables as pgt
WHERE pgt.tablename !~ '^pg_' and usename not in ('rdsrepladmin', 'rdsadmin')
    and u2.usename = list_user_table_permissions.user_name
$BODY$
LANGUAGE sql;
