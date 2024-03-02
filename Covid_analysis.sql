use portfolioProject;

select * 
from portfolioProject..[covid death]
order by 3,4

select * 
from portfolioProject..[covid vacnisation]
order by 3,4

--select the used data

select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..[covid death]
order by 1,2

--locking at total cases and total deaths 

select location, date, total_cases, total_deaths --(total_deaths/total_cases)*100 as deathPercentage
from portfolioProject..[covid death]
order by 1,2;

select sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as deathPercentage
from portfolioProject..[covid death]
where continent is not null
order by 1,2 ;

select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location)  as rollingPeopleVaccinated
from portfolioProject..[covid vacnisation] vac 
join portfolioProject..[covid death] dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use  cte

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location)  as rollingPeopleVaccinated
from portfolioProject..[covid vacnisation] vac 
join portfolioProject..[covid death] dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac

-- temp table

create table #PercentPopulationVaccinated
(
continent varchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

insert into #PercentPopulationVaccinated
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location)  as rollingPeopleVaccinated
from portfolioProject..[covid vacnisation] vac 
join portfolioProject..[covid death] dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

create view percentpopulationvaccinated as
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location)  as rollingPeopleVaccinated
from portfolioProject..[covid vacnisation] vac 
join portfolioProject..[covid death] dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated