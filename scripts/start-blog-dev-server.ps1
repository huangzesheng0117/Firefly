$ErrorActionPreference = "Stop"

$blogRoot = Split-Path -Parent $PSScriptRoot
$blogPort = 5173
$existingListener = Get-NetTCPConnection `
	-LocalAddress 127.0.0.1 `
	-LocalPort $blogPort `
	-State Listen `
	-ErrorAction SilentlyContinue

if ($existingListener) {
	exit 0
}

$blogRuntimeDirectory = Join-Path $env:LOCALAPPDATA "PacketAndPathBlog"
$blogLogPath = Join-Path $blogRuntimeDirectory "dev-server.log"
$pnpmExecutable = "C:\Program Files\nodejs\pnpm.CMD"

New-Item -ItemType Directory -Path $blogRuntimeDirectory -Force | Out-Null
Set-Location -LiteralPath $blogRoot

Add-Content -LiteralPath $blogLogPath -Value (
	"[{0}] Starting Astro development server." -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
)

try {
	& $pnpmExecutable dev *>> $blogLogPath
	$blogExitCode = $LASTEXITCODE
	Add-Content -LiteralPath $blogLogPath -Value (
		"[{0}] Astro development server exited with code {1}." -f (
			Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		), $blogExitCode
	)
	exit $blogExitCode
}
catch {
	Add-Content -LiteralPath $blogLogPath -Value (
		"[{0}] Failed to start Astro development server: {1}" -f (
			Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		), $_.Exception.Message
	)
	exit 1
}
