-- Explotary Data Analysis

SELECT * FROM world_layoffs.layoffs_stagging2;

-- let's  see total layoffs
SELECT SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2;


SELECT MAX(total_laid_off) ,MIN(total_laid_off)
FROM world_layoffs.layoffs_stagging2;

SELECT MAX(percentage_laid_off),MIN(percentage_laid_off)
FROM world_layoffs.layoffs_stagging2 
WHERE percentage_laid_off IS NOT NULL;

-- lets see maximum layoffs in a single company 
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_stagging2
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC
LIMIT 1;


-- lets see company with minimum layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_stagging2
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 
LIMIT 1;


-- companies where every employee laid off
 SELECT company 
 FROM world_layoffs.layoffs_stagging2
 WHERE percentage_laid_off=1;
 

 SELECT * FROM world_layoffs.layoffs_stagging2;
 
 -- industries where every employee laid off
 SELECT  industry 
 FROM world_layoffs.layoffs_stagging2
 WHERE percentage_laid_off=1
  GROUP BY industry;

-- country wise maximum layoffs
SELECT country,MAX(total_laid_off) 
FROM world_layoffs.layoffs_stagging2
GROUP BY country;

-- industry wise maximum layoffs
SELECT industry,MAX(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY industry
ORDER BY 2 DESC;

-- companies with most total layoffs 
SELECT company ,SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY company
ORDER BY 2 DESC;


-- industry with  most total layoffs
SELECT industry,SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY industry
ORDER BY 2 DESC;

-- countries with most total layoffs

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY country
ORDER BY 2 DESC;

-- lets see year wise with most layoffs
SELECT YEAR(`date`),SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage,SUM(total_laid_off)
FROM world_layoffs.layoffs_stagging2
GROUP BY stage
ORDER BY 2 DESC;


-- let see year wise layoff in different companies
WITH company_years AS(
SELECT company, YEAR(date) AS years , SUM(total_laid_off) AS laid_off
FROM world_layoffs.layoffs_stagging2
GROUP BY years,company),
company_rank AS(
SELECT company,years,laid_off,
DENSE_RANK() OVER(PARTITION BY years ORDER BY laid_off DESC) AS ranking
FROM company_years)
SELECT * FROM company_rank 
WHERE years is NOT NULL 
AND ranking <=3
ORDER BY years ASC;

-- rolling layoffs as per month
WITH month_date AS (
SELECT SUM(total_laid_off) AS laid_off, SUBSTRING(date,1,7) AS month_date FROM world_layoffs.layoffs_stagging2
GROUP BY month_date
ORDER BY month_date DESC),
rolling_total AS(
SELECT month_date ,laid_off,SUM(laid_off) OVER(ORDER BY month_date) AS rolling_total
FROM month_date)
SELECT * FROM rolling_total
WHERE month_date IS NOT NULL;

