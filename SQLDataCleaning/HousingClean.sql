SELECT * 
FROM Housing.nashvilledata;

-- delete first row of database since it repeated the column names
DELETE FROM Housing.nashvilledata LIMIT 1;



-- FORMATTING DATE COLUMN
-- standardizing SaleDate (APRIL 9, 2013 to 2013-04-09)
SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y')
From Housing.nashvilledata;

-- safe updates to zero in order to update our data with the new date format
SET SQL_SAFE_UPDATES = 0;

-- Updating database
UPDATE Housing.nashvilledata
SET 
	SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

-- Updated safe column to database
SELECT * 
FROM Housing.nashvilledata;

-- safe updates back to 1
SET SQL_SAFE_UPDATES = 1;


-- PROPERTY ADDRESS NULLS
-- Replacing empty cells with NULL 
SET SQL_SAFE_UPDATES = 0;

UPDATE Housing.nashvilledata
	SET
		UniqueID = CASE UniqueID WHEN '' THEN NULL ELSE UniqueID END,
		ParcelID = CASE ParcelID WHEN '' THEN NULL ELSE ParcelID END,
		LandUse = CASE LandUse WHEN '' THEN NULL ELSE LandUse END,
		PropertyAddress = CASE PropertyAddress WHEN '' THEN NULL ELSE PropertyAddress END,
		SaleDate = CASE SaleDate WHEN '' THEN NULL ELSE SaleDate END,
		SalePrice = CASE SalePrice WHEN '' THEN NULL ELSE SalePrice END,
		LegalReference = CASE LegalReference WHEN '' THEN NULL ELSE LegalReference END,
		SoldAsVacant = CASE SoldAsVacant WHEN '' THEN NULL ELSE SoldAsVacant END,
		OwnerName = CASE OwnerName WHEN '' THEN NULL ELSE OwnerName END,
		OwnerAddress = CASE OwnerAddress WHEN '' THEN NULL ELSE OwnerAddress END,
		Acreage = CASE Acreage WHEN '' THEN NULL ELSE Acreage END,
		TaxDistrict = CASE TaxDistrict WHEN '' THEN NULL ELSE TaxDistrict END,
		LandValue = CASE LandValue WHEN '' THEN NULL ELSE LandValue END,
		BuildingValue = CASE BuildingValue WHEN '' THEN NULL ELSE BuildingValue END,
		TotalValue = CASE TotalValue WHEN '' THEN NULL ELSE TotalValue END,
			YearBuilt = CASE YearBuilt WHEN '' THEN NULL ELSE YearBuilt END,
		Bedrooms = CASE Bedrooms WHEN '' THEN NULL ELSE Bedrooms END,
		FullBath = CASE FullBath WHEN '' THEN NULL ELSE FullBath END,
		HalfBath = CASE HalfBath WHEN '' THEN NULL ELSE HalfBath END;

SET SQL_SAFE_UPDATES = 1;    
    
-- Taking a look at the rows that have missing adresses 
SELECT *                    
FROM Housing.nashvilledata
WHERE PropertyAddress IS NULL;

-- We can fill missing addresses with their corresponding addresses using the PARCELID. 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
From Housing.nashvilledata a
Join Housing.nashvilledata b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

SET SQL_SAFE_UPDATES = 0;  
-- updating dataset with filled in addresses
UPDATE Housing.nashvilledata a
Join Housing.nashvilledata b
ON a.ParcelID = b.ParcelID
		AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

SET SQL_SAFE_UPDATES = 1;  


SELECT *                    
FROM Housing.nashvilledata;

-- SEPARATING OUT THE ADDRESS INFORMATION
SELECT PropertyAddress,
	SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Street,
	SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM Housing.nashville;

SET SQL_SAFE_UPDATES = 0;  

ALTER TABLE Housing.nashvilledata 
ADD PropertyAddy VARCHAR(250) DEFAULT NULL;

ALTER TABLE Housing.nashvilledata 
ADD PropertyCity VARCHAR(250) DEFAULT NULL;

UPDATE Housing.nashvilledata
SET PropertyAddy = SUBSTRING_INDEX(PropertyAddress, ',', 1);

UPDATE Housing.nashvilledata
SET PropertyCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

SET SQL_SAFE_UPDATES = 1;  

SELECT *                    
FROM Housing.nashvilledata;

-- SEPARATING OUT THE OWNERS ADDRESS
SELECT OwnerAddress,
	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerStreet,
	 SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) AS OwnerCity,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerState
FROM Housing.nashville;

SET SQL_SAFE_UPDATES = 0;  

ALTER TABLE Housing.nashvilledata 
ADD OwnerStreet VARCHAR(250) DEFAULT NULL;

ALTER TABLE Housing.nashvilledata 
ADD OwnerCity VARCHAR(250) DEFAULT NULL;

ALTER TABLE Housing.nashvilledata 
ADD OwnerState VARCHAR(250) DEFAULT NULL;

UPDATE Housing.nashvilledata
SET OwnerStreet = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE Housing.nashvilledata
SET OwnerCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1);

UPDATE Housing.nashvilledata
SET OwnerState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SET SQL_SAFE_UPDATES = 1;  

SELECT *                    
FROM Housing.nashvilledata;


-- Making SoldAsVacant column consistent

-- Viewing what our column actually contains
SELECT SoldAsVacant,COUNT(*) as count 
FROM Housing.nashvilledata 
GROUP BY SoldAsVacant
ORDER BY count DESC;
-- We have some Y and N occurences that we want to change to Yes and No 

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
FROM Housing.nashvilledata
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N';

SET SQL_SAFE_UPDATES = 0;

UPDATE Housing.nashvilledata
	SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
     END;   
     
SET SQL_SAFE_UPDATES = 1;

SELECT *                    
FROM Housing.nashvilledata;

-- Here we can see that there are duplicate rows that share the same parcelID, address, and saledate etc...
SELECT ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference, OwnerName, count(*) as no_of_records
FROM Housing.nashvilledata
GROUP BY ParcelID, LandUse, PropertyAddress, SaleDate, SalePrice, LegalReference, OwnerName
HAVING no_of_records > 1;


-- Deleting columns that we do not want
ALTER TABLE Housing.nashvilledata
	DROP COLUMN PropertyAddress,
    DROP COLUMN OwnerAddress;
