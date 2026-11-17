
-- =====================================================
-- PROJECT: DATA CLEANING - LAYOFFS DATASET
-- DATABASE: world_layoffs

-- ORIGINAL RECORDS: 2,361
-- EXPECTED CLEANED RECORDS: 1,995
-- =====================================================


-- =====================================================
-- 1. EXPLORE ORIGINAL DATA
-- =====================================================

SELECT *
FROM layoffs;

DESCRIBE layoffs;

SELECT COUNT(*) AS total_records
FROM layoffs;


-- Check missing values

SELECT
    SUM(company IS NULL OR TRIM(company) = '') AS missing_company,
    SUM(industry IS NULL OR TRIM(industry) = '') AS missing_industry,
    SUM(total_laid_off IS NULL) AS missing_total_laid_off,
    SUM(percentage_laid_off IS NULL) AS missing_percentage,
    SUM(`date` IS NULL OR TRIM(`date`) = '') AS missing_date,
    SUM(country IS NULL OR TRIM(country) = '') AS missing_country
FROM layoffs;


-- =====================================================
-- 2. CHECK DUPLICATES
-- =====================================================

WITH duplicate_check AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs
)
SELECT *
FROM duplicate_check
WHERE row_num > 1;


-- =====================================================
-- 3. CHECK INVALID DATE VALUES
-- =====================================================

SELECT `date`
FROM layoffs
WHERE `date` IS NOT NULL
  AND TRIM(`date`) <> ''
  AND STR_TO_DATE(`date`, '%m/%d/%Y') IS NULL;


-- =====================================================
-- 4. CREATE FINAL CLEANED TABLE
-- =====================================================

-- This removes only the previous output table
-- Original layoffs table remains untouched.
-- Existing layoffs_staging and layoffs_staging2
-- tables also remain untouched.

DROP TABLE IF EXISTS layoffs_staging_final;


CREATE TABLE layoffs_staging_final (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` DATE,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT
);


-- =====================================================
-- 5. REMOVE DUPLICATES AND CLEAN DATA
-- =====================================================

INSERT INTO layoffs_staging_final (
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
)

WITH ranked_data AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs
),

deduplicated AS (
    SELECT *
    FROM ranked_data
    WHERE row_num = 1
),

normalized AS (
    SELECT
        TRIM(company) AS company,
        TRIM(location) AS location,
        NULLIF(TRIM(industry), '') AS industry,
        total_laid_off,
        percentage_laid_off,
        STR_TO_DATE(NULLIF(TRIM(`date`), ''), '%m/%d/%Y') AS `date`,
        NULLIF(TRIM(stage), '') AS stage,
        TRIM(TRAILING '.' FROM TRIM(country)) AS country,
        funds_raised_millions
    FROM deduplicated
    WHERE NOT (
        total_laid_off IS NULL
        AND percentage_laid_off IS NULL
    )
),

industry_mapping AS (
    SELECT
        company,
        MAX(industry) AS industry
    FROM normalized
    WHERE industry IS NOT NULL
    GROUP BY company
    HAVING COUNT(DISTINCT industry) = 1
)

SELECT
    n.company,
    n.location,
    COALESCE(n.industry, m.industry) AS industry,
    n.total_laid_off,
    n.percentage_laid_off,
    n.`date`,
    n.stage,
    n.country,
    n.funds_raised_millions
FROM normalized n
LEFT JOIN industry_mapping m
    ON n.company = m.company;


-- =====================================================
-- 6. FINAL DATA VERIFICATION
-- =====================================================

-- Check final records

SELECT COUNT(*) AS final_total_records
FROM layoffs_staging_final;


-- Check duplicates

WITH duplicate_check AS (
    SELECT
        ROW_NUMBER() OVER (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs_staging_final
)
SELECT COUNT(*) AS remaining_duplicates
FROM duplicate_check
WHERE row_num > 1;


-- Check remaining missing values

SELECT
    SUM(company IS NULL OR TRIM(company) = '') AS missing_company,
    SUM(industry IS NULL OR TRIM(industry) = '') AS missing_industry,
    SUM(`date` IS NULL) AS missing_dates,
    SUM(stage IS NULL OR TRIM(stage) = '') AS missing_stage,
    SUM(total_laid_off IS NULL
        AND percentage_laid_off IS NULL) AS missing_both_layoff_values
FROM layoffs_staging_final;


-- Check date range

SELECT
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date
FROM layoffs_staging_final;


-- View final cleaned dataset

SELECT *
FROM layoffs_staging_final;
