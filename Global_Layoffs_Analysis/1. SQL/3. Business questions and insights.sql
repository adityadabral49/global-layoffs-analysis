 
 --                Business Questions AND insights
 
 -- Q1. Which top 10 companies have laid off the most employees overall ?
 
 Select company as Company , sum(total_laid_off)as Total_Laid_Off
 from staging_layoffs2
 group by company 
 order by 2 desc;
 
 -- Q2. How have total layoffs trended year-wise ?
 
 Select year(`date`)as YEAR , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
where year(`date`) is not null
group by year(`date`)
order by 2 desc;

-- Q3. Which Companies ranked in the top 5 layoffs each year ?

with Company_year (Company , years ,total_laid_off ) as
(
select company, year(`date`),sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by company , year(`date`)
order by 3 desc  ),
Company_year_rank as(
select *, dense_rank() over(partition by years ORDER BY total_laid_off desc) as Ranking  
from Company_year
where years is not null)
select * 
from Company_year_rank
where Ranking <= 5;

-- Q4. Are layoffs concentrated among a small number of companies ?

WITH company_totals AS (
    SELECT company, SUM(total_laid_off) AS total_layoffs
    FROM staging_layoffs2
    GROUP BY company ),
overall AS (
    SELECT SUM(total_layoffs) AS overall_layoffs
    FROM company_totals
),
top_companies AS (
    SELECT SUM(total_layoffs) AS top5_layoffs
    FROM (SELECT total_layoffs
        FROM company_totals
        ORDER BY total_layoffs DESC
        LIMIT 5 ) t
)
SELECT t.top5_layoffs,o.overall_layoffs,ROUND(t.top5_layoffs * 100.0 / o.overall_layoffs, 2) AS top5_percentage
FROM top_companies t
CROSS JOIN overall o;

-- Q5. Which top 10 industries were most impacted by layoffs ?

select industry , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by industry
order by 2 desc;

-- Q6. Which top 10 countries experienced the highest layoffs ? 

select country , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by country
order by 2 desc;

-- Q7. How did layoffs differ during Covid vs pos-Covid periods ? 

WITH yearly_layoffs AS (
    SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
    FROM staging_layoffs2
    GROUP BY YEAR(date) ),
stats AS (SELECT AVG(total_layoffs) AS avg_layoffs
    FROM yearly_layoffs)
SELECT y.year, y.total_layoffs, s.avg_layoffs
FROM yearly_layoffs y
CROSS JOIN stats s
WHERE y.total_layoffs > s.avg_layoffs
ORDER BY y.total_layoffs DESC;

-- Q8. Which companies show repeated layoffs across multiple years ?

WITH company_year_layoffs AS (
    SELECT company, YEAR(date) AS year,
        SUM(total_laid_off) AS yearly_layoffs
    FROM staging_layoffs2
    GROUP BY company, YEAR(date)
)
SELECT company,COUNT(DISTINCT year) AS layoff_years
FROM company_year_layoffs
WHERE yearly_layoffs > 0
GROUP BY company
HAVING COUNT(DISTINCT year) > 1
ORDER BY layoff_years DESC;

--             *****
