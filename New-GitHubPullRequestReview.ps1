filter New-GitHubPullRequestReview {
    [CmdletBinding(
        SupportsShouldProcess)]
    param(
        [string] $OwnerName,
  
        [string] $RepositoryName,
  
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName)]
        [Alias('RepositoryUrl')]
        [string] $Uri,
  
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName)]
        [Alias('PullRequestNumber')]
        [int64] $PullRequest,
  
        [string] $Body,
  
        [ValidateSet('REQUEST_CHANGES', 'COMMENT', 'APPROVE', 'PENDING')]
        [String]$ReviewAction = 'REQUEST_CHANGES',
  
        [String]$CommitId
    )
  
    $elements = Split-GitHubUri -Uri $Uri
    $OwnerName = $elements.ownerName
    $RepositoryName = $elements.repositoryName
  
    $uriFragment = "/repos/$OwnerName/$RepositoryName/pulls/$PullRequest/reviews"
    $description = "Getting reviews from pull request $PullRequest for $RepositoryName"
    $shouldProcessAction = "Create GitHub Pull Request Review"
  
  
    if (-not $PSCmdlet.ShouldProcess($RepositoryName, $shouldProcessAction)) {
        return
    }
  
    # https://docs.github.com/en/rest/reference/pulls#create-a-review-for-a-pull-request
    $restBody = @{
        commit_id = $CommitId
        body      = $Body -join "`n"
        event     = $ReviewAction
    }
  
    $params = @{
        UriFragment  = $uriFragment
        Method       = 'Post'
        Description  = $description
        Body         = ConvertTo-Json -InputObject $restBody -Compress
        AcceptHeader = 'application/vnd.github.v3+json'
    }
  
    return (Invoke-GHRestMethod @params | Add-GitHubPullRequestReviewAdditionalProperties)
}
