-- view all columns 
SELECT *
FROM covid.coviddeathss;

-- Total deaths world wide by summing total death count for every country on August 8th. 
SELECT SUM(total_deaths) as worldwide_deaths
FROM covid.coviddeathss 
WHERE date LIKE '2021-08-02 00:00:00'
	AND location NOT IN ('World','International','European Union', 'Europe', 'South America','North America','Asia','Africa','Oceania');
-- As of August 2nd 2021, there has been 4,235,868 deaths world wide due to covid. 

-- total_cases vs total_deaths
-- calculating death percentage, to see likelihood of dying if contracting the covid virus
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid.coviddeathss
WHERE location like '%States'
order by 2,1;
-- We now have a new column labeled 'death_percentage' which shows the percentage of people that are dying if they test postive for the covid vaccine in the United States. If we take a closer look at the death 
-- percentage here in the U.S. we can see that at the beginning of the pandemic, the death percentage peaked at just over 10%. Since then, possibly due to hospitals getting better at treating 
-- covid patients and the vaccine, the death percentage has been gradually decreasing and is now under 1.75%. 

-- total_cases vs population
-- running percentage of population that has had a positive test
SELECT date, location, total_cases, population, (total_cases/population)*100 AS case_percentage
FROM covid.coviddeathss
WHERE location like '%States'
order by 2,4;
-- Here, we are calculating the positive test rate for each country around the world. This is a running percentage that shows the percentage of people that have had covid. In the United States, 
-- we can see that over 10.6% of the population has had the corona virus. From the percentages, we can see a more rapid increase in covid cases during and after the holiday season. It will be 
-- interesting to see the if there is a sudden increase with the new Delta varient. 

-- Which countries have the highest/lowest infection rates relative to thier population size?
SELECT location, date, population, MAX(total_cases) AS highest_case_count, MAX((total_cases/population))*100 AS percent_infected
FROM covid.coviddeathss
GROUP BY location, population, date
ORDER BY percent_infected Desc;
-- The results from this query show that Andorra, an independent principality between France and Spain has the highest case percentage at over 19% of the population having had the covid virus 
-- so far. When looking in Ascending order, we can see that many of the countries/territories with the lowest case percentages are islands located West of Australia in the Pacific Ocean. this is 
-- most likely due them being in more isolated and remote areas. 

-- Countries with highest death counts relative to their population
SELECT location, MAX(total_deaths) AS highest_deaths, population, MAX((total_deaths/population))*100 AS death_percentage
FROM covid.coviddeathss
GROUP BY location, population
ORDER BY death_percentage Desc;
-- ORDER BY death_percentage Desc;
-- When comparing the number of deaths and the population of each country, we can see that Peru by far has the highest number of deaths due to covid relative to their popualtion size. 
-- Almost 0.6% of the population in Peru has died from the coronavirus vaccine and is possibly due to Peru's healthcare system lacking sufficient funding and only having 1,600 
-- intensive care unit beds per a Google search.  

-- Countries with highest death counts
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS total_deaths
FROM covid.coviddeathss
WHERE continent <> ''
GROUP BY location
ORDER BY total_deaths Desc;
-- Taking a look at the total death counts in each country, we can see that the United States leads in total deaths from the corona virus, followed by Brazil, India, and Mexico. 
-- This makes me wonder if places like India would have higher death counts if people had more access to covid testing. 


-- BY CONTINENT
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS total_deaths
FROM covid.coviddeathss
WHERE continent = '' and location not in ('World','International','European Union')
GROUP BY location
ORDER BY total_deaths Desc;
-- When looking the total number of deaths due to covid by continet, Europe leads with over 1 millions deaths. This is probably due to European cities being more densily populated 
-- than other areas around the world.


-- Global Daily death percentage
SELECT date, SUM(new_cases) AS new_cases, SUM(new_deaths) AS new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid.coviddeathss
WHERE continent <> ''
GROUP BY date
ORDER BY date;
-- Here we create a daily death percentage by dividing the number of new deaths by the number of new cases world wide. The daily death percentage from new cases is currently under 2%.


SELECT * 
FROM covid.coviddeathss d
JOIN covid.covidvaccinations v
	ON d.location = v.location AND d.date = v.date;
-- Here we suse the default inner join to cobine the covid death and vaccination datasets. 

-- total population vs vaccinations 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) 
	OVER (PARTITION BY d.location ORDER BY d.location, d.date)
FROM covid.coviddeath d
	JOIN covid.covidvaccinations v
		ON d.location = v.location 
        AND d.date = v.date
WHERE d.continent <> ''
ORDER BY 2,3;

-- CTE 
WITH RECURSIVE popvsvac
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) 
	OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinations
FROM covid.coviddeath d
	JOIN covid.covidvaccinations v
		ON d.location = v.location 
        AND d.date = v.date
WHERE d.continent <> ''
-- ORDER BY 2,3
)

-- FOR TABLEAU
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid.coviddeathss
WHERE continent <> ''
-- GROUP BY date
ORDER BY 1,2;

-- Tableau 
-- Reproduction Rate 
SELECT reproduction_rate
FROM covid.coviddeathss
WHERE location LIKE '%States';
-- Here we can see the reproduction rate of the virus and see that in the last few months, the reproduction rate has an upward trend. 


-- icu patients vs hospital patients 
SELECT date, icu_patients, hosp_patients, (icu_patients/hosp_patients) *100 AS percent_icu
FROM covid.coviddeathss
WHERE location LIKE '%States';
-- As of July 31st, the percentage of patients who were in the icu is about 25.7% in the United States.

-- Tableau
-- most up to date icu patients and hopsital patients
SELECT date, icu_patients, hosp_patients
FROM covid.coviddeathss
WHERE location LIKE '%States' and date LIKE '2021-07-31 00:00:00';
-- In the United States there are 43,585 hospital patients and 11206 icu patients.

