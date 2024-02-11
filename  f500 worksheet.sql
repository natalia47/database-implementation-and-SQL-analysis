set worksheetname f500 worksheet


SELECT * from f500

SELECT * FROM f500_ceo_add

-- Create Zodiac column
SELECT dob_mmdd,
CASE WHEN dob_mmdd between '21-MAR-23' and '19-APR-23' THEN 'Aries'
     WHEN dob_mmdd between '20-APR-23' and '20-MAY-23' THEN 'Taurus'
     WHEN dob_mmdd between '21-MAY-23' and '20-JUN-23' THEN 'Gemini'
     WHEN dob_mmdd between '21-JUN-23' and '22-JUL-23' THEN 'Cancer'
     WHEN dob_mmdd between '23-JUL-23' and '22-AUG-23' THEN 'Leo'
     WHEN dob_mmdd between '23-AUG-23' and '22-SEP-23' THEN 'Virgo'
     WHEN dob_mmdd between '23-SEP-23' and '22-OCT-23' THEN 'Libra'
     WHEN dob_mmdd between '23-OCT-23' and '21-NOV-23' THEN 'Scorpio'
     WHEN dob_mmdd between '22-NOV-23' and '21-DEC-23' THEN 'Sagittarius'
     WHEN dob_mmdd between '22-DEC-23' and '31-DEC-23' THEN 'Capricorn'
     WHEN dob_mmdd between '01-JAN-23' and '19-JAN-23' THEN 'Capricorn'
     WHEN dob_mmdd between '20-JAN-23' and '18-FEB-23' THEN 'Aquarius'
     WHEN dob_mmdd between '19-FEB-23' and '20-MAR-23' THEN 'Pisces'
     ELSE null END AS zodiac
FROM f500_ceo_add
WHERE missing_dobs IS NULL

-- Create Age column
SELECT dob_yyyy, round((date '2023-12-31' - dob_yyyy)/365.25) AS age
FROM f500_ceo_add

-- Create Age Turned CEO column
SELECT dob_yyyy, round((yr_turned_ceo - dob_yyyy)/365.25) AS age_turned_ceo
FROM f500_ceo_add

-- Query the newly created columns
SELECT ceo_name, yr_turned_ceo, dob_yyyy, round((date '2023-12-31' - dob_yyyy)/365.25) AS age, round((yr_turned_ceo - dob_yyyy)/365.25) AS age_turned_ceo
FROM f500_ceo_add


---------------COMMIT NEW COLUMNS-----------------

SELECT * FROM f500_ceo_add

-- Add Zodiac column to table
ALTER TABLE f500_ceo_add
ADD zodiac varchar2(15)

-- Update Zodiac column in table
UPDATE f500_ceo_add
SET zodiac = 
CASE WHEN dob_mmdd between '21-MAR-23' and '19-APR-23' THEN 'Aries'
     WHEN dob_mmdd between '20-APR-23' and '20-MAY-23' THEN 'Taurus'
     WHEN dob_mmdd between '21-MAY-23' and '20-JUN-23' THEN 'Gemini'
     WHEN dob_mmdd between '21-JUN-23' and '22-JUL-23' THEN 'Cancer'
     WHEN dob_mmdd between '23-JUL-23' and '22-AUG-23' THEN 'Leo'
     WHEN dob_mmdd between '23-AUG-23' and '22-SEP-23' THEN 'Virgo'
     WHEN dob_mmdd between '23-SEP-23' and '22-OCT-23' THEN 'Libra'
     WHEN dob_mmdd between '23-OCT-23' and '21-NOV-23' THEN 'Scorpio'
     WHEN dob_mmdd between '22-NOV-23' and '21-DEC-23' THEN 'Sagittarius'
     WHEN dob_mmdd between '22-DEC-23' and '31-DEC-23' THEN 'Capricorn'
     WHEN dob_mmdd between '01-JAN-23' and '19-JAN-23' THEN 'Capricorn'
     WHEN dob_mmdd between '20-JAN-23' and '18-FEB-23' THEN 'Aquarius'
     WHEN dob_mmdd between '19-FEB-23' and '20-MAR-23' THEN 'Pisces'
     ELSE null END
WHERE missing_dobs IS NULL

-- Add Age column to table
ALTER TABLE f500_ceo_add
ADD age int

-- Update Age column in table
UPDATE f500_ceo_add
SET age = round((date '2023-12-31' - dob_yyyy)/365.25)

-- Add Age Turned CEO column to table
ALTER TABLE f500_ceo_add
ADD age_turned_ceo int

-- Update Age turned CEO column in table
UPDATE f500_ceo_add
SET age_turned_ceo = round((yr_turned_ceo - dob_yyyy)/365.25)


---------JOIN F500 and F500_CEO_ADD tables-------------

-- Create join
SELECT * FROM f500 f JOIN f500_ceo_add f_add
ON f.ceo = f_add.ceo_name

