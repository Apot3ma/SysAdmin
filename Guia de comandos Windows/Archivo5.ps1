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

#Imagen63
Get-Help -Full Stop-Process

#Imagen 64
Get-Help -Full Get-Process

#Imagen 65 
Get-Process
Get-Process -Name Acrobat | Stop-Process

#Imagen 66
Get-Help -Full Get-ChildItem

Get-Help -Full Get-Clipboard

Get-ChildItem *.txt | Get-Clipboard

#Imagen 67
Get-Help -Full Stop-Service

#Imagen 69
Get-Service
Get-Service Spooler | Stop-Service
Get-Service

#Imagen 70 
Get-service 
"Spooler"| Stop-Service
Get-Process
Get-Process

#Imagen 71
Get-Process
$miObjeto = [PSCustomObject]@{
    Name = "Spooler"
}
$miObjeto | Stop-Service

