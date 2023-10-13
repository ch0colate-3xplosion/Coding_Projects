"# The path to the text file and banned password list file
$textFilePath = "C:\Users\Administrator\Documents\MSPasswordList\PasswordTest-Seasons.txt"
$bannedPasswordListPath = "C:\Users\Administrator\Documents\MSPasswordList\BannedPasswordList.txt"

# Ensure the files exist
if (!(Test-Path $textFilePath) -or !(Test-Path $bannedPasswordListPath)) {
    Write-Host "Files do not exist." -ForegroundColor Red
    return
}

# Read words from the text file
$words = Get-Content $textFilePath

foreach ($word in $words) {
    # Create a new password by appending 2023 and ! to the word
    $newPassword = $word + "2023" + "!"
    
    # Convert to a secure string
    $Password = ConvertTo-SecureString $newPassword -AsPlainText -Force
    
    # Try to change the AD user's password
    try {
        # Replace 'YourADUser' with the username of the AD user you want to update
        Set-ADAccountPassword -Identity "firstname.lastname" -NewPassword $Password -Reset
        Write-Host "Password for user updated successfully." -ForegroundColor Green
    }
    catch {
        # Log the word to the banned password list file with a timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$word - $timestamp" | Out-File -FilePath $bannedPasswordListPath -Append
        Write-Host "Password change failed for: $word. Added to banned password list." -ForegroundColor Yellow
    }
}"
