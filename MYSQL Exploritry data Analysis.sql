-- Exploritry Data Analysis 

-- View the entire data from the layoffs_staging2 table
SELECT * 
FROM layoffs_staging2;

-- Find the maximum number of layoffs and the highest layoff percentage in the dataset
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Show all companies that laid off 100% of their employees, sorted by the highest funding raised
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1  
ORDER BY funds_raised_millions DESC;

-- Calculate total layoffs per company and order them by highest layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Get the earliest and latest date of layoffs in the dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Calculate total layoffs by industry and order by highest layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Calculate total layoffs by country and order by highest layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Show total layoffs on each date, sorted by most recent dates first
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;

-- Calculate total layoffs for each year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Show total layoffs by funding stage (like Seed, Series A, etc.)
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Calculate total layoffs per month (format YYYY-MM), exclude rows where month is null
SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 6, 2) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;



-- Create a rolling monthly total of layoffs over time

-- Step 1: Get total layoffs per month
WITH Rolling_total AS (
  SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS total_off
  FROM layoffs_staging2
  WHERE SUBSTRING(`date`, 6, 2) IS NOT NULL
  GROUP BY `Month`
  ORDER BY 1 ASC
)

-- Step 2: Calculate cumulative (rolling) total layoffs month by month
SELECT `Month`, total_off, 
SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_total;



-- Calculate yearly layoffs per company, sorted by highest total layoffs
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;
					
-- Find the top 5 companies with the most layoffs per year

-- Step 1: Create a temporary table with total layoffs per company per year
WITH Company_year (Company, Years, total_laid_off) AS (
  SELECT company, YEAR(`date`), SUM(total_laid_off)
  FROM layoffs_staging2
  GROUP BY company, YEAR(`date`)
),

-- Step 2: Rank companies within each year by their total layoffs
Company_year_rank AS (
  SELECT *, DENSE_RANK() OVER(PARTITION BY Years ORDER BY total_laid_off DESC) AS Ranking
  FROM Company_year
  WHERE Years IS NOT NULL
)

-- Step 3: Get only the top 5 companies for each year
SELECT *
FROM Company_year_rank
WHERE Ranking <= 5;
                    