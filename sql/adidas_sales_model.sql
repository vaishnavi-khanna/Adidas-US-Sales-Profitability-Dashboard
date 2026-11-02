/*
  SQL Server star-schema starter for Adidas US Sales.
  Import the workbook's 13 source columns into dbo.AdidasSalesStage first.
  Grain: one row per source workbook row (a retailer/product/date/method line).
  Monetary values use DECIMAL; margins are calculated from profit / sales.
*/

CREATE TABLE dbo.AdidasSalesStage (
    StageRowID       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Retailer         NVARCHAR(100) NOT NULL,
    RetailerID       INT NULL,
    InvoiceDate      DATE NOT NULL,
    Region           NVARCHAR(50) NOT NULL,
    State            NVARCHAR(100) NOT NULL,
    City             NVARCHAR(100) NOT NULL,
    Product          NVARCHAR(150) NOT NULL,
    PricePerUnit     DECIMAL(12,2) NOT NULL,
    UnitsSold        INT NOT NULL,
    TotalSales       DECIMAL(14,2) NOT NULL,
    OperatingProfit  DECIMAL(14,2) NOT NULL,
    OperatingMargin  DECIMAL(9,6) NULL,
    SalesMethod      NVARCHAR(50) NOT NULL
);

CREATE TABLE dbo.DimRetailer (
    RetailerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    RetailerID  INT NULL,
    Retailer    NVARCHAR(100) NOT NULL
);

CREATE TABLE dbo.DimGeography (
    GeographyKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Region       NVARCHAR(50) NOT NULL,
    State        NVARCHAR(100) NOT NULL,
    City         NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_DimGeography UNIQUE (Region, State, City)
);

CREATE TABLE dbo.DimProduct (
    ProductKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Product    NVARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE dbo.DimSalesMethod (
    SalesMethodKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SalesMethod    NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dbo.FactSales (
    SalesKey       BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceRowID    BIGINT NOT NULL UNIQUE,
    InvoiceDate    DATE NOT NULL,
    RetailerKey    INT NOT NULL REFERENCES dbo.DimRetailer(RetailerKey),
    GeographyKey   INT NOT NULL REFERENCES dbo.DimGeography(GeographyKey),
    ProductKey     INT NOT NULL REFERENCES dbo.DimProduct(ProductKey),
    SalesMethodKey INT NOT NULL REFERENCES dbo.DimSalesMethod(SalesMethodKey),
    PricePerUnit   DECIMAL(12,2) NOT NULL,
    UnitsSold      INT NOT NULL,
    TotalSales     DECIMAL(14,2) NOT NULL,
    OperatingProfit DECIMAL(14,2) NOT NULL
);

CREATE INDEX IX_FactSales_InvoiceDate ON dbo.FactSales(InvoiceDate);
CREATE INDEX IX_FactSales_GeographyKey ON dbo.FactSales(GeographyKey);
CREATE INDEX IX_FactSales_ProductKey ON dbo.FactSales(ProductKey);

/* Load dimensions and fact rows. Safe to rerun against the same staging batch.
   StageRowID identifies this load's rows; a full staging reload needs a stable
   source-row key or a coordinated truncate/reload of the fact table. */
INSERT dbo.DimRetailer (RetailerID, Retailer)
SELECT DISTINCT s.RetailerID, s.Retailer
FROM dbo.AdidasSalesStage AS s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DimRetailer AS d
    WHERE (d.RetailerID = s.RetailerID OR (d.RetailerID IS NULL AND s.RetailerID IS NULL))
      AND d.Retailer = s.Retailer
);

INSERT dbo.DimGeography (Region, State, City)
SELECT DISTINCT s.Region, s.State, s.City
FROM dbo.AdidasSalesStage AS s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DimGeography AS d
    WHERE d.Region = s.Region AND d.State = s.State AND d.City = s.City
);

INSERT dbo.DimProduct (Product)
SELECT DISTINCT s.Product FROM dbo.AdidasSalesStage AS s
WHERE NOT EXISTS (SELECT 1 FROM dbo.DimProduct AS d WHERE d.Product = s.Product);

INSERT dbo.DimSalesMethod (SalesMethod)
SELECT DISTINCT s.SalesMethod FROM dbo.AdidasSalesStage AS s
WHERE NOT EXISTS (SELECT 1 FROM dbo.DimSalesMethod AS d WHERE d.SalesMethod = s.SalesMethod);

INSERT dbo.FactSales (
    SourceRowID, InvoiceDate, RetailerKey, GeographyKey, ProductKey,
    SalesMethodKey, PricePerUnit, UnitsSold, TotalSales, OperatingProfit
)
SELECT
    s.StageRowID, s.InvoiceDate, r.RetailerKey, g.GeographyKey, p.ProductKey,
    m.SalesMethodKey, s.PricePerUnit, s.UnitsSold, s.TotalSales, s.OperatingProfit
FROM dbo.AdidasSalesStage AS s
JOIN dbo.DimRetailer AS r
  ON r.Retailer = s.Retailer
 AND (r.RetailerID = s.RetailerID OR (r.RetailerID IS NULL AND s.RetailerID IS NULL))
JOIN dbo.DimGeography AS g
  ON g.Region = s.Region AND g.State = s.State AND g.City = s.City
JOIN dbo.DimProduct AS p ON p.Product = s.Product
JOIN dbo.DimSalesMethod AS m ON m.SalesMethod = s.SalesMethod
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.FactSales AS f WHERE f.SourceRowID = s.StageRowID
);
