<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/9/2020 09:43
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	deploy.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



Write-Host "Beginning deployment" -ForegroundColor Green

$PS1Files = Get-ChildItem "$PSScriptRoot\Functions" -Filter "*.ps1" -Recurse | Sort-Object Name

"" | Out-File -FilePath .\concatenated.ps1 -Encoding utf8

$Counter = 0
foreach ($File in $PS1Files) {
    $Counter++
    Write-Host (" Adding file {0:D2}/{1:D2}: $($File.Name)" -f $Counter, $PS1Files.Count)
    
    "`r`n#region File $($File.Name)`r`n" | Out-File -FilePath .\concatenated.ps1 -Encoding utf8 -Append
    
    Get-Content $File.FullName -Encoding UTF8 | Out-File -FilePath .\concatenated.ps1 -Encoding utf8 -Append
    
    "`r`n#endregion" | Out-File -FilePath .\concatenated.ps1 -Encoding utf8 -Append
}

"" | Out-File -FilePath .\concatenated.ps1 -Encoding utf8 -Append

Write-Host " Adding psm1"
Get-Content .\NetboxPS.psm1 | Out-File -FilePath .\concatenated.ps1 -Encoding UTF8 -Append

Write-Host " Copying psd1"
Copy-Item -Path .\NetboxPS.psd1 -Destination .\dist\NetboxPS.psd1 -Force

Write-Host " Copying psm1"
Copy-Item -Path .\concatenated.ps1 -Destination .\dist\NetboxPS.psm1 -Force

Write-Host "Deployment complete" -ForegroundColor Green