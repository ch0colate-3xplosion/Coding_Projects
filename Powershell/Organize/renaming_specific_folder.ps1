$baseDirectory = "H:\"  # Change this to your target directory path

# Define the specific directories to rename
$directoriesToRename = @(
    "text_directory", "pdf_directory", "microsoft_documents", 
    "powerpoint_documents", "excel_documents", "microsoft_visio_directory",
    "microsoft_onenote_directory", "microsoft_projectplan", "picture_directory", 
    "media_directory", "video_directory", "cherrytree_directory", 
    "zip_directory", "python3_directory", "bash_scripts_directory",
    "powershell_directory", "java_directory", "c_scripts_directory", 
    "config_directory", "database_directory", "rss_feed_directory"
)

$counter = 1
foreach ($dir in $directoriesToRename) {
    $originalPath = Join-Path -Path $baseDirectory -ChildPath $dir
    if (Test-Path $originalPath) {
        $newFolderName = "new_$counter"
        $newFolderPath = Join-Path -Path $baseDirectory -ChildPath $newFolderName

        # Rename the folder
        Rename-Item -Path $originalPath -NewName $newFolderPath
        Write-Host "Renamed $dir to $newFolderName"

        $counter++
    } else {
        Write-Host "Directory does not exist: $dir"
    }
}
