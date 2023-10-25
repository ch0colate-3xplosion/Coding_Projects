$rootDirectory = "H:\"
$baseDuplicateDir = "duplicate_directory"
$hashTable = @{}

function Get-FileHashValue {
    param ([Parameter(Mandatory = $true)][string]$FilePath)
    return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash
}

# Define directories for specific file types
$directoriesByFileType = @{
    ".txt"        = "text_directory";
    ".docx"       = "microsoft_documents";
    ".doc"        = "microsoft_documents";
    ".docm"       = "microsoft_documents";
    ".rtf"        = "microsoft_documents";
    ".ppt"        = "powerpoint_documents";
    ".pptx"       = "powerpoint_documents";
    ".xls"        = "excel_documents";
    ".xlsx"       = "excel_documents";
    ".csv"        = "excel_documents";
    ".jpg"        = "picture_directory";
    ".jpeg"       = "picture_directory";
    ".png"        = "picture_directory";
    ".svg"        = "picture_directory";
    ".webp"       = "picture_directory";
    ".ico"        = "picture_directory";
    ".jfif"        = "picture_directory";
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
    ".one"        = "microsoftonenote_directory";
    ".vsdx"       = "microsoftvisio_directory";	
    ".rss"        = "rss_feed_directory";
}

$runspacePool = [runspacefactory]::CreateRunspacePool(1, 6)
$runspacePool.Open()

$runspaces = @()

$files = Get-ChildItem -Path $rootDirectory -Recurse -File

foreach ($file in $files) {
    $runspace = [powershell]::Create().AddScript({
        param ($file, $rootDirectory, $directoriesByFileType, $baseDuplicateDir, $hashTable)

        function CategorizeAndMove($file) {
            $extension = $file.Extension
            if ($directoriesByFileType.ContainsKey($extension)) {
                $destination = Join-Path -Path $rootDirectory -ChildPath $directoriesByFileType[$extension]
                New-Item -Path $destination -ItemType Directory -Force | Out-Null
                Move-Item -Path $file.FullName -Destination $destination
            }
        }

        function CheckAndMoveDuplicate($file) {
            $hashValue = Get-FileHashValue -FilePath $file.FullName
            if ($hashTable.ContainsKey($hashValue)) {
                $index = 1
                $destDir = Join-Path -Path $rootDirectory -ChildPath ($baseDuplicateDir + "_$index")
                while (Test-Path (Join-Path $destDir $file.Name)) {
                    $index++
                    $destDir = Join-Path -Path $rootDirectory -ChildPath ($baseDuplicateDir + "_$index")
                    New-Item -Path $destDir -ItemType Directory -Force | Out-Null
                }
                Move-Item -Path $file.FullName -Destination $destDir
            } else {
                $hashTable[$hashValue] = $file.FullName
            }
        }

        # Execute the categorize and move function
        CategorizeAndMove $file

        # Execute the check and move duplicates function
        CheckAndMoveDuplicate $file

    }).AddArgument($file).AddArgument($rootDirectory).AddArgument($directoriesByFileType).AddArgument($baseDuplicateDir).AddArgument($hashTable)
    
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
