$baseDirectory = "H:\File 6\database_directory\"  # Change this to your target directory path

# Function to rename "duplicate_directory_#" directories
function Rename-DuplicateDirectories {
    param (
        [string]$directoryPath
    )

    $counter = 1

    # Get all directories starting with "duplicate_directory_#"
    $duplicateDirectories = Get-ChildItem -Path $directoryPath -Directory | Where-Object { $_.Name -match "^duplicate_directory_\d+" }

    foreach ($dir in $duplicateDirectories) {
        $newDirectoryName = "new_$counter"

        # Check if the "new_#" directory already exists, and if so, keep incrementing the counter until a unique name is found
        while (Test-Path (Join-Path -Path $directoryPath -ChildPath $newDirectoryName)) {
            $counter++
            $newDirectoryName = "new_$counter"
        }

        # Rename the directory
        Rename-Item -Path $dir.FullName -NewName $newDirectoryName
        Write-Host "Renamed directory $($dir.FullName) to $newDirectoryName"

        # Recursively rename subdirectories
        Rename-DuplicateDirectories -directoryPath $dir.FullName
        $counter++
    }
}

# Start renaming "duplicate_directory_#" directories from the base directory
Rename-DuplicateDirectories -directoryPath $baseDirectory
