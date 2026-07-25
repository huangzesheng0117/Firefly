$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repoRoot = Split-Path -Parent $PSScriptRoot
$archiveDir = Join-Path $repoRoot "docs\reference\fqzlr-posts"
$rssPath = Join-Path $archiveDir "rss.xml"
$userAgent = "Packet-and-Path-Maintenance-Archive/1.0"

function Save-WebFile {
	param(
		[Parameter(Mandatory = $true)][string]$Uri,
		[Parameter(Mandatory = $true)][string]$OutFile
	)

	& curl.exe --fail --location --retry 3 --silent --show-error --user-agent $userAgent --output $OutFile $Uri
	if ($LASTEXITCODE -ne 0) {
		throw "Download failed with exit code $LASTEXITCODE`: $Uri"
	}
}

if (-not (Test-Path -LiteralPath $archiveDir)) {
	New-Item -ItemType Directory -Path $archiveDir | Out-Null
}

Save-WebFile -Uri "https://www.fqzlr.com/posts/" -OutFile (Join-Path $archiveDir "index.html")
Save-WebFile -Uri "https://www.fqzlr.com/rss.xml" -OutFile $rssPath

[xml]$rss = [IO.File]::ReadAllText($rssPath)
$items = @($rss.rss.channel.item)
$index = [Collections.Generic.List[string]]::new()
$index.Add("# fqzlr.com Article Archive")
$index.Add("")
$index.Add("Generated: $([DateTime]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz'))")
$index.Add("")
$index.Add("Source: <https://www.fqzlr.com/posts/>")
$index.Add("")
$index.Add("| # | Article | Source | Local snapshot |")
$index.Add("|---:|---|---|---|")

for ($i = 0; $i -lt $items.Count; $i++) {
	$item = $items[$i]
	$uri = [Uri][string]$item.link
	$downloadUri = [UriBuilder]$uri
	$downloadUri.Host = "www.fqzlr.com"
	$slug = $uri.AbsolutePath.Trim("/") -replace "^posts/", "" -replace "/", "--"
	$slug = $slug -replace '[<>:"/\\|?*]', "-"
	$fileName = "{0:D2}-{1}.html" -f ($i + 1), $slug
	$filePath = Join-Path $archiveDir $fileName

	Save-WebFile -Uri $downloadUri.Uri.AbsoluteUri -OutFile $filePath
	$title = ([string]$item.title).Replace("|", "\|")
	$index.Add("| " + ($i + 1) + " | " + $title + " | <" + $uri.AbsoluteUri + "> | ``" + $fileName + "`` |")
}

$index.Add("")
$index.Add("> Local snapshots are for private maintenance reference only. Copyright remains with the source author.")
[IO.File]::WriteAllLines((Join-Path $archiveDir "INDEX.md"), $index, [Text.UTF8Encoding]::new($false))

Write-Host "Archived $($items.Count) articles to $archiveDir"
