/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * FROM coviddeaths
WHERE continent IS NOT NULL
order by 3,4;

SELECT * FROM covidvaccinations
WHERE continent IS NOT NULL;

-- Select Data that we are going to be starting with
SELECT location, date, total_cases, new_cases, total_deaths, population FROM coviddeaths
WHERE continent is not null 
order by 1,2;

-- Total Cases vs Total Deaths - Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage From coviddeaths
Where location like '%africa%'
and continent is not null 
order by 1,2;

-- Total Cases vs Population - Shows what percentage of population infected with Covid
Select location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected 
From coviddeaths
order by 1,2;


-- Create view including deathpercentge, and %populationInfected
DROP VIEW IF EXISTS covidStatsView;
CREATE VIEW covidStatsView AS 
SELECT location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage, (total_cases/population)*100 as PercentPopulationInfected
FROM coviddeaths;

SELECT * FROM covidStatsView;

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected 
FROM coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;


-- BREAKING THINGS DOWN BY CONTINENT - Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
where continent is not null 
order by 1,2;


-- Total Population vs Vaccinations -Shows Percentage of Population that has recieved at least one Covid Vaccine
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From coviddeaths d
Join covidvaccinations v
	On v.location = d.location
	and v.date = d.date
where d.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From coviddeaths d
Join covidvaccinations v
	On v.location = d.location
	and v.date = d.date
where d.continent is not null 
ORDER BY RollingPeopleVaccinated DESC
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table 
DROP TEMPORARY Table if exists PercentPopulationVaccinated;
Create TEMPORARY Table PercentPopulationVaccinated
(
	Continent text(255),
    Location  TEXT(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric
);


Insert into PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, S
From coviddeaths d
Join covidvaccinations v
	On v.location = d.location
	and v.date = d.date;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From coviddeaths d
Join covidvaccinations v
	On v.location = d.location
	and v.date = d.date
where d.continent is not null 