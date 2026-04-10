/*

Cleaning Data in SQL Queries

*/

Select *
From portfolioproject.nashville_housing;
    
-- Standardize Date Format


SELECT saleDate, DATE(SaleDate)
FROM portfolioproject.nashville_housing;


SET SQL_SAFE_UPDATES = 0;

UPDATE portfolioproject.nashville_housing
SET SaleDate = DATE(SaleDate);

SET SQL_SAFE_UPDATES = 1;

--If it does not Update properly

ALTER TABLE portfolioproject.nashville_housing
add SaleDateConverted date;

SET SQL_SAFE_UPDATES = 0;

UPDATE portfolioproject.nashville_housing
SET SaleDate = DATE(SaleDate);

SET SQL_SAFE_UPDATES = 1;
 
 --Populate Property Address Data
 
 Select *
From PortfolioProject.nashville_housing
Where PropertyAddress is not null
order by ParcelID

SELECT 
    a.ParcelID, 
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    IFNULL(NULLIF(a.PropertyAddress, ''), b.PropertyAddress) as NewPropertyAddress
FROM PortfolioProject.nashville_housing a
JOIN PortfolioProject.nashville_housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE (a.PropertyAddress IS NULL OR a.PropertyAddress = '')
  AND b.PropertyAddress IS NOT NULL;
  
UPDATE PortfolioProject.nashville_housing a
JOIN PortfolioProject.nashville_housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL
  AND b.PropertyAddress IS NOT NULL
  AND a.UniqueID IS NOT NULL;

--Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.nashville_housing
--Where PropertyAddress is null
--order by ParcelID

SELECT
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM PortfolioProject.nashville_housing;


ALTER TABLE portfolioproject.nashville_housing
Add PropertySplitAddress varchar(255);

Update portfolioproject.nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, locate(',', PropertyAddress) -1)

ALTER TABLE portfolioproject.nashville_housing
Add PropertySplitCity varchar(255);

Update portfolioproject.nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, locate(',', PropertyAddress) + 1 , length(PropertyAddress))

Select OwnerAddress
From portfolioproject.nashville_housing

SELECT
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1)) AS Address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS City,
    TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS State
FROM PortfolioProject.nashville_housing;


ALTER TABLE portfolioproject.nashville_housing
Add OwnerSplitAddress varchar(255);

UPDATE PortfolioProject.nashville_housing
SET OwnerSplitAddress = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', 1))
WHERE OwnerAddress IS NOT NULL;

ALTER TABLE portfolioproject.nashville_housing
Add OwnerSplitCity varchar(255);

UPDATE PortfolioProject.nashville_housing
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1))
WHERE OwnerAddress IS NOT NULL;


ALTER TABLE portfolioproject.nashville_housing
Add OwnerSplitState varchar(255);

UPDATE PortfolioProject.nashville_housing
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1))
WHERE OwnerAddress IS NOT NULL;


Select *
From portfolioproject.nashville_housing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolioproject.nashville_housing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From portfolioproject.nashville_housing


Update portfolioproject.nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From portfolioproject.nashville_housing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From portfolioproject.nashville_housing

