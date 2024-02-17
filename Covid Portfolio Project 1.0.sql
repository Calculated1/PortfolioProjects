--select * 
--from ProjectCovid1..CovidDeaths$
--order by 3,4

--select * 
--from ProjectCovid1..CovidVaccinations$
--order by 3,4

select Location, Date, total_cases, new_cases, total_deaths, population
from ProjectCovid1..CovidDeaths$
order by 1,2

-- looking at Total Cases vs Total Deaths
-- Shows chance of dyinng if you contract covid in your country
select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectCovid1..CovidDeaths$
where location like '%states%'
order by 1,2

-- Looking at total Cases by Population
-- Shows what percentage of population got Covid

select Location, Date, population, total_cases, (total_cases/population)*100 as TotalCasesbyPopulationPercentage
from ProjectCovid1..CovidDeaths$
--where location like '%states%'
order by 1,2

--Showing highest Infected population percentage for each country

select Location, population, max(total_cases) as HighestInfectionRate, max((total_cases/population))*100 as InfectedPopulationPercentage
from ProjectCovid1..CovidDeaths$
--where location like '%states%'
group by location, population
order by InfectedPopulationPercentage desc


--Showing countries with the highest Death Count per Population

select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from ProjectCovid1..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--broken down by continent

--Showing countries with the highest Death Count per Population

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from ProjectCovid1..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select Date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectCovid1..CovidDeaths$
where continent is not null
group by date
order by 1,2


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations, sum(convert(int, vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectCovid1..CovidDeaths$ dea
join ProjectCovid1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--USE CTE


--TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations, sum(convert(int, vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectCovid1..CovidDeaths$ dea
join ProjectCovid1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 --as PercentPopulationVaccinated
from #PercentPopulationVaccinated


create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac. new_vaccinations, sum(convert(int, vac.new_vaccinations)) over
(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectCovid1..CovidDeaths$ dea
join ProjectCovid1..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated