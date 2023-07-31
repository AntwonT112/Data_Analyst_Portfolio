SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]



  SELECT * 
  FROM PortfolioProject.dbo.NashvilleHousing

  --Converting SaleDate without TIME MARKS
  
  SELECT SaleDate
  FROM PortfolioProject.dbo.NashvilleHousing

  SELECT SaleDateConverted, CONVERT(Date, SaleDate)
  FROM PortfolioProject.dbo.NashvilleHousing
  
  UPDATE NashvilleHousing
  SET SaleDate = CONVERT(Date, SaleDate)

  ALTER TABLE NashvilleHousing
  Add SaleDateConverted Date;

  UPDATE NashvilleHousing
  SET SaleDateConverted = CONVERT(Date, SaleDate)

  -- Populate Property Address Data

  SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing
  --WHERE PropertyAddress is NULL
  ORDER BY ParcelID

  --ParcelID changes, but Property Address doesn't even with mulitple parcel's --
  -- Lets use a SELF JOIN! --

  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  FROM PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.parcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is NULL

  UPDATE a
  SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
   FROM PortfolioProject.dbo.NashvilleHousing a
  JOIN PortfolioProject.dbo.NashvilleHousing b
  on a.parcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]


  -- Breaking out Address into Individual COlums (Address, City, State)
  
  SELECT PropertyAddress
  FROM PortfolioProject.dbo.NashvilleHousing
  --It goes SUBSTRING(column, 1(first value), CHARINDEX('x' (up to comma in my example), column)-1) 
  --(-1 adds back a space for my example!)
  -- Next one added +1 so it's to the right of the comma rather than showing it in front
 
   SELECT
   SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
	 

  FROM PortfolioProject.dbo.NashvilleHousing

  ALTER TABLE NashvilleHousing
  Add PropertySplitAddress Nvarchar(255);

  UPDATE NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  ALTER TABLE NashvilleHousing
  Add PropertySplitCity Nvarchar(255) ;

  UPDATE NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

  SELECT *
  FROM PortfolioProject.dbo.NashvilleHousing

   SELECT OwnerAddress
  FROM PortfolioProject.dbo.NashvilleHousing


  SELECT
  PARSENAME (REPLACE(OwnerAddress,',','.') , 3),
  PARSENAME (REPLACE(OwnerAddress,',','.') , 2),
  PARSENAME (REPLACE(OwnerAddress,',','.') , 1)
  FROM PortfolioProject.dbo.NashvilleHousing

  ALTER TABLE NashvilleHousing
  Add OwnerSplitAddress Nvarchar(255);

  UPDATE NashvilleHousing
  SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.') , 3)

  ALTER TABLE NashvilleHousing
  Add OwnerSplitCity Nvarchar(255);

  UPDATE NashvilleHousing
  SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.') , 2)

  ALTER TABLE NashvilleHousing
  Add OwnerSplitState Nvarchar(255);

  UPDATE NashvilleHousing
  SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.') , 1)

  -- Changing the Y & N to Yes & No in Sold As Vacant
    
	SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
  FROM PortfolioProject.dbo.NashvilleHousing
  GROUP BY SoldAsVacant

  SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END
  FROM PortfolioProject.dbo.NashvilleHousing

  UPDATE NashvilleHousing
  SET SoldAsVacant =
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
   WHEN SoldAsVacant = 'N' THEN 'No'
   ELSE SoldAsVacant
   END

   -- Remove Duplicates!! My Favorite

WITH RowNumCTE AS(   
   SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
				PropertyAddress,
				Saleprice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
   FROM PortfolioProject.dbo.NashvilleHousing
   --ORDER BY ParcelID 
   )
   SELECT *
   FROM RowNumCTE
   WHERE row_num > 1
   ORDER BY PropertyAddress

   WITH RowNumCTE AS(   
   SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
				PropertyAddress,
				Saleprice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
   FROM PortfolioProject.dbo.NashvilleHousing
   --ORDER BY ParcelID 
   )
   DELETE
   FROM RowNumCTE
   WHERE row_num > 1
   --ORDER BY PropertyAddress


   ----- Delete Unusued Columns! ------

   SELECT *
   FROM PortfolioProject.dbo.NashvilleHousing

   ALTER TABLE PortfolioProject.dbo.NashvilleHousing
   DROP COLUMN OwnerAddress, TaxDistrict

  -- MORE OPTIONS --
  -- ALTER TABLE PortfolioProject.dbo.NashvilleHousing
  -- DROP COLUMN SaleDate

  -- Check Using CONVERT, ISNULL, Using CTE's, '' vs "", PARSENAME, COUNT, CASE Statements, ROW_NUMBER, Maybe Change NULL to something else?? -----
