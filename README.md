# Adidas US Sales & Profitability Dashboard

This workspace contains the Adidas US sales source workbook, a Power BI report working copy, explicit DAX measures, and a SQL Server star-schema starter.

## Files

- `Adidas US Sales Datasets.xlsx` — source workbook, with 9,648 data rows and 13 columns: retailer and retailer ID, invoice date, region/state/city, product, unit price, units sold, total sales, operating profit and margin, and sales method.
- `Adidas_US_Sales_Working.pbix` — working copy of the Power BI report. The finished output requested in `POWER_BI_AGENT_TASK.md`, `Adidas_US_Sales_Final.pbix`, is not present yet.
- `Adidas_Sales_Measures.dax` — DAX definitions for explicit sales, profit, units, margin, per-unit, row-count, and year-over-year measures, plus a calculated `DimDate` table.
- `sql/adidas_sales_model.sql` — SQL Server DDL and load statements for staging, retailer/geography/product/sales-method dimensions, and a fact table.
- `POWER_BI_AGENT_TASK.md` — implementation and validation checklist for completing the Power BI report.

## Power BI model and measures

The report is based on the `Data Sales Adidas` table. Create `DimDate` from the calculated-table expression at the bottom of `Adidas_Sales_Measures.dax`, relate `DimDate[Date]` (one) to `Data Sales Adidas[Invoice Date]` (many), mark `DimDate` as the date table, and sort `Month Name` by `Month Number`.

Add the other definitions in the DAX file as measures on `Data Sales Adidas`. `Operating Margin %` is calculated as total operating profit divided by total sales; it should replace any average of row-level margins. Format sales and profit as currency, margin measures as percentages, and unit and row counts as whole numbers.

Use the explicit measures in the report visuals: `Total Sales` for sales charts and the state map; `Total Sales`, `Operating Profit`, `Units Sold`, `Revenue per Unit`, and `Operating Margin %` for KPI cards; and `Operating Profit`, `Units Sold`, `Revenue per Unit`, and `Operating Margin %` for map tooltips. Plot monthly sales by `DimDate[Year Month]` to distinguish 2020 from 2021. Keep the region and date slicers, with the date slicer based on `DimDate[Date]`.

## SQL Server model

The SQL script expects the workbook's **13** source columns to be loaded into `dbo.AdidasSalesStage` first, with invoice dates converted to `DATE`. It creates a retailer, geography, product, and sales-method dimension, and a `FactSales` table with one row per source row. The load statements avoid re-inserting dimension and fact rows when rerun against the same staging batch. For a full staging reload, use a stable source-row key or coordinate a fact-table reload; the generated `StageRowID` alone does not identify the same source row across reloads.

## Current completion status

The DAX definitions and SQL starter are present. The Power BI task document calls for saving the completed report as `Adidas_US_Sales_Final.pbix`, then reopening it to validate the model, measures, date relationship, visuals, and slicer interactions. That final file and validation are not included in this workspace yet. Do not describe the report as real-time: it uses an imported workbook unless a scheduled or DirectQuery refresh setup is added.
