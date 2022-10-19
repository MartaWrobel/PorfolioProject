Select *
From Portfolio_project..CovidDeaths
Where continent is not null
order by 3,4

Select
location
,date
,total_cases
,new_cases
,total_deaths
,population
From Portfolio_project..CovidDeaths
order by 1,2

--Looking at total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 

Select
location
,date
,total_cases
,total_deaths
,(total_deaths/total_cases)*100 as DeathPercentage 
From Portfolio_project..CovidDeaths
Where location like 'Poland'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percetage of population got Covid

Select
location
,date
,total_cases
,population
,(total_cases/population)*100 as PercentPopulationInfected
From Portfolio_project..CovidDeaths
--Where location like 'Poland'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select
location
,population
,MAX(total_cases) as  HighestInfectionCount
,MAX((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_project..CovidDeaths
Group by location,population
--Where location like 'Poland'
order by 4 DESC

--Showing Countries with highest Death Count per Population

Select
location
,MAX(CAST(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC 

--Break down things by continent
 

--Showing continents with the highest death count per population

Select
continent
,MAX(CAST(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC 

-- Global numbers

Select
location
,date
,total_cases
,total_deaths
,(total_deaths/total_cases)*100 as DeathPercentage 
From Portfolio_project..CovidDeaths
Where continent is not null
--Where location like 'Poland'
order by 1,2

Select
SUM(total_cases) as total_cases
,SUM(cast(total_deaths as int)) as total_deaths
,SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
Where continent is not null
--Where location like 'Poland'
order by 1,2


-- Looking at Total Population vs Vaccination

Select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
Select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentagePopulationVaccinated as
Select 
dea.continent
,dea.location
,dea.date
,dea.population
,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
From PercentagePopulationVaccinated