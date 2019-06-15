$Server = "nombreServer"

# Obtiene servicios con modo automatico no corriendo
Get-WmiObject win32_service -computer $Server | Where {$_.startmode -eq 'auto' -and $_.state -ne 'running'}

# Obtiene fecha de inicio del equipo
Get-WmiObject win32_operatingsystem -computer $server | 
    select csname, @{n=’LastBootUpTime’;e={$_.ConverttoDateTime($_.lastbootuptime)}}

