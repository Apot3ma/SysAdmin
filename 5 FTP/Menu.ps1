. "$PSScriptRoot\FTPconfig.ps1"

while (true)
{
    Clear-Host
    Write-Host "Configuracion de los usuarios" -ForegroundColor Cyan
    Write-Host "1)crear usuario ftp"
    Write-Host "2)modificar usuario ftp"
    Write-Host "3)salir"

    $choice = Read-Host "Please enter your choice (1-4)"
    
    switch ($choice) {
        1 {Crear-UsuarioFTP}
        2 {Submenu-FTP}
        3 { exit }
        default { Write-Host "Invalid choice, please try again." -ForegroundColor Red }
    }
    
    Read-Host "Press Enter to continue..."
}