# Directories to check
$rootDirectory = "H:\"
$additionalDirectories = @(
    "H:\",
    "H:\File Backup\Computer Science",
    "H:\File Backup\Information Technology Security II Assignment 1",
    "H:\File Backup\Computer Science 2",
    "H:\Files",
    "H:\Microsoft Excel Files",
    "H:\Microsoft Powerpoint Files",
    "H:\Microsoft Word Files",
    "H:\PDF Files",
    "H:\Pictures",
    "H:\Server Administration",
    "H:\Server Management and Data Centres",
    "H:\Text Files",
    "H:\The Actually Useful Programming Library",
    "H:\Theory Of Computation",
    "H:\VB, C#, Visual Studio",
    "H:\Zipped Files",
	"H:\Humble Bundle",
	"C:\Users\MarkT\Downloads",
    "H:\File Backup\Computer Science (Backup)"
    # Add as many as you need
)

# Subdirectories for each file type
$text_directory = "H:\text_directory"
$docx_directory = "H:\microsoft_documents"
$ppt_directory = "H:\powerpoint_documents"
$excel_directory = "H:\excel_documents"
$picture_directory = "H:\picture_directory"
$zip_directory = "H:\zip_directory"
$pdf_directory = "H:\pdf_directory"
$duplicate_directory = "H:\duplicate_directory"
$media_directory = "H:\media_directory"
$pythonscript_directory = "H:\pythonscript_directory"
$video_directory = "H:\video_directory"
$bashscript_directory = "H:\bashscript_directory"
$powershell_directory = "H:\powershell_directory"
$cherrytree_directory = "H:\cherrytree_directory"

# Ensure directories exist
$directories = @($text_directory, $docx_directory, $ppt_directory, $excel_directory, $picture_directory, 
                 $zip_directory, $pdf_directory, $duplicate_directory, $media_directory, $pythonscript_directory, $video_directory, $powershell_directory, $cherrytree_directory)

foreach ($dir in $directories) {
    New-Item -Path $dir -ItemType Directory -Force
}

# Search and Move function with duplicate handling
function SearchAndMove($searchPattern, $destination, $searchRoot) {
    $files = Get-ChildItem -Path $searchRoot -Recurse -File | Where-Object { $_.Name -like $searchPattern }
    
    foreach ($file in $files) {
        $destFile = Join-Path -Path $destination -ChildPath $file.Name
        
        if (Test-Path -Path $destFile) {
            Move-Item -Path $file.FullName -Destination $duplicate_directory
        } else {
            Move-Item -Path $file.FullName -Destination $destination
        }
    }
}

# Loop through each directory including root
$allDirectoriesToCheck = @($rootDirectory) + $additionalDirectories

foreach ($dirToCheck in $allDirectoriesToCheck) {
    # Search for each file type and move
    SearchAndMove "*.txt" $text_directory $dirToCheck
    SearchAndMove "*.docx" $docx_directory $dirToCheck
    SearchAndMove "*.doc" $docx_directory $dirToCheck
    SearchAndMove "*.ppt" $ppt_directory $dirToCheck
    SearchAndMove "*.pptx" $ppt_directory $dirToCheck
    SearchAndMove "*.xls" $excel_directory $dirToCheck
    SearchAndMove "*.xlsx" $excel_directory $dirToCheck
    SearchAndMove "*.jpg" $picture_directory $dirToCheck
    SearchAndMove "*.gif" $picture_directory $dirToCheck
    SearchAndMove "*.jpeg" $picture_directory $dirToCheck
    SearchAndMove "*.svg" $picture_directory $dirToCheck
    SearchAndMove "*.webp" $picture_directory $dirToCheck
    SearchAndMove "*.icon" $picture_directory $dirToCheck
    SearchAndMove "*.png" $picture_directory $dirToCheck
    SearchAndMove "*.zip" $zip_directory $dirToCheck
    SearchAndMove "*.archive" $zip_directory $dirToCheck
    SearchAndMove "*.gz" $zip_directory $dirToCheck
    SearchAndMove "*.7z" $zip_directory $dirToCheck
    SearchAndMove "*.pdf" $pdf_directory $dirToCheck
	SearchAndMove "*.mp3" $media_directory $dirToCheck
	SearchAndMove "*.mp4" $video_directory $dirToCheck
	SearchAndMove "*.py" $pythonscript_directory $dirToCheck
	SearchAndMove "*.ps1" $powershell_directory $dirToCheck
	SearchAndMove "*.sh" $bashscript_directory $dirToCheck
	SearchAndMove "*.ctb" $cherrytree_directory $dirToCheck
	SearchAndMove "*.ctb~" $cherrytree_directory $dirToCheck
	SearchAndMove "*.ctb~~" $cherrytree_directory $dirToCheck
	SearchAndMove "*.ctb~~~" $cherrytree_directory $dirToCheck
	SearchAndMove "*.ctx" $cherrytree_directory $dirToCheck
	SearchAndMove "*.ctx~" $cherrytree_directory $dirToCheck
	SearchAndMove "*.ctx~~" $cherrytree_directory $dirToCheck
	SearchAndMove "*.ctx~~~" $cherrytree_directory $dirToCheck
}

Write-Host "Files moved successfully!"