-- Create view for join
CREATE VIEW FullF500 AS
SELECT * FROM f500 f JOIN f500_ceo_add f_add
ON f.ceo = f_add.ceo_name

SELECT * FROM fullf500

SELECT count(*) FROM fullf500

----------ZODIAC----------------------

SELECT count(zodiac) 
FROM fullf500

-- Distribution of zodiacs
SELECT zodiac, count(zodiac) 
FROM fullf500
GROUP BY zodiac
ORDER BY count(zodiac) DESC

-- Number of zodiac records in each sector
SELECT DISTINCT sector, count(sector)
FROM fullf500
WHERE zodiac IS NOT NULL
GROUP BY sector
ORDER BY count(sector) DESC

-- Industries per zodiac
SELECT sector, zodiac, count(zodiac) 
FROM fullf500
WHERE zodiac IS NOT NULL
GROUP BY sector, zodiac
ORDER BY zodiac

-- High to low zodiac counts by industry
SELECT sector, zodiac, count(zodiac) 
FROM fullf500
WHERE zodiac IS NOT NULL
GROUP BY sector, zodiac
ORDER BY count(zodiac) DESC

-- Run a Zodiac by Age Group CTE to get age group counts
-- This did not provide much value so I did not include it in my report
WITH zodiacAge AS (
SELECT zodiac,
CASE  WHEN age BETWEEN 20 AND 29 THEN '20s'
      WHEN age BETWEEN 30 AND 39 THEN '30s'
      WHEN age BETWEEN 40 AND 49 THEN '40s'
      WHEN age BETWEEN 50 AND 59 THEN '50s'
      WHEN age BETWEEN 60 AND 69 THEN '60s'
      WHEN age BETWEEN 70 AND 79 THEN '70s'
      WHEN age BETWEEN 80 AND 89 THEN '80s'
      WHEN age BETWEEN 90 AND 99 THEN '90s'
      WHEN age BETWEEN 100 AND 110 THEN '100+'
END AS ageGroup
FROM fullf500
WHERE zodiac IS NOT NULL
ORDER BY zodiac, ageGroup
)
SELECT zodiac, ageGroup, count(*) AS groupCount
FROM zodiacAge
GROUP BY zodiac, ageGroup
ORDER BY zodiac, ageGroup

-- Zodiac counts by gender
SELECT ceo_woman, zodiac, count(zodiac) 
FROM fullf500
WHERE zodiac IS NOT NULL
GROUP BY ceo_woman, zodiac
ORDER BY zodiac

-- Zodiac counts: Female
SELECT ceo_woman, zodiac, count(zodiac) 
FROM fullf500
WHERE zodiac IS NOT NULL  AND ceo_woman = 'yes'
GROUP BY ceo_woman, zodiac
ORDER BY count(zodiac) DESC

-- Zodiac counts: Male
SELECT ceo_woman, zodiac, count(zodiac) 
FROM fullf500
WHERE zodiac IS NOT NULL AND ceo_woman = 'no'
GROUP BY ceo_woman, zodiac
ORDER BY count(zodiac) DESC

-- List of founders and their zodiac signs
SELECT ceo, ceo_founder, zodiac 
FROM fullf500
WHERE ceo_founder = 'yes'AND zodiac IS NOT NULL

-- Zodiac counts: Founders
SELECT ceo_founder, zodiac, count(zodiac) 
FROM fullf500
WHERE ceo_founder = 'yes'AND zodiac IS NOT NULL
GROUP BY ceo_founder, zodiac
ORDER BY count(zodiac) DESC

------EDUCATION--------

-- Top Schools (Bachelors)
SELECT ceo_bach_school, count(ceo_bach_school) 
FROM fullf500
WHERE ceo_bach_school IS NOT NULL AND ceo_bach_school != 'no'
GROUP BY ceo_bach_school
ORDER BY count(ceo_bach_school) DESC

-- Top 20 (Bachelors)
SELECT ceo_bach_school, count(ceo_bach_school) 
FROM fullf500
WHERE ceo_bach_school IS NOT NULL AND ceo_bach_school != 'no'
GROUP BY ceo_bach_school
ORDER BY count(ceo_bach_school) DESC
FETCH FIRST 27 ROWS ONLY

-- Count of top 20 (Bach)
SELECT ceo_bach_school, count(ceo_bach_school) 
FROM fullf500
WHERE ceo_bach_school IS NOT NULL AND ceo_bach_school != 'no'
GROUP BY ceo_bach_school
ORDER BY count(ceo_bach_school) DESC
FETCH FIRST 20 ROWS ONLY

-- Count of ivy leagues in top 20
SELECT ceo_bach_school, count(ceo_bach_school) 
FROM fullf500
WHERE ceo_bach_school IS NOT NULL AND ceo_bach_school != 'no'
AND ceo_bach_school IN ('UPenn', 'Harvard', 'Cornell', 'Brown', 'Dartmouth', 'Princeton')
GROUP BY ceo_bach_school
ORDER BY count(ceo_bach_school) DESC

