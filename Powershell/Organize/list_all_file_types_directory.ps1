# Define the root directory to start from. '.' represents the current directory.
$rootDirectory = "H:\"

# Get all files recursively
$files = Get-ChildItem -Path $rootDirectory -File -Recurse

# Create an empty list to hold the results
$results = @()

foreach ($file in $files) {
    # Extract the directory and file extension
    $directory = [System.IO.Path]::GetDirectoryName($file.FullName)
    $extension = [System.IO.Path]::GetExtension($file.Name)

    # Construct the result string and add to the list
    $results += "$directory : $extension"
}

# Get unique results
$uniqueResults = $results | Sort-Object | Get-Unique

# Output the unique results to the file_types.txt
$uniqueResults | Out-File -Path file_types.txt

# Display a completion message
Write-Output "Process completed! Check file_types.txt for the output."
