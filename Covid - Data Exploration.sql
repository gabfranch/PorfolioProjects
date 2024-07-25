/*

Covid-19 Data Exploration

*/



Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4






-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2






-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_Cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Brazil'
and continent is not null
Order by 1, 2






-- Looking at Total Cases vs Population

Select Location, date, total_cases, population, (CAST(total_cases as float)/CAST(population as float))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
Where location like 'Brazil'
and continent is not null
Order by 1, 2






-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(CAST(total_cases as int)) as HighestInfectionCount, MAX((CAST(total_cases as float)/(CAST(population as float))))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Brazil'
Where continent is not null
Group by Location, population
Order by TotalInfectedPopulationPercentage Desc






-- Showing Countries with The Highest Death Count per Population

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Brazil'
Where continent is not null
Group by Location
Order by TotalDeathCount Desc






-- Showing the Continents with The Highest Death Count per Population

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Brazil'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc






-- Global Numbers

Select SUM(new_cases) as TotalCases, SUM(new_deaths) as NewDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Brazil'
Where continent is not null
--Group by date
Order by 1,2






--Looking at Total Population vs Vaccinations

--CTE Version
With PopVsVac (Continent, location, date, population, new_vaccinations, VaccinatedCirculatingPeople)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as VaccinatedCirculatingPeople
--, (VaccinatedCirculatingPeople/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (VaccinatedCirculatingPeople/population)*100
From PopVsVac


-- Temp Table Version
DROP Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_Vaccinations numeric,
VaccinatedCirculatingPeople numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as VaccinatedCirculatingPeople
--, (VaccinatedCirculatingPeople/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
Order by 2,3

Select *, (VaccinatedCirculatingPeople/population)*100
From #PercentPopulationVaccinated






-- Creating view to store data for later visualization

Create View InfectedPopulationPercentage as
Select Location, population, MAX(CAST(total_cases as int)) as HighestInfectionCount, MAX((CAST(total_cases as float)/(CAST(population as float))))*100 as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Brazil'
Where continent is not null
Group by Location, population
--Order by TotalInfectedPopulationPercentage Desc



Create View TotalDeathPerCountry as
Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Brazil'
Where continent is not null
Group by Location
--Order by TotalDeathCount Desc



Create View TotalDeathPerContinent as
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Brazil'
Where continent is not null
Group by continent
--Order by TotalDeathCount Desc



Create View GlobalNumbers as
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as NewDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Brazil'
Where continent is not null
--Group by date
--Order by 1,2



Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as VaccinatedCirculatingPeople
--, (VaccinatedCirculatingPeople/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3



Select *
From InfectedPopulationPercentage

Select *
From TotalDeathPerCountry

Select *
From TotalDeathPerContinent

Select *
From GlobalNumbers

Select *
From PercentPopulationVaccinated