-- DROP FUNCTION correct_millennium_date(date);

CREATE OR REPLACE FUNCTION correct_millennium_date(input_date date)
 RETURNS date
 LANGUAGE plpgsql
AS $function$
DECLARE
    year_part INTEGER;
    corrected_year INTEGER;
    corrected_date DATE;
BEGIN
    -- Extract the year part from the date
    year_part := EXTRACT(YEAR FROM input_date::DATE);

    -- Determine the corrected year based on the century threshold
    IF year_part < 100 THEN
        -- Use a threshold to determine the century
        IF year_part <= 50 THEN
            -- Map to 2000s
            corrected_year := year_part + 2000;
        ELSE
            -- Map to 1900s
            corrected_year := year_part + 1900;
        END IF;
    ELSE
        -- No correction needed
        corrected_year := year_part;
    END IF;

    -- Construct the corrected date with the corrected year and the same month/day
    corrected_date := DATE 'epoch' + (corrected_year - 1970) * INTERVAL '1 year' 
                    + (EXTRACT(MONTH FROM input_date::DATE) - 1) * INTERVAL '1 month' 
                    + (EXTRACT(DAY FROM input_date::DATE) - 1) * INTERVAL '1 day';

    RETURN corrected_date;
END;
$function$
;
