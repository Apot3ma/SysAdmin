#Imagen 93
try{
    Write-Output "Todo Bien"
}catch{
    Write-Output "Algo lanzo una excepcion"
    Write-Output $_

}

try {
    Start-Something -ErrorAction Stop
}
catch {
    Write-Output "Algo genero una excepcion o uso Write-Error"
    Write-Output $_
}

#Imagen 94
$comando =[System.Data.SqlClient.SqlCommand]::New(queryString,connection)
try {
    $comando.Connection.Open()
    $comando.ExecuteNonQuery()
}finally{
    Write-Error "ha habido un problema con la ejecucion de la query. Cerrando la conexion"
    $comando.Connection.Close()
}

#Imagen 95
try{
    Start-Something -Path $path -ErrorAction stop
}catch [System.IO.DirectoryNotFoundException],[System.IO.FileNotFoundException]{
    Write-Output "El directorio o fichero no ha sido encontrado: [$path]"
}catch [System.IO.IOException]{
    Write-Output "Error de IO con el Archivo [$path]"
}

#Imagen 96 
throw "no se puede encontrar la ruta: [$path]"

throw [System.IO.FileNotFoundException] "no se puede encontrar la ruta [$path]"

throw [System.IO.FileNotFoundException]::New()

throw [System.IO.FileNotFoundException]::New("no se puede encontrar la ruta [$path]")

throw (New-Object -TypeName System.IO.FileNotFoundException)

throw (New-Object -TypeName System.IO.FileNotFoundException -ArgumentList "no se puede encontrar la ruta: [$path]")

#Imagen 97
trap{
    Write-Output $PSItem.ToString()
}
throw [System.Exception]::New('primero')
throw [System.Exception]::New('segundo')
throw [System.Exception]::New('tercero')

#Imagen 102
ls'D:\tmp\Backups\Registro\'
Import-Module BackupRegistry

#imagen 103
Get-Help backup-registry

#Imagen 104
backup-registry -rutaBackup 'D:\tmp\Backups\Registro\'
ls'D:\tmp\Backups\Registro\'

#Imagen 105
vim .\Archivo8.ps14
Import-Module BackupRegistry
backup-registry -rutaBackup 'D:\tmp\Backups\Registro\'
ls'D:\tmp\Backups\Registro\'

#Imagen 107 
ls'D:\tmp\Backups\Registro\'
Get-Date
ls'D:\tmp\Backups\Registro\'

#Imagen 108
Get-ScheduledTask

#Imagen 109
Unregister-ScheduledTask

#Imagen 110 
Get-ScheduledTask
