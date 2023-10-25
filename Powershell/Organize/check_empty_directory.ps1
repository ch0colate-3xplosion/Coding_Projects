# Define the directory to start the search from
$startDirectory = "H:\"

# Recursively get all directories from the start directory
$directories = Get-ChildItem -Path $startDirectory -Recurse -Directory

# Loop through each directory and check if it's empty, then delete it
foreach ($dir in $directories) {
    if ((Get-ChildItem -Path $dir.FullName -Recurse -File).Count -eq 0) {
        Remove-Item -Path $dir.FullName -Force -Confirm:$false
        Write-Host "Deleted empty directory: $($dir.FullName)"
    }
}

Write-Host "Operation completed!"
