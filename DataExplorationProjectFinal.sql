SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVacciations
--ORDER BY 3,4

--Select the Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying in my country (Indonesia)
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths/total_cases AS int))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Indo%'
AND continent is NOT NULL
ORDER BY 1,2 
--Error Operand data type nvarchar is invalid for divide operator. 
--After fixing, no error

--fixing error
--update data type from nvarchar into float
EXEC sp_help CovidDeaths
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float
--------------------------------------------

--Looking at total cases vs population
--Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (CAST(total_cases/population AS int))*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'Indo%'
AND continent is NOT NULL
ORDER BY 1,2 

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Indo%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Indo%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest death count per population


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'Indo%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

--SELECT date, location, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE location like 'Indo%'
--WHERE continent is NOT NULL
--GROUP BY date, location
--ORDER BY 1,2 

----Error Warning: Null value is eliminated by an aggregate or other SET operation.
----How to fixing errror?


--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVacciations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacciations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


--  USE CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVacciations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVacciations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacciations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVacciations/population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVacciations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVacciations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacciations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVacciations/population)*100 as Percentage
FROM #PercentPopulationVaccinated
--Data not accurate 


-- Creating View to Store Data For Later Visualization

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVacciations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVacciations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3


SELECT *
FROM PercentPopulationVaccinated
