-- Data cleanning

select *
from layoffs;
-- 1. Remove Duplicate data
-- 2. Standardize the data
-- 3. Null Values or Blank Values
-- 4. Remove any Columns 

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

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

select *
from  layoffs_staging2;

Alter table layoffs_staging2
modify column `date` DATE;



select *
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

Select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select  t1.industry, t2.industry 
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company 
where t1.industry is null or t1.industry = ''
 and t2.industry is not null;
 
 update  layoffs_staging2 t1
 join layoffs_staging2 t2
on t1.company = t2.company 
set t1.industry = t2.industry
where t1.industry is null 
 and t2.industry is not null;
 
 update layoffs_staging2
 set industry = null
 where industry = '';
 
 delete
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

select *
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;