-- Count of hidden ivies in top 20
SELECT ceo_bach_school, count(ceo_bach_school) 
FROM fullf500
WHERE ceo_bach_school IS NOT NULL AND ceo_bach_school != 'no'
AND ceo_bach_school IN ('Stanford', 'Georgetown', 'University of Virginia', 
                          'University of Michigan, Ann Arbor', 'University of Texas, Austin',
                          'Notre Dame')
GROUP BY ceo_bach_school
ORDER BY count(ceo_bach_school) DESC

-- Ivy League total Bachelors count
SELECT count(*) 
FROM fullf500
WHERE ceo_bach_school IN ('Brown', 'Columbia', 'Cornell', 'Dartmouth', 'Harvard', 'UPenn', 'Princeton', 'Yale')

-- Total Bach count of highly esteemed universities in top 20
SET DEFINE OFF
SELECT count(*) 
FROM fullf500
WHERE ceo_bach_school IN ('Brown', 'Cornell', 'Dartmouth', 'Harvard', 'UPenn', 'Princeton',
                          'Stanford', 'Georgetown', 'University of Virginia', 
                          'University of Michigan, Ann Arbor', 'University of Texas, Austin',
                          'Notre Dame')                  

-- Sum total of Bach count in top 20 universities
SELECT sum(ceo_bach_school_count) 
FROM (
    SELECT ceo_bach_school, count(ceo_bach_school) AS ceo_bach_school_count 
    FROM fullf500
    WHERE ceo_bach_school IS NOT NULL AND ceo_bach_school != 'no'
    GROUP BY ceo_bach_school
    ORDER BY count(ceo_bach_school) DESC
    FETCH FIRST 27 ROWS ONLY
)

-- Sum of total Bach count outside of the top 20 universities
SELECT sum(ceo_bach_school_count) 
FROM (
    SELECT ceo_bach_school, count(ceo_bach_school) AS ceo_bach_school_count 
    FROM fullf500
    WHERE ceo_bach_school IS NOT NULL AND ceo_bach_school != 'no'
    GROUP BY ceo_bach_school
    ORDER BY count(ceo_bach_school) DESC
    OFFSET 20 ROWS
)

-- Top Schools (Masters)
SELECT mast_school, sum(attendance_count) 
FROM (
    SELECT ceo_mast_school AS mast_school, count(ceo_mast_school) AS attendance_count 
    FROM fullf500
    GROUP BY ceo_mast_school
    UNION
    SELECT second_mast_school AS mast_school, count(second_mast_school) AS attendance_count 
    FROM fullf500
    GROUP BY second_mast_school
    )
WHERE mast_school != 'no'
GROUP BY mast_school
ORDER BY sum(attendance_count) DESC

-- Count by Top 20 School (Masters)
SELECT mast_school, sum(attendance_count) 
FROM (
    SELECT ceo_mast_school AS mast_school, count(ceo_mast_school) AS attendance_count 
    FROM fullf500
    GROUP BY ceo_mast_school
    UNION
    SELECT second_mast_school AS mast_school, count(second_mast_school) AS attendance_count 
    FROM fullf500
    GROUP BY second_mast_school
    )
WHERE mast_school != 'no'
GROUP BY mast_school
ORDER BY sum(attendance_count) DESC
FETCH FIRST 20 ROWS ONLY

-- Total Masters attendance in top 20 universities
SELECT SUM(attendance_count) as total_attendance
FROM (
    SELECT mast_school, COUNT(*) AS attendance_count
    FROM (
        SELECT ceo_mast_school AS mast_school
        FROM fullf500
        WHERE ceo_mast_school != 'no'
        UNION ALL
        SELECT second_mast_school AS mast_school
        FROM fullf500
        WHERE second_mast_school != 'no'
    )
    GROUP BY mast_school
    ORDER BY COUNT(*) DESC
)
WHERE ROWNUM <= 20

-- Grand total of Masters attendance
SELECT SUM(attendance_count) AS total_attendance
FROM (
    SELECT mast_school, COUNT(*) AS attendance_count
    FROM (
        SELECT ceo_mast_school AS mast_school
        FROM fullf500
        WHERE ceo_mast_school != 'no' AND ceo_mast_school IS NOT NULL
        UNION ALL
        SELECT second_mast_school AS mast_school
        FROM fullf500
        WHERE second_mast_school != 'no' AND second_mast_school IS NOT NULL
    )
    GROUP BY mast_school
    ORDER BY COUNT(*) DESC
)

