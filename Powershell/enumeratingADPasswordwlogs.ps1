# Paths
$textFilePath = "C:\path\to\your\inputTextFile.txt"
$bannedPasswordListPath = "C:\path\to\your\BannedPasswordList.txt"
$logPath = "C:\path\to\your\log.txt"
$allowedPasswordPath = "C:\path\to\your\AllowedPasswordList.txt"
$username = 

function Update-Password {
    param (
        [string]$username
    )

    if (!(Test-Path $textFilePath) -or !(Test-Path $bannedPasswordListPath)) {
        Write-Host "Files do not exist." -ForegroundColor Red
        return
    }

    $words = Get-Content $textFilePath

    foreach ($word in $words) {
        $passwordVariants = @(
            "!" + $word + "2023",
            $word + "2023" + "!",
            $word + "2023"
        )

        foreach ($newPassword in $passwordVariants) {
            $Password = ConvertTo-SecureString $newPassword -AsPlainText -Force

            try {
                Set-ADAccountPassword -Identity $username -NewPassword $Password -Reset
                Write-Host "Password for user updated successfully: $newPassword" -ForegroundColor Green
                $successfultimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                "$newPassword - Successfull Password - $successfultimestamp" | Out-File -FilePath $allowedPasswordPath -Append
                return
            }
            catch {
                Write-Host "Password change failed for: $newPassword. Error: $_" -ForegroundColor Yellow
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                "$word - Failed Password: $newPassword - $timestamp" | Out-File -FilePath $bannedPasswordListPath -Append

                # Check Event Viewer when password change fails
                Check-EventViewer -logPath $logPath
            }
        }
    }
}

function Check-EventViewer {
    param (
        [string]$logPath
    )

    $eventLog = Get-WinEvent -LogName 'Microsoft-AzureADPasswordProtection/DCAgent/Admin' -MaxEvents 1 | Where-Object { $_.Id -eq 30005 } | Select-Object -First 1

    if ($null -ne $eventLog) {
        if ($eventLog.Message -match "tokens present in the Microsoft global banned password list") {
            Add-Content -Path $logPath -Value ("[" + (Get-Date) + "] " + $eventLog.Message)
        } else {
            Add-Content -Path $logPath -Value ("[" + (Get-Date) + "] tokens not present in the Microsoft global banned password list but due to password policy password was banned")
        }
    } else {
        Add-Content -Path $logPath -Value ("[" + (Get-Date) + "] Event ID 30005 not found in the AzureADPasswordProtection/DCAgent/Admin log")
    }
}

# Call Functions
Update-Password -username "YourADUser"
