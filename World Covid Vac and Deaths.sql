SELECT * 
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVacc$
--ORDER BY 3,4

--Selecting the data I am using!

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2 

-- Taking a look at Total Cases VS Total Deaths
-- Your chances of dying if you fall victim to covid, in your country.


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
and continent is not null
ORDER BY location, date 


--Total Cases VS Population
--What percntage of population got Covid?

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentofPOP_Infected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
ORDER BY location, date 


--Countries with Highest Infection Rates vs Their Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS PercentPOP_Infected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population 
ORDER BY PercentPOP_Infected DESC


--Highest Death count per Population based on Country
--Check cast USAGE! Wrong, data type need to convert...
-- Check MAX AS WELL

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount DESC

--More Continent Focused!

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing Continent with Highest Death Count Per Population (Same as Above)

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Scale!
--Total cases, deaths, & Death Percentage Globally By DATES

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY date 

--Total cases, deaths, & Death Percentage Globally OVERALL
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY total_cases

--Total POP vs Vaccinations

SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as int)) OVER 
(Partition by death.location ORDER BY death.location, death.date) as Vaccinated_BY_Day
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVacc$ vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null
ORDER BY 1, 2


-- CTE USAGE

WITH POPvsVAC (continent, location, Date, population, new_vaccinations, Vaccinated_BY_Day)
as
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as int)) OVER 
(Partition by death.location ORDER BY death.location, death.date) as Vaccinated_BY_Day
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVacc$ vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null
)
SELECT *, (Vaccinated_BY_Day/population) * 100
FROM POPvsVAC


-- TEMP TABLE
--Using CONVERT TOO w/ bigint

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Vaccinated_BY_Day numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER 
(Partition by death.location ORDER BY death.location, death.date) as Vaccinated_BY_Day
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVacc$ vacc
	ON death.location = vacc.location
	and death.date = vacc.date
--WHERE death.continent is not null
SELECT *, (Vaccinated_BY_Day/population)*100
FROM #PercentPopulationVaccinated

--Creating a VIEW for TABLEU!?

CREATE VIEW PercentPopulationVaccinations as 
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(CONVERT(bigint,vacc.new_vaccinations)) OVER 
(Partition by death.location ORDER BY death.location, death.date) as Vaccinated_BY_Day
FROM PortfolioProject..CovidDeaths$ death
JOIN PortfolioProject..CovidVacc$ vacc
	ON death.location = vacc.location
	and death.date = vacc.date
WHERE death.continent is not null