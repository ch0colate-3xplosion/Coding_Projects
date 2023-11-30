# Define the root directory
$rootDirectory = "H:\"

# Define the directories to create
$directories = @("duplicate_directory", "cscript_directory", "config_directory", "database_directory", 
                 "excel_documents", "java_directory", "media_directory", "microsoft_documents", "microsoft_onenote_directory", 
                 "microsoft_visio_directory", "pdf_directory", "picture_directory", "powerpoint_directory", "powershell_directory", 
                 "python3_directory", "text_directory", "video_directory", "zip_directory", "rss_directory", "microsoft_projectplan", "bash_scripts_directory")

# Define file extensions for each directory
$fileTypes = @{
    "text_directory" = @(".txt", ".log", ".md")
    "pdf_directory" = @(".pdf")
    "microsoft_documents" = @(".doc", ".docx", ".docm", ".rtf")
    "powerpoint_documents" = @(".ppt", ".pptx")
    "excel_documents" = @(".xls", ".xlsx", ".csv", ".xlsm", ".xlsb", ".xltx")
    "microsoft_visio_directory" = @(".vsd", ".vsdx", ".vss")
    "microsoft_onenote_directory" = @(".one")
    "microsoft_projectplan" = @(".mpp", ".mpt", ".mpx")
    "picture_directory" = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".svg", ".jtif", ".jtf", ".ico")
    "media_directory" = @(".mp3", ".wav", ".aac", ".flac")
    "video_directory" = @(".mp4", ".avi", ".mov", ".mkv")
    "cherrytree_directory" = @(".ctd", ".ctb", ".ctx", ".ctb~", ".ctb~~", ".ctb~~~", ".ctx~", ".ctx~~", ".ctx~~~")
    "zip_directory" = @(".zip", ".rar", ".7z", ".archive", ".gz", ".tar", ".tar.bz2", ".bz2")
    "python3_directory" = @(".py")
    "bash_scripts_directory" = @(".sh")
    "powershell_directory" = @(".ps1", ".ps")
    "java_directory" = @(".java", ".jar")
    "c_scripts_directory" = @(".c", ".cpp", ".cs", ".h", ".hpp", ".hxx", ".hh")
    "config_directory" = @(".config", ".ini", ".bin", ".yml")
    "database_directory" = @(".db", ".sql", ".sqlite3", "sqlite")
    "rss_feed_directory" = @(".rss")
}

# Create directories
foreach ($directory in $directories) {
    $path = Join-Path -Path $rootDirectory -ChildPath $directory
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path
    }
}

# Log file
$logFile = Join-Path -Path $rootDirectory -ChildPath "results_organize.txt"

# Function to move files
function Move-FileToDirectory {
    param (
        [string]$filePath,
        [string]$destDirectory
    )
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $destPath = Join-Path -Path $destDirectory -ChildPath $fileName

    if (Test-Path -LiteralPath $destPath) {
        # Handle duplicates
        $counter = 1
        do {
            $newFileName = [System.IO.Path]::GetFileNameWithoutExtension($fileName) + "-$counter" + [System.IO.Path]::GetExtension($fileName)
            $destPath = Join-Path -Path $destDirectory -ChildPath $newFileName
            $counter++
        } while (Test-Path -LiteralPath $destPath)
    }

    Move-Item -LiteralPath $filePath -Destination $destPath
    "$filePath -> $destPath" | Out-File -FilePath $logFile -Append
}

# Start time
$startTime = Get-Date

# Search and move files
Get-ChildItem -Path $rootDirectory -Recurse | ForEach-Object {
    $filePath = $_.FullName

    # Log current file being processed
    "Processing file: $filePath" | Out-File -FilePath $logFile -Append

    foreach ($dir in $directories) {
        $destDirectory = Join-Path -Path $rootDirectory -ChildPath $dir
        if ($fileTypes[$dir] -contains $_.Extension) {
            Move-FileToDirectory -filePath $filePath -destDirectory $destDirectory
            break
        }
    }
}

# End time and time lapse calculation
$endTime = Get-Date
$timeLapse = $endTime - $startTime

# Log completion and time lapse
"File organization complete. Time elapsed: $timeLapse" | Out-File -FilePath $logFile -Append
