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

CREATE OR REPLACE FUNCTION public.list_user_schema_permissions(IN user_name character varying)
  RETURNS SETOF user_permissions AS
$BODY$
SELECT u2.usename::text,
       s2.nspname::text,
       has_schema_privilege(u2.usename, s2.nspname, 'USAGE') AS can_use,
       has_schema_privilege(u2.usename, s2.nspname, 'CREATE') AS can_create,
       null::bool,
    null::bool,
       null::bool,
    null::bool
FROM pg_user as u2
         cross join
     pg_catalog.pg_namespace as s2
         cross join
     pg_tables as pgt
WHERE
    s2.nspname !~ '^pg_' and u2.usename not in ('rdsrepladmin', 'rdsadmin') and u2.usename = list_user_schema_permissions.user_name
    GROUP BY u2.usename, s2.nspname, can_use, can_create
    ORDER BY s2.nspname
    ;
$BODY$
LANGUAGE sql;
