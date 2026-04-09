/*

Queries used for Tableau Project

*/
select * from nishantdb.coviddeathsnew


-- 1. 

SELECT
    SUM(CAST(new_cases AS SIGNED)) AS total_cases, 
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, 
    (SUM(CAST(new_deaths AS SIGNED)) * 100.0 / NULLIF(SUM(CAST(new_cases AS SIGNED)), 0)) AS DeathPercentage
FROM nishantdb.coviddeathsnew
WHERE continent IS NOT NULL
AND iso_code NOT LIKE 'OWID%';

-- 2. 

-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

SELECT 
    Location, 
    MAX(CAST(population AS SIGNED)) AS Population,
    MAX(CAST(total_cases AS SIGNED)) AS HighestInfectionCount,
    (MAX(CAST(total_cases AS SIGNED)) / MAX(CAST(population AS SIGNED))) * 100 AS PercentPopulationInfected
FROM nishantdb.coviddeathsnew
GROUP BY Location
ORDER BY PercentPopulationInfected DESC;


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From nishantdb.coviddeathsnew
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
