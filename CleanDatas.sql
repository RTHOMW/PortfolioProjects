 
 Select *
 From PortfolioProject.[dbo].[NashvilleHousing]
 
 -- Standardize Date Format

 Select SaleDate, CONVERT(Date,SaleDate) as SaleDate
 From PortfolioProject.[dbo].[NashvilleHousing]

 Update [NashvilleHousing]
 Set SaleDate = CONVERT(Date,SaleDate)

 
 ALTER TABLE [NashvilleHousing]
 Add SaleDateConverted Date;

  Update [NashvilleHousing]
 Set SaleDateConverted = CONVERT(Date,SaleDate)

  Select SaleDateConverted
 From PortfolioProject.[dbo].[NashvilleHousing]

 -- Populate property Address data

 
 Select *
 From PortfolioProject.[dbo].[NashvilleHousing]
-- Where PropertyAddress is null
order by ParcelID

 Select a.ParcelID, b.ParcelID , a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 From PortfolioProject.[dbo].[NashvilleHousing] a
 JOIN PortfolioProject.[dbo].[NashvilleHousing] b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]
 Where a.PropertyAddress is null

 Update a
 Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
 From PortfolioProject.[dbo].[NashvilleHousing] a
 JOIN PortfolioProject.[dbo].[NashvilleHousing] b
 on a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]

 -- Breaking out address into individual collumns (city address...)

   Select *
 From PortfolioProject.[dbo].[NashvilleHousing]

 SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)+1), LEN(PropertyAddress)	as Address


  From PortfolioProject.[dbo].[NashvilleHousing]

   ALTER TABLE [NashvilleHousing]
 Add PropertyAddressSplit nvarchar(255);

  Update [NashvilleHousing]
 Set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

  ALTER TABLE [NashvilleHousing]
 Add PropertyCitySplit nvarchar(255);

  Update [NashvilleHousing]
 Set PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


 -- Remove duplicates


    Select *
 From PortfolioProject.[dbo].[NashvilleHousing]

    Select OwnerAddress
 From PortfolioProject.[dbo].[NashvilleHousing]

 Select 
 PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
  PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
   PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
  From PortfolioProject.[dbo].[NashvilleHousing]

     ALTER TABLE [NashvilleHousing]
 Add OwnerAddressSplit nvarchar(255);

  Update [NashvilleHousing]
 Set OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

  ALTER TABLE [NashvilleHousing]
 Add OwnerCitySplit nvarchar(255);

  Update [NashvilleHousing]
 Set OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

   ALTER TABLE [NashvilleHousing]
 Add OwnerStateSplit nvarchar(255);

  Update [NashvilleHousing]
 Set OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

 -- Change Y to Yes and N to NO

     Select Distinct(SoldAsVacant), Count(SoldAsVacant)
	 From PortfolioProject.[dbo].[NashvilleHousing]
	 Group by SoldAsVacant
	 order by 2

	
	 
     Select SoldAsVacant
	 , Case When SoldAsVacant = 'Y' Then 'YES'
	  When SoldAsVacant = 'N' Then 'NO'
	 Else SoldAsVacant
	 END
	 From PortfolioProject.[dbo].[NashvilleHousing]

	   Update [NashvilleHousing]
 Set SoldAsVacant =
 Case When SoldAsVacant = 'Y' Then 'YES'
	  When SoldAsVacant = 'N' Then 'NO'
	 Else SoldAsVacant
	 	 END
	 From PortfolioProject.[dbo].[NashvilleHousing]

	  -- Delete duplicates

	  WITH RowNumCTE As(
	      Select *,
		  ROW_NUMBER() OVER(
		  PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID
						) row_num
				
 From PortfolioProject.[dbo].[NashvilleHousing]
 --Order by ParcelID
 )
 Select * 
 From RowNumCTE
 Where row_num > 1
 order by PropertyAddress

 	  -- Delete unused collumns

	       Select *

	 From PortfolioProject.[dbo].[NashvilleHousing]

	ALTER TABLE PortfolioProject.[dbo].[NashvilleHousing]
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

		ALTER TABLE PortfolioProject.[dbo].[NashvilleHousing]
	DROP COLUMN SaleDate