# US Healthcare Analytics

A portfolio project combining a Power BI report with MySQL analysis of healthcare admissions, diagnoses, length of stay, billing, hospital outcomes, medications, insurance, and location patterns.

The embedded data in the Power BI report is synthetic, as confirmed by the project owner. The separate source CSV is not included. No license is provided; the project remains subject to applicable default copyright rules.

## Dashboard screenshots

### Overview

![National Healthcare Performance Dashboard](screenshots/dashboard.png)

### Cost and stay analysis

![Healthcare cost and stay analysis](screenshots/cost-stay-analysis.png)

### Hospitals and medications

![Hospital and medication analysis](screenshots/hospital-medications.png)


## What’s included

- `US_Healthcare_Project.pbix` — Power BI report with four pages: Dashboard, Cost & Stay Analysis, Patient and Condition, and Hospital and Medical Condition.
- `sql/healthcare_analysis.sql` — MySQL schema, data-quality checks, a cleaned analytical view, and queries for demographics, conditions, length of stay, cost, outcomes, medications, insurance, geography, and time trends.
- `data/` — local input data location. The CSV is excluded; place an authorized `healthcare_data.csv` here.

## Requirements

- Power BI Desktop on Windows to open the report.
- MySQL 8.0 or later to run the SQL analysis (it uses window functions).
- A CSV named `healthcare_data.csv` with columns matching the table definition in the SQL script. The data file is not included.

## Use the Power BI report

Open `US_Healthcare_Project.pbix` in Power BI Desktop. The file contains its own embedded synthetic model. For refreshes, configure the report to use your authorized data source.

## Run the SQL analysis

1. Place an authorized `healthcare_data.csv` file in `data/`.
2. From the repository root, open `sql/healthcare_analysis.sql` in a MySQL client and execute it.
3. If MySQL rejects local file loading, enable `LOCAL INFILE` on both the server and client according to your MySQL installation’s security guidance.

The script creates `healthcare_db`, loads the CSV, creates `healthcare_clean`, and runs the documented analysis queries. The clean view excludes rows with negative billing amounts and derives age groups and length of stay. Initial quality checks report row and distinct-patient counts, negative billing rows, and the admission date range.

## Contributions and security

Please do not include patient-level records, credentials, or other sensitive information in issues or pull requests. See [SECURITY.md](SECURITY.md) for reporting guidance.

