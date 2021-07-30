--Cleaning Data 
SELECT *
FROM PortfolioProjects..housing

-- Standardize Date Format


SELECT saleDate, CONVERT(Date,SaleDate)
FROM PortfolioProjects.dbo.Housing


Update Housing
SET SaleDate = CONVERT(Date,SaleDate)


-- Another Method that can be used

ALTER TABLE Housing
ADD SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProjects.dbo.Housing

--Populate Property Address data

SELECT *
FROM PortfolioProjects.dbo.Housing
WHERE PropertyAddress is NULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProjects.dbo.Housing a
JOIN PortfolioProjects.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.Housing a
JOIN PortfolioProjects.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.Housing a
JOIN PortfolioProjects.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Separating the Address into Individual Columns (Address, City)

Select PropertyAddress
From PortfolioProjects.dbo.Housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City_Address
From PortfolioProjects.dbo.Housing

ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProjects.dbo.Housing

-- Separating the Address into Individual Columns (Address, City, State)
Select OwnerAddress
From PortfolioProjects.dbo.Housing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjects.dbo.Housing

ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProjects.dbo.Housing

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects.dbo.Housing
Group by SoldAsVacant

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjects.dbo.Housing

Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Removing Duplicates
WITH Remdupli AS(
Select *,
	ROW_NUMBER() OVER( 
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProjects.dbo.Housing
)
DELETE
From Remdupli
WHERE row_num > 1

-- Deleting Unused Columns
Select *
From PortfolioProjects.dbo.Housing

ALTER TABLE PortfolioProjects..Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


