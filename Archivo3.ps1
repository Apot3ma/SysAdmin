
#Imagen 14
$condicion= $true

if($condicion)
{
    Write-Output "La condicion es verdadera"
}
else {
    Write-Output "La condicion es falsa"
}

#Imagen 15
$numero = 2
if ($numero -ge 3)
{
    Write-Output "El numero [$numero] es mayor o igual a 3"
}
elseif ($numero -lt 2)
{
    Write-Output "Es menor [$numero] es menor a 2"
}
else {
    Write-Output "Es igual a dos"
}

#Imagen 17
$PSVersionTable

#Imagen 18
$mensaje = (Test-Path $path) ? "Path existe" : "Path no encontrado"

$mensaje

#Imagen 21
switch (3) {
    1 {"[$_] es uno"}
    2 {"[$_] es dos"}
    3 {"[$_] es tres"}
    4 {"[$_] es cuatro"}
}

#Imagen 22
switch (3) {
    1 {"[$_] es uno"}
    2 {"[$_] es dos"}
    3 {"[$_] es tres"}
    4 {"[$_] es cuatro"}
    3 {"[$_] es tres de nuevo"}
}

#Imagen 23
switch (3) {
    1 {"[$_] es uno"}
    2 {"[$_] es dos"}
    3 {"[$_] es tres"; Break}
    4 {"[$_] es cuatro"}
    3 {"[$_] es tres de nuevo"}
}

#Imagen 24
switch (1,5) {
    1 {"[$_] es uno"}
    2 {"[$_] es dos"}
    3 {"[$_] es tres"}
    4 {"[$_] es cuatro"}
    5 {"[$_] es cinco"}
}

#Imagen 25
switch ("seis") {
    1 {"[$_] es uno"; Break}
    2 {"[$_] es dos"; Break}
    3 {"[$_] es tres"; Break}
    4 {"[$_] es cuatro"; Break}
    5 {"[$_] es cinco"; Break}
    "se*"{"[$_] coincide con se*."}
    Default {
        "No hay coincidencias con [$_]"
    }
}

#Imagen 26
switch -Wildcard ("seis")
{
    1 {"[$_] es uno"; Break}
    2 {"[$_] es dos"; Break}
    3 {"[$_] es tres"; Break}
    4 {"[$_] es cuatro"; Break}
    5 {"[$_] es cinco"; Break}
    "se*"{"[$_] coincide con se*."}
    Default {
        "No hay coincidencias con [$_]"
    }
}

#Imagen 27
$email = 'antonio.yanez@udc.es'
$email2 = 'antonio.yanez@udc.gal'
$url = 'https://www.dc.fi.udc.es/~afyanez/Docencia/2023'
switch -Regex ($url,$email,$email2)
{
    '^\w+\.\w+@(udc|usc|edu)\.es|gal$'{"[$_] es una direccion de correo electronico academica"}
    '^ftp\://.*$'{"[$_] es una direccion ftp"}
    '^(http[s]?)\://.*$'{"[$_] es una direccion web, que utiliza [$($Matches[1])]"}
}

#Imagen 28
1 -eq "1.0"
"1.0" -eq 1

#Imagen 31
for (($i = 0),($j=0);$i -lt 5; $i++)
{
    "`$i:$i"
    "`$j:$j"
}

#Imagen 32
for ($($i=0;$j=0); $i -lt 5; $($i++;$j++))
{
    "`$i:$i"
    "`$j:$j"
}

#Imagen 34
$ssoo = "freebsd", "openbsd","solaris","fedora","ubuntu","netbsd"
foreach ($so in $ssoo)
{
    Write-Host $so
}

#Imagen 35
foreach ($archivo in Get-ChildItem)
{
    if ($archivo.Length -ge 10KB)
    {
        Write-Host $archivo -> [($archivo.Length)]
    }
}

$num = 0

#Imagen 37
while ($num -ne 3)
{
    $num++
    Write-Host $num
}

#Imagen 38
while ($num -ne 5)
{
    if ($num -eq 1) {$num =$num + 3 ; Continue}
    $num++
    Write-Host $num
}


#Imagen 40
$valor = 5
$multiplicacion = 1
do
{
    $multiplicacion = $multiplicacion * $valor
    $valor--
}
while ($valor -gt 0)
Write-Host $multiplicacion


#Ilustracion 41
$Valor = 5
$multiplicacion = 1
do
{
    $multiplicacion = $multiplicacion * $valor
    $valor--
}
until ($valor -eq 0)

Write-Host $multiplicacion


#Imagen 42
$num = 10

for($i = 2; $i -lt 10;$i++)
{
    $num = $num+$i
    if ($i -eq 5) { Break }
}

Write-Host $num
Write-Host $i


#Imagen 43
$cadena ="Hola, buenas tardes"
$cadena2 ="Hola, buenas noches"

switch -Wildcard ($cadena,$cadena2)
{
    "Hola, buenas*"{"[$_] coincide con [Hola,buenas*]"}
    "Hola, bue*" {"[$_] coincide con [Hola,bue*]"}
    "Hola, *"{"[$_] coincide con [Hola,*]"; Break }
    "Hola, buenas tardes" {"[$_] coincide con [Hola, buenas tardes]"}
}

#Imagen 44
$num = 10
for ($i = 2; $i -lt 10; $i++)
{
    if ($i -eq 5) {Continue}
    $num = $num+$i
}

Write-Host $num
Write-Host $i

#Imagen 45
$cadena ="Hola, buenas tardes"
$cadena2 ="Hola, buenas noches"

switch -Wildcard($cadena,$cadena2)
{
    "Hola, buenas*" {"[$_] coincide con [Hola, buenas*]"}
    "Hola, bue*" {"[$_] coincide con [Hola,bue*]"; continue}
    "Hola,*" {"[$_] coincide con [Hola,*]"}
    "Hola, buenas tardes" {"[$_] coincide con [Hola,buenas tardes]"}
}