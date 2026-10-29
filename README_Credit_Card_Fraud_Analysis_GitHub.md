# Credit Card Fraud Analysis and Rule Simulation

## Project Overview

This project explores credit card transaction data to identify patterns associated with fraudulent activity and evaluate simple transaction-amount thresholds. The goal is to understand where fraud appears in the dataset and how detection rules might balance fraud caught against genuine transactions incorrectly flagged.

**Project status:** Initial SQL analysis and an interactive Excel dashboard have been created. Threshold results should be rechecked against the original SQL queries before being treated as final.

## Business Problem

Fraud can create financial losses and undermine customer trust. However, a rule that flags too many genuine transactions can inconvenience customers and disrupt legitimate purchases. This project investigates transaction patterns and compares simple amount-based rules to illustrate this trade-off.

## Dataset

- **Dataset:** Credit Card Fraud Detection
- **Source/author:** Kaggle dataset by Kartik2112
- **File used in the analysis:** `fraudTest.csv`
- **Recorded transaction count:** 555,719
- **Recorded fraudulent transaction count:** 2,145

The dataset contains transaction details such as timestamp, amount, category, state, and a fraud indicator. Confirm the final workbook's row count and fields before publishing the project.

## Tools

- **Microsoft SQL Server / SSMS:** querying, aggregation, time analysis, category analysis, amount bands, and threshold comparisons
- **Microsoft Excel:** PivotTables, PivotCharts, KPI calculations, category slicer, and dashboard presentation

## Interactive Excel Dashboard

**[Open the Excel workbook on Google Drive](https://docs.google.com/spreadsheets/d/1pI2hmgG2lcBd4SksskFBi6P-1ZR49kpL/edit?usp=sharing&ouid=113605884029068352455&rtpof=true&sd=true)**-https://docs.google.com/spreadsheets/d/1pI2hmgG2lcBd4SksskFBi6P-1ZR49kpL/edit?usp=sharing&ouid=113605884029068352455&rtpof=true&sd=true

The workbook contains the interactive Excel dashboard, PivotTables, PivotCharts, category slicer, and supporting analysis sheets. If you cannot access it, the owner may need to update the Google Drive sharing settings to allow access.

For the overall dashboard view, clear the category slicer. Selecting a category filters the dashboard to that category.

## Analysis Performed

1. **Overall fraud summary** — counted transactions and fraud cases, calculated fraud rate, and summed the amount associated with fraudulent transactions.
2. **Time-of-day analysis** — grouped transactions by hour to investigate when fraud occurs.
3. **Amount-band analysis** — compared fraud rates across transaction amount bands: under 100, 100–499.99, 500–999.99, and 1,000+ (dataset currency units).
4. **Category analysis** — compared fraud rates and fraudulent transaction amounts by transaction category.
5. **Threshold simulation** — compared simple amount thresholds to examine fraud detected, genuine transactions flagged, fraud missed, precision, and recall.
6. **Interactive dashboard** — built five KPI cards, four charts, and a category slicer in Excel.

## Recorded Overall Results

These are the values recorded during the analysis and shown in the current workbook; validate them against the final saved workbook before publication.

| Metric | Recorded result |
|---|---:|
| Total transactions | 555,719 |
| Fraudulent transactions | 2,145 |
| Fraud rate | Approximately 0.39% |
| Total amount associated with fraud | 1,133,324.68 |
| Average amount per fraudulent transaction | 528.36 |

The amount figures are reported in the dataset's transaction currency units; this README does not assume a currency symbol.

## Initial Observations

- Fraud rates vary by transaction hour, transaction amount band, and category.
- The analysis recorded elevated fraud activity during late-night hours, including the 22:00–03:00 period. This pattern should be validated across relevant segments and should not be treated as proof that a transaction is fraudulent.
- The initial amount-band analysis recorded higher fraud rates in the 500–999.99 and 1,000+ bands than in the lower bands. Verify these rates against the final PivotTables or SQL output before publishing exact percentages.
- A simple amount threshold creates a trade-off: lower thresholds may capture more fraud while flagging more genuine transactions; higher thresholds may reduce flags but miss more fraud.

## Threshold Simulation

The following values were recorded during the initial threshold analysis. They are **provisional** until the source SQL queries are checked to confirm consistent threshold conditions, transaction populations, and counting logic.

| Amount threshold | Fraud detected | Genuine transactions flagged | Fraud missed | Precision | Recall |
|---:|---:|---:|---:|---:|---:|
| 100 | 1,665 | 98,336 | 480 | 1.66% | 77.62% |
| 250 | 1,582 | 13,882 | 563 | 10.23% | 73.75% |
| 500 | 1,036 | 5,042 | 1,109 | 17.05% | 48.30% |
| 1,000 | 276 | 1,307 | 1,869 | 17.44% | 12.87% |

**Interpretation:** In the recorded comparison, the lower threshold detected more fraud but also flagged many more genuine transactions. The higher threshold flagged fewer genuine transactions but missed more fraud. These results alone do not establish an optimal threshold.

Before publishing or relying on this table, verify:
- whether the rule uses `amt >= threshold` or `amt > threshold`;
- that every threshold uses the same dataset and definitions;
- that “genuine transactions flagged” counts only genuine transactions meeting the rule;
- that precision and recall are calculated consistently;
- that the totals reconcile with the dataset's fraud and genuine counts.

## Business Recommendations

1. Investigate hours and categories with elevated observed fraud rates, and validate whether the patterns persist across days and customer segments.
2. Evaluate amount-based rules using precision, recall, false positives, missed fraud, and estimated financial impact.
3. Consider additional signals rather than relying on transaction amount or hour alone.
4. Test candidate rules on separate data and assess customer impact before considering deployment.
5. Treat the dashboard as exploratory analysis, not a production fraud detection system.

## Limitations

- Observed associations do not establish causation.
- A simple threshold is not sufficient to determine whether an individual transaction is fraudulent.
- Threshold results are provisional until validated against the original SQL queries.
- The project does not establish performance on unseen data or production readiness.
- No quantified business savings or reduction in fraud has been demonstrated.

## Dashboard

The Excel dashboard includes:
- Total transactions
- Fraud transactions
- Fraud rate
- Total amount associated with fraud
- Average amount per fraudulent transaction
- Fraud rate by hour
- Fraud rate by amount band
- Fraud rate by category
- Fraud amount by category
- Interactive category slicer

## How to Review the Project

1. Open the final Excel workbook.
2. Start on `Dashboard_Final`.
3. Clear the category slicer to see overall results, or select a category to explore a segment.
4. Review the supporting PivotTable sheets and SQL analysis sheets.
5. Review `Business_Insights`, `Threshold_Comparison`, and `Executive_Summary` for interpretations and caveats.

## Future Improvements

- Re-run and validate every threshold query.
- Add a reproducible SQL script with comments and consistent rule definitions.
- Add a documented data-cleaning and validation section.
- Compare candidate rules on a holdout dataset.
- Quantify potential financial impact and customer friction using clearly stated assumptions.
- Add a final screenshot of the dashboard after clearing the slicer filter.

## Author Notes

This project was created as a portfolio exercise to practise SQL analysis, Excel dashboarding, and translating data patterns into business questions and recommendations. All findings should be presented as exploratory results unless independently validated.
