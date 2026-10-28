# Double-click Start-Preview.cmd to start the local Jekyll preview and open it.
param([int]$Port = 4000, [switch]$NoBrowser)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$previewUrl = "http://127.0.0.1:$Port/"
$cachePath = Join-Path $projectRoot '.cache'
$stdoutPath = Join-Path $cachePath 'preview-stdout.log'
$stderrPath = Join-Path $cachePath 'preview-stderr.log'

function Test-Preview {
    try {
        $response = Invoke-WebRequest -Uri $previewUrl -UseBasicParsing -TimeoutSec 2
        return $response.StatusCode -eq 200
    } catch {
        return $false
    }
}

try {
    if (-not (Test-Preview)) {
        New-Item -ItemType Directory -Path $cachePath -Force | Out-Null
        $previewScript = Join-Path $PSScriptRoot 'preview.ps1'
        $shellPath = Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
        $previewArguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $previewScript), '-Port', $Port)
        $previewProcess = Start-Process -FilePath $shellPath -ArgumentList $previewArguments -WorkingDirectory $projectRoot -WindowStyle Hidden -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath -PassThru
        $previewProcess.Id | Set-Content -LiteralPath (Join-Path $cachePath 'preview-process-id.txt')
        $deadline = (Get-Date).AddSeconds(45)
        $ready = $false
        while ((Get-Date) -lt $deadline) {
            if (Test-Preview) { $ready = $true; break }
            $previewProcess.Refresh()
            if ($previewProcess.HasExited) { break }
            Start-Sleep -Milliseconds 400
        }
        if (-not $ready) {
            if (Test-Path -LiteralPath $stderrPath) {
                Get-Content -LiteralPath $stderrPath -Tail 12 | Write-Host
            }
            throw "Preview could not start. Logs: $stdoutPath and $stderrPath"
        }
    }
    Write-Host "Preview is ready: $previewUrl"
    Write-Host 'Save your content files, then refresh the browser to see changes.'
    if (-not $NoBrowser) { Start-Process $previewUrl }
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
