Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices


# Core Workflow
1. Develop Models:
    - Create a new branch
    - Write transformation in models/ folder using SQL + Jinja
    - Reference Other models using `{{ ref('model_name') }}` function.

2. Run and Test:
    - Run `dbt run` to compile and run the models in the database
    - Run `dbt test` to run the tests in the test/ folder

3. Documentation
    - `dbt docs generate` to generate documentation
    - `dbt docs serve` to view documentation in the web interface

4. Deploy CI/CD
    - Usually set up Git-based workflows to ensure code merges only after passing tests.
    - Use CI tools (e.g. Github Actions, GitLab CI, etc.) or dbt Cloud's automated job runs.


## Best Practices to Master dbt
1. Adopt a Layered Approach

- Staging (Bronze): Pull in raw sources, rename columns, apply minimal transformations.
- Intermediate/Transform (Silver): Join tables, apply logic, handle business transformations.
- Analytics/Presentation (Gold): Final data sets, metrics, user-facing dashboards.

This layering ensures each stage has a clear purpose and is easy to understand.

2. Write Tests for Critical Assumptions

- Check that primary keys are unique (unique test) and foreign keys have matching records (relationships test).
- Ensure fields that must not be empty (not_null test) remain populated.

3. Use Source Freshness

- dbt can monitor how fresh your data is (i.e., how old the raw source data is).
- This is especially useful if you have SLAs around data latency.

4. Macros and DRY

- If you’re repeating the same logic across multiple models, factor it out into a macro.
- Leverage macros for advanced transformations or custom materializations.

5. Leverage Incremental Models

- If you have large datasets, consider incremental models to load new/updated records and optimize performance.
- Keep track of updated timestamps or surrogate keys to handle merges.

6. Document Everything

- Provide descriptions in your YAML files for each model, column, and source.
- Encourage your team to use the dbt docs site for data discovery.

7. Version Control & CI/CD

- Keep your dbt project in a Git repository.
- Use branching, pull requests, and automated tests for a robust deployment pipeline.

8. Performance Tuning

- Rely on your warehouse’s query optimization. For example, if you’re on BigQuery, ensure partitioned tables if needed.
- Use ephemeral models for transformations that are best done “on-the-fly” without physically creating tables.

9. Watch Out for Hard-Coding

- Keep environment-specific credentials out of your model code or macros.
- Use Jinja variables or environment variables for references to schema names, connection details, etc.

10. Community and Plugins
- Explore packages on dbt Hub (e.g., dbt-utils, dbt-expectations, dbt-audit-helper).
- Stay updated with new dbt features (such as Metrics, Slim CI, exposures, etc.).


##  Path to Mastery

1. Fundamentals
- Build a few simple models and get comfortable with dbt run and dbt test.
- Practice referencing and building dependent models.

2. Advanced SQL + Jinja

- Create macros to handle repeating logic.
- Explore Jinja for dynamic SQL generation.

3. Testing & Documentation

- Write robust tests, including custom SQL tests.
- Maintain detailed YAML docs for each model, so teammates understand transformations.

4. Large-Scale Project Structures

- Organize models into subfolders by domain or business area.
- Implement environment-based deployment (dev, staging, production).

5. Data Observability
- Use dbt’s source freshness, or connect external tools (e.g., Monte Carlo, Bigeye) for broader data quality checks.

6. Continuous Integration/Continuous Deployment
- Automate runs and tests in your Git CI pipeline.
- Establish processes to track and review changes in transformation logic before merging.

7. Contribute to the Community
- Read the dbt Slack channels.
- Share packages or macros that you develop for your project.
- Attend events like dbt Coalesce to stay current on best practices.