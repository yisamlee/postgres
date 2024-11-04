-- DROP FUNCTION public.f_get_ddl_idx_tbl(text, text, json);

CREATE OR REPLACE FUNCTION public.f_get_ddl_idx_tbl(_sn text DEFAULT 'public'::text, _tn text DEFAULT ''::text, _opt json DEFAULT '{}'::json)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
 _oid bigint;
 _rtn text;
 _seq text;
 _t text;
 _r record;
begin
  select f_get_ddl_oid(_sn,_tn,_opt)::bigint into _oid;
  for _r in (
  --********* QUERY **********
  SELECT c2.relname, i.indisprimary, i.indisunique, i.indisclustered, i.indisvalid, pg_catalog.pg_get_indexdef(i.indexrelid, 0, true),
    pg_catalog.pg_get_constraintdef(con.oid, true), contype, condeferrable, condeferred, c2.reltablespace
    , conname
  FROM pg_catalog.pg_class c, pg_catalog.pg_class c2, pg_catalog.pg_index i
    LEFT JOIN pg_catalog.pg_constraint con ON (conrelid = i.indrelid AND conindid = i.indexrelid AND contype IN ('p','u','x'))
  WHERE c.oid = _oid AND c.oid = i.indrelid AND i.indexrelid = c2.oid
    --AND contype is null
  ORDER BY i.indisprimary DESC, i.indisunique DESC, c2.relname
  ) loop
    if _r.contype is null then
      _rtn := concat(_rtn,_r.pg_get_indexdef,';',chr(10));
    else
      _rtn := concat(_rtn,format('ALTER TABLE ONLY %I ADD CONSTRAINT %I ',_tn,_r.conname),_r.pg_get_constraintdef,';',chr(10));
    end if;
  end loop;

  return _rtn;
end;
$function$
;
