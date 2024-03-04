CREATE
OR REPLACE FUNCTION public.cul_initcap(input_val text) RETURNS text LANGUAGE sql IMMUTABLE STRICT AS $ function $
SELECT
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    regexp_replace(
    regexp_replace(
        initcap($ 1),
    --  $$'(([MSTD]|Ve|Re|Ll))([^[:upper:][:lower:]]|$)$$, 
    --	$$'{@*#!\1!#*@}\3$$, 
        'g'
    '('')(([MSTD]|Ve|Re|Ll))',
    '\1{@*#!\2!#*@}',
    'g'
    ),
    '(\s?)(Ii|Iii|Iv|Vi|Ix)(?!\w)',
    '\1{@*#!\2!#*@}',
    'g'
    ),
    '{@*#!M!#*@}',
    'm'
    ),
    '{@*#!S!#*@}',
    's'
    ),
    '{@*#!T!#*@}',
    't'
    ),
    '{@*#!D!#*@}',
    'd'
    ),
    '{@*#!Ve!#*@}',
    've'
    ),
    '{@*#!Re!#*@}',
    're'
    ),
    '{@*#!Ll!#*@}',
    'll'
    ),
    '{@*#!Ii!#*@}',
    'II'
    ),
    '{@*#!Iii!#*@}',
    'III'
    ),
    '{@*#!Iv!#*@}',
    'IV'
    ),
    '{@*#!Vi!#*@}',
    'VI'
    ),
    '{@*#!Ix!#*@}',
    'IX'
    );

$ function $;