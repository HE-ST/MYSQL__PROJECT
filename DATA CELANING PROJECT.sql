-- Data cleanning



-- 1. Check original dataset

SELECT *
FROM layoffs;

-- 2. Check table structure

DESCRIBE layoffs;

-- 3. Check total records

SELECT COUNT(*) AS total_records
FROM layoffs;

-- 4. Check missing values

SELECT
    SUM(company IS NULL OR TRIM(company) = '') AS missing_company,
    SUM(industry IS NULL OR TRIM(industry) = '') AS missing_industry,
    SUM(total_laid_off IS NULL) AS missing_total_laid_off,
    SUM(percentage_laid_off IS NULL) AS missing_percentage,
    SUM(`date` IS NULL OR TRIM(`date`) = '') AS missing_date,
    SUM(country IS NULL OR TRIM(country) = '') AS missing_country
FROM layoffs;

-- 5. Check duplicate count

SELECT COUNT(*) AS duplicate_groups
FROM (
    SELECT
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    FROM layoffs
    GROUP BY
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    HAVING COUNT(*) > 1
) AS duplicates;
-- FIrst We Create a Copy of ROW data

CREATE TABLE layoffs_staging
like layoffs;

select *
from layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

select *
from layoffs_staging;

SELECT * ,
ROW_NUMBER() OVER(PaRTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions )as row_num
from  layoffs_staging;

with duplicate_cte as
(SELECT * ,
ROW_NUMBER() OVER(PaRTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions )as row_num
from  layoffs_staging
)
select *
from duplicate_cte
where row_num >1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

insert into layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(PaRTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions )as row_num
from  layoffs_staging;

select *
from layoffs_staging2
where row_num >1
;

SET SQL_SAFE_UPDATES = 0;

DELETE 
from layoffs_staging2
where row_num >1
;

-- standardization

select company , trim(company)
from  layoffs_staging2;

UPDATE layoffs_staging2
set company = trim(company);

select *
from  layoffs_staging2;
select distinct industry
from  layoffs_staging2;

update  layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country
from  layoffs_staging2;

select distinct country , trim(Trailing '.' from country)
from layoffs_staging2;

update layoffs_staging2
set country = trim(Trailing '.' from country)
where country like 'United States%';

select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

SELECT `date`
FROM layoffs_staging2
WHERE `date` IS NOT NULL
  AND STR_TO_DATE(`date`, '%m/%d/%Y') IS NULL;


update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select *
from  layoffs_staging2;

Alter table layoffs_staging2
modify column `date` DATE;



-- =========================================
-- 3. HANDLE NULL AND BLANK VALUES
-- =========================================

-- Step 1: Check rows with missing layoff information

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- Step 2: Check Airbnb records

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';


-- Step 3: Convert blank industry values into NULL

UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(industry) = '';


-- Step 4: Check missing industry values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;


-- Step 5: Find available industry values from same company

SELECT
    t1.company,
    t1.industry AS missing_industry,
    t2.industry AS available_industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- Step 6: Fill missing industry values safely

UPDATE layoffs_staging2 t1
JOIN (
    SELECT
        company,
        MAX(industry) AS industry
    FROM layoffs_staging2
    WHERE industry IS NOT NULL
      AND industry <> ''
    GROUP BY company
    HAVING COUNT(DISTINCT industry) = 1
) t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL;


-- Step 7: Remove rows with no layoff information

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- Step 8: Final check

SELECT *
FROM layoffs_staging2;


-- Step 9: Remove temporary column

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- =========================================
-- FINAL DATA VERIFICATION
-- =========================================

-- 1. View cleaned dataset

SELECT *
FROM layoffs_staging2;

-- 2. Check final total records

SELECT COUNT(*) AS final_total_records
FROM layoffs_staging2;

-- 3. Check missing company and industry

SELECT *
FROM layoffs_staging2
WHERE company IS NULL
   OR TRIM(company) = ''
   OR industry IS NULL
   OR TRIM(industry) = '';

-- 4. Check rows without layoff information

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

