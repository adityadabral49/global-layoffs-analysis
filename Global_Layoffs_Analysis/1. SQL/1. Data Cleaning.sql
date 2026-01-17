
--        Data Cleaning

-- Raw Data Overview

SELECT * 
FROM world_layoffs.layoffs;

-- Create staging table

CREATE TABLE world_layoffs.staging_layoffs
LIKE world_layoffs.layoffs;

INSERT into staging_layoffs
SELECT * FROM world_layoffs.layoffs;


-- 1. Remove Duplicates

# Check for duplicates record

SELECT *
FROM world_layoffs.staging_layoffs;

SELECT company, industry, total_laid_off,`date`,
	ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM world_layoffs.staging_layoffs;

SELECT *
FROM (SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM world_layoffs.staging_layoffs
) duplicates
WHERE row_num > 1;
    
SELECT *
FROM world_layoffs.staging_layoffs
WHERE company = 'Oda';

-- Identifying True Duplicate Records

SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.staging_layoffs
) duplicates
WHERE 
	row_num > 1;

-- Removing Duplicate Records Using CTE 

WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.staging_layoffs
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE
;


WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM world_layoffs.staging_layoffs
)
DELETE FROM world_layoffs.staging_layoffs
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num > 1;

-- Delete Duplicate records and Finalize Clean Table

ALTER TABLE world_layoffs.staging_layoffs ADD row_num INT;

SELECT *
FROM world_layoffs.staging_layoffs
;

CREATE TABLE `world_layoffs`.`staging_layoffs2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

INSERT INTO `world_layoffs`.`staging_layoffs`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.staging_layoffs;

-- Final Duplicate Clean Up

DELETE FROM world_layoffs.staging_layoffs2
WHERE row_num >= 2;


-- 2. Standardize Data

SELECT * 
FROM world_layoffs.staging_layoffs2;

-- Standardize and Clean Industry Values

SELECT DISTINCT industry
FROM world_layoffs.staging_layoffs2
ORDER BY industry;

SELECT *
FROM world_layoffs.staging_layoffs2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Identify and handle missing Industry values 

SELECT *
FROM world_layoffs.staging_layoffs2
WHERE company LIKE 'Bally%';

SELECT *
FROM world_layoffs.staging_layoffs2
WHERE company LIKE 'airbnb%';

-- Convert Blank Industry Values to NULL 

UPDATE world_layoffs.staging_layoffs2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM world_layoffs.staging_layoffs2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Populate missing Industry values using self join

UPDATE staging_layoffs2 t1
JOIN staging_layoffs2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM world_layoffs.staging_layoffs2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Standardize industry categories

SELECT DISTINCT industry
FROM world_layoffs.staging_layoffs2
ORDER BY industry;

UPDATE staging_layoffs2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

SELECT DISTINCT industry
FROM world_layoffs.staging_layoffs2
ORDER BY industry;

-- Standardize Data Overview

SELECT *
FROM world_layoffs.staging_layoffs2 ;

-- Standardize country name

SELECT DISTINCT country
FROM world_layoffs.staging_layoffs2
ORDER BY country;

UPDATE staging_layoffs2
SET country = TRIM(TRAILING '.' FROM country);

SELECT DISTINCT country
FROM world_layoffs.staging_layoffs2
ORDER BY country;


-- Standardize and convert data column

SELECT *
FROM world_layoffs.staging_layoffs2;

UPDATE staging_layoffs2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE staging_layoffs2
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoffs.staging_layoffs2;

-- 3. Review and validate null value

SELECT *
FROM world_layoffs.staging_layoffs2
WHERE total_laid_off IS NULL;

SELECT *
FROM world_layoffs.staging_layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete irrelevant Records and finalize data

DELETE FROM world_layoffs.staging_layoffs2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM world_layoffs.staging_layoffs2;

ALTER TABLE staging_layoffs2
DROP COLUMN row_num;

-- Final Cleaned Data set for EDA

SELECT * 
FROM world_layoffs.staging_layoffs2;

--                ******
































