SELECT *
FROM (SELECT*
      FROM job_postings_fact
      WHERE
           EXTRACT(MONTH FROM job_posted_date) =1 )
AS january_jobs;
       



WITH january_jobs AS ( -- CTE definition starts here
    Select *
    From job_postings_fact
    WHERE
         EXTRACT(MONTH FROM job_posted_date) =1
)   -- CTE definition ends here

SELECT *
FROM january_jobs;



SELECT company_id,  
    name
From company_dim
Where 
    company_id IN (
        SELECT Company_id
        FROM
        job_postings_fact
        Where
            job_no_degree_mention = true
)







WITH company_job_counts AS (
SELECT 
    company_id,
    COUNT(*) AS total_jobs
FROM 
    job_postings_fact
GROUP BY
    company_id )


SELECT 
    company_dim.name AS company_name,
    company_job_counts.total_jobs

FROM
    company_job_counts
LEFT JOIN company_dim
ON company_job_counts.company_id = company_dim.company_id 
ORDER BY total_jobs DESC;





With company_job_counts AS (
    Select
          company_id,
          count(*) as total_jobs
    From
          job_postings_fact
    Group by
          company_id
)


Select
    
    company_dim.name,
    company_job_counts.total_jobs
From
    company_job_counts
Left join company_dim
on  company_job_counts.company_id = company_dim.company_id
Order BY
    total_jobs DESC









with skill_counts AS (
SELECT 
    skill_id,
    COUNT (skills) AS total_skills
    
FROM
     skills_dim
GROUP BY
    skill_id)


SELECT 
    job_postings_fact.job_title_short,
    skill_counts.total_skills
FROM
    skill_counts
    join skills_job_dim
    ON skill_counts.skill_id = skills_job_dim.skill_id
    join job_postings_fact
    ON skills_job_dim.job_id = job_postings_fact.job_id
GROUP BY
    job_postings_fact.job_title_short,
    skill_counts.total_skills




WITH job_skill_counts AS (
    SELECT
        job_id,
        COUNT(DISTINCT skill_id) AS total_skills
    FROM
        skills_job_dim
    GROUP BY
        job_id
)
SELECT
    j.job_title_short,
    COALESCE(jsc.total_skills, 0) AS total_skills
FROM
    job_postings_fact AS j
    LEFT JOIN job_skill_counts AS jsc
        ON j.job_id = jsc.job_id
GROUP BY
    j.job_title_short, jsc.total_skills
ORDER BY
    total_skills DESC;


    

SELECT
    s.skill_id,
    s.skills AS skill_name,
    sjd.skill_count
FROM
    (
        SELECT
            skill_id,
            COUNT(*) AS skill_count
        FROM
            skills_job_dim
        GROUP BY
            skill_id
        ORDER BY
            skill_count DESC
        LIMIT 5
    ) AS sjd
    JOIN skills_dim AS s
        ON sjd.skill_id = s.skill_id
ORDER BY
    sjd.skill_count DESC;




SELECT
    skills_dim.skill_id,
    skills_dim.skills AS skill_name,
    top_skill_counts.skill_count
FROM
    (
        SELECT
            skills_job_dim.skill_id,
            COUNT(*) AS skill_count
        FROM
            skills_job_dim
        GROUP BY
            skills_job_dim.skill_id
        ORDER BY
            skill_count DESC
        LIMIT 5
    ) AS top_skill_counts
    JOIN skills_dim
        ON top_skill_counts.skill_id = skills_dim.skill_id
ORDER BY
    top_skill_counts.skill_count DESC;




WITH company_job_counts AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)

SELECT
    cd.company_id,
    cd.name AS company_name,
    cjc.total_jobs,
    CASE
        WHEN cjc.total_jobs < 10 THEN 'Small'
        WHEN cjc.total_jobs BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS size_category
FROM
    company_job_counts AS cjc
    JOIN company_dim AS cd
        ON cjc.company_id = cd.company_id
ORDER BY
    cjc.total_jobs DESC;





WITH company_job_counts AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)
SELECT
    company_dim.company_id,
    company_dim.name AS company_name,
    company_job_counts.total_jobs,
    CASE
        WHEN company_job_counts.total_jobs < 10 THEN 'Small'
        WHEN company_job_counts.total_jobs BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS size_category
