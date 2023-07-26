SELECT worldcities.country,
	((emissions::money)::decimal/(land_area::money)::decimal) AS emissions_per_sqkm,
	gdp,
	RANK() OVER(ORDER BY GDP::money DESC) AS gdp_rank 
FROM world_data_2023
LEFT JOIN worldcities
ON worldcities.iso2 = world_data_2023.abbreviation
WHERE capital IN ('primary')
AND emissions IS NOT NULL
GROUP BY worldcities.country,
	gdp,
	emissions_per_sqkm
ORDER BY emissions_per_sqkm DESC;