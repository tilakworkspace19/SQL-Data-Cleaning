-- SQL Project Data Cleaning

SELECT* FROM world_layoffs.layoffs;

-- Creating a stagging tables,incase any issue ocuur we can have raw data
CREATE TABLE world_layoffs.layoffs_stagging
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_stagging
SELECT * FROM world_layoffs.layoffs;

SELECT * FROM world_layoffs.layoffs_stagging;

-- Checking for duplicates
-- we dont have any unique coloumn so we use row_number window function
WITH duplicate_cte AS(
SELECT *,ROW_NUMBER() 
OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_stagging)
SELECT * FROM duplicate_cte WHERE row_num>1;

-- Creating a new table like layoffs_stagging by adding a new coloumn row_num

CREATE TABLE`world_layoffs`. `layoffs_stagging2` (
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

INSERT INTO world_layoffs.layoffs_stagging2
SELECT *,ROW_NUMBER() 
OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_stagging;

SELECT * FROM world_layoffs.layoffs_stagging2;

-- deleting duplicate values
SELECT * FROM world_layoffs.layoffs_stagging2 
WHERE row_num>1;

DELETE FROM world_layoffs.layoffs_stagging2 
WHERE row_num>1;

-- Standardizing data

SELECT DISTINCT(company) FROM world_layoffs.layoffs_stagging2;
-- removing extra spaces
UPDATE world_layoffs.layoffs_stagging2 
SET company= TRIM(company);

SELECT DISTINCT(location) FROM world_layoffs.layoffs_stagging2;

SELECT DISTINCT(industry) 
FROM world_layoffs.layoffs_stagging2 
ORDER BY industry;

SELECT * FROM world_layoffs.layoffs_stagging2 
WHERE industry LIKE 'crypto%';

UPDATE world_layoffs.layoffs_stagging2
SET industry= 'Crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT(country) FROM world_layoffs.layoffs_stagging2
ORDER BY country;

SELECT * FROM world_layoffs.layoffs_stagging2 
WHERE country LIKE 'united states%';

UPDATE world_layoffs.layoffs_stagging2 
SET country= TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'united states%';

-- changing date coloumn from text to date format
SELECT `date` FROM world_layoffs.layoffs_stagging2;

UPDATE world_layoffs.layoffs_stagging2
SET `date`=STR_TO_DATE(`date`,'%m/%d/%Y');

-- modyfying coloumn name
ALTER TABLE world_layoffs.layoffs_stagging2 
MODIFY COLUMN `date` DATE;

SELECT * FROM world_layoffs.layoffs_stagging2;

-- checking for null empty values and trying to fill them

SELECT * FROM world_layoffs.layoffs_stagging2
WHERE industry IS NULL OR industry='' 
ORDER BY industry;


-- let's take a look at these
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';
-- nothing wrong here


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others.
-- now we write to queiry if there is a row with same company and location it will  update null rows



-- we can't update empty space so we change them into null values

UPDATE world_layoffs.layoffs_stagging2 
SET industry= NULL
WHERE industry='';

-- checking every empty is set into null
SELECT * FROM world_layoffs.layoffs_stagging2
WHERE industry IS NULL OR industry='' 
ORDER BY industry;


-- filling empty rows which have almost exact data and missing VALUES

UPDATE world_layoffs.layoffs_stagging2 AS t1
JOIN world_layoffs.layoffs_stagging2 AS t2
ON t1.company=t2.company 
AND  t1.location=t2.location
SET t1.industry=t2.industry
WHERE (t1.industry IS NULL OR t1.industry='')
AND t2.industry IS NOT NULL;

-- Removing row with null values from coloumns total_laid_off and percentage_laid_off as the table is about layoffs if these two coloumns are empty then those rows are not required

SELECT * FROM world_layoffs.layoffs_stagging2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE FROM world_layoffs.layoffs_stagging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- removing row_num coloumn we added
ALTER TABLE world_layoffs.layoffs_stagging2
DROP COLUMN row_num;


-- Final table after data cleaning

SELECT * FROM world_layoffs.layoffs_stagging2;