FROM
    company_job_counts
    JOIN company_dim
        ON company_job_counts.company_id = company_dim.company_id
ORDER BY
    company_job_counts.total_jobs DESC;




-- Find the number of remote job postings per skill

    --Display top 5 skills by their demand in remote jobs.

    --Include skill ID, Name & count of job postings requiring the skill

    
WITH remote_job_skills AS (
SELECT
    skill_id,
    COUNT (*) AS skill_count
FROM
    skills_job_dim
JOIN job_postings_fact
ON skills_job_dim.job_id = job_postings_fact.job_id
WHERE
    job_postings_fact.job_work_from_home = true
GROUP BY
     skill_id
     )

SELECT 
    skills_dim.skill_id,
    Skills_dim.skills,
    remote_job_skills.skill_count
FROM 
    remote_job_skills
JOIN skills_dim
ON remote_job_skills.skill_id = skills_dim.skill_id






WITH remote_job_skills AS (
SELECT
    skills_job_dim.skill_id,
    COUNT(*) AS skill_count
FROM
    skills_job_dim
JOIN job_postings_fact
ON skills_job_dim.job_id = job_postings_fact.job_id 
WHERE
    job_postings_fact.job_work_from_home = true
    AND  job_postings_fact.job_title_short LIKE '%Data Analyst%'
GROUP BY
    skills_job_dim.skill_id   )

SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    remote_job_skills.skill_count
FROM
    remote_job_skills
join skills_dim
ON remote_job_skills.skill_id = skills_dim.skill_id

ORDER BY
    remote_job_skills.skill_count DESC
LIMIT 5;




SELECT 
    salary_year_avg, 
    job_title_short, 
    job_posted_date ::DATE
    
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs ) 
                      AS first_quarter_jobs
Where
    job_title_short LIKE '%Data Analyst%'
    AND salary_year_avg > 70000
ORDER BY
    salary_year_avg DESC;





SELECT
    first_quarter_jobs.job_title_short,
    skills_dim.skills,
    skills_dim.type
FROM (
SELECT job_title_short, job_id
FROM january_jobs

UNION ALL

SELECT job_title_short, salary_year_avg
FROM february_jobs

UNION ALL

SELECT 
    job_title_short,
    salary_year_avg
FROM 
    march_jobs       ) AS first_quarter_jobs
JOIN skills_job_dim
ON first_quarter_jobs.job_id = skills_job_dim.job_id
Join skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id




SELECT
    first_quarter_jobs.job_title_short,
    first_quarter_jobs.salary_year_avg,
    COALESCE(skills_dim.skills, 'No Skill Found') AS skills,
    skills_dim.type
FROM (
    SELECT
         job_title_short, job_id, salary_year_avg
    FROM 
        january_jobs
    UNION ALL
    SELECT 
        job_title_short, job_id, salary_year_avg
    FROM 
        february_jobs
    UNION ALL
    SELECT 
        job_title_short, job_id, salary_year_avg
    FROM 
        march_jobs  ) AS first_quarter_jobs
LEFT JOIN skills_job_dim
  ON first_quarter_jobs.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim
  ON skills_job_dim.skill_id = skills_dim.skill_id
Where
    salary_year_avg > 70000;





-- Find the number of remote job postings per skill
 --Display top 5 skills by their demand in remote jobs.
  --Include skill ID, Name & count of job postings requiring the skill


select * from skills_job_dim LIMIT 5;




WITH remote_job_skills AS (
SELECT
    skills_job_dim.skill_id,
    skills_dim.skills,
    COUNT (*) AS skills_count
FROM
    skills_job_dim
JOIN job_postings_fact
ON skills_job_dim.job_id = job_postings_fact.job_id
JOIN skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id 
Where
    job_postings_fact.job_work_from_home = true 
GROUP BY
     skills_job_dim.skill_id,skills_dim.skills
ORDER BY
     skills_count DESC
LIMIT 5
 )

SELECT
    remote_job_skills.skill_id,
    remote_job_skills.skills,
    remote_job_skills.skills_count
FROM remote_job_skills;





