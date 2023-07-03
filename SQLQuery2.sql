
Select *
From [Covid analysis]..Death$
where continent is not null
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From [Covid analysis]..Death$
order by 3,4

--Looking at total cases vs total deaths 

USE [Covid analysis]
GO
--create view CasesVsDeathTotal as
select location, date, total_cases, total_deaths, (cast(total_deaths as numeric))/ cast(total_cases as numeric)*100 as deathpercentage
From [Covid analysis]..Death$
where location like '%states%'
--order by 1,2

-- Looking at total cases vs Population
--shows percentage of population that got covid

USE [Covid analysis]
GO
--create view CovidPop as
select location, date, total_cases, population, (cast(total_cases as numeric))/ cast(population as numeric)*100 as deathpercentage
From [Covid analysis]..Death$
where location like '%states%'
--order by 1,2

--Looking as countries with highest infection rate compared to population

USE [Covid analysis]
GO
--create view InfectionRate as
select location, population, MAX(total_cases) as HJighestInfection, MAX((cast(total_cases as numeric))/ cast(population as numeric))*100 as PercentPoulationInfected
From [Covid analysis]..Death$
--where location like '%states%'
group by location, population
order by PercentPoulationInfected desc

select location, population, date, MAX(total_cases) as HJighestInfection, MAX((cast(total_cases as numeric))/ cast(population as numeric))*100 as PercentPoulationInfected
From [Covid analysis]..Death$
--where location like '%states%'
group by location, population, date
order by PercentPoulationInfected desc


--Showing countries with highest death per population

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid analysis]..Death$
--where location like '%states%'
where continent is not null
group by location, population
order by location asc

--by continent

USE [Covid analysis]
GO
--create view TotalDeathCount as
select continent, date, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid analysis]..Death$
--where location like '%states%'
where continent is not null
group by continent,date
order by TotalDeathCount desc


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid analysis]..Death$
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


--showing continents with highest death count per population


--USE [Covid analysis]
--go
--create view newDeathCountperPop as
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid analysis]..Death$
--where location like '%states%'
where continent is not null
and location not in ('world','European Union', 'international')
group by continent
order by TotalDeathCount desc


--Global numbers of the death percentage in its entiriety 


--USE [Covid analysis]
--GO
--reate view newglobalnum as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
 (new_deaths as numeric))/SUM(cast(new_cases as numeric))*100 as death_percent
From [Covid analysis]..Death$
where continent is not null 
and new_cases > 0
--group by date
order by 1,2

select *
from globalnum

-- joining tables from the dbo.Death$ and dbo.Vaccination$


with popsvac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(numeric, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, 
 dea.date) as RollingPeopleVac
From [Covid analysis]..Death$ dea
join [Covid analysis]..vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVac/population)*100
from popsvac


--temp table for accessing data readily

drop table if exists #PercentPopulationVac
Create table #PercentPopulationVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVac numeric,
)

insert into #PercentPopulationVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(numeric, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, 
 dea.date) as RollingPeopleVac
From [Covid analysis]..Death$ dea
join [Covid analysis]..vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVac/population)*100
from #PercentPopulationVac



-- storing data for later



USE [Covid analysis]
GO
--create view PercentPopulationvacc as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(numeric, vac.new_vaccinations)) over (partition by dea.location Order by dea.location, 
 dea.date) as RollingPeopleVac
From [Covid analysis]..Death$ dea
join [Covid analysis]..vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
--From PercentPopulationvacc
