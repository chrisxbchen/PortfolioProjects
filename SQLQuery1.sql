select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3, 4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4
-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' 
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--countries with highest infection rate compared to population 
select location,population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc




--showing countries with highest deathcount per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--break by continents
select continent, sum(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null and new_cases != 0
group by date
order by 1,2

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100 as VaccinationRate
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100 as VaccinationRate
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
--order by 2,3
select * ,(RollingPeopleVaccinated/population)*100 as VaccinationRate
from PopvsVac

---TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date date,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100 as VaccinationRate
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/dea.population)*100 as VaccinationRate
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated1