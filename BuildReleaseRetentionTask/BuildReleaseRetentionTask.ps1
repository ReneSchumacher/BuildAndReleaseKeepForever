Param(
    $mode,
    $usedefaultcreds
    )

function Set-BuildRetention
{
    param
    (
        $tfsuri,
        $teamproject,
        $buildID,
		$releaseid,
        $keepForever,
        $usedefaultcreds
    )

    $webclient = Get-WebClient -usedefaultcreds $usedefaultcreds
    
    write-verbose "Setting BuildID $buildID with Retention set to $keepForever"

    $uri = "$($tfsUri)/$($teamproject)/_apis/build/builds/$($buildID)?api-version=2.0"
    $data = @{keepForever = $keepForever} | ConvertTo-Json
    $response = $webclient.UploadString($uri,"PATCH", $data) 
}

function Set-ReleaseRetention
{
    param
    (
        $tfsuri,
        $teamproject,
        $buildID,
		$releaseid,
        $keepForever,
        $usedefaultcreds
    )
	write-verbose "Setting ReleaseID $releaseid with Retention set to $keepForever"
	$body = @{
				"keepForever"= 'true'
			 }
	$Uri = "$($tfsUri)$($teamproject)/_apis/release/releases/$($releaseid)?api-version=2.2-preview.1"
	$buildresponse = Invoke-RestMethod -Method Patch -UseDefaultCredentials -ContentType application/json -Uri $Uri -Body (ConvertTo-Json $body) 

  	write-verbose "Respones Value = $buildresponse"
}


function Get-BuildsForRelease
{
    param
    (
        $tfsuri,
        $teamproject,
        $releaseID,
        $usedefaultcreds
    )

    $webclient = Get-WebClient -usedefaultcreds $usedefaultcreds
    
    write-verbose "Getting Builds for Release releaseID"

    # at present Jun 2016 this API is in preview and in different places in VSTS hence this fix up   
	$rmtfsUri = $tfsUri -replace ".visualstudio.com",  ".vsrm.visualstudio.com/defaultcollection"
    $uri = "$($rmtfsUri)/$($teamproject)/_apis/release/releases/$($releaseId)?api-version=3.0-preview"
    $response = $webclient.DownloadString($uri)

    $data = $response | ConvertFrom-Json

    $return = @()
    $data.artifacts.Where({$_.type -eq "Build"}).ForEach( {
        $return += $_.definitionReference.version.id
    })

    $return

}


function Get-WebClient
{
    param
    (
       $usedefaultcreds
    )

    $webclient = new-object System.Net.WebClient
	
    if ([System.Convert]::ToBoolean($usedefaultcreds) -eq $true)
    {
        Write-Verbose "Using default credentials"
        $webclient.UseDefaultCredentials = $true
    } else {
        Write-Verbose "Using SystemVssConnection personal access token"
        $vssEndPoint = Get-ServiceEndPoint -Name "SystemVssConnection" -Context $distributedTaskContext
        $personalAccessToken = $vssEndpoint.Authorization.Parameters.AccessToken
        $webclient.Headers.Add("Authorization" ,"Bearer $personalAccessToken")
    }

    $webclient.Encoding = [System.Text.Encoding]::UTF8
    $webclient.Headers["Content-Type"] = "application/json"
    $webclient

}


# Output execution parameters.
$VerbosePreference ='Continue' # equiv to -verbose

# Get the build and release details
$collectionUrl = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$teamproject = $env:SYSTEM_TEAMPROJECT
$releaseid = $env:RELEASE_RELEASEID
$buildid = $env:BUILD_BUILDID

Write-Verbose "collectionUrl = [$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI]"
Write-Verbose "teamproject = [$env:SYSTEM_TEAMPROJECT]"
Write-Verbose "releaseid = [$env:RELEASE_RELEASEID]"
Write-Verbose "buildid = [$env:BUILD_BUILDID]"
Write-Verbose "usedefaultcreds =[$usedefaultcreds]"

if ($mode -eq "AllArtifacts")
{
    $builds = Get-BuildsForRelease -tfsUri $collectionUrl -teamproject $teamproject -releaseid $releaseid -usedefaultcreds $usedefaultcreds
    foreach($id in $builds)
    {
        Set-BuildRetention -tfsUri $collectionUrl -teamproject $teamproject -buildid $id -releaseid $releaseid -keepForever $true -usedefaultcreds $usedefaultcreds
		Set-ReleaseRetention -tfsUri $collectionUrl -teamproject $teamproject -buildid $id -releaseid $releaseid -keepForever $true -usedefaultcreds $usedefaultcreds
    }
} else 
{
    Set-BuildRetention -tfsUri $collectionUrl -teamproject $teamproject -buildid $buildid -releaseid $releaseid -keepForever $true -usedefaultcreds $usedefaultcreds
	Set-ReleaseRetention -tfsUri $collectionUrl -teamproject $teamproject -buildid $id -releaseid $releaseid -keepForever $true -usedefaultcreds $usedefaultcreds
}