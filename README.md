# US Healthcare Analytics

A portfolio project combining a four-page Power BI report with MySQL analysis of synthetic hospital admission records. It explores patient demographics, medical conditions, billing, length of stay, hospitals, medications, insurers, and admission trends.

> **Synthetic-data notice:** The project owner confirms that the Power BI report uses synthetic data and has identified `Healthcare Analysis Dataset.xlsx` as the raw input workbook. The workbook is not included in this public repository. The dataset publisher/source, generation method, and generation date are not currently documented. These figures are for demonstration only; they are not real patient records, clinical evidence, or representative U.S. healthcare statistics.

## Project snapshot

The dashboard shows **55,392 records** from **May 2019 through May 2024** with its default filters. The start and end months may be partial periods; the project does not document whether they contain complete months.

| Dashboard measure (default filters) | Displayed value |
|---|---:|
| Records / patients | 55,392 |
| Total billing | $1.42 billion |
| Average billing per record | $25,590 |
| Average length of stay | 15.5 days |
| Abnormal test results | 54.99% |

### How to read the figures

- Dashboard values above are transcribed from the report with its filters set to **All**. They are displayed rounded.
- In SQL, `healthcare_clean` excludes the **108 rows with negative billing**. If the source file has 55,392 rows, that leaves 55,284 rows in the view. Dashboard values and SQL results can therefore differ.
- SQL average billing is `AVG(billing_amount)` across rows in `healthcare_clean`; average stay is the average of `DATEDIFF(discharge_date, date_of_admission)` in days.
- SQL's abnormal percentage is the count of rows whose `test_results` value is `Abnormal`, divided by all rows in the same group. These are record-level descriptive calculations.
- The report's displayed values may reflect its own model and measures. The exact DAX definitions and whether its measures exclude negative billing are not documented here. Confirm the measures in Power BI before comparing them directly to SQL.

### Key findings shown in the dashboard

- **Most frequent conditions:** Hypertension (13,852 records), diabetes (13,846), and obesity (12,739).
- **Hospital volume:** Houston Methodist (20,362) and Johns Hopkins (11,248) account for about 57% of the displayed records.
- **Demographics:** Average age is 52; the report shows 50% female, 40.02% male, and 9.99% non-binary. A+ is the most common displayed blood type (19,385 records, about 35%).
- **Cost and stay:** Average billing by listed condition ranges from about $25.34K to $25.77K; average stay ranges from 15.39 to 15.63 days.
- **Billing by insurer:** Medicare represents 49.91% of displayed billing, UnitedHealthcare 30.06%, and Cigna and Aetna about 10% each.
- **Hospital concentration:** The two largest hospitals represent 57.1% of displayed patient volume.

These findings describe only the synthetic project data. They should not be used to infer clinical outcomes, population patterns, hospital performance, or real-world healthcare costs.

## Dashboard previews

### Overview

![National Healthcare Performance Dashboard](screenshots/dashboard.png)

### Cost and stay analysis

![Healthcare cost and stay analysis](screenshots/cost-stay-analysis.png)

### Patient and condition

![Patient and condition analysis](screenshots/patient-condition.png)

### Hospitals and medications

![Hospital and medication analysis](screenshots/hospital-medications.png)

## Repository contents

- `US_Healthcare_Project.pbix` — Power BI report with four pages: Dashboard, Cost & Stay Analysis, Patient and Condition, and Hospital and Medical Condition. It contains an embedded model.
- `sql/healthcare_analysis.sql` — MySQL table definition, CSV import, quality checks, cleaned analytical view, and analysis queries.
- `data/README.md` — expected CSV columns, import expectations, and notes about the separately held raw workbook.
- `screenshots/` — dashboard previews.

The raw `Healthcare Analysis Dataset.xlsx` workbook and a data-generation script are not included. The SQL script reads a CSV, not an Excel workbook, so the SQL workflow is **not fully reproducible from this repository alone**. Use only a dataset you are authorized to use and that matches the documented schema.

## Requirements

- Windows with Power BI Desktop to open the report.
- MySQL 8.0 or later for the SQL analysis (window functions are used).
- A CSV named `healthcare_data.csv` in `data/`, with the columns and order documented in [data/README.md](data/README.md).
- MySQL client and server configured to allow `LOAD DATA LOCAL INFILE`, if that import method is enabled in your environment.

## Open the Power BI report

Open `US_Healthcare_Project.pbix` in Power BI Desktop. Its embedded model supports viewing the existing report. Refreshing with a different source requires configuring an authorized, schema-compatible data source in Power BI.

## Run the SQL analysis

1. Convert or export the raw workbook to an authorized `healthcare_data.csv` matching [data/README.md](data/README.md). The exact workbook sheet/header mapping has not yet been verified.
2. Place the CSV in `data/`.
3. Open `sql/healthcare_analysis.sql` from the repository root in a MySQL client.
4. Confirm the client/server permit `LOCAL INFILE`. Set the input path in the `LOAD DATA LOCAL INFILE` statement to a path accessible to the MySQL client; relative paths are resolved according to the client and may not be relative to the SQL file.
5. Run the script **once against an empty project database**. Re-running the import appends records again. To replace an existing load, back up any needed data and clear the target table before importing; do not rerun blindly.

The script creates or reuses `healthcare_db` and `healthcare_data`, imports the CSV, reports row counts, negative billing rows, and the admission date range, then creates/replaces `healthcare_clean`. The clean view removes negative billing records and derives age groups and length of stay.

## Data provenance and reuse

The project owner has identified the workbook as the raw input and confirmed the dashboard data is synthetic. The workbook's sheet structure, exact relationship to the embedded Power BI data, dataset publisher/source, and generation method have not been verified or documented in this repository. Documenting those details and a repeatable workbook-to-CSV step would improve reproducibility.

This repository intentionally has **no license**. Unless the owner adds a license, visitors should not assume they have permission to reuse, modify, or redistribute the project. Do not upload real patient information, credentials, or other sensitive data.

## Contributions and security

Please do not include patient-level records or credentials in issues or pull requests. See [SECURITY.md](SECURITY.md) for reporting guidance.
