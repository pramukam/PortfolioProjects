select * 
from `covid-364509.covid_deaths.covid_deaths`
where continent is not null
order by 3,4;

-- select * 
-- from `covid-364509.covid_deaths.covid_vac`
-- order by 3,4

--select data that we are going to be using

select  location, date, total_cases, new_cases,total_deaths,population
from `covid-364509.covid_deaths.covid_deaths`
where continent is not null
order by 1,2;

--loking at total deaths as at 2022.09.19 in Sri Lanka

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from `covid-364509.covid_deaths.covid_deaths`
where location like "%Sri Lanka%" AND Date = "2022-09-19" 
order by 1,2;

-- shows what percentage of population got covid in in Sri Lanka as at 2022.09.19

select location, date, total_cases,population,(total_cases/population)*100 as infectedPercentage
from `covid-364509.covid_deaths.covid_deaths`
where location like "%Sri Lanka%" AND Date = "2022-09-19"
order by 1,2;

--countries with highest infection rates (TOP 10) as at 2022-09-19

SELECT location,population,total_cases, (total_cases/population)*100 as total_infected_rate
FROM `covid-364509.covid_deaths.covid_deaths` 
where date = '2022-09-19'and continent is not null
order by total_infected_rate desc
limit 10;

--countries with highest deaths (TOP 10) as at 2022-09-19

SELECT location,population,total_deaths, (total_deaths/total_cases)*100 as total_death_rate
FROM `covid-364509.covid_deaths.covid_deaths` 
where date = '2022-09-19' and continent is not null
order by total_death_rate desc
limit 10;

-- total deaths by country from highest (TOP 10) as at 2022-09-19

SELECT location,population,total_deaths
FROM `covid-364509.covid_deaths.covid_deaths` 
where date = '2022-09-19' and continent is not null 
order by total_deaths desc 
limit 10;

-- total deaths by continent as at 2022-09-19

SELECT location,total_deaths 
From `covid-364509.covid_deaths.covid_deaths`
where date = "2022-09-19" and continent is null and location !="High income" and location != "Upper middle income" and location != "Lower middle income" and location != "Low income" and location != "European Union" 
order by total_deaths;

-- global numbers by date

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from `covid-364509.covid_deaths.covid_deaths`
where continent is not null
Group by date 
order by 1,2;

-- total global numbers as at 2022-09-19

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from `covid-364509.covid_deaths.covid_deaths`
where continent is not null 
order by 1,2;

-- Looking at total population vs Vaccination

select  deaths.continent,deaths.location,deaths.date,deaths.population,vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
from `covid-364509.covid_deaths.covid_deaths` deaths
join `covid-364509.covid_deaths.covid_vac` vacs 
on deaths.location=vacs.location and deaths.date = vacs.date
where deaths.continent is not null 
order by 2,3;

----------------------------------------------------------------------------------------------------------------------------------------------------
-- --use temp table (This oprion is not possible in BigQuery free version)

-- drop table if exists `covid-364509.covid_deaths.newTable`;
-- create table `covid-364509.covid_deaths.newTable` (
-- ontinent string(255),
-- location string(255),
-- date datetime,
-- population numeric,
-- new_vaccinations numeric,
-- RollingPeopleVaccinated numeric
-- );


-- insert into `covid-364509.covid_deaths.newTable`
-- select  deaths.continent,deaths.location,deaths.date,deaths.population,vacs.new_vaccinations,
-- sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
-- from `covid-364509.covid_deaths.covid_deaths` deaths
-- join `covid-364509.covid_deaths.covid_vac` vacs 
-- on deaths.location=vacs.location and deaths.date = vacs.date
-- where deaths.continent is not null;

----------------------------------------------------------------------------------------------------------------------------------------------------


--CTE (common table expression)

with PopvsVac
as 

(
select  deaths.continent,deaths.location,deaths.date,deaths.population,vacs.new_vaccinations,
sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
from `covid-364509.covid_deaths.covid_deaths` deaths
join `covid-364509.covid_deaths.covid_vac` vacs 
on deaths.location=vacs.location and deaths.date = vacs.date
where deaths.continent is not null 
order by 2,3
) 

select *, (RollingPeopleVaccinated/population) 
from PopvsVac;


-- creating a view for total population vs Vaccination data

-- create view `covid-364509.covid_deaths.percentPopulationVaccinated` as 
-- select  deaths.continent,deaths.location,deaths.date,deaths.population,vacs.new_vaccinations,
-- sum(cast(vacs.new_vaccinations as int)) over (partition by deaths.location order by deaths.location,deaths.date) as RollingPeopleVaccinated
-- from `covid-364509.covid_deaths.covid_deaths` deaths
-- join `covid-364509.covid_deaths.covid_vac` vacs 
-- on deaths.location=vacs.location and deaths.date = vacs.date
-- where deaths.continent is not null;
