Select *
From Project1..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From Project1..CovidVaccinations
--order by 3,4

-- Select the data that we are going to be using.

Select Location, Date, total_cases, new_cases, total_deaths, population_density
From Project1..CovidDeaths
ORDER by 1,2

-- Looking at total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, Date, total_cases,total_deaths, (CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2), total_cases) )*100 as DeathPercent
From Project1..CovidDeaths
Where location like '%states%'
ORDER by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid.
Select Location, Date, total_cases, population_density, (CONVERT(DECIMAL(18,2), total_cases) / CONVERT(DECIMAL(18,2), population_density) )*100 as PercentPopulationInfected
From Project1..CovidDeaths
--Where location like '%states%'
ORDER by 1,2

-- Which countries have highest infection rates compared to Population
Select Location, population_density, MAX(total_cases) as HighestInfectionCount, Max((CONVERT(DECIMAL(18,2), total_cases)) / CONVERT(DECIMAL(18,2), population_density))*100 as PercentPopulationInfected
From Project1..CovidDeaths
--Where location like '%states%'
Group by location, population_density
ORDER by PercentPopulationInfected desc

-- Showing Countries with Highest Death per count per population died
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is not null
Group by location
ORDER by TotalDeathCount desc


-- Let's break things down by continent
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is null
Group by continent
ORDER by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
Where continent is null
Group by continent
ORDER by TotalDeathCount desc


-- GLOBAL NUMBERS
Select Date, SUM(new_cases), SUM(new_deaths)--,total_cases, population_density, (CONVERT(DECIMAL(18,2), total_cases) / CONVERT(DECIMAL(18,2), population_density) )*100 as PercentPopulationInfected
From Project1..CovidDeaths
--Where location like '%states%'
where continent is not null
group by date
ORDER by 1,2

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea 
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea 
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea 
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulation as
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project1..CovidDeaths dea 
Join Project1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccinated
