$rootDirectory = "H:\"

# Function to calculate file hash
function Get-FileHashValue {
    param ([Parameter(Mandatory = $true)][string]$filePath)
    return (Get-FileHash -Path $filePath -Algorithm SHA256).Hash
}

# Ensure directories are created
$directories = @("duplicate_directory", "bash_directory", "cscript_directory", "config_directory", "database_directory", 
                 "excel_documents", "java_directory", "media_directory", "microsoft_documents", "microsoft_onenote_directory", 
                 "microsoft_visio_directory", "pdf_directory", "picture_directory", "powerpoint_directory", "powershell_directory", 
                 "python3_directory", "text_directory", "video_directory", "zip_directory", "rss_directory", "microsoft_projectplan")

$directories | ForEach-Object {
    $dirPath = Join-Path -Path $rootDirectory -ChildPath $_
    if (-not (Test-Path $dirPath)) {
        New-Item -Path $dirPath -ItemType Directory | Out-Null
    }
}

# Categorize files based on extension
$extensionMapping = @{	
    ".txt"        = "text_directory";
    ".docx"       = "microsoft_documents";
    ".doc"        = "microsoft_documents";
    ".docm"       = "microsoft_documents";
    ".rtf"        = "microsoft_documents";
    ".ppt"        = "powerpoint_documents";
    ".pptx"       = "powerpoint_documents";
    ".xls"        = "excel_documents";
    ".xlsx"       = "excel_documents";
    ".xlm"        = "excel_documents";
    ".xlsm"       = "excel_documents";
    ".xlsb"       = "excel_documents";
    ".xltx"       = "excel_documents";
    ".csv"        = "excel_documents";
    ".jpg"        = "picture_directory";
    ".jpeg"       = "picture_directory";
    ".png"        = "picture_directory";
    ".svg"        = "picture_directory";
    ".webp"       = "picture_directory";
    ".ico"        = "picture_directory";
    ".jtif"       = "picture_directory";
    ".jtf"        = "picture_directory";
    ".gif"        = "picture_directory";
    ".bmp"        = "picture_directory";
    ".zip"        = "zip_directory";
    ".7z"         = "zip_directory";
    ".gz"         = "zip_directory";
    ".tar"        = "zip_directory";
    ".tar.bz2"    = "zip_directory";
    ".bz2"        = "zip_directory";
    ".rar"        = "zip_directory";
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
    ".ps"         = "powershell_directory";	
    ".java"       = "java_directory";
    ".jar"        = "java_directory";
    ".sh"         = "bash_directory";
    ".cs"         = "c_scripts_directory";
    ".cpp"        = "c_scripts_directory";
    ".c"          = "c_scripts_directory";
    ".h"          = "c_scripts_directory";
    ".cxx"        = "c_scripts_directory";
    ".cc"         = "c_scripts_directory";
    ".hpp"        = "c_scripts_directory";
    ".hxx"        = "c_scripts_directory";
    ".hh"         = "c_scripts_directory";
    ".conf"       = "config_directory";
    ".yml"        = "config_directory";
    ".bin"        = "config_directory";
    ".sql"        = "database_directory";
    ".db"         = "database_directory";
    ".sqlite3"    = "database_directory";
    ".sqlite"     = "database_directory";	
    ".mdb"        = "database_directory";	
    ".mdb"        = "database_directory";
    ".one"        = "microsoft_onenote_directory";
    ".vsdx"       = "microsoft_visio_directory";
    ".vsd"        = "microsoft_visio_directory";
    ".vss"        = "microsoft_visio_directory";
    ".mpp"        = "microsoft_projectplan";
    ".mpt"        = "microsoft_projectplan";
    ".mpx"        = "microsoft_projectplan";	
    ".rss"        = "rss_feed_directory";
}

$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

$runspaces = @()

$files = Get-ChildItem -Path $rootDirectory -Recurse -File

foreach ($file in $files) {
    $runspace = [powershell]::Create().AddScript({
        param ($file, $rootDirectory, $extensionMapping)

        function MoveFileToCategory {
            param ($file, $destination)
            $destinationPath = Join-Path -Path $destination -ChildPath $file.Name

            if (Test-Path $destinationPath) {
                $originalHash = Get-FileHashValue -filePath $destinationPath
                $newFileHash = Get-FileHashValue -filePath $file.FullName

                if ($originalHash -eq $newFileHash) {
                    $duplicateDirBase = Join-Path -Path $rootDirectory -ChildPath "duplicate_directory"
                    $duplicateDir = $duplicateDirBase
                    $counter = 1

                    while ((Test-Path (Join-Path -Path $duplicateDir -ChildPath $file.Name)) -or (-not (Test-Path $duplicateDir))) {
                        $duplicateDir = $duplicateDirBase + $counter
                        $counter++
                    }

                    if (-not (Test-Path $duplicateDir)) {
                        New-Item -Path $duplicateDir -ItemType Directory | Out-Null
                    }

                    Move-Item -Path $file.FullName -Destination $duplicateDir
                } else {
                    Move-Item -Path $file.FullName -Destination $destinationPath -Force
                }
            } else {
                Move-Item -Path $file.FullName -Destination $destinationPath -Force
            }
        }

        $extension = $file.Extension
        if ($extensionMapping.ContainsKey($extension)) {
            $destination = Join-Path -Path $rootDirectory -ChildPath $extensionMapping[$extension]
            MoveFileToCategory -file $file -destination $destination
        }

    }).AddArgument($file).AddArgument($rootDirectory).AddArgument($extensionMapping)
    
    $runspace.RunspacePool = $runspacePool
    [void]$runspaces.Add([PSCustomObject]@{
        Runspace = $runspace
        Status   = $runspace.BeginInvoke()
    })
}

$runspaces | ForEach-Object {
    $_.Runspace.EndInvoke($_.Status)
}

$runspacePool.Close()
$runspacePool.Dispose()

Write-Host "Files categorized and duplicates moved successfully!"

