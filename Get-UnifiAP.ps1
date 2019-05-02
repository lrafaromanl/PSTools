[CmdletBinding()]
param (

    [String]
    $url = "https://unifi:8443",

    [pscredential]
    $Credential = (Get-Credential)


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


    # Query for status of all devices in the default site

    $device = Invoke-WebRequest -Uri "$($url)/api/s/default/stat/device" -Method POST -Body "" -WebSession $session -UserAgent $useragent -UseBasicParsing 
    $status = ConvertFrom-Json -InputObject $device.Content

    if ( $status.meta.rc -ne "ok" ) {
        Throw "Unable to retrieve UniFi device status. $($device.RawContent)"
    }

    # Loop through each device and output it's status
    ForEach ( $ap in $status.data ) {

        $apmodel = "$($ap.type) $($ap.model)"
        If ( $ap.state = 1 ) {
            # Device is online
            $status = "ONLINE"
        }
        Else {
            # Device is offline
            $status = "OFFLINE"
        }
        
        # format uptime
        $uptime = ([timespan]::fromseconds($ap.uptime))
        $formatUptime = "{0}h {1}m {2}s" -f $uptime.hours, $uptime.minutes, $uptime.seconds
        if ($uptime.days -gt 0) { $formatUptime = '{0}d {1}' -f $uptime.days, $formatUptime }

        [PSCustomObject]@{
            Name     = $ap.name
            Mac      = $ap.mac
            IP       = $ap.ip
            Model    = "{0} {1}" -f $apmodel, $ap.version
            Status   = $Status
            Isolated = $ap.isolated
            Uptime   = $formatUptime

        } # output object

    } # foreach


}
Catch {
   
    Write-Warning "Unable to connect to UniFi controller. $($_.Exception.Message) $_"

}