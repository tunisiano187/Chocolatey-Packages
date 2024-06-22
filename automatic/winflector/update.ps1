$ErrorActionPreference = 'Stop'
import-module au

$releases = "https://www.winflector.com/english/download.html"

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1' = @{
            "(^[$]url\s*=\s*)('.*')"            = "`$1'$($Latest.URL32)'"
            "(^[$]checksum\s*=\s*)('.*')"       = "`$1'$($Latest.Checksum32)'"
            "(^[$]checksumType\s*=\s*)('.*')"   = "`$1'$($Latest.ChecksumType32)'"
        }
     }
}

function global:au_AfterUpdate($Package) {
	Invoke-VirusTotalScan $Package
}

function global:au_GetLatest {
    $link = ((Invoke-WebRequest -Uri $releases -UseBasicParsing).Links | Where-Object {$_.outerHTML -match "Server and client"} | Select-Object -First 1)
	$url32="https://www.winflector.com/$($link.href)"

    $regexPattern = 'Server and client package \((\d+(\.\d+)*)'
	$versionMatch = $page.Content | Select-String -Pattern $regexPattern -AllMatches
	$version = $versionMatch.Matches[0].Groups[1].Value

	$Latest = @{ URL32 = $url32; Version = $version }

    return $Latest
}

update -ChecksumFor 32
