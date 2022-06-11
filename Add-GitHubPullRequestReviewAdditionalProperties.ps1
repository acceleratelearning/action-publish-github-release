filter Add-GitHubPullRequestReviewAdditionalProperties {
    <#
    .SYNOPSIS
        Adds type name and additional properties to ease pipelining to GitHub Repository objects.
    .PARAMETER InputObject
        The GitHub object to add additional properties to.
    .PARAMETER TypeName
        The type that should be assigned to the object.
#>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Internal helper that is definitely adding more than one property.")]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [PSCustomObject[]] $InputObject
    )

    foreach ($item in $InputObject) {
        if (-not (Get-GitHubConfiguration -Name DisablePipelineSupport)) {
            $elements = Split-GitHubUri -Uri $item.html_url
            $repositoryUrl = Join-GitHubUri @elements
            Add-Member -InputObject $item -Name 'RepositoryUrl' -Value $repositoryUrl -MemberType NoteProperty -Force
            Add-Member -InputObject $item -Name 'ReviewId' -Value $item.id -MemberType NoteProperty -Force
            Add-Member -InputObject $item -Name 'PullRequestNumber' -Value (([System.Uri]$item.pull_request_url).Segments | Select -Last 1) -MemberType NoteProperty -Force
            Add-Member -InputObject $item -Name 'ReviewAction' -Value $item.state -MemberType NoteProperty -Force
        }

        Write-Output $item
    }
}
