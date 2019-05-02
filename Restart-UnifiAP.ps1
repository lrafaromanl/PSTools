[CmdletBinding()]
param (

    [String]
    $url = "https://unifi:8443",
    
    [pscredential]
    $Credential = (Get-Credential),
    
    [String[]]
    [Parameter(Mandatory = $True)]
    $Mac

)

Try {

    # Set variables
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $useragent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer


    # Ignore SSL errors
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true } 

    $Username = $Credential.UserName
    $password = $credential.GetNetworkCredential().password

    # Login to UniFi Controller
    $postparams = ConvertTo-Json -InputObject @{username = $username; password = $password }
    $result = Invoke-WebRequest -Uri "$($url)/api/login" -ContentType "application/json" -Method POST -Body $postparams -SessionVariable session -UserAgent $useragent -UseBasicParsing
    $loginsuccess = ConvertFrom-Json -InputObject $result.Content
    if ( $loginsuccess.meta.rc -ne "ok" ) {
        Throw "Unable to login to UniFi Controller. $($result.RawContent)"
    }

    $cmd = 'restart'
    foreach ($ap in $Mac) {

        Write-Verbose "Restarting AP $ap"
        $payload = ConvertTo-Json -InputObject @{cmd = $cmd; mac = $ap }
        
        $Restart = Invoke-WebRequest -Uri "$($url)/api/s/default/cmd/devmgr/" -Method POST -Body $payload  -WebSession $session -UserAgent $useragent -UseBasicParsing 
        $status = ConvertFrom-Json -InputObject $restart.Content
        
        if ( $status.meta.rc -ne "ok" ) {
            Throw "Unable to retrieve UniFi device status. $($device.RawContent)"
        }
        else {
            Write-host "AP $ap was restarted" -ForegroundColor Green
        }
    }

}
Catch {
   
    Write-Warning "Unable to connect to UniFi controller. $($_.Exception.Message) $_"

}