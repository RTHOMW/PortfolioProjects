select *
from PortfolioProject..['covid deaths$']
order by 3,4

--select *
--from PortfolioProject..['covid vaccinations$']
--order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['covid deaths$']
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..['covid deaths$'] where ISNULL(total_cases,0)!=0
and location like '%states%'
order by 1,2

-- Look at total cases vs pop

select location, date, total_cases,population, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..['covid deaths$']
where location like '%France%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, MAX(total_cases) as HighestInfectionCount,population, max((total_cases/population))*100 as CasesPercentage
from PortfolioProject..['covid deaths$']
--where location like '%France%'
group by location, population
order by 4 desc

-- looking at countries with highest death%

select location, MAX(total_deaths) as HighestDeathsCount,population, max((total_deaths/population))*100 as DeathsPercentage
from PortfolioProject..['covid deaths$']
where continent is not null
--where location like '%France%'
group by location, population
order by 4 desc

-- looking at countries with highest death

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['covid deaths$']
where continent is not null
group by location
order by TotalDeathCount desc


select *
from PortfolioProject..['covid deaths$']
where continent is not null
order by 3,4

--               ****** lets beak things down by continent

--showing the continent with the highest death count

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['covid deaths$']
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..['covid deaths$']
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..['covid deaths$']
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

--USE CTE

With PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated) 
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- MAKING VIEWS to store data for later visualizations

Create View PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated