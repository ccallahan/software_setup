# System Setup Script for Chance's Computers

param (
    [string]$os = $(throw "-OS is required, options are Windows or Fedora"),
    [string]$global:stage = $(throw "-stage is required if not found. See code for details."),
    [string]$hostname = $(throw "-hostname is required."),
    [switch]$SaveData = $false
)

# Variable Time!
$fileName = “report.xml”;
$xmlDoc = [System.Xml.XmlDocument](Get-Content $fileName);
$global:stagestatus = 0;
$niniteURL = "https://ninite.com/.net4.7.2-7zip-adoptjdkx11-adoptjdkx8-air-cccp-chrome-discord-filezilla-gimp-googleearth-imgburn-inkscape-notepadplusplus-python-qbittorrent-shockwave-silverlight-spotify-steam-teamviewer14-vlc-windirstat/ninite.exe";
$niniteOutput = "$PSScriptRoot\Ninite.exe";


function OSRouting {
    if (os = Windows) {
        WindowsStaging;
    }
    elseif (os = Fedoira) {
        FedoraStaging;
    }
    else {
        Write-Error -Message "OS Routing Failed. Check your flags.";
    }
}

function XMLWriteLogic {
    $XMLWriteSystemStatus = $xmlDoc.report.AppendChild($xmlDoc.CreateElement("status"));
    $XMLWriteSystemStatus.SetAttribute("stage",$stage);
    $XMLWriteSystemStatus.SetAttribute("status",$stagestatus);
}

function XMLReadLogic {
    Set-Variable -Name $global:stage -Value $xmlDoc.status.stage;
    Set-Variable -Name $global:stagestatus -Value $xmlDoc.status.status;
}

function WindowsStaging {
    XMLReadLogic;
    if (stage = 1) {
        XMLLogic;
        WindowsStage1;       
    }
    if ((stage = 1) -and (status = 1)) {
        Set-Variable -Name $global:stage -Value 2;
        Set-Variable -Name $global:stagestatus -Value 0; 
        WindowsStage2;
    }
    if ((stage = 2) -and (status = 1)) {
        Set-Variable -Name $global:stage -Value 3;
        Set-Variable -Name $global:stagestatus -Value 0; 
        WindowsStage3;
    }
}

function WindowsStage1 {
    Write-Output "Setting Hostname";
    Rename-Computer -ComputerName $hostname -Confirm; # Asks to confirm hostname change then commits it.
    if ($env:HOSTNAME = $hostname) {
        Write-Information "Hostname Setup Complete";
    }
    else {
        Write-Error -Message "Well, something failed. I'm going to sleep for fifteen seconds while you figure out your next steps.";
        Start-Sleep -Seconds 15;
        Write-Information -MessageData "Hostname Setup Completed Successfully.";
    }
    Write-Information "Now updating Windows, please wait.";
    Install-Module PSWindowsUpdate; # This will download and install the Windows Update module for PowerShell.
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d; # Use Microsoft Update Service instead of Windows Update Service
    Get-WUInstall –MicrosoftUpdate –AcceptAll;
    Set-Variable -Name $global:stagestatus -Value 1;
    XMLWriteLogic;
    Write-Information "Rebooting in 30 seconds.";
    shutdown /r /t 30 /c "Rebooting after hostname configuration and Windows Update.";
}

function WindowsStage2 {
    Write-Information "Welcome back, this obviously means you survived the reboot, and I didn't fuck up your day too bad.";
    Write-Information "Let's get Ninite cooking.";
    Invoke-WebRequest -Uri $niniteURL -OutFile $niniteOutput;
    Ninite.exe;
    Write-Information "Ninite has finished, marking this stage as complete and preparing for reboot.";
    Set-Variable -Name $global:stagestatus -Value 1;
    XMLWriteLogic;
    shutdown /r /t 30 /c "Rebooting after Ninite installation.";
}

function WindowsStage3 {
    Write-Information "Stage 3 is ready. Beginning defrag.";
    defrag C: /H /V;
    Write-Information "Tada! Sysprep is complete."
    Set-Variable -Name $global:stagestatus -Value 1
    XMLWriteLogic;

}