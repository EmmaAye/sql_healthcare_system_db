# Healthcare System Database

## Project Overview

This project presents a robust and scalable SQL database schema designed for a comprehensive healthcare management system. It aims to efficiently organize, store, and retrieve critical information related to healthcare facilities, patients, medical consultations, prescriptions, billing, and inventory management. The system is built to enhance operational efficiency, improve patient care through quick access to information, and provide a strong foundation for advanced analytics and future technological integrations.

## Key Features & Accomplishments

* **Optimized Data Management:** Leverages efficient table relationships and constraints (primary and foreign keys) to prevent data redundancy and maintain high data integrity across the entire system.
* **Advanced Querying Capabilities:** Utilizes Common Table Expressions (CTEs), aggregate functions, and `JOIN` operations for complex data retrieval and meaningful analysis, including treatment cost predictions and financial insights.
* **Support for Predictive Analytics:** Generates structured datasets suitable for machine learning tasks such as claim prediction and staffing optimization, thereby enhancing decision-making capabilities.
* **Practical Implementation:** Includes realistic dummy data and optimized SQL queries addressing real-world challenges in financial analysis, resource allocation, and operational efficiency within a healthcare context.
* **Scalability:** The modular design of the schema allows for easy expansion to accommodate new features or additional entities as healthcare needs evolve.
* **Operational Efficiency:** Automates repetitive tasks such as appointment tracking, inventory restocking, and insurance processing, streamlining healthcare operations.
* **Improved Patient Care:** Provides healthcare professionals with quick access to patient records and history, enabling more informed and timely decision-making.

## Database Schema

The database schema is composed of 14 interconnected tables, each serving a specific purpose within the healthcare management system. These tables facilitate the efficient organization, storage, and retrieval of critical information.

<img width="1449" height="1301" alt="ER_diagram" src="https://github.com/user-attachments/assets/d0fbb1ad-e49a-441f-9f8e-1a20e16cd9d3" />

## Technologies Used

* **SQL (Structured Query Language):** The core language used for database creation, manipulation, and querying.
* **Database Management System:** (Specify the DBMS you used, e.g., MySQL, PostgreSQL, SQL Server, etc.)

## Project Structure

This repository typically contains the following:

* `schema.sql`: Contains the SQL script for creating the database tables and defining relationships.
* `data.sql`: Contains SQL scripts for populating the database with realistic dummy data.
* `queries.sql`: Contains various SQL queries demonstrating data retrieval, analysis, and insights.
* `CPSC500-1_ProjectReport_Gp15.pdf`: The detailed project report outlining the design, implementation, and findings.
* `README.md`: This file.

## Setup and Usage

To set up and run this project locally, follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/EmmaAye/sql_healthcare_system_db.git]
    ```
2.  **Set up your SQL environment:**
    * Ensure you have your chosen SQL DBMS (e.g., MySQL, PostgreSQL) installed and configured.
3.  **Create the database:**
    * Connect to your SQL server and execute the `healthcaresystem.sql` file to create the tables.
    ```sql
    -- Example for MySQL workbench or similar client
    SOURCE healthcaresystem.sql;
    ```
4.  **Populate with dummy data:**
    * Execute the `Project_DDL.sql` and `Project_DML.sql` file to insert sample data into the tables.

5.  **Run queries:**
    * Explore the `All_queries.sql.sql` file to see examples of advanced queries and how to retrieve meaningful insights from the database.

## Contributors

* Ezennaya, Chinenye Kate
* Mogollón Vargas, Ingrid
* Naw Mu Aye, Naw Mu Aye

## University & Course

* **University:** University of Niagara Falls Canada
* **Course:** CPSC500-1: SQL DATABASE
* **Professor:** Prof. Abbas Hamze
* **Faculty:** Master's in Data Analytics

## License

This project is open-source and available under the [MIT License](LICENSE). (You might want to create a `LICENSE` file in your repository with the full license text.)

---
