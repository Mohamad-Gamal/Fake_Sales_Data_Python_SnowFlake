# Fake_Sales_Data_Python_SnowFlake
## Data Warehouse & Business Intelligence (DWBI) Project

![Animation](https://github.com/user-attachments/assets/80d10d76-d517-4560-a788-d39116d38485)


  Overview
  
  This project demonstrates a complete Data Warehouse and Business Intelligence (DWBI) implementation, covering data generation, data modeling, data
  analysis, and visualization using Python, Snowflake, SQL, and Power BI. The goal is to simulate a real-world business scenario and showcase best 
  practices in data engineering and analytics.

Project Workflow

  1️⃣ ER Diagram Design
  
    Designed an Entity-Relationship (ER) diagram to represent business data.
    Created a Star Schema and Snowflake Schema to optimize querying performance.

  2️⃣ Generating Fake Sales Data with Python
  
    Used random and faker Python packages to create realistic sales transaction data.
    Automated the creation of large datasets with customer, product, and sales information.
    Exported generated data into CSV files for loading into Snowflake.

  3️⃣ Snowflake Configuration and Data Modeling
  
    Set up a Snowflake environment and created:
    Databases & Schemas
    Fact and Dimension tables
    Views for optimized reporting
    Optimized table structures for efficient querying and storage.

  4️⃣ Loading Data into Snowflake
  
    Used Python scripts and Snowflake’s COPY INTO command to load data efficiently.
    Implemented best practices for batch loading and error handling.

  5️⃣ Scenario-Based SQL Queries
  
    Developed complex SQL queries to analyze and retrieve insights from the data.
    Handled real-world use cases such as:
      Monthly revenue trends
      Customer purchase behaviors
      Product performance analysis

  6️⃣ Business Intelligence & Report Design
  
    Designed a report blueprint to ensure clear and insightful visualizations.
    Defined KPIs and metrics relevant to the business scenario.

7️⃣ Data Visualization with Power BI

  Connected Power BI to Snowflake and built interactive dashboards.
  Created dynamic reports to showcase:
    Sales trends & growth analysis
    Top customers and best-selling products
    Regional performance insights

Technologies Used

  Python (faker, random, pandas) for test data generation
  Snowflake for cloud data warehousing
  SQL for data transformation & querying
  Power BI for visualization & reporting
