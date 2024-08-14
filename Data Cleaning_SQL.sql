--Cleaning Data in SQL Queries


Select * 
from PortfolioProject..NashvilleHousing



--Standardize Date Format

Select SaleDateConverted, Convert(Date, SaleDate)
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate= Convert(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted= Convert(Date, SaleDate)


--Populate Property Address data

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

Select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is Null

Update a set propertyaddress=ISNULL(a.propertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID]<>b.[UniqueID]
where a.propertyAddress is null



--Breaking out Address into Individual Columns(Address, city, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
Substring(propertyaddress, 1, charindex(',',PropertyAddress) -1) as Address,
Substring(propertyaddress, charindex(',',PropertyAddress) + 1, Len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress= Substring(propertyaddress, 1, charindex(',',PropertyAddress) -1)

Alter Table NashvilleHousing
Add  PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set  PropertySplitCity= Substring(propertyaddress, charindex(',',PropertyAddress) + 1, Len(PropertyAddress))

Select *
from PortfolioProject..NashvilleHousing

Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select 
Parsename(replace(OwnerAddress,',','.'),3),
Parsename(replace(OwnerAddress,',','.'),2),
Parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress= Parsename(replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add  OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set  OwnerSplitCity= Parsename(replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add  OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set  OwnerSplitState= Parsename(replace(OwnerAddress,',','.'),1)

Select *
from
PortfolioProject..NashvilleHousing


--Change Y and N to Yes and No in 'Sold in vacant' Field

Select Distinct(SoldasVacant), Count(SoldasVacant)
from PortfolioProject..NashvilleHousing
Group by Soldasvacant
order by 2


Select SoldasVacant,
case when SoldasVacant = 'Y' then 'Yes'
     when SoldasVacant = 'N' then 'No'
	 else soldasvacant
	 end
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set soldasVacant = case when SoldasVacant = 'Y' then 'Yes'
     when SoldasVacant = 'N' then 'No'
	 else soldasvacant
	 end


--Remove Duplicates
With RowNumCTE AS(
Select *,
Row_number() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID) as row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)

Select * from RowNumCTE
where row_num > 1
order by PropertyAddress

Select* 
from PortfolioProject..NashvilleHousing


--Delete unused Columns


Select * from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


