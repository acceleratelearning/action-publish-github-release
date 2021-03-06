function Initialize-GitHubActionTasks {
    param (
        [Parameter(Mandatory)]
        [String]$GitHubToken,
        [Switch]$SkipGitConfiguration
    )
  
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
  
    $OwnerName, $RepositoryName = $env:GITHUB_REPOSITORY -split '/'
    Set-GitHubConfiguration -DefaultOwnerName $OwnerName `
        -DefaultRepositoryName $RepositoryName `
        -DisableTelemetry `
        -DisableLogging `
        -DisableUpdateCheck `
        -SessionOnly
  
    $credential = New-Object System.Management.Automation.PSCredential "x", ($GitHubToken | ConvertTo-SecureString -AsPlainText -Force)
    Set-GitHubAuthentication -Credential $credential -SessionOnly
  
    if (-Not $SkipGitConfiguration.IsPresent) {
        Write-Host -ForegroundColor Green "Configuring git"
        # git config url."https://x-access-token:$($GitHubToken)@github.com".insteadOf https://github.com
        git config user.name github-actions
        git config user.email github-actions@github.com
    }
}
