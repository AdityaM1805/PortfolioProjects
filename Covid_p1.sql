select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Looking at total Population vs Vaccinations 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_Vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

WITH PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_Vaccinations,
        SUM(CONVERT(BIGINT, vac.new_Vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
    AND 
        dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *
FROM PopvsVac;

--Temp Table
Drop table if exists #PercentPopulaionVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_Vaccinations,
        SUM(CONVERT(BIGINT, vac.new_Vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
    AND 
        dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL

SELECT *
FROM #PercentPopulationVaccinated





--Select Data that I am going to use
select Location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select Location,date, total_cases,total_deaths, (total_deaths/NULLIF(total_cases, 0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at Total Cases vs Population
--shows what percentage of population got Covid
select Location,date, total_cases,Population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location,population
order by PercentofPopulationInfected desc

--Showing Countries with Highest DEath Count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--lets break things down by continent

--Showing the continents with highest death count
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLobal numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2  


--Creating view to store data for visualisation

Create view PercentPeopleVaccinated as
SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_Vaccinations,
        SUM(CONVERT(BIGINT, vac.new_Vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
    AND 
        dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL

Select * from PercentPeopleVaccinated
 