# Capture the start time
$startTime = Get-Date

# Define the root directory to start from. '.' represents the current directory.
$rootDirectory = 'H:\'

# Get all files recursively
$files = Get-ChildItem -Path $rootDirectory -File -Recurse

# Create an empty list to hold the results
$results = @()

$totalFiles = $files.Count
$currentFileNumber = 0

foreach ($file in $files) {
    # Increment the file counter
    $currentFileNumber++

    # Extract the directory and file extension
    $directory = [System.IO.Path]::GetDirectoryName($file.FullName)
    $extension = [System.IO.Path]::GetExtension($file.Name)

    # Construct the result string and add to the list
    $results += "$directory : $extension"

    # Display progress
    Write-Progress -Activity "Processing Files" -Status "Scanning: $($file.FullName)" -PercentComplete (($currentFileNumber / $totalFiles) * 100)
}

# Get unique results
$uniqueResults = $results | Sort-Object | Get-Unique

# Output the unique results to the file_types.txt
$uniqueResults | Out-File -Path file_types.txt

# Calculate elapsed time
$endTime = Get-Date
$elapsedTime = $endTime - $startTime

# Display a completion message with elapsed time
Write-Output "Process completed in $($elapsedTime.TotalSeconds) seconds! Check file_types.txt for the output."

