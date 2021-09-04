SELECT Location, Date, Total_Cases, New_Cases, total_deaths, population
FROM PortfolioProject..['CovidDeath']
WHERE Continent is not Null
ORDER BY 1,2

-- Shows likelihood of dying if I contracted in Malaysia
SELECT Location, Date, Total_Cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['CovidDeath']
WHERE location like '%Malaysia%'
ORDER BY 1,2

-- Total cases vs Population
SELECT Location, Date, Total_Cases, Population, (Total_cases/Population)*100 as CasesPercentage
FROM PortfolioProject..['CovidDeath']
WHERE location = 'Malaysia'
ORDER BY 1,2

-- Highest infection rate compared to population
SELECT Location, Population, MAX(Total_Cases) as HighestInfectionCount, Max((Total_cases/Population)*100) as PercentPolulationInfected
FROM PortfolioProject..['CovidDeath']
WHERE Continent is not Null
Group by Location, Population
ORDER BY 4 DESC 

-- Countries with Highest Death rate count per Population
SELECT Location, MAX(cast(Total_Deaths as float)) as HighestDeathCount, Max((Total_deaths/Population)*100) as PercentPolulationDeath
FROM PortfolioProject..['CovidDeath']
WHERE Continent is not Null
Group by Location
ORDER BY 2 DESC

-- Continent with highest death rate count 
SELECT continent, MAX(cast(Total_Deaths as float)) as HighestDeathCount
FROM PortfolioProject..['CovidDeath']
WHERE Continent is not Null
Group by continent
ORDER BY 2 DESC

--total cases & total deaths & death rate
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_death, sum(cast(new_deaths as float))/SUM(cast(new_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject..['CovidDeath']
WHERE Continent is not Null
--Group by date
ORDER BY 1,2

--total population vs vaccinations
SELECT dea.continent, dea.location, population, dea.date, vac.new_vaccinations
FROM PortfolioProject..['CovidDeath'] dea
Join PortfolioProject..['CovidVaccination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not Null
Order By 2,4 

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, population, dea.date, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeath'] dea
Join PortfolioProject..['CovidVaccination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not Null
Order By 2,4 

--Use CTE
With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeath'] dea
Join PortfolioProject..['CovidVaccination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not Null
--Order By 2,4 
)
SELECT *, (RollingPeopleVaccinated/(cast(Population as int)) * 100
FROM PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

SELECT *, (RollingPeopleVaccinated/(cast(Population as int)) * 100
FROM #PercentPopulationVaccinated

--Creating view to store data for visualization later

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, population, dea.date, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['CovidDeath'] dea
Join PortfolioProject..['CovidVaccination'] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.Continent is not Null
--Order By 2,4 

SELECT *
FROM PercentPopulationVaccinated

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage
FROM PortfolioProject..['CovidDeath']
WHERE continent is not null
ORDER BY 1,2

SELECT location, SUM(CAST(new_deaths AS INT)) AS total_deaths_counts
FROM PortfolioProject..['CovidDeath']
WHERE continent is null
and location not in ('World', 'Europeon Union', 'International')
GROUP BY location
ORDER BY total_deaths_counts DESC

SELECT location, population, MAX(total_cases) AS highest_infection_counts, MAX(total_cases)/population * 100 AS percent_population_infected
FROM PortfolioProject..['CovidDeath']
GROUP BY location, population
ORDER BY percent_population_infected DESC

SELECT location, population, date, MAX(total_cases) AS highest_infection_counts, MAX(total_cases)/population * 100 AS percent_population_infected
FROM PortfolioProject..['CovidDeath']
GROUP BY location, population, date
ORDER BY percent_population_infected DESC
