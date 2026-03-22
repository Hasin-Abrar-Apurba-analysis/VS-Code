# Data Analyst Job Market Analysis

## Introduction

Dive into the data job market! This project provides a analysis of remote data analyst job opportunities, salaries, and the skills that drive compensation. By analyzing real job postings data, I uncover the highest-paying roles, most in-demand skills, and the strategic skills that offer both job security and attractive salaries.

SQL queries? Cheak them out here [project_sql_folder](/project_sql/)

## Background

The data analyst job market is competitive and rapidly evolving. Understanding which skills command the highest salaries, which are most in-demand, and which skills offer the best career prospects is crucial for job seekers and professionals looking to upskill. This project leverages a dataset of job postings to answer five key questions:

1. What are the highest-paying data analyst positions?
2. What skills do top-paying jobs require?
3. What skills are most in-demand across the market?
4. Which skills offer the highest average salaries?
5. What are the most optimal skills to learn (high demand + high pay)?

Data hails from my [SQL course](https://lukebarousse.com/sql)

## Tools I Used

- **SQL** – Data querying, JOIN operations, and aggregation analysis
- **PostgreSQL** – Database management and query execution
- **CSV Data Files** – job_postings_fact, company_dim, skills_dim, skills_job_dim tables
- **Git/GitHub** – Version control

## The Analysis

### Query 1: Top 10 Highest-Paying Data Analyst Jobs
Identifies remote data analyst positions with the highest average salaries. This query reveals which companies offer the most competitive compensation and what salary benchmarks to target.

/*  
**Question 1**
Question: What are the top-paying data analyst jobs?

- Identify the top 10 highest-paying Data Analyst roles that are available remotely.
- Focuses on job postings with specified salaries (remove nulls).
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into employers or employment opportunities
*/

```sql
SELECT
    job_id,
    company_dim.name AS company_name,
    job_title,
    job_location,
    salary_year_avg,
    job_posted_date
FROM
    job_postings_fact
    JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title ILIKE '%Data Analyst%' AND

    job_location = 'Anywhere'  AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 10;
```
[Top paying roles](project_sql/1_Assets.png)

*This graph showingthe salary for the top 10 salaries for data analyst. ChatGPT generated this from my query*


### Query 2: Skills Required for Top-Paying Jobs
Combines the top 10 highest-paying positions with their required skills. Key findings:
- **SQL** appears in 100% of top-paying roles (non-negotiable)
- **Python** is essential in 89% of top positions
- **Tableau** is the dominant visualization tool (67% of postings)
- **R** appears in senior/principal roles earning $195K+

/*
Question: What skills are required for the top-paying data analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from first query
- Add the specific skills required for these roles
- Why? It provides a detailed look at which high-paying jobs demand certain skills,
  helping job seekers understand which skills to develop that align with top salaries
*/

```
WITH top_paying_jobs AS (
    SELECT
        job_postings_fact.job_id,
        company_dim.name AS company_name,
        job_postings_fact.job_title,
        job_postings_fact.salary_year_avg,
        job_postings_fact.job_posted_date
    FROM
        job_postings_fact
        LEFT JOIN company_dim
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title LIKE '%Data Analyst%' AND
        job_location = 'Anywhere'  AND
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)
SELECT
    top_paying_jobs.*,
    skills_dim.skills
FROM
    top_paying_jobs
    JOIN skills_job_dim
        ON top_paying_jobs.job_id = skills_job_dim.job_id
        JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
   ```
[Top demanding skill](project_sql/2_assets.png)

### Query 3: Most In-Demand Skills
Analyzes all remote data analyst job postings to identify the top 5 skills with the highest demand. This provides insights into which skills are most sought-after by employers.


| Skills | Demand Count |
|--------|-------------|
| SQL | 9,015 |
| Python | 5,384 |
| Excel | 5,311 |
| Tableau | 4,744 |
| Power BI | 3,070 |

/*
Question: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market,
  providing insights into the most valuable skills for job seekers.
*/

```sql
SELECT
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
GROUP BY
    Skills_dim.skills
ORDER BY
    demand_count DESC
LIMIT 5
```


### Query 4: Top-Paying Skills
Analyzes the average salary associated with each skill for Data Analyst positions, regardless of location. This reveals how different skills directly impact earning potential and identifies the most financially rewarding skills to acquire.

/*
Query 4
🧑‍💼 Scenario:
Answer: 
- What are the top skills based on salary?

- Look at the average salary associated with each skill for Data Analyst positions

- Focuses on roles with specified salaries, regardless of location

- Why? It reveals how different skills impact salary levels for Data Analysts and helps identify the most financially rewarding skills to acquire or improve
*/

```sql
SELECT
    Skills_dim.skills,
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
    Skills_dim.skills
ORDER BY
    Avg_salary DESC
LIMIT 25;
```

**Key Findings:**

1. **Outliers Skew the Top** – SVN ($400K), VMware ($261K), and Yarn ($220K) represent one-off high-salary postings, not realistic market premiums. The meaningful premium tier starts around **$120K–$165K** with skills like Golang, Couchbase, and MXNet.



2. **AI/ML and Big Data Are Real Salary Drivers** – Tools like PyTorch ($124.9K), Kafka ($128.9K), Airflow ($121.6K), and Spark ($116.7K) consistently cluster in the **$120K–$130K range**. This signals that analysts who can work with ML models and data pipelines command a reliable **20–30% salary premium** over pure SQL/BI analysts.

3. **The Salary Floor Has Risen** – Every skill in the top-50 list pays above **$112K**, even "baseline" tools like Snowflake, Hadoop, and PostgreSQL. This demonstrates that specializing beyond standard tools now carries a **strong, consistent wage bump** regardless of specialization direction.

| Skills | Avg Salary |
|--------|------------|
| SVN | $400,000 |
| VMware | $261,250 |
| Yarn | $219,575 |
| FastAPI | $185,000 |
| Solidity | $179,000 |
| Golang | $162,833 |
| Couchbase | $160,515 |
| MXNet | $149,000 |
| dplyr | $147,633 |
| Twilio | $138,500 |

### Query 5: Optimal Skills to Learn
Combines demand metrics and salary data to identify skills that offer both job security and financial benefits. Targets remote positions with specified salaries to provide the most actionable insights for career development.

 /*
Answer:
- What are the most optimal skills to learn (aka it's in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why? Targets skills that offer job security (high demand) and financial benefits (high salaries),
  offering strategic insights for career development in data analysis
  */

```
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
```

## Key Insights

✅ **SQL and Python** are the foundation — mastering these two languages is non-negotiable  
✅ **Tableau** dominates visualization — more valuable than Power BI or Excel in the job market  
✅ **Specialization pays** — Big Data and ML tools offer a consistent 20-30% salary premium  
✅ **Remote flexibility is available** — Most top-paying positions offer remote or hybrid work  
✅ **Strategic skill selection matters** — Choosing high-demand, high-paying skills accelerates career growth  

## What I Learned

- **Data-driven career planning** yields better outcomes than generic skill recommendations
- **Outliers in salary data** can be misleading — patterns matter more than single anomalies
- **Skill combinations** are more valuable than individual skills, especially SQL + Python + Tableau
- **Remote positions** don't sacrifice salary — some of the highest-paying roles are fully remote
- **Emerging technologies** (AI/ML, Big Data tools) are establishing themselves as premium skill categories

## Conclusion

This analysis shows that success in the data analyst job market requires a strategic approach. Rather than learning every tool, focus on the high-impact combination of **SQL, Python, and Tableau**, then specialize in AI/ML or Big Data tools to maximize earning potential. The data clearly shows that specialized skills command higher salaries while remaining in-demand, making them the optimal choice for career development.
