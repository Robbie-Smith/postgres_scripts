CREATE OR REPLACE VIEW v_list_object_owners AS
(
select owner.objtype    AS object_type,
       owner.objowner   AS object_owner,
       owner.userid,
       owner.schemaname AS schema_name,
       owner.objname    as object_name
from (
-- Functions owned by the user

         select 'Function' AS object_type,
                pgu.usename,
                pgu.usesysid,
                nc.nspname,
                textin(regprocedureout(pproc.oid::regprocedure))
         from pg_proc pproc,
              pg_user pgu,
              pg_namespace nc
         where pproc.pronamespace = nc.oid and pproc.proowner = pgu.usesysid
         UNION ALL
-- Databases owned by the user
         select 'Database' AS object_type, pgu.usename, pgu.usesysid, null, pgd.datname
         from pg_database pgd,
              pg_user pgu
         where pgd.datdba = pgu.usesysid
         UNION ALL
-- Schemas owned by the user
         select 'Schema' AS object_type, pgu.usename, pgu.usesysid, null, pgn.nspname
         from pg_namespace pgn,
              pg_user pgu
         where pgn.nspowner = pgu.usesysid
         UNION ALL
-- Tables or Views owned by the user
         select case
                    when pgc.relkind = 'r' THEN 'Table'
                    when pgc.relkind = 'v' THEN 'View'
                    end AS object_type,
                pgu.usename,
                pgu.usesysid,
                nc.nspname,
                pgc.relname
         from pg_class pgc,
              pg_user pgu,
              pg_namespace nc
         where
             pgc.relnamespace = nc.oid and pgc.relkind in ('r', 'v') and
             pgu.usesysid = pgc.relowner) owner("objtype", "objowner", "userid", "schemaname", "objname")
    )
