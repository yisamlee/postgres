# cul_initcap
It fixes some common abbreviations.

```
SELECT 
    public.cul_initcap(input_text) AS cul_initcap,
    initcap(input_text) AS standard_initcap
FROM (VALUES ('iii'),('i''ll'),('we''ve')) AS tbl(input_text);
```
![Alt text](image.png)

1. iii -> III (instead of Iii)
2. i'll -> I'll (instead of I'Ll')
3. we've -> We've (instead of We'Ve)