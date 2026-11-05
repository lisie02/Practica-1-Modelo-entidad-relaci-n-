# Practica 4 - Ejercicio 1.4
# Programa de carga automatizada de EcoData.

$ErrorActionPreference = "Stop"

$Container = "practica1"
$CsvPath = Join-Path $PSScriptRoot "..\datos\envases_355ml.csv"
$SqlPath = Join-Path $PSScriptRoot "poblar.sql"

# Las conexiones utilizan variables de entorno.
if ([string]::IsNullOrWhiteSpace($env:PGUSER)) {
    throw "Falta configurar la variable de entorno PGUSER."
}

if ([string]::IsNullOrWhiteSpace($env:PGDATABASE)) {
    throw "Falta configurar la variable de entorno PGDATABASE."
}

# Comprobar archivos.
if (!(Test-Path $CsvPath)) {
    throw "No se encontro el archivo CSV: $CsvPath"
}

if (!(Test-Path $SqlPath)) {
    throw "No se encontro el archivo SQL: $SqlPath"
}

# Comprobar que Docker esta ejecutandose.
$Running = docker inspect --format '{{.State.Running}}' $Container

if ($LASTEXITCODE -ne 0 -or $Running.Trim() -ne "true") {
    throw "El contenedor $Container no esta en ejecucion."
}

# Copiar los archivos al contenedor.
docker cp $CsvPath "${Container}:/tmp/envases_355ml.csv"

if ($LASTEXITCODE -ne 0) {
    throw "No se pudo copiar el archivo CSV."
}

docker cp $SqlPath "${Container}:/tmp/poblar.sql"

if ($LASTEXITCODE -ne 0) {
    throw "No se pudo copiar el archivo SQL."
}

# Ejecutar la carga en PostgreSQL.
docker exec -i `
    -e "PGUSER=$($env:PGUSER)" `
    -e "PGDATABASE=$($env:PGDATABASE)" `
    -e "PGCLIENTENCODING=UTF8" `
    $Container psql -X -v ON_ERROR_STOP=1 -f /tmp/poblar.sql

if ($LASTEXITCODE -ne 0) {
    throw "La carga fallo. PostgreSQL devolvio un error."
}

Write-Host "Carga automatizada finalizada correctamente." -ForegroundColor Green
