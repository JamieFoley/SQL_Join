SELECT worldcities.country,
	gdp,
	(emissions/land_area) AS emissions_per_sqkm 
FROM world_data_2023
LEFT JOIN worldcities
ON worldcities.iso2 = world_data_2023.abbreviation
WHERE capital IN ('primary')
AND emissions IS NOT NULL
GROUP BY worldcities.country,
	gdp,
	emissions_per_sqkm
ORDER BY emissions_per_sqkm;