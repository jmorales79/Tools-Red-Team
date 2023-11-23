#
.SYNOPSIS
    This script is designed for an administrator to uninstall and then re-install the XBC/Basecamp uninstaller and then re-install directly after.
  
    *PowerShell 5.1 or up is required to run this script
    *Internet connection required
  
    Created by: William Evans
    Edits: Patrick Friedman, Harry Tran, and Dalton House
  
    NOTICE: Trend Micro developed this script as a workaround or solution
          to a problem reported by customers. As such, this script has
          received limited testing and has not been certified as an
          official product update. Consequently, THIS SCRIPT IS PROVIDED
          "AS IS". TREND MICRO MAKES NO WARRANTY OR PROMISE ABOUT THE
          OPERATION OR PERFORMANCE OF THIS SCRIPT NOR DOES TREND MICRO
          WARRANT THIS SCRIPT AS ERROR FREE.TO THE FULLEST EXTENT
          PERMITTED BY LAW, TREND MICRO DISCLAIMS ALL IMPLIED AND
          STATUTORY WARRANTIES, INCLUDING BUT NOT LIMITED TO THE IMPLIED
          WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT AND FITNESS FOR
          A PARTICULAR PURPOSE. 
  
.DESCRIPTION
  
This tool uninstalls/re-installs the XBC/Basecamp agent. Below is a section of the script that is required to be modified for this script to work.
  
Pre-Req:
1. PowerShell 5.1 or up is required to run this script.
2. Internet connection required.
  
  
This script will do the following:
1. Download the XBC/Basecamp uninstaller from online.
2. Extract dependency files.
3. Execute the XBC/Basecamp Uninstaller.
4. Clean up dropped files.
5. Verifies that the XBC/Basecamp agent has been removed
6. Download the XBC/Basecamp Installer from the Vision One console online.
7. Execute the XBC/Basecamp Installer.
8. Profit!
  
Error Level Output:
0 = Successfully completed with no errors.
1 = Script was not run as admin and does not have privleges required to execute successfully.
2 = The agent still exists, the uninstall has failed.
3 = The XBC/Basecamp installer ran into an issue.
  
  
Prepare Script Steps:
  
1. Find a section that says, "Change the following Variables values:".
2. You will need to input the $BasecampDownloadURL variable to the download link for the basecamp agent (Endpoint Inventory > Agent Installer > "Copy Download Link" button in the "Windows" box) There will be a copy button for the download link of the URL to copy.
3. Copy the provided JSON (Provided by the support engineer) and place it in the $JSON variable. You will need to ensure that the JSON string is encapsulated in ''
3a. Similar to:
  
$JSON = '{
  "ce_uninstall_tool": {
    "x64": "https://xxxxxx.xxxxxx.trendmicro.com/pkg/app-cloudep-win-agent/latest/x64/CloudEndpointServiceWebInstaller.zip",
    "x86": "https://xxxxxx.xxxxxx.trendmicro.com/pkg/app-cloudep-win-agent/latest/x86/CloudEndpointServiceWebInstaller.zip"
  },
  "jwt": "ReallyLongStringOfRandomCharactersXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "xbc_uninstall_tool": "https://XXXXXX.XXXXXX.trendmicro.com/pkg/app-xbc-uninstaller-win-agent/win32/endpoint_basecamp_uninstall_tool.exe"
}'
  
4. Deploy Script out to enpoints via a GPO, Deployment software or any other deployment method.
  
#>
  
#*******************************************************************************************************************************************************************************************
  
# *** Change the following Variables values: ***
  
# URL to the basecamp agent download.
$BasecampDownloadURL="" # Ensure to encapsulate the URL into the ""
  
# JSON File provided by Trend Micro Support.
$JSON = '' # Ensure that the JSON is encapsulated in the ''
  
# Allow for re-install of the XBC/Basecamp agent? (Default: 1 | Yes)
$reinstall = 1 # Set to 0 if you do not want the script to not re-install the XBC/Basecamp.
  
#********************************************************************************************************************************************************************************************
  
# Verify that script is running as Admin.
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
   Write-Warning "You are not running as an Administrator. Please try again with admin privileges."
   exit 1
}
  
