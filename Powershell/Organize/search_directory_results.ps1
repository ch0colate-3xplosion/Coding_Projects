# Define the root directory
$rootDirectory = "H:\"

# Define the output file (Word document)
$outputFile = "H:\SearchResults.docx"

# Create a new Word document
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$document = $word.Documents.Add()

# Function to add text to the Word document
function Add-TextToDocument {
    param (
        [string]$text,
        [bool]$isBold = $false
    )
    $range = $document.Content
    $range.Collapse(1)  # Collapse the range to the end
    $range.Text = $text + "`r`n"
    if ($isBold) {
        $range.Font.Bold = 1
    } else {
        $range.Font.Bold = 0
    }
}

# Search and collect files and empty directories
$files = Get-ChildItem -Path $rootDirectory -Recurse -File
$emptyDirectories = Get-ChildItem -Path $rootDirectory -Recurse -Directory | Where-Object { $_.GetFiles().Count -eq 0 }

# Add files to the document
foreach ($file in $files) {
    Add-TextToDocument -text $file.FullName
}

# Add a section for empty directories
Add-TextToDocument -text "`r`nEmpty Directories" -isBold $true

# Add empty directories to the document
foreach ($dir in $emptyDirectories) {
    Add-TextToDocument -text $dir.FullName
}

# Save and close the Word document
$document.SaveAs([ref]$outputFile)
$document.Close()
$word.Quit()

# Release the COM object
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
