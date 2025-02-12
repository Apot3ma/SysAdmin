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