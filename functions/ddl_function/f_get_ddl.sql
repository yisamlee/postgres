-- DROP FUNCTION public.f_get_ddl(text, text, json);

CREATE OR REPLACE FUNCTION public.f_get_ddl(_sn text DEFAULT 'public'::text, _tn text DEFAULT ''::text, _opt json DEFAULT '{}'::json)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
 _c bigint;
 _n int := 0;
 _columns text;
 _comments text;
 _table_comments text;
 _indices_ddl text;
 _rtn text := '';
 _oid text;
 _seq text;
begin
  select f_get_ddl_oid(_sn,_tn,_opt) into _oid;
  select f_get_ddl_seq_tbl(_sn,_tn,_opt) into _seq;
  select pg_catalog.obj_description(_oid::bigint) into _table_comments;
  select f_get_ddl_idx_tbl(_sn,_tn,_opt) into _indices_ddl;
  -- 1. Get list of columns
  SELECT concat(
      chr(10)
    , string_agg(
      concat(
        chr(9)
        , format('%I',a.attname)
        , ' '
        , pg_catalog.format_type(a.atttypid, a.atttypmod)
        , ' '
        , (
          SELECT concat('DEFAULT ',substring(pg_catalog.pg_get_expr(d.adbin, d.adrelid) for 128))
          FROM pg_catalog.pg_attrdef d
          WHERE d.adrelid = a.attrelid AND d.adnum = a.attnum AND a.atthasdef
        )
        , case when attnotnull then ' NOT NULL' end
      )
      , concat(',',chr(10))
      ) over (order by attnum)
    )
    , string_agg('COMMENT ON COLUMN '||_tn||'.'||a.attname||$c$ IS '$c$||col_description(a.attrelid, a.attnum)||$c$';$c$,chr(10)) over (order by attnum)
  into _columns,_comments
  FROM pg_catalog.pg_attribute a
  join pg_class c on c.oid = a.attrelid
  join pg_namespace s on s.oid = c.relnamespace
  WHERE a.attnum > 0 AND NOT a.attisdropped
    AND nspname = _sn
    and relname = _tn
    order by 1 desc limit 1;

--   _rtn := '--Sequences DDL:'||_seq; --we want to skip this line when no comments => no concat
  _rtn := concat(format('CREATE TABLE %I.%I (',_sn,_tn),_columns,chr(10), ');');
--   _rtn := concat(_rtn,(chr(10)||chr(10)||'--Columns Comments:'||chr(10)||_comments));
--   _rtn := concat(_rtn,(chr(10)||chr(10)||'--Table Comments:'||chr(10)||case when _table_comments is not null then format($f$COMMENT ON TABLE %I is '%s';$f$,_tn,_table_comments) end));
--   _rtn := concat(_rtn,(chr(10)||chr(10)||'--Indexes DDL:'||chr(10)||_indices_ddl));

  return _rtn;
end;
$function$
;