--- Total Masters attendance in Ivy League Schools
WITH MastersSchools AS (
    SELECT mast_school, COUNT(*) AS total_attendance
    FROM (
        SELECT ceo_mast_school AS mast_school
        FROM fullf500
        WHERE ceo_mast_school != 'no'
        UNION ALL
        SELECT second_mast_school AS mast_school
        FROM fullf500
        WHERE second_mast_school != 'no'
    )
    WHERE mast_school IN ('Brown', 'Columbia', 'Cornell', 'Dartmouth', 'Harvard', 'UPenn', 'Princeton', 'Yale')
    GROUP BY mast_school
)
SELECT SUM(total_attendance) AS total_attendance_count
FROM MastersSchools

-- Number of Ivy League in top 20 (Masters)
WITH MastersSchools AS (
    SELECT mast_school, COUNT(*) AS total_attendance
    FROM (
        SELECT ceo_mast_school AS mast_school
        FROM fullf500
        WHERE ceo_mast_school != 'no'
        UNION ALL
        SELECT second_mast_school AS mast_school
        FROM fullf500
        WHERE second_mast_school != 'no'
    )
    WHERE mast_school IN ('Harvard', 'UPenn', 'Columbia', 'Darthmouth')
    GROUP BY mast_school
)
SELECT SUM(total_attendance) AS total_attendance_count
FROM MastersSchools

--- Total Masters attendance at Highly Esteemed universities within the top 20
WITH MastersSchools AS (
    SELECT mast_school, COUNT(*) AS total_attendance
    FROM (
        SELECT ceo_mast_school AS mast_school
        FROM fullf500
        WHERE ceo_mast_school != 'no'
        UNION ALL
        SELECT second_mast_school AS mast_school
        FROM fullf500
        WHERE second_mast_school != 'no'
    )
    WHERE mast_school IN ('Harvard', 'UPenn', 'Columbia', 'Northwestern', 'Stanford', 'University of Chicago', 
                          'MIT', 'NYU', 'UCLA', 'University of Texas, Austin', 'University of Michigan, Ann Arbor',
                          'Dartmouth', 'University of Virginia', 'University of California, Berkeley', 'Texas A&M')
    GROUP BY mast_school
)
SELECT SUM(total_attendance) AS total_attendance_count
FROM MastersSchools

-- Overall top schools attended by CEOs
SELECT school, sum(ceo_count) 
FROM (
    SELECT ceo_bach_school AS school, count(ceo_bach_school) AS ceo_count 
    FROM fullf500
    GROUP BY ceo_bach_school
    UNION ALL
    SELECT ceo_mast_school AS school, count(ceo_mast_school) AS ceo_count 
    FROM fullf500
    GROUP BY ceo_mast_school
    UNION ALL
    SELECT second_mast_school AS school, count(second_mast_school) AS ceo_count 
    FROM fullf500
    GROUP BY second_mast_school
    )
WHERE school != 'no' AND school IS NOT NULL
GROUP BY school
ORDER BY sum(ceo_count) DESC

-- Top Majors (Bachelors)
SELECT ceo_bach_major, count(ceo_bach_major) 
FROM fullf500
WHERE ceo_bach_major IS NOT NULL
GROUP BY ceo_bach_major
ORDER BY count(ceo_bach_major) DESC

-- Unique Number of Bachelor's Majors
SELECT DISTINCT count(ceo_bach_major)
FROM (
      SELECT ceo_bach_major, count(ceo_bach_major) 
      FROM fullf500
      WHERE ceo_bach_major IS NOT NULL
      GROUP BY ceo_bach_major
      ORDER BY count(ceo_bach_major) DESC
      )

-- Top Majors (Masters)
SELECT mast_major, sum(degree_count) 
FROM (
    SELECT ceo_mast_major AS mast_major, count(ceo_mast_major) AS degree_count 
    FROM fullf500
    GROUP BY ceo_mast_major
    UNION
    SELECT second_mast_major AS mast_major, count(second_mast_major) AS degree_count 
    FROM fullf500
    GROUP BY second_mast_major
    ORDER BY degree_count DESC
    )
WHERE mast_major != 'no'
GROUP BY mast_major
ORDER BY sum(degree_count) DESC

-- Unique Number of Master's Majors
SELECT DISTINCT count(mast_major)
FROM (
    SELECT mast_major, sum(degree_count) 
    FROM (
        SELECT ceo_mast_major AS mast_major, count(ceo_mast_major) AS degree_count 
        FROM fullf500
        GROUP BY ceo_mast_major
        UNION
        SELECT second_mast_major AS mast_major, count(second_mast_major) AS degree_count 
        FROM fullf500
        GROUP BY second_mast_major
        ORDER BY degree_count DESC
         )
    WHERE mast_major != 'no'
    GROUP BY mast_major
    ORDER BY sum(degree_count) DESC
    )

-- How many Engineering Masters degrees?
SELECT * 
FROM fullf500
WHERE ceo_mast_major = 'Industrial Engineering' OR second_mast_major = 'Industrial Engineering'

