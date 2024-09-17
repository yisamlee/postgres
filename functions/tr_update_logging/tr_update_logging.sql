CREATE OR REPLACE FUNCTION api.tr_update_logging()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    old_json jsonb;
    new_json jsonb;
    old_values jsonb := '{}'::jsonb;
   	new_values jsonb := '{}'::jsonb;
   	changes jsonb := '{}'::jsonb;
    column_name text;
    key_count int;
BEGIN
    -- Convert OLD and NEW rows to JSONB
    old_json := to_jsonb(OLD) - 'log_text'; -- Exclude 'log_text' if needed
    new_json := to_jsonb(NEW) - 'log_text'; -- Exclude 'log_text' if needed

    -- Loop through each key (column name) in NEW JSON
    FOR column_name IN
        SELECT key
        FROM jsonb_each(new_json)
    LOOP
        -- Compare old and new values for the column
        IF new_json -> column_name IS DISTINCT FROM old_json -> column_name THEN
            -- Add the changed column and its new value to 'changes'
            old_values := jsonb_set(old_values, ARRAY[column_name], old_json -> column_name, true);
            new_values := jsonb_set(new_values, ARRAY[column_name], new_json -> column_name, true);
        END IF;
    END LOOP;
   	
   	changes := jsonb_set(changes,'{updated_on}',to_jsonb(now()),true);
   	changes := jsonb_set(changes,'{updated_by}',to_jsonb(current_user),true);
   	if new_values = '{}'::jsonb and current_user = 'postgres' then 
   		changes := jsonb_set(changes,'{new}',to_jsonb('clear log'::text),true);
   	elsif new_values = '{}'::jsonb and current_user != 'postgres' then
   		raise EXCEPTION 'Only admin can clear log';
--   		exit
   	else 
   		changes := jsonb_set(changes,'{new}',new_values,true);
   	end if;
   	changes := jsonb_set(changes,'{old}',old_values,true);

    -- Check if there are any keys in the changes JSON
    key_count := (SELECT COUNT(*) FROM jsonb_each(changes));

    -- If any columns have changed, update last_updated and updated_by, and append to log_text
    IF key_count > 0 THEN
        NEW.updated_on := now();
        NEW.updated_by := user; -- Assuming you want the current user
        
        -- Append the changes to log_text
        NEW.log_text := changes::json || NEW.log_text ;
    END IF;

    RETURN NEW;
END;
$function$
;
drop trigger if exists masterdata_hk_building_log on masterdata_hk.building;
create trigger __your_trigger_name__ before
insert
    or
update
    on
    __your_table__ for each row execute function api.tr_update_logging()


