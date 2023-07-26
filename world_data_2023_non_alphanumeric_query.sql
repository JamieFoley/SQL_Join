SELECT country, capitalmajor_city, largest_city
FROM world_data_2023
WHERE country ~ '^.*[^A-Za-z0-9 .-].*$'
OR capitalmajor_city ~ '^.*[^A-Za-z0-9 .-].*$'
OR largest_city ~ '^.*[^A-Za-z0-9 .-].*$';