-- 1) query all engineering majors
SELECT mast_major, sum(degree_count) 
FROM (
    SELECT ceo_mast_major AS mast_major, count(ceo_mast_major) AS degree_count 
    FROM fullf500
    GROUP BY ceo_mast_major
    UNION ALL
    SELECT second_mast_major AS mast_major, count(second_mast_major) AS degree_count 
    FROM fullf500
    GROUP BY second_mast_major
    ORDER BY degree_count DESC
    )
WHERE mast_major LIKE '%Engineering%'
GROUP BY mast_major
ORDER BY sum(degree_count) DESC

-- 2) get grand total of engineering majors
SELECT SUM(total_count) AS grand_total_count
FROM (
    SELECT mast_major, SUM(degree_count) AS total_count
    FROM (
        SELECT ceo_mast_major AS mast_major, COUNT(ceo_mast_major) AS degree_count
        FROM fullf500
        GROUP BY ceo_mast_major
        UNION ALL
        SELECT second_mast_major AS mast_major, COUNT(second_mast_major) AS degree_count
        FROM fullf500
        GROUP BY second_mast_major
    )
    WHERE mast_major LIKE '%Engineering%'
    GROUP BY mast_major
)

-- OR use CTE to get grand total
WITH MajorCounts AS (
    SELECT ceo_mast_major AS mast_major, COUNT(ceo_mast_major) AS degree_count 
    FROM fullf500
    GROUP BY ceo_mast_major
    UNION ALL
    SELECT second_mast_major AS mast_major, COUNT(second_mast_major) AS degree_count 
    FROM fullf500
    GROUP BY second_mast_major
)
SELECT SUM(degree_count) AS total_count
FROM MajorCounts
WHERE mast_major LIKE '%Engineering%'

-- Total CEOs who obtained a Bachelors degree
SELECT count(ceo_bach_major), count(ceo_bach_school) 
FROM fullf500
WHERE dropped_out = 'no' AND ceo_bach_school != 'no'

-- Percent of CEOs who obtained a Bachelors
SELECT ROUND((COUNT(CASE WHEN dropped_out = 'no' 
                    AND ceo_bach_school IS NOT NULL 
                    AND ceo_bach_school != 'no' THEN 1 END) / COUNT(*)) * 100, 1) AS percentage
FROM fullf500

--Total CEOs who obtained a Masters degree
SELECT count(ceo_mast_major), count(ceo_mast_school)
FROM fullf500
WHERE dropped_out = 'no' AND ceo_mast_school != 'no'

-- Percent of CEOs who obtained a Masters
SELECT ROUND((COUNT(CASE WHEN ceo_mast_school IS NOT NULL AND ceo_mast_school != 'no' THEN 1 END) / COUNT(*)) * 100, 1) AS percentage
FROM fullf500

-- Total CEOs who obtained a Second Masters
SELECT count(second_mast_major), count(second_mast_school)
FROM fullf500
WHERE dropped_out = 'no' AND second_mast_school != 'no'

-- Percent of CEOs who obtained a Second Masters
SELECT ROUND((COUNT(CASE WHEN dropped_out = 'no' 
                         AND second_mast_school IS NOT NULL 
                         AND second_mast_school != 'no' THEN 1 END) / COUNT(*)) * 100, 1) AS percentage
FROM fullf500

-- Total CEOs who obtained a Third Masters
SELECT count(third_mast_major), count(third_mast_school)
FROM fullf500
WHERE dropped_out = 'no' AND third_mast_school != 'no'

-- Percent of CEOs who obtained Third Masters
SELECT ROUND((COUNT(CASE WHEN dropped_out = 'no' 
                         AND third_mast_school IS NOT NULL 
                         AND third_mast_school != 'no' THEN 1 END) / COUNT(*)) * 100, 1) AS percentage
FROM fullf500

-- PhD Categories and Counts
SELECT phd , count(phd) 
FROM fullf500
GROUP BY phd