# More Variables
$JSON = Convertfrom-Json $JSON
$XBCtoken= $JSON.jwt # Token provided by Trend Micro Support for XES uninstallation.
$XBCuninstallerPack= $JSON.xbc_uninstall_tool # URL to download XBCUninstaller pack provided by Trend Micro Support.
$ce_uninstaller_x86 = $JSON.ce_uninstall_tool.x86 # URL to download XBCUninstaller 32 bit dependency file.
$ce_uninstaller_x64 = $JSON.ce_uninstall_tool.x64 # URL to download XBCUninstaller 64 bit dependency file.
$TMdir = "C:\Program Files (x86)\Trend Micro" # Basecamp default install location.
  
# Verify that a c:\temp directory exists, create if not.
if(!(test-path c:\temp)){
  New-Item -Path "c:\" -Name "temp" -ItemType Directory -Force
}
  
# Funtion to delete remenant files
$deletetraces = {
    Start-Sleep -Seconds 5
    Set-Location c:\temp
    Remove-Item XBCUninstallToken.txt,XBCUninstaller.exe,CloudEndpointServiceWebInstaller.exe,ce_uninstaller_x86.zip,ce_uninstaller_x64.zip,ce_uninstaller_x86,ce_uninstaller_x64,XBC -Recurse -ErrorAction Ignore
}
  
  
# Check to see if basecamp folder exists, if so proceed with downloading and executing the Basecamp/xbc uninstaller.
if (Test-Path -Path $TMdir) {
    Write-Host "Starting XBC/Basecamp Uninstall Process" -ForegroundColor Green
    Set-Location c:\temp # Set location to temp directory
  
    # Download XBC Uninstaller Files
    Invoke-WebRequest -Uri $XBCuninstallerPack -OutFile "XBCUninstaller.exe"
    Invoke-WebRequest -Uri $ce_uninstaller_x64 -OutFile "ce_uninstaller_x64.zip"
    Invoke-WebRequest -Uri $ce_uninstaller_x86 -OutFile "ce_uninstaller_x86.zip"
      
    # Expand CE uninstallers
    Expand-Archive ce_uninstaller_x86.zip -DestinationPath c:\temp -force
    Expand-Archive ce_uninstaller_x64.zip -DestinationPath c:\temp -force
  
    # Create Token File
    New-Item "XBCUninstallToken.txt" -ItemType File -Value $XBCtoken -force
      
    # Run XBC uninstaller with Token provided.
    Invoke-Expression -command ("C:\temp\XBCUninstaller.exe XBCUninstallToken.txt")
    Remove-Item "$TMdir\Endpoint Basecamp" -Force -ErrorAction SilentlyContinue    
    Write-Host "Uninstall Process Completed" -ForegroundColor Green
}
  
# Remove uninstaller files.
Write-Host "Cleaning Uninstall Files" -ForegroundColor Green
Invoke-Command -ScriptBlock $deletetraces
  
# Check to see if the agent was uninstalled properly and removed folder.
 if(Test-Path -Path "$TMdir\Endpoint Basecamp" -ErrorAction SilentlyContinue){
    Write-Host "The agent still exists, the uninstall has failed. To determine cause try using the uninstaller manually to view error." -ForegroundColor Red
    exit 2
 }
  
# Run Basecamp installer
if ((!(Test-Path -Path "$TMdir\Endpoint Basecamp")) -and ($reinstall -eq 1)) { # Checks to verify agent was uninstalled and that re-install is allowed
    try {
        Write-Host "Starting XBC/Basecamp Install Process" -ForegroundColor Green
        set-location c:\temp
        Invoke-WebRequest -Uri $BasecampDownloadURL -OutFile "EndpointBasecamp.exe"
          
        # Start XBC/Basecamp installer.
        Write-Host "Executing Installer" -ForegroundColor Green
        Start-Process .\EndpointBasecamp.exe -Wait
        Write-Host "Install Process Completed" -ForegroundColor Green
        exit 0
    }
    catch {
        # Catch errors if they exist.
        throw $_.Exception.Message
        Write-Host "The installer ran into an issue. Try running the installer manually to determine the cause."-ForegroundColor Red
        exit 3
    }
  
 }