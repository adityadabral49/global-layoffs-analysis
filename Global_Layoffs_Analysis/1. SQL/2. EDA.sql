
--                   EXPOLARATORY DATA ANALYSIIS 

select *
from staging_layoffs2;

-- Maximum Laid off (in numbers and percentage) in one day

select max(total_laid_off) , max(percentage_laid_off)
from staging_layoffs2;

-- Total Layoffs during Covid

select sum(total_laid_off) as Total
from staging_layoffs2;

-- Overall layoffs across all Companies

select company , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by company 
order by 2 desc;

-- Layoff Date Range (Covid to Post-Covid Period)

select min(`date`), max(`date`)
from staging_layoffs2;

-- Overall layoffs across all Industries

select industry , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by industry
order by 2 desc;

-- Overall layoffs across all Countries

select country , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by country
order by 2 desc;

-- Stage-wise Total Layoffs

select stage , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by stage
order by 2 desc;

-- Date-wise Total Layoffs

select `date` , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by `date`
order by 2 desc;

-- Year-wise Total Layoffs

Select year(`date`)as YEAR , sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
where year(`date`) is not null
group by year(`date`)
order by 2 desc;

-- Month-wise Total Layoffs

select substring(`date`,1,7)as `Month`, sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
where substring(`date`,1,7) is not Null
group by `Month`
order by 1 ;

-- Monthly Layoffs Rolling Total Calculation

with Rolling_Total as
(
select substring(`date`,1,7)as `Month`, sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
where substring(`date`,1,7) is not Null
group by `Month`
order by 1 
)
select `Month`, Total_Laid_Off ,sum(Total_Laid_Off) over(order by `Month`) as Rolling_Total
from Rolling_Total;

-- Annual Total Layoffs by Company

select company, year(`date`) as Year,sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by company , year(`date`)
order by 3 desc   ;

-- Year-wise Company Ranking by Total Layoffs

with Company_year (Company , years ,total_laid_off ) as
(
select company, year(`date`),sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by company , year(`date`)
order by 3 desc  )
select * , dense_rank() over(partition by years ORDER BY total_laid_off desc) as Ranking
from Company_year
where years is not null
order by Ranking ;

-- Top 5 Companies by Total Layoffs (Year-wise)

with Company_year (Company , years ,total_laid_off ) as
(
select company, year(`date`),sum(total_laid_off)as Total_Laid_Off
from staging_layoffs2
group by company , year(`date`)
order by 3 desc  ),
Company_year_rank as(
select * , dense_rank() over(partition by years ORDER BY total_laid_off desc) as Ranking
from Company_year
where years is not null)
select * 
from Company_year_rank
where Ranking <= 5;

 
 --              ****



