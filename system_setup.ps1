# System Setup Script for Chance's Computers


param (
    [string]$os = $(throw "-OS is required, options are Windows or Fedora"),
    [int]$stage = $(throw "-stage is required if not found. See code for details."),
    [string]$hostname = $(throw "-hostname is required.")
)


# Variable Time!
$stagestatus = 1; # Initializing the stage status as a global.
$niniteURL = "https://ninite.com/.net4.7.2-7zip-adoptjdkx11-adoptjdkx8-air-cccp-chrome-discord-filezilla-gimp-googleearth-imgburn-inkscape-notepadplusplus-python-qbittorrent-shockwave-silverlight-spotify-steam-teamviewer14-vlc-windirstat/ninite.exe";
$niniteOutput = "$PSScriptRoot\Ninite.exe";

function OSRouting {
    if ($os -eq "Windows") {
        WindowsStaging;
    }
    elseif ($os -eq "Fedora") {
        FedoraStaging;
    }
    else {
        Write-Error -Message "OS Routing Failed. Check your flags.";
    }
}

function XMLTest {
    if ([System.IO.File]::Exists($fileName)) {
        XMLReadLogic;
    }
    else {
        XMLWriteLogic;
    }
}

function WindowsStaging {
    if ($stage -eq 1) {
        WindowsStage1;       
    }
    if ($stage -eq 2) {
        WindowsStage2;
    }
    if ($stage -eq 3) { 
        WindowsStage3;
    }
}

function WindowsStage1 {
    Write-Output "Setting Hostname";
    Rename-Computer -NewName $hostname; # Asks to confirm hostname change then commits it.
    if ($env:HOSTNAME = $hostname) {
        Write-Output "Hostname Setup Complete";
    }
    else {
        Write-Error -Message "Well, something failed. I'm going to sleep for fifteen seconds while you figure out your next steps.";
        Start-Sleep -Seconds 15;
        Write-Output -MessageData "Hostname Setup Completed Successfully.";
    }
    Write-Output "Now updating Windows, please wait.";
    Install-Module PSWindowsUpdate; # This will download and install the Windows Update module for PowerShell.
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d; # Use Microsoft Update Service instead of Windows Update Service
    Get-WUInstall –MicrosoftUpdate –AcceptAll;
    Write-Output "Rebooting in 30 seconds.";
    shutdown /r /t 30 /c "Rebooting after hostname configuration and Windows Update.";
}

function WindowsStage2 ($os, $stage, $hostname) {
    Write-Output "Welcome back, this obviously means you survived the reboot, and I didn't fuck up your day too bad.";
    Write-Output "Let's get Ninite cooking.";
    Invoke-WebRequest -Uri $niniteURL -OutFile $niniteOutput;
    .\Ninite.exe
    Write-Output "I am going to sleep for fifteen minutes. If Ninite doesn't finish in time, type shutdown /a into a run prompt."
    Start-Sleep -Seconds 900
    Write-Output "Ninite has finished, marking this stage as complete and preparing for reboot.";
    shutdown /r /t 30 /c "Rebooting after Ninite installation.";
}

function WindowsStage3 ($os, $stage, $hostname) {
    Write-Output "Stage 3 is ready. Beginning defrag.";
    defrag C: /H /V;
    Write-Output "Tada! Sysprep is complete."
}

OSRouting