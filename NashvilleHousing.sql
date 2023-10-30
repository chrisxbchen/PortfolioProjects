--change date format

select SaleDate, convert(date, saledate) as newdate
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set saledate = convert(date, saledate)

alter table NashvilleHousing
Add saledateconverted date;

update NashvilleHousing
set saledateconverted = convert(date, saledate)

select saledateconverted 
from NashvilleHousing

--property address
select *
from PortfolioProject..NashvilleHousing

select a.ParcelID, a.propertyaddress, b.parcelid, b.PropertyAddress , ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address
select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as address
, substring(propertyaddress, charindex(',', propertyaddress) +1,LEN(Propertyaddress)) as address2
from PortfolioProject..NashvilleHousing

--create new columns
alter table PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', propertyaddress) -1)

alter table PortfolioProject..NasvilleHousing
Add PropertySplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(propertyaddress, charindex(',', propertyaddress) +1,LEN(Propertyaddress))

select * 
from PortfolioProject..NashvilleHousing

--split owneraddress
select 
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1)
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnersplitState nvarchar(255)

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3), 
	OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2),
	OwnersplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)


select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when soldasvacant = 'Y' then 'Yes'
		 when soldasvacant = 'N' then 'No'
		 else soldasvacant
		 End
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant =
case when soldasvacant = 'Y' then 'Yes'
		 when soldasvacant = 'N' then 'No'
		 else soldasvacant
		 End

--remove duplicates
With RowNumCTE as(
select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 ) row_num
from PortfolioProject..NashvilleHousing
)
--select * 
--from RowNumCTE
--where row_num >1
--order by PropertyAddress

delete
from RowNumCTE
where row_num >1


--delete columns

alter table PortfolioProject..NashvilleHousing
drop column saledate

select *
from PortfolioProject..NashvilleHousing