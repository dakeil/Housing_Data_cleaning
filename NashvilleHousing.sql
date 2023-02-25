/*

Cleaning Data in SQL Queries

*/


Select *
from Portfolio.dbo.NashvilleHousing


--------------------------------------------------
-------------Standardize Date Format--------------
--------------------------------------------------


Select SaleDateConverted, convert(Date,SaleDate)
From Portfolio.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
Set SaleDateConverted = convert(Date,SaleDate)


--------------------------------------------------
----------Populate Property Address Data----------
--------------------------------------------------


Select *
From Portfolio.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing a
Join Portfolio.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing a
Join Portfolio.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is null



--------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)--
--------------------------------------------------



Select PropertyAddress
From Portfolio.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

select 
substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as Address

From Portfolio.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = substring(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))


select OwnerAddress
from Portfolio.dbo.NashvilleHousing

Select
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from Portfolio.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)


--------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field--
--------------------------------------------------

Select distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  End
from Portfolio.dbo.NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  End
--------------------------------------------------
----------------Remove Duplicates----------------
--------------------------------------------------

/*
With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by 
			UniqueID
			) row_num

from Portfolio.dbo.NashvilleHousing
--order by ParcelID
)
Delete
from RowNumCTE
Where row_num>1
*/--used to delete 104 duplicates-- 

With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by 
			UniqueID
			) row_num

from Portfolio.dbo.NashvilleHousing
--order by ParcelID
)
Select*
from RowNumCTE
Where row_num>1
order by PropertyAddress 
--------------------------------------------------
--------------Delete Unused Columns--------------
--------------------------------------------------

Select *
from Portfolio.dbo.NashvilleHousing

Alter Table Portfolio.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio.dbo.NashvilleHousing
Drop Column SaleDate

----------/----------