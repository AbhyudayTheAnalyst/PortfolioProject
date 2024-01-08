SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4;

--SELECT * 
--FROM PortfolioProject..covidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
where continent is not null
AND continent is not null
ORDER BY 1,2;

--looking at total Caases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths, (Convert(float,total_deaths)/NULLIF(convert(float,total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%India%'
AND continent is not null
ORDER BY 1,2;


--looking at the Total Cases vs Population
SELECT location,date,total_cases,population, (Convert(float,total_cases)/NULLIF(convert(float,population),0))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%India%'
AND continent is not null
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((Convert(float,total_cases)/NULLIF(convert(float,population),0))*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
Group By location,population
ORDER BY PercentPopulationInfected desc;

-- Showing Countries with highest Death Count per Population
SELECT location, MAX(cast(total_cases as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group By location 
ORDER BY TotalDeathCount desc;

--Things By CONTINENT

-- Showing Countries with highest Death Count per Population
SELECT continent, MAX(cast(total_cases as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group By continent
ORDER BY TotalDeathCount desc;



-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(NULLIF(New_cases,0)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- where location like '%India%'
where continent is not null
-- Group By date
ORDER BY 1,2;



--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Convert(bigint,vac.new_vaccinations)) over (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinat
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3;



-- USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinat)  --Population vs Vaccination since we want perc of vacc population to store as a table
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Convert(bigint,vac.new_vaccinations)) over (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinat
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2,3
)
Select *, (RollingPeopleVaccinat/population)*100   --> This will give the % of people vaccinated so far
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinat numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Convert(bigint,vac.new_vaccinations)) over (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinat
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- ORDER BY 2,3

Select *, (RollingPeopleVaccinat/population)*100   --> This will give the % of people vaccinated so far
From #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Convert(bigint,vac.new_vaccinations)) over (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinat
from PortfolioProject..CovidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2,3



Select *
From PercentPopulationVaccinated
