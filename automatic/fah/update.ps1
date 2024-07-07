$ErrorActionPreference = 'Stop'
import-module au

$releases = 'https://download.foldingathome.org/releases/public/fah-client/meta.json'

function global:au_AfterUpdate($Package) {
	Invoke-VirusTotalScan $Package
}

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]url32\s*=\s*)('.*')"      = "`$1'$($Latest.URL32)'"
			"(^[$]checksum32\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
		}
	}
}

function global:au_GetLatest {
	$page = Invoke-WebRequest -Uri $releases -UseBasicParsing
	$json = $page.Content | convertfrom-json
	$url32 = "https://download.foldingathome.org/releases/public/fah-client/$($json[0].package)"
	$version = (Get-Version $url32).Version

	$Latest = @{ URL32 = $url32; Version = $version }
	return $Latest
}

update -ChecksumFor 32
