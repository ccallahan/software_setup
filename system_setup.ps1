# System Setup Script for Chance's Computers

param (
    [string]$os = $(throw "-OS is required, options are Windows or Fedora"),
    [string]$stage = $(throw "-stage is required if not found. See code for details."),
    [string]$hostname = $(throw "-hostname is required."),
    [switch]$SaveData = $false
)

function OSRouting {
    if (os = Windows) {
        WindowsStaging
    }
    elseif (os = Fedoira) {
        FedoraStaging
    }
    else {
        Write-Error -Message "OS Routing Failed. Check your flags."
    }
}

