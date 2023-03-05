select distinct *
from PortfolioProject..CovidDeaths
where continent is null
order by continent;

select *
from PortfolioProject..CovidVaccinations
order by 3,4;

-- select Data that we are going to use

select location, date, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;

-- looking at total cases vs total deaths

select distinct(date),location, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 2,1;

/* select date,location, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2; */

-- looking at total cases vs population
-- shows what percentage of population got covid

select distinct(date),location, total_cases, population, (total_cases/population)*100 as cases_percentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 2,1;

-- looking at countries with highest infection rate compared to population

select location,population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as
	PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where population > 100000000
group by location, population
--order by PercentPopulationInfected desc; 
order by population desc;

-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc;

-- mine alternative but wrong

select location as continents, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc;

/*select distinct *
from PortfolioProject..CovidDeaths
where location like '%Grenada%'
--where continent is null
order by location,date;

select location, sum(cast(new_deaths as int))as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is null
--where location like '%Grenada%'
group by location
order by totaldeathcount desc;*/

-- showing the continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc;

-- GLOBAL NUMBER

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/(sum(new_cases)) as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date 
order by 1,2;

--JOINING OF TWO TABLES
-- Looking at total population vs vaccinatons

select distinct(dea.date) as date,dea.continent, dea.location , dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinted
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null	
order by continent, location;
	


-- USE CTE


with PopvsVac (date, continent, location, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select distinct(dea.date) as date,dea.continent, dea.location , dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinted
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null	
--order by continent, location
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View 
PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
