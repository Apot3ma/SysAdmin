#Imagen 73
Get-Verb

#Imagen 74
function Get-Fecha
{
    Get-Date
}

Get-Fecha

#Imagen 75
Get-ChildItem -Path Function:\get-*

#Imagen 76
Get-ChildItem -Path Function:\Get-Fecha | Remove-Item
Get-ChildItem -Path Function:\get*

#Imagen 77
function Get-Resta {
    param ([int]$num1,[int]$num2)
    $resta=$num1+$num2
    Write-Host "La resta de los parametros es $resta"
}

#Imagen 78
Get-Resta 10 5

#Imagen79
Get-Resta -num2 10 -num1 5

#Imagen 80
Get-Resta -num2 10 

#imagen 81
function Get-Resta {
    param ([Parameter(Mandatory)][Int]$num1,[int]$num2)
    $resta=$num1-$num2
    Write-Host "La resta de los parametros es $resta"
}

Get-Resta -num2 10

#Imagen 82
function Get-Resta {
    [Cmdletbinding()]
    param ([int]$num1,[int]$num2)
    $resta = $num1-$num2
    Write-Host "La resta de los parametros es $resta"
}

#Imagen83
(Get-Command -Name Get-Resta).Parameters.Keys

#Imagen 84
function Get-Resta {
    [Cmdletbinding()]
    param ([int]$num1,[int]$num2)
    $resta=$num1 -$num2
    Write-Verbose -Message "Operacion que va a realizar una resta de $num1 y $num2"
    Write-Host "La resta de los parametros es $resta"
}

Get-Resta 10 5 -Verbose