# Input data

The SQL analysis expects an authorized CSV named `healthcare_data.csv` in this directory. The project owner has identified a local workbook, `Healthcare Analysis Dataset.xlsx`, as the raw input and confirmed the dashboard data is synthetic. That workbook is not included in this public repository. Its sheet layout and exact correspondence to the embedded Power BI model have not yet been verified.

The SQL script does not load Excel workbooks directly. Export or transform the appropriate worksheet to CSV, then map it to this exact column order:

```text
patient_id,age,gender,blood_type,medical_condition,date_of_admission,doctor,hospital,insurance_provider,billing_amount,room_number,admission_type,discharge_date,medication,test_results,hospital_latitude,hospital_longitude
```

Dates should be compatible with MySQL `DATE` values (for example, `YYYY-MM-DD`). Billing should be numeric. Latitude and longitude should be numeric decimal values. The SQL schema in `../sql/healthcare_analysis.sql` defines the target types.

## Availability, provenance, and sharing

The raw workbook and a generator are not included here. The dataset publisher/source, generation method, generation date, and sharing terms are not currently documented. Do not infer that the synthetic records reflect real patients or real hospital performance.

Only add the workbook or a converted CSV if you have the right to share it publicly and have checked that it contains no real personal or confidential data. If you later add a generator or a redistributable sample, document its method, source, version, and license here.
