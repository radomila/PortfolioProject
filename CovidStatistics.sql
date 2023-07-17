SELECT * 
FROM CovidDeaths  
WHERE Continent IS NOT NULL
ORDER BY 3,4

-- Looking at total cases vs total deaths 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths   
WHERE Location LIKE 'g%y'
ORDER BY 1, 2	

-- Looking at the total cases vs Population 
SELECT Location, date, total_cases, population, (total_cases/population) * 100 AS TotalCasesPercentage 
FROM CovidDeaths 
WHERE Location = 'United States'
ORDER BY 1, 2 

-- Looking at the country with the highest infection rates compared to the population 
SELECT Location, MAX(total_cases) AS HighestNumberOfTotalCases, population, MAX((total_cases/population)) * 100 AS HighestInfectionRate
FROM CovidDeaths 
GROUP BY Location, Population
ORDER BY HighestInfectionRate DESC

-- Showing the countries with the highest Death count
SELECT continent, MAX(cast(total_deaths AS INT)) AS HighestNumberOfDeaths
FROM CovidDeaths  
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY HighestNumberOfDeaths DESC 

-- GLOBAL NUMBERS - new cases per day for every country 
SELECT Location, date, SUM(new_cases) AS NumberOfCasesPerDay
FROM CovidDeaths 
GROUP BY Location, date 
ORDER BY 1,2 


-- Joining tables together 
SELECT * 
FROM CovidDeaths dea
JOIN CovidVaccinations vacc 
     ON dea.iso_code = vacc.iso_code       
	 AND dea.date = vacc.date 


-- Looking at total population vs vaccination (rate)  
-- Looking at total rate  

-- Using CTE Table  

WITH CTE_TotalNumberOfVaccinationsTable (Continent, Location, Date, Population, New_Vaccinations, TotalNumberOfVaccinations)
AS 
(
SELECT dea.continent, dea.location, dea.date, population, vacc.new_vaccinations
, SUM(CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) TotalNumberOfVaccinations  
FROM CovidDeaths dea
JOIN CovidVaccinations vacc 
     ON dea.iso_code = vacc.iso_code       
	 AND dea.date = vacc.date 
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (TotalNumberofVaccinations/Population)*100 RateOfVaccinated 
FROM CTE_TotalNumberOfVaccinationsTable 

-- Using CTE Table  

DROP TABLE IF EXISTS #Temp_PercentPopulationVaccinated 
CREATE TABLE #Temp_PercentPopulationVaccinated 
( 
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
TotalNumberOfVaccinations numeric
)

INSERT INTO #Temp_PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, population, vacc.new_vaccinations
, SUM(CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) TotalNumberOfVaccinations  
FROM CovidDeaths dea
JOIN CovidVaccinations vacc 
     ON dea.iso_code = vacc.iso_code       
	 AND dea.date = vacc.date 
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3 

SELECT *, (TotalNumberofVaccinations/Population)*100 RateOfVaccinated 
FROM #Temp_PercentPopulationVaccinated 


-- Create View to store data for later vizualizations 
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, population, vacc.new_vaccinations
, SUM(CONVERT(INT,vacc.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) TotalNumberOfVaccinations  
FROM CovidDeaths dea
JOIN CovidVaccinations vacc 
     ON dea.iso_code = vacc.iso_code       
	 AND dea.date = vacc.date 
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3 

SELECT *
FROM PercentPopulationVaccinated