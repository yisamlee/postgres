-- DROP FUNCTION public.f_get_ddl_seq_tbl(text, text, json);

CREATE OR REPLACE FUNCTION public.f_get_ddl_seq_tbl(_sn text DEFAULT 'public'::text, _tn text DEFAULT ''::text, _opt json DEFAULT '{}'::json)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
 _rtn text;
 _t text;
 _r record;
 _oid text;
begin
  select f_get_ddl_oid(_sn,_tn,_opt) into _oid;
  /*
  https://www.postgresql.org/docs/current/static/functions-info.html
  pg_get_serial_sequence(table_name, column_name) is the only pg_get_ f() using name instead of oid
  need additional format for "weird.relation.names"
  */
  for _r in (
    SELECT pg_get_serial_sequence(format('%I',_tn),a.attname) _seq
    FROM pg_catalog.pg_attribute a
    WHERE a.attrelid::text = _oid AND a.attnum > 0 AND NOT a.attisdropped
    and length(pg_get_serial_sequence(format('%I',_tn),a.attname)) > 1
    /*
    select pg_get_serial_sequence(format('%I',table_name),column_name) _seq
    from information_schema.columns
    where table_name = _tn--format('%I',_tn)
    and table_schema = _sn--format('%I',_sn)
    and length(pg_get_serial_sequence(format('%I',table_name),column_name)) > 1
    */
  ) loop
    begin
      EXECUTE FORMAT($f$
        SELECT concat(
          'CREATE SEQUENCE %s'
          , chr(10),chr(9), 'START WITH ', start_value
          , chr(10),chr(9), 'INCREMENT BY ', increment_by
          , chr(10),chr(9), 'MINVALUE ', min_value
          , chr(10),chr(9), 'MAXVALUE ', max_value
          , chr(10),chr(9), 'CACHE ', cache_value
          , chr(10),');',chr(10)
          )
        FROM %s$f$,_r._seq,_r._seq)
      into _t;
    exception
      when others
      then
        if _opt->>'handle exceptions' then
          --raise info '%',SQLERRM;
          _rtn := concat(chr(10),_rtn,'--',SQLSTATE,': ',SQLERRM);
        else
          raise exception '%',concat(SQLSTATE,': ',SQLERRM);
        end if;
    end;
    _rtn := concat(chr(10),_rtn,_t);
  end loop;
  return _rtn;
end;
$function$
;
