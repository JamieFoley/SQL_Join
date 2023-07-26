# SQL_Join

The SQL statements in this repository showcase my SQL skills using two tables, namely `world_data_2023` and `worldcities`. The CSV files for these tables can be found on Kaggle:
- [world_data_2023](https://www.kaggle.com/datasets/nelgiriyewithana/countries-of-the-world-2023)
- [worldcities](https://www.kaggle.com/datasets/juanmah/world-cities)

To import the data into my local PostgreSQL database, I have developed an [automatic CSV uploader script](https://github.com/JamieFoley/csv_text_cleaner).

## Identifying Missing Data

Initially, I planned to query the `world_data_2023` table directly. However, I noticed some encoding errors with certain non-Latin characters in `country`, `capitalmajor_city`, and `largest_city` columns in the `world_data_2023` table. To avoid potential issues when querying, I decided to investigate the rows containing missing data.

To achieve this, I ran the following query to get a closer look at the rows with non-Latin characters in the `country`, `capitalmajor_city`, and `largest_city` columns:

```sql
SELECT country, capitalmajor_city, largest_city
FROM world_data_2023
WHERE country ~ '^.*[^A-Za-z0-9 .-].*$'
OR capitalmajor_city ~ '^.*[^A-Za-z0-9 .-].*$'
OR largest_city ~ '^.*[^A-Za-z0-9 .-].*$';


```
This is the resulting table:
 
| country             | capitalmajor_city      | largest_city           |
|---------------------|------------------------|------------------------|
| Antigua and Barbuda | St. John's, Saint John | St. John's, Saint John |
| The Bahamas         | Nassau, Bahamas        | Nassau, Bahamas        |
| Brazil              | Bras���                | S����                  |
| Cameroon            | Yaound�                | Douala                 |
| Chad                | N'Djamena              | N'Djamena              |
| Colombia            | Bogot�                 | Bogot�                 |
| Comoros             | Moroni, Comoros        | Moroni, Comoros        |
| Costa Rica          | San Jos������          | San Jos������          |
| Cyprus              | Nicosia                | Statos�������          |
| Grenada             | St. George's, Grenada  | St. George's, Grenada  |
| Guyana              | Georgetown, Guyana     | Georgetown, Guyana     |
| Iceland             | Reykjav��              | Reykjav��              |
| Jamaica             | Kingston, Jamaica      | Kingston, Jamaica      |
| Lebanon             | Beirut                 | Tripoli, Lebanon       |
| Maldives            | Mal�                   | Mal�                   |
| Moldova             | Chi����                | Chi����                |
| Paraguay            | Asunci��               | Ciudad del Este        |
| S�����������        | S����                  | S����                  |
| Seychelles          | Victoria, Seychelles   | Victoria, Seychelles   |
| Sweden              | Stockholm              | S�����                 |
| Switzerland         | Bern                   | Z���                   |
| Togo                | Lom�                   | Lom�                   |
| Tonga               | Nuku����               | Nuku����               |
| United States       | Washington, D.C.       | New York City          |

## Populating Missing Data with Joins
To address the missing data, I decided to join the world_data_2023 table with another table containing an extensive list of world cities `worldcities`. `abbreviation` and `iso2`, which represent the country code, are identical, and will be used to join the tables to eachother.

By leveraging Common Table Expressions (CTEs) and window functions, I populated the `capitalmajor_city` and `largest_city` columns. The use of CTEs allowed me to efficiently filter out duplicate results for countries with more than one capital.

Here's the query to populate the columns:

```sql
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

```

This is the resulting table (limited to the first 20 rows):

| country             | first_capital    | second_capital | largest_city_filtered   |
|---------------------|------------------|----------------|-------------------------|
| Afghanistan         | Kabul            | NULL           | Kabul                   |
| Albania             | Tirana           | NULL           | Tirana                  |
| Algeria             | Algiers          | NULL           | Algiers                 |
| Andorra             | Andorra la Vella | NULL           | Andorra la Vella        |
| Angola              | Luanda           | NULL           | Luanda                  |
| Antigua and Barbuda | Saint John's     | NULL           | NULL                    |
| Argentina           | Buenos Aires     | NULL           | Buenos Aires            |
| Armenia             | Yerevan          | NULL           | Yerevan                 |
| Australia           | Canberra         | NULL           | Sydney                  |
| Austria             | Vienna           | NULL           | Vienna                  |
| Azerbaijan          | Baku             | NULL           | Baku                    |
| Bahrain             | Manama           | NULL           | Riffa                   |
| Bangladesh          | Dhaka            | NULL           | Dhaka                   |
| Barbados            | Bridgetown       | NULL           | Bridgetown              |
| Belarus             | Minsk            | NULL           | Minsk                   |
| Belgium             | Brussels         | NULL           | Brussels                |
| Belize              | Belmopan         | NULL           | Belize City             |
| Benin               | Cotonou          | Porto-Novo     | Cotonou                 |
| Bhutan              | Thimphu          | NULL           | Thimphu                 |
| Bolivia             | La Paz           | Sucre          | Santa Cruz de la Sierra |

## Result

The result of the above query provides a clean and easy-to-query table with one row per country. For countries with multiple capital cities, the first_capital and second_capital columns allow easy identification of the capitals. Only a few entries in the largest_city column containing special characters were filtered out, amounting to approximately 12 rows. I plan to manually re-enter this lost data due to its small quantity.

With these SQL statements, I have successfully handled missing data and created a structured and organized dataset.

