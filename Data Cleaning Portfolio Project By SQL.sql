/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing;





---------------------------------------------------------------------------------------------------------
--Standrize Date Format

Select SaleDateConverted, Convert(Date,saleDate)
From PortfolioProject.dbo.NashvilleHousing;


Update PortfolioProject.dbo.NashvilleHousing
Set SaleDate = Convert(Date,saleDate)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashVilleHousing
Set SaleDateConverted = Convert(date,SaleDate)






---------------------------------------------------------------------------------------------------------
-- Populate Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null;
order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) --> basically we are replacing b.property address into a.property address
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on  a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]  --> <> not equal
Where a.PropertyAddress is null;


----> basically we are replacing b.property address into a.property address)
Update a
Set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on  a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;






---------------------------------------------------------------------------------------------------------
-- Breaking out Address Into Individual COlumns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null;
--order By ParcelID

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashVilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashVilleHousing
Set PropertySplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

-- ParseName will return the object name but here we are looking for the ',' 
-- using replace and then removing it with period '.' but it seprating backwards 
-- that;s why we use 3,2,1




Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashVilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add  OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashVilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Alter Table PortfolioProject.dbo.NashvilleHousing
Add  OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashVilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
From PortfolioProject.dbo.NashvilleHousing





---------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Field


Select Distinct(SoldAsVacant),count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2



Select SoldAsVacant
,  Case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject.dbo.NashvilleHousing


Update NashVilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End


Select Distinct(SoldAsVacant),count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2





---------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE As (
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
	
From PortfolioProject.dbo.NashVilleHousing
-- order By ParcelId
)
Select *  --(Use delete here to remove all duplicates within this queries)
From RowNumCTE
where row_num > 1
Order By PropertyAddress




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashVilleHousing


Alter Table PortfolioProject.dbo.NashVilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashVilleHousing
Drop Column SaleDate