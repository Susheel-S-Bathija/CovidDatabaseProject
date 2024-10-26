--Create Database Covid19Data

--USE Covid19Data

-- Select the data we are using
Select * from dbo.CovidDeaths
Select * from dbo.covidvaccinations

Select cd.location, cd.date, cd.total_cases,cd.total_deaths,cd.population
from dbo.CovidDeaths cd
order by 1,2

--Total cases vs. total deaths in India
-- Show the likelihood of dying if covid is contracted
Select cd.location, cd.date, cd.total_cases,cd.total_deaths, Round((cd.total_deaths/cd.total_cases)*100,2) AS DeathPercentage
from dbo.CovidDeaths cd
Where cd.location like 'India'
order by 1,2

-- looking at total cases vs. population in India
Select cd.location, cd.date, cd.total_cases,cd.population, Round((cd.total_cases/cd.population)*100,2) AS PercentagePopulatedoinfected
from dbo.CovidDeaths cd
Where cd.location like 'India'
order by 1,2

-- Looking at countries with highest infection rates compared to population
Select cd.location,cd.population, MAX(cd.total_cases) as highest_infection_count, Round(MAX(cd.total_cases/cd.population)*100,2) AS Percentage_Population_infected
from dbo.CovidDeaths cd
Group by cd.location,cd.population
order by 4 Desc

-- Showing continent with highest death count per population
Select cd.location, MAX(cd.total_deaths) as Total_death_count
from dbo.CovidDeaths cd
Where cd.continent is null
Group by cd.location
order by 2 Desc

-- Showing countries with highest death count per population
Select cd.location, MAX(cd.total_deaths) as Total_death_count
from dbo.CovidDeaths cd
Where cd.continent is not null
Group by cd.location
order by 2 Desc

-- Global numbers 
-- Show the likelihood of dying if covid is contracted
Select SUM(cd.new_cases) as new_cases_total, Sum(new_deaths) as new_deaths_total, Round(sum(new_deaths)/sum(new_cases)*100,2) as Death_percentage
from dbo.CovidDeaths cd
Where cd.continent is not null
--Group by cd.date
order by 1,2

--Total populations vs. vaccinations
Select cd.continent,cd.location,cd.date,cd.population,
	cast(cv.new_vaccinations as int),sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date) as rolling_pop_vac
from dbo.CovidDeaths cd
join dbo.CovidVaccinations cv 
	on cd.location = cv.location 
	and cd.date=cv.date
Where cd.continent is not null
Order by 2,3

--Rolling vaccination percentage

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_pop_vac) AS (
    SELECT 
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        CAST(cv.new_vaccinations AS int) AS new_vaccinations,
        SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_pop_vac
    FROM 
        dbo.CovidDeaths cd
    JOIN 
        dbo.CovidVaccinations cv 
        ON cd.location = cv.location 
        AND cd.date = cv.date
    WHERE 
        cd.continent IS NOT NULL
)
Select *, round((rolling_pop_vac/population)*100,2) as rollingpercentage
From PopvsVac

