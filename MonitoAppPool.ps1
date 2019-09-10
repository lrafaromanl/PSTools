#########################################################################################################################
#####################T his script has the purpose of monitoring the status of the app pool,##############################
##################### and in case the service suffers a fall, notify those responsible by mail ##########################
#########################################################################################################################

import-module WebAdministration
$Username = "usuario@mail.com"; # replace with your mail
$Password = "P4ssW0rd" | ConvertTo-SecureString -asPlainText -Force; # replace with your password
$to = "monitoring@mail.com" # replace with the mail that will receive the notifications
$date = Get-Date
$server = hostname

##########################################################################################################################
########################################  Send Mail Fuction  ############################################################
function Send-ToEmail([string]$email){
    $message = new-object Net.Mail.MailMessage;
    $message.From = "support@mail.com";
    $message.To.Add($email);
    $message.Subject = "[CLIENTE] Alerta Sitio $Name | $server"; # edit the subject if you want it
    $message.Body = "El Sitio <b>$Name</b> se detuvo de forma inesperada el <b>$date</b>, por favor estar atento"; # Edit the body if you want it
	$message.IsBodyHTML = $true
##########################################################################################################################
    $smtp = new-object Net.Mail.SmtpClient("smtp.dominio.com", "port");
    $smtp.EnableSSL = $true;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
    $smtp.send($message);
 }
##########################################################################################################################
set-Location IIS:\AppPools
$A = ls
#$A.count
foreach($i in $A){
$Name = $i.name
$State = $i.state
###########################################################################################################################
################################################# Conditions ##############################################################

################################# Replace AppPoolName for your site's name ###############################################
if($State -eq "Stopped" -And $Name -eq "AppPoolName"){
#Start-WebAppPool -Name $Name
Send-ToEmail  -email $to;
}
##########################################################################################################################
if($State -eq "Stopped" -And $Name -eq "AppPoolName2"){
#Start-WebAppPool -Name $Name
Send-ToEmail  -email $to;
}
##########################################################################################################################
if($State -eq "Stopped" -And $Name -eq "AppPoolName3"){
#Start-WebAppPool -Name $Name
Send-ToEmail  -email $to;
}
}