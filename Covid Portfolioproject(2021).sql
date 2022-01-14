select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio.dbo.coviddeaths
order by 1,2

--Looking at total cases vs total deaths
--showing likelihood of dying if you come into contract virus in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Portfolio.dbo.coviddeaths
where location='India'
order by 1,2

--Looking total cases vs population
--Showing infection percentage in your country
select Location, date, total_cases, population, (total_cases/population)*100 as Infectionpercentage
from Portfolio.dbo.coviddeaths
where location='India'
order by 1,2

--Which location has highest infection rate
select Location, MAX(total_cases), population, MAX((total_cases/population))*100 as Infectionpercentage
from Portfolio.dbo.coviddeaths
Group by Location, population
order by Infectionpercentage Desc

--Infection rate in India
select Location, MAX(total_cases) as highestcases, population, MAX((total_cases/population))*100 as Infectionpercentage
from Portfolio.dbo.coviddeaths
where location like '%India%'
Group by Location, population


--Showing locations with highest death count per population
select Location, Max(cast(total_deaths as int)) as Deathcount
from Portfolio.dbo.coviddeaths
where continent is not null
Group by Location 
order by Deathcount Desc

--Break it down by continent
select continent, Max(cast(total_deaths as int)) as Deathcount
from Portfolio.dbo.coviddeaths
where continent is not null
Group by continent
order by Deathcount Desc
--The above query doesn't look like returning actual results. So, let's try where continent is not null
select location, Max(cast(total_deaths as int)) as Deathcount
from Portfolio.dbo.coviddeaths
where continent is null
Group by location
order by Deathcount Desc

--GLOBAL NUMBERS(total new cases across the world that day)
select date, SUM(new_cases) as todaycases
from Portfolio.dbo.coviddeaths
where continent is not null
group by date
order by date asc
--total number of deaths across the world that day
select date, SUM(cast(new_deaths as int)) as todaydeaths
from Portfolio.dbo.coviddeaths
where continent is not null
group by date
order by date asc

--Death rate across the world that day
select date, SUM(cast(new_deaths as int)) as todaydeaths, SUM(new_cases) as todaycases, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathrate  
from Portfolio.dbo.coviddeaths
where continent is not null
group by date
order by date asc

--Total cases, total deaths, death rate
select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) as Deathrate
from Portfolio.dbo.coviddeaths
where continent is not null

--Joining another table
select*
from Portfolio..coviddeaths dea
join Portfolio..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--Looking at total population vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
From Portfolio..coviddeaths dea
Join Portfolio..covidvaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
From Portfolio..coviddeaths dea
Join Portfolio..covidvaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(Rollingpeoplevaccinated/population)*100 as vaccinationrate
From PopvsVac

--TEMP TABLE
Drop table if exists #Percentpeoplevaccinated
create Table #Percentpeoplevaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #Percentpeoplevaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
From Portfolio..coviddeaths dea
Join Portfolio..covidvaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (Rollingpeoplevaccinated/population)*100 as vaccinationrate
From #Percentpeoplevaccinated


--Creating view to store data for visualizations later

Create view Percentpeoplevaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated
From Portfolio..coviddeaths dea
Join Portfolio..covidvaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2

Select *
From #Percentpeoplevaccinated