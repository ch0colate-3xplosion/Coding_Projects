$rootDirectory = "H:\"
$baseDuplicateDir = "duplicate_directory"

# Calculate a hash for a file
function Get-FileHashValue {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
}

# Define directories for specific file types
$directoriesByFileType = @{
    ".txt"        = "text_directory";
    ".docx"       = "microsoft_documents";
    ".doc"        = "microsoft_documents";
    ".docm"        = "microsoft_documents";
    ".ppt"        = "powerpoint_documents";
    ".pptx"       = "powerpoint_documents";
    ".xls"        = "excel_documents";
    ".xlsx"       = "excel_documents";
    ".csv"        = "excel_documents";
    ".jpg"        = "picture_directory";
    ".jpeg"       = "picture_directory";
    ".png"        = "picture_directory";
    ".svg"        = "picture_directory";
    ".webp"        = "picture_directory";
    ".ico"        = "picture_directory";
    ".zip"        = "zip_directory";
    ".7z"         = "zip_directory";
    ".gz"         = "zip_directory";
    ".pdf"        = "pdf_directory";
    ".mp3"        = "media_directory";
    ".wav"        = "media_directory";
    ".flac"       = "media_directory";
    ".mp4"        = "video_directory";
    ".mkv"        = "video_directory";
    ".ctb"        = "cherrytree_directory";
    ".ctx"        = "cherrytree_directory";
    ".ctb~"       = "cherrytree_directory";
    ".ctb~~"      = "cherrytree_directory";
    ".ctb~~~"     = "cherrytree_directory";
    ".ctx~"       = "cherrytree_directory";
    ".ctx~~"      = "cherrytree_directory";
    ".ctx~~~"     = "cherrytree_directory";
    ".py"         = "python3_directory";
    ".ps1"        = "powershell_directory";
    ".java"       = "java_directory";
    ".sh"         = "bash_directory";
}

# Categorize and move based on file type
function CategorizeAndMove($file) {
    $extension = $file.Extension
    if ($directoriesByFileType.ContainsKey($extension)) {
        $destination = Join-Path -Path $rootDirectory -ChildPath $directoriesByFileType[$extension]
        New-Item -Path $destination -ItemType Directory -Force | Out-Null
        Move-Item -Path $file.FullName -Destination $destination
    }
}

# Check and move duplicates
function CheckAndMove($file) {
    $hashValue = Get-FileHashValue -FilePath $file.FullName
    if ($hashTable.ContainsKey($hashValue)) {
        $existingFiles = $hashTable[$hashValue]
        $index = 1
        foreach ($existing in $existingFiles) {
            if (Compare-Object (Get-Content $file.FullName) (Get-Content $existing.FullName)) {
                $dupDir = Join-Path -Path $rootDirectory -ChildPath ($baseDuplicateDir + "_$index")
                New-Item -Path $dupDir -ItemType Directory -Force | Out-Null
                Move-Item -Path $file.FullName -Destination $dupDir
                $index++
            }
        }
        $hashTable[$hashValue] += $file
    } else {
        $hashTable[$hashValue] = @($file)
    }
}

$files = Get-ChildItem -Path $rootDirectory -Recurse -File

# First categorize files by type
foreach ($file in $files) {
    CategorizeAndMove $file
}

# Now, check for duplicates in each category
$hashTable = @{}
foreach ($directory in $directoriesByFileType.Values) {
    $categoryFiles = Get-ChildItem -Path (Join-Path $rootDirectory $directory) -Recurse -File
    foreach ($file in $categoryFiles) {
        CheckAndMove $file
    }
}

# Create a runspace pool
$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

# Create a list to store runspaces
$runspaces = @()

# First categorize files by type in parallel
$files = Get-ChildItem -Path $rootDirectory -Recurse -File
foreach ($file in $files) {
    $runspace = [powershell]::Create().AddScript({
        param ($file, $directoriesByFileType, $rootDirectory)
        CategorizeAndMove $file
    }).AddArgument($file).AddArgument($directoriesByFileType).AddArgument($rootDirectory).Runspace

    $runspace.RunspacePool = $runspacePool
    [void]$runspaces.Add([PSCustomObject]@{
        Runspace = $runspace
        Status   = $runspace.BeginInvoke()
    })
}

# Wait for all categorization tasks to complete
$runspaces | ForEach-Object {
    $_.Runspace.EndInvoke($_.Status)
}

# Clear the runspaces for the next task
$runspaces.Clear()

# Now, check for duplicates in each category in parallel
foreach ($directory in $directoriesByFileType.Values) {
    $categoryFiles = Get-ChildItem -Path (Join-Path $rootDirectory $directory) -Recurse -File
    foreach ($file in $categoryFiles) {
        $runspace = [powershell]::Create().AddScript({
            param ($file, $hashTable, $rootDirectory, $baseDuplicateDir)
            CheckAndMove $file
        }).AddArgument($file).AddArgument($hashTable).AddArgument($rootDirectory).AddArgument($baseDuplicateDir).Runspace

        $runspace.RunspacePool = $runspacePool
        [void]$runspaces.Add([PSCustomObject]@{
            Runspace = $runspace
            Status   = $runspace.BeginInvoke()
        })
    }
}

# Wait for all duplicate checking tasks to complete
$runspaces | ForEach-Object {
    $_.Runspace.EndInvoke($_.Status)
}

$runspacePool.Close()
$runspacePool.Dispose()


Write-Host "Files categorized and duplicates moved successfully!"
