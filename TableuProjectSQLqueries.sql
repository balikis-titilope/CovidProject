/* 
	Queries for Tableu Peojects
*/

-- 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
where continent is not null 
order by 1,2;

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From coviddeaths
-- Where continent is null 
WHERE location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- 4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
Group by Location, Population, date
order by PercentPopulationInfected desc;