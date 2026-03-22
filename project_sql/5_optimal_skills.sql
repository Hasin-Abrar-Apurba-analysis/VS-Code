
 /*
Answer: What are the most optimal skills to learn (aka it's in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why? Targets skills that offer job security (high demand) and financial benefits (high salaries),
  offering strategic insights for career development in data analysis
  */


WITH skills_demand AS (

    SELECT
        Skills_job_dim.skill_id,
        Skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM
        job_postings_fact
        JOIN skills_job_dim
            ON job_postings_fact.job_id = skills_job_dim.job_id
        JOIN skills_dim
            ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short LIKE '%Data Analyst%'
        AND job_work_from_home = 'TRUE'
        AND salary_year_avg IS NOT NULL
    GROUP BY
        Skills_job_dim.skill_id,
        Skills_dim.skills

),  avg_salary AS (

    SELECT
        skills_job_dim.skill_id,
        Round(AVG(salary_year_avg), 0) AS Avg_salary
    FROM
        job_postings_fact
        JOIN skills_job_dim
            ON job_postings_fact.job_id = skills_job_dim.job_id
        JOIN skills_dim
            ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short LIKE '%Data Analyst%'
        -- AND job_work_from_home = 'TRUE'
        AND salary_year_avg IS NOT NULL
    GROUP BY
        skills_job_dim.skill_id
)

SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    Avg_salary
FROM
    skills_demand
Inner Join Avg_salary ON skills_demand.skill_id = Avg_salary.skill_id
WHERE
    demand_count > 10
ORDER BY
    demand_count DESC,
    Avg_salary DESC
LIMIT 25;

