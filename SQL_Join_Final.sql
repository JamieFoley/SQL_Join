WITH ranked_capitals AS (
  SELECT
    wd.abbreviation,
    wc.country,
    city,
    ROW_NUMBER() OVER (PARTITION BY wc.country ORDER BY city) AS capital_rank
  FROM world_data_2023 wd
  INNER JOIN worldcities wc ON wd.abbreviation = wc.iso2
  WHERE capital = 'primary'
)
SELECT
  rc.country,
  MAX(rc.city) FILTER (WHERE rc.capital_rank = 1) AS first_capital,
  MAX(rc.city) FILTER (WHERE rc.capital_rank = 2) AS second_capital,
  CASE 
    WHEN wd.largest_city ~ '^[A-Za-z0-9 .-]*$'
    THEN wd.largest_city
    ELSE NULL
  END AS largest_city_filtered
FROM ranked_capitals rc
LEFT JOIN world_data_2023 wd ON rc.abbreviation = wd.abbreviation
GROUP BY rc.country, wd.largest_city;
