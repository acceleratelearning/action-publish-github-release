#!/usr/bin/env pwsh
[CmdletBinding()]
param (
    [Version]$Version
)


Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Install-Module -Name 'hugoalh.GitHubActionsToolkit' -AcceptLicense -Scope CurrentUser
Install-Module -Name PowerShellForGitHub -Scope CurrentUser
Import-Module -Name 'hugoalh.GitHubActionsToolkit' -Scope 'Local'
Import-Module PowerShellForGitHub

. $PSScriptRoot/Add-GitHubPullRequestReviewAdditionalProperties.ps1
. $PSScriptRoot/Initialize-GitHubActionTasks.ps1
. $PSScriptRoot/New-GitHubPullRequestReview.ps1
. $PSScriptRoot/Write-Host.ps1
 

Initialize-GitHubActionTasks $env:GITHUB_TOKEN

$GitHubSha = $env:GITHUB_SHA
Write-Host -ForegroundColor Green "Getting Pull Request for $GitHubSha"
$pull_request = Get-GitHubPullRequest -State Closed | Where-Object { $_.merge_commit_sha -eq $GitHubSha }
if ($pull_request) {
    Write-Host -ForegroundColor Cyan "Getting release notes from $($pull_request.html_url)"
    $releaseNotes = $pull_request.body
}
else {
    Write-GitHubActionsWarning "No pull request found for $GitHubSha, no release information to publish"
    $releaseNotes = "# $Version"
}


$tag = "$Version"

Write-Host -ForegroundColor Cyan "Publishing Release $tag"
Write-Host ''

Write-Host -ForegroundColor Cyan "Release Notes"
$body | Write-Host
Write-Host ''

Write-Host -ForegroundColor Cyan "Validating tags: $tag"
Set-GitTag $tag $GitHubSha
Write-Host ''

Write-Host -ForegroundColor Cyan "Pushing tags"
git push origin $branch_name --tags
Write-Host ''

Write-Host -ForegroundColor Cyan "Checking for existing release for $($tag)"
# If you use Get-GitHubRelese -Tag $tag -ErrorAction:SilentlyContinue, it will
# still throw an error is the tag doesn't exist
$release = Get-GitHubRelease | Where-Object { $_.tag_name -eq $tag }
if ($release) {
    Write-Host -ForegroundColor Yellow "Updating existing release $($tag) with commit $GitHubSha"
    Set-GitHubRelease -ReleaseId $release.ID -Tag $tag -Name $tag -Committish $GitHubSha -Body $releaseNotes
    $release = Get-GitHubRelease -Tag $tag
}
else {
    Write-Host -ForegroundColor Green "Creating new release for $($tag) with commit $GitHubSha"
    $release = New-GitHubRelease -Tag $tag -Name $tag -Committish $GitHubSha -Body $releaseNotes
}

Set-GitHubActionsOutput 'release-html-url' $release.html_url
Set-GitHubActionsOutput 'release-notes' $releaseNotes
Write-GitHubActionsNotice "Release create from pull request $($pull_request.html_url)"
Write-GitHubActionsNotice "Release information can be found at $($release.html_url)"
