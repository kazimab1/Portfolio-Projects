--Previewing the CovidDeath Table
SELECT *
FROM PortfolioProjects..CovidDeaths$
ORDER BY 3,4

--Previewing the CovidVaccination Table
SELECT *
FROM PortfolioProjects..CovidVaccinations$
ORDER BY 3,4

--Merging Covid Death and Covid Vaccination Tables
SELECT *
FROM PortfolioProjects..CovidDeaths$ as D
JOIN PortfolioProjects..CovidVaccinations$ as V	
	ON D.location = V.location
	AND D.date = V.date

--Viewing Specific Data from CovidDeaths
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths$
ORDER BY 1,2

--Percentage of death rate in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProjects..CovidDeaths$
ORDER BY 1,2

--Percentage of death rate in USA
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProjects..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1,2

--Percentage of catching covid in USA
SELECT Location, date, total_cases, population, (total_cases/population)*100 as CovidRate
FROM PortfolioProjects..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1,2

--Where the highest chance of catching Covid is in descending order
SELECT Location,population,MAX(total_cases) as HighestCase, MAX((total_cases/population))*100 as CovidRate
FROM PortfolioProjects..CovidDeaths$
GROUP BY Location, population
ORDER BY CovidRate Desc

--Which locations have the highest deaths
SELECT Location,MAX(cast(Total_deaths as int)) as HighestDeaths
FROM PortfolioProjects..CovidDeaths$
GROUP BY Location
ORDER BY HighestDeaths Desc

--Which Continents have the highest deaths
SELECT location,MAX(cast(Total_deaths as int)) as HighestDeaths
FROM PortfolioProjects..CovidDeaths$
WHERE continent is NULL AND location != 'World'
GROUP BY location
ORDER BY HighestDeaths Desc

--Daily Cases, Deaths and death percentage per day 
SELECT date, SUM(new_cases) as CasesToday, SUM(cast(new_deaths as int)) as DeathToday, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$
Where continent is not NULL
GROUP BY date
ORDER BY 1,2

--Total Cases, Deaths and Death Percentage in the World till day
SELECT SUM(new_cases) as CasesTillToday, SUM(cast(new_deaths as int)) as DeathTillToday, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as OverallDeathPercentage
FROM PortfolioProjects..CovidDeaths$
Where continent is not NULL
ORDER BY 1,2

--VACCINATIONS
--New Vaccinations Per Day for locations ordered by date
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
FROM PortfolioProjects..CovidDeaths$ as D
JOIN PortfolioProjects..CovidVaccinations$ as V	
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent is not NULL AND V.new_vaccinations is not NULL
ORDER BY D.date

--Total number of people vaccinated according to the date
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.location Order by D.location,D.date) as VaccinationsToDate
FROM PortfolioProjects..CovidDeaths$ as D
JOIN PortfolioProjects..CovidVaccinations$ as V	
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent is not NULL AND V.new_vaccinations is not NULL
ORDER BY 2,3

--Using CTE
--Vaccinated Percentage Per day according to the date
With VaccinatedPopulation (continent,location,date,population,new_vaccinations,VaccinationsToDate)
as
(SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.location Order by D.location,D.date) as VaccinationsToDate
FROM PortfolioProjects..CovidDeaths$ as D
JOIN PortfolioProjects..CovidVaccinations$ as V	
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent is not NULL AND V.new_vaccinations is not NULL)

SELECT *, (VaccinationsToDate/Population)*100 as DailyVaccinationPercentage
FROM VaccinatedPopulation
ORDER BY location,date

--TEMP Table
--Vaccinated Percentage Per day according to the date
Drop Table if exists VaccinationPercentage
Create Table VaccinationPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationsToDate numeric)

INSERT INTO VaccinationPercentage
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations, SUM(CONVERT(int, V.new_vaccinations)) OVER (Partition by D.location Order by D.location,D.date) as VaccinationsToDate
FROM PortfolioProjects..CovidDeaths$ as D
JOIN PortfolioProjects..CovidVaccinations$ as V	
	ON D.location = V.location
	AND D.date = V.date
WHERE D.continent is not NULL AND V.new_vaccinations is not NULL

SELECT *, (VaccinationsToDate/Population)*100 as DailyVaccinationPercentage
FROM VaccinationPercentage
ORDER BY location,date

--Creating a view for visualization
Create View PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(int,V.new_vaccinations)) OVER (Partition by D.Location Order by D.location, D.Date) as VaccinationsToDate
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.CovidDeaths$ D
Join PortfolioProjects.dbo.CovidVaccinations$ V
	On D.location = V.location
	and D.date = V.date
where D.continent is not null 
