-- DROP FUNCTION public.f_get_ddl_oid(text, text, json);

CREATE OR REPLACE FUNCTION public.f_get_ddl_oid(_sn text DEFAULT 'public'::text, _tn text DEFAULT ''::text, _opt json DEFAULT '{}'::json)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
 _oid text;
begin
  --********* QUERY **********
  SELECT c.oid INTO _oid
  FROM pg_catalog.pg_class c
       LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relname = _tn
    AND n.nspname = _sn
    AND pg_catalog.pg_table_is_visible(c.oid)
  ;
  return _oid;
end;
$function$
;
