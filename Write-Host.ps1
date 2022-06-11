function Set-GitTag {
    param (
        [Parameter(Mandatory)]
        [String]$Tag,
        [Parameter(Mandatory)]
        [String]$CommitId
    )
  
    $current_commit_id = $(git rev-list -n 1 $Tag 2>$null)
    if (-Not $current_commit_id) {
        Write-Host -ForegroundColor Green "Creating new tag $tag to reference $CommitId"
        git tag -fa $Tag -m $Tag
    }
    elseif ($current_commit_id -ne $CommitId) {
        Write-Host -ForegroundColor Yellow "Updating tag $tag to reference $CommitId"
        git push origin ":refs/tags/$($Tag)"
        git tag -fa $Tag -m $Tag
    }
}