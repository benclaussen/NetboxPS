function GenerateSlug {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true)]
    [string]$Slug
  )

  Write-Verbose "Generating slug"

  $Slug = $Slug.Replace("-", "").Replace(" ", "-").ToLower()

  Write-Verbose " Completed building URIBuilder"
  # Return the entire UriBuilder object
  $Slug
}