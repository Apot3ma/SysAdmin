#Imagen 50
Get-Service -Name "LSM"| Get-Member

#Imagen 51
Get-Service -Name "LSM" | Get-Member -MemberType Property

#Imagen 52
Get-Item .\Archivo5.ps1 | Get-Member -MemberType Method

#Imagen 53 
Get-Item .\Archivo5.ps1 | Select-Object Name, Length

#Imagen 54
Get-Service | Select-Object -First 5

#Imagen 55
Get-Service | Select-Object -Last 5

#Imagen 56
Get-Service | Where-Object {$_.Status -eq "Running"}

#Imagen 57 
(Get-Item .\Archivo5.ps1).IsReadOnly
(Get-Item .\Archivo5.ps1).IsReadOnly = 1
(Get-Item .\Archivo5.ps1).IsReadOnly

#Imagen 58
Get-ChildItem*.ps1
(Get-Item .\TestComand.ps1). CopyTo("D:\Desktop\prueba.ps1")
(Get-Item .\TestComand.ps1). Delete()
Get-ChildItem *.ps1

#Imagen 59
$miObjeto = New-Object psobject
$miObjeto | Add-Member -MemberType NoteProperty -Name Nombre -Value "Miguel"
$miObjeto | Add-Member -MemberType NoteProperty -Name Edad -Value 23
$miObjeto | Add-Member -MemberType NoteProperty -Name Saludar -Value {Write-Host "!Hola Mundo!"}

#Imagen 60
$miObjeto = New-Object -TypeName psobject -Property @{
    Nombre = "Miguel"
    Edad = 23
}
$miObjeto| Add-Member -MemberType ScriptMethod -Name Saludar -Value {Write-Host "!Hola Mundo!"}
$miObjeto | Get-Member

#Imagen 61
$miObjeto = [PSCustomObject]@{
    Nombre = "Miguel"
    Edad = 23
}
$miObjeto | Add-Member ScriptMethod -Name Saludar -Value {Write-Host "!Hola Mundo!"}
$miObjeto | Get-Member

#Imagen 62 
Get-Process -Name | Stop-Process

