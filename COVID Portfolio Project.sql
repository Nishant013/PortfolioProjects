/*Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select * from nishantdb.coviddeathsnew
where continent is not null
order by 3,4;

-- Selecting the Data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population 
from nishantdb.coviddeathsnew
where continent is not null
order by 1,2;


 -- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country   


select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Rate
from nishantdb.coviddeathsnew
where location like "%India%"
and continent is not null
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, total_cases,population,(total_cases/population)*100 as Population_Infected_Percent
from nishantdb.coviddeathsnew
where location like "%India%"
and continent is not null
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

Select Location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Population_Infected_Percent
From nishantdb.coviddeathsnew
where continent is not null
Group by Location, population
order by Population_Infected_Percent desc;

-- Countries with Highest Death Count per Population

Select Location, max(cast(total_deaths as signed)) as Highest_Death_Count
From nishantdb.coviddeathsnew
where location not in ("Asia","World","Europe","North America","European Union","South America","Africa")
group by Location
order by  Highest_Death_Count desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, max(cast(total_deaths as signed)) as Highest_Death_Count
From nishantdb.coviddeathsnew
where continent is not null
AND TRIM(continent) != ''
group by continent
order by  Highest_Death_Count desc;

-- GLOBAL NUMBERS

select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as signed)) as Total_Deaths, sum(cast(new_deaths as signed))/sum(new_cases) * 100 as DeathPercentage
from nishantdb.coviddeathsnew
where continent is not null
group by date
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From nishantdb.coviddeathsnew dea
Join nishantdb.covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *,(RollingPeopleVaccinated/population)*100 from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATE,
    Population BIGINT,
    New_vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);
INSERT INTO PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) 
        AS RollingPeopleVaccinated
FROM nishantdb.coviddeathsnew dea
JOIN nishantdb.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentVaccinated
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

percentpopulationvaccinatedCreate View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
From nishantdb.coviddeathsnew dea
Join nishantdb.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

select * from percentpopulationvaccinated;
