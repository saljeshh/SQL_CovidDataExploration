SELECT top 2 * FROM CovidDeaths$

SELECT location, date, total_cases, new_cases,total_deaths,population
from CovidDeaths$
where continent is not null -- issue with location and continent
ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths
-- Shows Likelihood of dying if you contract covid in Nepal
select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
where location = 'Nepal'
order by date 
/*so first death in nepal was at 2020-05-16 and there was chances / death percentage according to cases was 0.3% at this date,
but it rose up 1.5% but in france it was very high like 11 */


--2 Shows what percentage of population got covid
SELECT Location,date,Population, total_cases, (total_cases/population)*100 as Percent_got_covid
FROM CovidDeaths$
where location = 'Nepal'


--3 Looking at Countries at Highest Infection Rate compared to Population
SELECT Location, population, Max(total_cases)as HighestInfection, MAX((total_cases/population))*100 as Percent_population_infected
from CovidDeaths$
GROUP BY Location, population
order by Percent_population_infected desc


--4 Showing countries with Highest Death count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null -- issue in data wheere continent is in place of location and contient is null giving world , asia as country so removed
GROUP BY location
order by TotalDeathCount desc


--5 Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers

-- 6 Sum of all new cases in single day globally
SELECT date, SUM(new_cases) as new_total_cases, SUM(CAST(new_deaths as int)) as new_total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 4 desc

-- USING vaccine table

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated*100) we cant use alis so this is point we use CTE or temp table
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE
WITH PopvsVac(Continent, Location,Date, Population,new_vaccinations, rollingPeopleVaccinated)
as(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
	--(rollingPeopleVaccinated/Population)*100 we cant use alis so this is point we use CTE or temp table
	FROM CovidDeaths$ dea
	JOIN CovidVaccinations$ vac 
		ON dea.location = vac.location 
		AND dea.date = vac.date
	where dea.continent is not null
	--order by 1,2,3
)
select location, max(rollingPeopleVaccinated/Population)*100 
from PopvsVac
group by location
order by 2 desc

/*
	NULL	66755
3967	70722
4147	74869
4003	78872
1648	80520
788	81308
6295	87603
6476	94079
7836	101915
8767	110682

when null comes it stop adding
*/



-- Using Temp Tables
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated bigint
)

-- when we insert into and select using query it will populate data in temp table schema we created up.
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingPeopleVaccinated
FROM CovidDeaths$ dea
join CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select * from
#PercentPopulationVaccinated

drop table #PercentPopulationVaccinated


-- VIEWS
-- Creating View to store data for later visualizatoin

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated*100) we cant use alis so this is point we use CTE or temp table
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
where dea.continent is not null

select * 
from PercentPopulationVaccinated