-- Percent of CEOs with a PhD
SELECT ROUND(SUM(CASE WHEN phd = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100.0, 1) AS percentage
FROM fullf500

-- Percent of CEOs with an Honorary PhD
SELECT ROUND(SUM(CASE WHEN phd = 'honorary' THEN 1 ELSE 0 END) / COUNT(*) * 100.0, 1) AS percentage
FROM fullf500

-- Number of founders with an Honorary PhD
SELECT * 
FROM fullf500
WHERE phd = 'honorary' AND ceo_founder = 'yes'

-- Total CEOs who never pursued their Bachelors
SELECT count(*) 
FROM (   
    SELECT ceo_bach_major, ceo_bach_school 
    FROM fullf500
    WHERE ceo_bach_major = 'no'
    )

-- Who are they?    
SELECT * 
FROM fullf500
WHERE ceo_bach_major = 'no' 

-- Total CEOs who dropped out of college
SELECT * 
FROM fullf500
WHERE dropped_out = 'yes'

-- How many CEOs that dropped out are founders?
SELECT * 
FROM fullf500
WHERE dropped_out = 'yes' AND ceo_founder = 'yes'

-- Degree Vs Industry (Bachelors)
SELECT DISTINCT sector 
FROM fullf500

SELECT sector, ceo_bach_major, count(ceo_bach_major) 
FROM fullf500
WHERE ceo_bach_major IS NOT NULL AND ceo_bach_major != 'no'
GROUP BY sector, ceo_bach_major
ORDER BY sector

-- Degree Vs Industry (Masters)
SELECT sector, ceo_mast_major, count(ceo_mast_major) 
FROM fullf500
WHERE ceo_mast_major IS NOT NULL AND ceo_mast_major != 'no'
GROUP BY sector, ceo_mast_major
ORDER BY sector
    
----------ORIGIN---------------

-- Where the largest number of CEOs were born
SELECT DISTINCT birth_state, count(birth_state) 
FROM fullf500
GROUP BY birth_state
ORDER BY count(birth_state) DESC

-- Where the largest number of CEOs were raised
SELECT DISTINCT origin_state, count(origin_state) 
FROM fullf500
GROUP BY origin_state
ORDER BY count(origin_state) DESC

-- Where the largest number of CEOs currently reside
SELECT DISTINCT current_residence, count(current_residence) 
FROM fullf500
GROUP BY current_residence
ORDER BY count(current_residence) DESC

-- Distinct Headquarter States
SELECT state, count(state)
FROM fullf500
GROUP BY state
ORDER BY count(state) DESC

-- Birth states and counts of Non-US Born CEOs
SELECT birth_state, count(birth_state)
FROM fullf500
WHERE LENGTH(birth_state) > 2
GROUP BY birth_state
ORDER BY count(birth_state) DESC

-- Total Count of non-US born CEOs
SELECT COUNT(*)
FROM fullf500
WHERE LENGTH(birth_state) > 2   
    
-- Percent of non-US born CEOs
SELECT
  ROUND((non_us_count / non_null_count) * 100, 1) AS percentage
FROM (
  SELECT
    COUNT(CASE WHEN LENGTH(birth_state) > 2 THEN 1 END) AS non_us_count,
    COUNT(*) AS non_null_count
  FROM fullf500
  WHERE birth_state IS NOT NULL
)

-- Total Count of non-US born CEOs (origin state)
SELECT COUNT(*)
FROM fullf500
WHERE LENGTH(origin_state) > 2   

-- Percent of non-US born CEOs (origin state)
SELECT
  ROUND((non_us_count / non_null_count) * 100, 1) AS percentage
FROM (
  SELECT
    COUNT(CASE WHEN LENGTH(origin_state) > 2 THEN 1 END) AS non_us_count,
    COUNT(*) AS non_null_count
  FROM fullf500
  WHERE origin_state IS NOT NULL
)

-- CEOs who relocated from their birth state
SELECT * 
FROM fullf500
WHERE birth_state != current_residence
AND birth_state IS NOT NULL and current_residence IS NOT NULL

-- CEOs who relocated from their home state
SELECT * 
FROM fullf500
WHERE origin_state != current_residence
AND origin_state IS NOT NULL and current_residence IS NOT NULL

-- CEOs who still reside in their birth state
SELECT * 
FROM fullf500
WHERE birth_state = current_residence

-- CEOs who still reside in their home state
SELECT * 
FROM fullf500
WHERE origin_state = current_residence

-- Industry Vs Location
SELECT sector, state, current_residence, count(state), count(current_residence) 
FROM fullf500
GROUP BY sector, state, current_residence
ORDER BY sector, count(current_residence) DESC

-- CEOs who do not live in the same state the company is headquartered in
SELECT ceo_name, state, current_residence, sector
FROM fullf500
WHERE state != current_residence

----------GENDER---------------

-- List of Female CEOs on the Fortune 500
SELECT * 
FROM fullf500
WHERE ceo_woman = 'yes'

-- Count of Female CEOs
SELECT count(*) 
FROM fullf500
WHERE ceo_woman = 'yes'

-- Percent of Female CEOs
SELECT ROUND((COUNT(CASE WHEN ceo_woman = 'yes' THEN 1 END) / COUNT(*)) * 100, 1) AS percentage
FROM fullf500

-- Industries with Female CEOs
SELECT DISTINCT sector, count(sector) 
FROM fullf500
WHERE ceo_woman = 'yes'
GROUP BY sector
ORDER BY count(sector) DESC

-- Number of Female vs Male CEOs per Industry
SELECT DISTINCT sector, ceo_woman, count(sector), count(ceo_woman) 
FROM fullf500
GROUP BY sector, ceo_woman
ORDER BY sector, ceo_woman DESC

-- Female Founders
SELECT * 
FROM fullf500
WHERE ceo_woman = 'yes' AND ceo_founder = 'yes'

-- Male vs Female Newcomers
SELECT DISTINCT ceo_woman, count(ceo_woman) 
FROM fullf500
WHERE newcomer = 'yes'
GROUP BY ceo_woman

------AGE--------

-- List of CEOs under 40
SELECT * 
FROM fullf500
WHERE age <= 40
ORDER BY age ASC

-- List of CEOs who became CEO under 30
SELECT * 
FROM fullf500
WHERE age_turned_ceo <= 29
ORDER BY age_turned_ceo ASC

-- Age When Fortune 500 CEOs Became CEO
SELECT DISTINCT age_turned_ceo, count(age_turned_ceo) 
FROM fullf500
GROUP BY age_turned_ceo
ORDER BY age_turned_ceo ASC

-- CEOs Who Became CEO at 40 or younger
SELECT * 
FROM fullf500
WHERE age_turned_ceo <= 40

-- How many of those are founders vs. non-founders?
SELECT ceo_founder, count(ceo_founder) 
FROM (
    SELECT * 
    FROM fullf500
    WHERE age_turned_ceo <= 40
    )
GROUP BY ceo_founder

-- How many founders total
SELECT count(ceo_founder)
FROM fullf500
WHERE ceo_founder = 'yes'

-- Ages of Newcomers
SELECT DISTINCT age, count(age) 
FROM fullf500
WHERE newcomer = 'yes'
GROUP BY age
ORDER BY count(age) DESC

-- Age Range of Newcomers
SELECT min(age), max(age) 
FROM fullf500
WHERE newcomer = 'yes'

-- Current Age Distribution of CEOs
WITH AgeGroups AS (
  SELECT
    CASE
      WHEN age BETWEEN 20 AND 29 THEN '20s'
      WHEN age BETWEEN 30 AND 39 THEN '30s'
      WHEN age BETWEEN 40 AND 49 THEN '40s'
      WHEN age BETWEEN 50 AND 59 THEN '50s'
      WHEN age BETWEEN 60 AND 69 THEN '60s'
      WHEN age BETWEEN 70 AND 79 THEN '70s'
      WHEN age BETWEEN 80 AND 89 THEN '80s'
      WHEN age BETWEEN 90 AND 99 THEN '90s'
      WHEN age BETWEEN 100 AND 110 THEN '100+'
    END AS age_group
  FROM fullf500
)
SELECT
  age_group,
  COUNT(age_group) AS age_group_count,
  ROUND((COUNT(age_group) / (SELECT COUNT(*) FROM fullf500 WHERE age IS NOT NULL)) * 100, 1) AS percentage
FROM AgeGroups
GROUP BY age_group
ORDER BY age_group

-- Distribution of Age Turned CEO
WITH AgeGroupsTurnedCEO AS (
  SELECT
    CASE
      WHEN age_turned_ceo BETWEEN 0 AND 19 THEN 'Under 20'    
      WHEN age_turned_ceo BETWEEN 20 AND 29 THEN '20s'
      WHEN age_turned_ceo BETWEEN 30 AND 39 THEN '30s'
      WHEN age_turned_ceo BETWEEN 40 AND 49 THEN '40s'
      WHEN age_turned_ceo BETWEEN 50 AND 59 THEN '50s'
      WHEN age_turned_ceo BETWEEN 60 AND 69 THEN '60s'
      WHEN age_turned_ceo BETWEEN 70 AND 79 THEN '70s'
      WHEN age_turned_ceo BETWEEN 80 AND 89 THEN '80s'
      WHEN age_turned_ceo BETWEEN 90 AND 99 THEN '90s'
      WHEN age_turned_ceo BETWEEN 100 AND 110 THEN '100+'
    END AS age_group_turned_ceo
  FROM fullf500
)
SELECT age_group_turned_ceo, count(age_group_turned_ceo),
       ROUND((COUNT(age_group_turned_ceo) / (SELECT COUNT(*) FROM fullf500 WHERE age_turned_ceo IS NOT NULL)) * 100, 1) AS percentage
FROM AgeGroupsTurnedCEO
GROUP BY age_group_turned_ceo
ORDER BY age_group_turned_ceo
    
-- Current Age Male vs Female
WITH AgeGroups AS (
  SELECT
    CASE
      WHEN age BETWEEN 20 AND 29 THEN '20s'
      WHEN age BETWEEN 30 AND 39 THEN '30s'
      WHEN age BETWEEN 40 AND 49 THEN '40s'
      WHEN age BETWEEN 50 AND 59 THEN '50s'
      WHEN age BETWEEN 60 AND 69 THEN '60s'
      WHEN age BETWEEN 70 AND 79 THEN '70s'
      WHEN age BETWEEN 80 AND 89 THEN '80s'
      WHEN age BETWEEN 90 AND 99 THEN '90s'
      WHEN age BETWEEN 100 AND 110 THEN '100+'
    END AS age_group, ceo_woman
  FROM fullf500
)
SELECT
  age_group, 
  ceo_woman,
  COUNT(age_group) AS age_group_count,
  ROUND((COUNT(age_group) / (SELECT COUNT(*) FROM fullf500 WHERE age IS NOT NULL)) * 100, 1) AS percentage
FROM AgeGroups
GROUP BY age_group, ceo_woman
ORDER BY age_group, ceo_woman

-- Current age range of male CEOS
SELECT min(age), max(age) 
FROM fullf500
WHERE ceo_woman = 'no'
    
-- Current age range of female CEOs
SELECT min(age), max(age) 
FROM fullf500
WHERE ceo_woman = 'yes'

--When did female CEOs become CEO compared to male CEOs
WITH AgeGroupsTurnedCEO AS (
  SELECT
    CASE
      WHEN age_turned_ceo BETWEEN 0 AND 19 THEN 'Under 20'    
      WHEN age_turned_ceo BETWEEN 20 AND 29 THEN '20s'
      WHEN age_turned_ceo BETWEEN 30 AND 39 THEN '30s'
      WHEN age_turned_ceo BETWEEN 40 AND 49 THEN '40s'
      WHEN age_turned_ceo BETWEEN 50 AND 59 THEN '50s'
      WHEN age_turned_ceo BETWEEN 60 AND 69 THEN '60s'
      WHEN age_turned_ceo BETWEEN 70 AND 79 THEN '70s'
      WHEN age_turned_ceo BETWEEN 80 AND 89 THEN '80s'
      WHEN age_turned_ceo BETWEEN 90 AND 99 THEN '90s'
      WHEN age_turned_ceo BETWEEN 100 AND 110 THEN '100+'
    END AS age_group_turned_ceo, ceo_woman
  FROM fullf500
)
SELECT age_group_turned_ceo, 
       ceo_woman,
       count(age_group_turned_ceo),
       ROUND((COUNT(age_group_turned_ceo) / (SELECT COUNT(*) FROM fullf500 WHERE age_turned_ceo IS NOT NULL)) * 100, 1) AS percentage
FROM AgeGroupsTurnedCEO
GROUP BY age_group_turned_ceo, ceo_woman
ORDER BY age_group_turned_ceo, ceo_woman
 

------PATH TO CEO--------------    

SELECT * 
FROM fullf500
WHERE previously_ceo IS NULL
    
-- Count of various ways CEOs attained the top spot
SELECT DISTINCT previously_ceo, count(previously_ceo) 
FROM fullf500
GROUP BY previously_ceo
ORDER BY count(previously_ceo) DESC
    
-- Add percent per category to above query
SELECT
  previously_ceo,
  COUNT(previously_ceo) AS count,
  ROUND((COUNT(previously_ceo) / (SELECT COUNT(*) FROM fullf500 WHERE previously_ceo IS NOT NULL)) * 100, 1) AS percentage
FROM fullf500
WHERE previously_ceo IS NOT NULL
GROUP BY previously_ceo
ORDER BY count(previously_ceo) DESC

-- List of Newcomer CEOs
SELECT * 
FROM fullf500
WHERE newcomer = 'yes'

-- Count of Newcomers vs Existing CEOs
SELECT DISTINCT newcomer, count(newcomer) 
FROM fullf500
GROUP BY newcomer

----------PROFITABILITY---------------
    
-- Most Profitable Industries
SELECT DISTINCT sector, sum(profit) 
FROM fullf500
GROUP BY sector
ORDER BY sum(profit) DESC

-- Most Profitable Companies
SELECT ceo, company, sector, profit 
FROM fullf500
WHERE profit IS NOT NULL
ORDER BY profit DESC

-- Most Profitable Company per Sector
WITH RankedCompanies AS (
  SELECT
    ceo,
    company,
    sector,
    profit,
    ROW_NUMBER() OVER (PARTITION BY sector ORDER BY profit DESC) AS company_rank
  FROM fullf500
  WHERE profit IS NOT NULL
)
SELECT ceo, company, sector, profit
FROM RankedCompanies
WHERE company_rank = 1
ORDER BY profit DESC

-- Calculate median profit per industry (deduplicate company names)
SELECT
    sector AS Industry,
    MEDIAN(profit) AS MedianProfit
FROM (
    SELECT
        sector,
        profit,
        ROW_NUMBER() OVER(PARTITION BY sector ORDER BY profit) AS Row_Num,
        COUNT(*) OVER(PARTITION BY sector) AS TotalCount
    FROM (
        SELECT
            sector,
            profit,
            ROW_NUMBER() OVER(PARTITION BY sector, company ORDER BY profit) AS company_row_num
        FROM fullf500
        WHERE profit IS NOT NULL 
    )
    WHERE company_row_num = 1 
)
WHERE Row_Num = CEIL(TotalCount / 2.0) OR Row_Num = FLOOR(TotalCount / 2.0) + 1
GROUP BY sector
ORDER BY MedianProfit DESC

---END---
