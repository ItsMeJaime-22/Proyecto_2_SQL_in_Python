
/*Data Cleaning in SQL*/


/* Nos permite posicionarnos en nuestra base de datos */
USE PORTFOLIO_PROYECT;


/* Nos permite ejecutar nuestra tabla "NashvilleHousing" */
SELECT*
FROM NashvilleHousing;


/* Nos permite eliminar nuestra tabla "NashvilleHousing" */
DROP TABLE -- NashvilleHousing;


-- Standardize Date Format


/*Paso_1: Nos permite alterar nuestra tabla "NashvilleHousing" y agregar una columna "SaleDateConverted"*/
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


/*Paso_2: Nos permite convertir la columna "SaleDateConverted" al formato fecha*/
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (date, SaleDate);


/*Paso_3: Nos permite convertir la columna "SaleDateConverted" al formato fecha y crear una nueva columna "Date"*/
SELECT SaleDateConverted, CONVERT (date, SaleDate) AS Date
FROM NashvilleHousing;

-- En caso quiera hacer otra vez el ejercicio, debo eliminar la columna creada "SaleDateConverted". 

/* Nos permite eliminar una columna de una tabla*/
ALTER TABLE --NashvilleHousing
DROP COLUMN --SaleDateConverted;


-- Populate Property Address data

/* Solo visualizamos la columna "PropertyAddress". */
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID;

/*Realizamos un Join entre la misma tabla "NashvilleHousing", y reemplazamos los valores vacios de la tabla A con los valores de la tabla B */
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) AS New_Col
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

/* Actualizamos los valores en nuestra tabla original*/
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM NashvilleHousing AS A
JOIN NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;


-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing
-- WHERE PropertyAddress IS NULL
--ORDER BY ParcelID;

/*Separamos los valores de la tabla "PropertyAddress", por medio del delimitador ',' */
SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) - 1) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN ( PropertyAddress)) AS Address
FROM NashvilleHousing;

/*Alteramos la tabla original, creando una columna titutalada "PropertySplitAddress" */
ALTER TABLE NashvilleHousing
    ADD PropertySplitAddress nvarchar(255);

/*Actualizamos los valores de la columna "PropertySplitAddress" con los datos que se encuentran antes de la coma ',', referente a la columna original "PropertyAddress" */
UPDATE NashvilleHousing
    SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX (',', PropertyAddress) - 1)

/*Alteramos la tabla original, creando una columna titutalada "PropertySplitCity" */
ALTER TABLE NashvilleHousing
    ADD PropertySplitCity nvarchar (255);

/*Actualizamos los valores de la columna "PropertySplitAddress" con los datos que se encuentran despues de la coma ',', referente a la columna original "PropertyAddress" */
UPDATE NashvilleHousing
    SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress) + 1, LEN ( PropertyAddress));

/*Consultamos nuestra tabla "NashvilleHousing"*/
SELECT *
FROM NashvilleHousing;

/*Separamos los valores de nuestra columna "OwnerAddress"*/
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
, OwnerAddress
FROM NashvilleHousing;

/*Creamos la tabla "OwnerSplitAddress"*/
ALTER TABLE NashvilleHousing
    ADD OwnerSplitAddress nvarchar(255);

/*Agregamos los valores que hemos separado referente a la columna "OwnerSplitAddress"*/
UPDATE NashvilleHousing
    SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

/*Creamos la tabla "OwnerSplitCity"*/
ALTER TABLE NashvilleHousing
    ADD OwnerSplitCity nvarchar (255);

/*Agregamos los valores que hemos separado referente a la columna "OwnerSplitCity"*/
UPDATE NashvilleHousing
    SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

/*Creamos la tabla "OwnerSplitState"*/
ALTER TABLE NashvilleHousing
    ADD OwnerSplitState nvarchar(255);

/*Agregamos los valores que hemos separado referente a la columna "OwnerSplitState"*/
UPDATE NashvilleHousing
    SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


/* Nos permite eliminar una columna de una tabla*/
ALTER TABLE --NashvilleHousing
DROP COLUMN --OwnerSplitState;

/*Mostramos el cambio en la columna "SoldAsVacant" */
SELECT SoldAsVacant
    , CASE When SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
    FROM NashvilleHousing;


/*Aplicamos los cambios hacia la columna "SoldAsVacant" */
UPDATE NashvilleHousing
    SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;

/*Consultamos la tabla con los cambios aplicados*/
SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant) AS CountSoldAsVacant
    FROM NashvilleHousing
    GROUP BY SoldAsVacant
    ORDER BY 2;

-- Remove Duplicates

/*Filtramos los valores duplicados*/
-- Creamos una nueva columna titulada "row_num" donde los valores duplicados son mayores a 1.
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

/*Eliminamos los valores duplicados*/
-- Eliminamos los valores duplicados, los cuales son filtrados por medio de la columna "row_num", estos son mayores a 1.
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;
-- Consultamos la tabla y vemos que se han eliminado 104 filas.
SELECT *
FROM NashvilleHousing;

--Delete unused columns.

SELECT *
FROM NashvilleHousing;

/* Nos permite eliminar una columna de una tabla*/
ALTER TABLE --NashvilleHousing
DROP COLUMN --SaleDateConverted;





















