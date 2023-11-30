#This will require PowerShell 7.0+
# Define the source and destination drives
$sourceDrive = "H:\"  # Change this to the source drive letter
$destinationDrive = "F:\organized_files\"  # Change this to the destination drive letter

# Define the directories and their corresponding file extensions
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

# Function to create/check duplicate directories on the destination drive
function Get-DuplicateDirectory {
    param ([string]$baseDirectory, [string]$fileName)
    $counter = 0
    while ($true) {
        $duplicateDirName = "duplicate_directory"
        if ($counter -ne 0) {
            $duplicateDirName += "_$counter"
        }

        $duplicateDir = Join-Path -Path $baseDirectory -ChildPath $duplicateDirName

        if (-not (Test-Path $duplicateDir)) {
            New-Item -Path $duplicateDir -ItemType Directory -Force
            Write-Host "Created new duplicate directory: $duplicateDir"
        }
        
        $fullDuplicateFilePath = Join-Path -Path $duplicateDir -ChildPath $fileName
        if (-not (Test-Path $fullDuplicateFilePath)) {
            return $duplicateDir
        }

        $counter++
    }
}

# Function to calculate file hash
function Get-FileHashString ($filePath) {
    $hash = Get-FileHash -Path $filePath -Algorithm SHA256
    return $hash.Hash
}

# Create a hashtable to track found files and their hashes
$foundFiles = @{}

# Initialize directories on the destination drive
$destinationBaseDirectory = Join-Path -Path $destinationDrive -ChildPath "\"
foreach ($dir in $fileTypes.Keys) {
    $path = Join-Path -Path $destinationBaseDirectory -ChildPath $dir
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory
    }
}

# Starting the parallel processing
Write-Host "Starting to search and process files in $sourceDrive"
Get-ChildItem -Path $sourceDrive -Recurse -File | ForEach-Object -Parallel {
    param ($file)

    # Extract file extension using Path.GetExtension()
    $extension = [System.IO.Path]::GetExtension($file.Name).ToLower()

    # Extract file types outside the loop
    $localFileTypes = $using:fileTypes

    # Check if file's extension is in any of the defined categories
    foreach ($dir in $localFileTypes.Keys) {
        $extensions = $localFileTypes[$dir]
        if ($extension -in $extensions) {
            $destinationDir = Join-Path -Path $using:destinationBaseDirectory -ChildPath $dir
            $destinationPath = Join-Path -Path $destinationDir -ChildPath $file.Name

            # Check if a file with the same name already exists in the destination directory
            if (Test-Path $destinationPath) {
                # File exists, handle as duplicate
                $duplicateDir = Get-DuplicateDirectory -baseDirectory $using:destinationBaseDirectory -fileName $file.Name
                Copy-Item -Path $file.FullName -Destination $duplicateDir
            } else {
                # New file, move it to its corresponding directory on the destination drive
                Move-Item -Path $file.FullName -Destination $destinationPath
            }
            break
        }
    }
} -ThrottleLimit 12 # Adjust the ThrottleLimit based on your system's capabilities

Write-Host "File processing completed."
