# Agent task: finish the Adidas Power BI report

## Goal

Update the existing Adidas US Sales report by integrating the explicit DAX model in `Adidas_Sales_Measures.dax`, correcting visuals that currently use implicit aggregations, and saving a finished PBIX.

This task requires Power BI Desktop on Windows. Use Tabular Editor 2 if available, or Power BI Desktop's model view and formula bar. Do the actual edits and save the PBIX; do not stop after giving instructions.

## Files

- **Starting PBIX candidate:** `project_2.pbix-2`
- **DAX definitions:** `Adidas_Sales_Measures.dax`
- **Source workbook:** `Adidas US Sales Datasets.xlsx`
- **Final output name:** `Adidas_US_Sales_Final.pbix`

The workspace contains another file, `project_2.pbix`. Leave both source PBIX files unchanged. `project_2.pbix-2` appears to be the later version: it has the corrected report title and the same 11 visuals as the other copy.

## Implementation steps

1. Make a working copy of `project_2.pbix-2` named `Adidas_US_Sales_Working.pbix`, then open the working copy in Power BI Desktop.
2. Confirm the model has the table `Data Sales Adidas` and its columns referenced by the DAX file. If Power BI asks to locate the source workbook, point it to `Adidas US Sales Datasets.xlsx` and refresh.
3. In the DAX file, create `DimDate` as a **calculated table**. Do not create it as a measure. Create a one-to-many relationship from `DimDate[Date]` to `Data Sales Adidas[Invoice Date]`.
4. Mark `DimDate` as the model's date table, using its `[Date]` column. Sort `DimDate[Month Name]` by `DimDate[Month Number]`.
5. Add each remaining DAX definition as a **measure** on `Data Sales Adidas`. Set sales and profit measures to currency, margin measures to percentage, and unit/row counts to whole numbers.
6. Update the report visuals to use the explicit measures:
   - KPI cards: `Total Sales`, `Operating Profit`, `Units Sold`, `Revenue per Unit`, and `Operating Margin %`.
   - Product, retailer, region, and state-map sales values: `Total Sales`.
   - Map tooltips: `Operating Profit`, `Units Sold`, `Revenue per Unit`, and `Operating Margin %`.
   - Monthly trend: `Total Sales` by `DimDate[Year Month]` (not just month name, so 2020 and 2021 are distinct).
   - Keep the existing region and date slicers, using `DimDate[Date]` for the date slicer.
7. Save the finished copy as `Adidas_US_Sales_Final.pbix`. Keep the original PBIX files intact.

## Validation before handing back

- Reopen `Adidas_US_Sales_Final.pbix` in Power BI Desktop and confirm it loads without a model error.
- Confirm the measures exist and that `Operating Margin %` is calculated as total operating profit divided by total sales, not as an average or sum of row margins.
- Confirm the date relationship is active and the monthly chart separates the two years.
- Change the region/date slicers and confirm the KPI cards and charts respond.
- Confirm the source workbook still has 9,648 data rows and the report visuals are retained.
- Return the final PBIX and briefly list any steps that could not be completed. Do not claim validation that was not performed.
