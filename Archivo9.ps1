#Imagen 111
Get-Service

#Imagen 112
Get-Service -Name Spooler
Get-Service DisplayName Hora*

#Imagen 113
Get-Service | Where-Object {$_.Status -eq "Running"}

#Imagen 114
Get-Service |
Where-Object {$_.StartType -eq "Automatic"}|
Select-Object Name,StartType

#Imagen 115
Get-Service -DependentServices Spooler

#Imagen 116
Get-Service -RequiredServices Fax

#Imagen 117 
Stop-Service -Name Spooler -Confirm -PassThru

#Imagen 118
Start-Service -Name Spooler -Confirm -PassThru

#Imagen 119
Suspend-Service -Name StiSvc -Confirm -PassThru

#Imagen 120
Get-Service|Where-Object CanPauseAndContinue -EQ True 

#Imagen 121
Suspend-Service -Name Spooler

#Imagen 122
Restart-Service -Name WSearch -Confirm -PassThru

#Imagen 123
Set-Service -Name dcsvc -DisplayName "Servicio de virtualización de credenciales de seguridad distribuidas"

#Imagen 124
Set-Service -Name BITS -StartupType Automatic -Confirm -PassThru | Select-Object Name, StartType

#Imagen 125
Set-Service -Name BITS -Description "Transfiere archivos en segundo plano mediante el uso de ancho de banda de red inactivo"

#Imagen 126
Get-CimInstance Win32_Service -Filter 'Name = BITS' | Format-List Name, Description

#Imagen 127
Set-Service -Name Spooler -Satus Running -Confirm -PassThru

#Imagen 128
Set-Service -Name BITS -Status Stopped -Confirm -PassThru

#Imagen 129
Set-Service -Name stisvc -Status Paused -Confirm -PassThru

#Imagen 130 
Get-Process

#Imagen 131
Get-Process -Name Acrobat
Get-Process -Name Search*
Get-Process -Id 13948

#Imagen 132
Get-Process WINWORD -FileVersionInfo

#Imagen 133
Get-Process WINWORD -IncludeUserName

#Imagen 134
Get-Process WINWORD -Module

#Imagen 135
Stop-Process -Name Acrobat -Confirm -PassThru
Stop-Process  -Id 10940 -Confirm -PassThru
Get-Process -Name Acrobat | Stop-Process -Confirm -PassThru

#Imagen 136
Start-Process -FilePath "C:\WINDOWS\System32\notepad.exe" -PassThru

#Imagen 137
Start-Process -FilePath "cmd.exe" -ArgumentList "/c mkdir NuevaCarpeta" -WorkingDirectory "C\Documents\FIC\Q6\ASO" -PassThru

#imagen 138
Start-Process -FilePath "notepad.exe" -WindowStyle "Maximized" -PassThru

#Imagen 139 
Start-Process -FilePath "D:\Documents\FIC\Q6\ASO\TT\TT.txt" -Verb Print -PassThru

#Imagen 140
Get-Process -Name notep*
Wait-Process -Name notepad
Get-Process -Name notep*

Get-Process -Name notepad
Wait-Process -Id 11568
Get-Process -Name notep*

Get-Process -Name notep*
Get-Process -Name notepad | Wait-Process

#Imagen 141
Get-LocalUser

#Imagen 142
Get-LocalUser -SID 5-1-5-21-619942196-4045554399-1956444398-500  Select-Object *

#Imagen 143 
Get-LocalUser -Name Miguel | Select-Object *

#Imagen 144
Get-LocalGroup

#Imagen145
Get-LocalGroup -Name Administradores | Select-Object *

#Imagen 146 
Get-LocalGroup -SID 5-1-8-32-545 | Select-Object *

#Imagen 147
New-LocalUser -Name "Usuario2" -Description "Usuario de prueba 2" -Password (ConvertTo-SecureString -AsPlainText "12345" -Force)

#Imagen 148
New-LocalUser -Name "Usuario1" -Description "Usuario de prueba 1" -NoPassword

#Imagen 149 
Get-LocalUser -Name "Usuario1"

Remove-LocalUser -Name "Usuario1"
Get-LocalUser -Name "Usuario1"

Get-LocalUser -Name "Usuario2"

Get-LocalUser -Name "Usuario2" | Remove-LocalUser
Get-LocalUser -Name "Usuario2"

#Imagen 150
New-LocalGroup -Name 'Group1' -Description 'Grupo de prueba 1'

#Imagen 151
Add-LocalGroupMember -Group Grupo1 -Member Usuario2 -Verbose

#Imagen 152
Get-LocalGroupMember Group1

#Imagen 153
Remove-LocalGroupMember -Group Grupo1 -Member Usuario1
Remove-LocalGroupMember -Group Grupo1 -Member Usuario2
Get-LocalGroupMember Group1

#Imagen 154
Get-LocalGroup -Name "Grupo1"
Remove-LocalGroup -Name "Grupo1"
Get-LocalGroup -Name "Grupo1"