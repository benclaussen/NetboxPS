function Get-NetboxSlug {
    param (
        [Parameter(ValueFromPipeline)]
        [string]$slug,

        [uint16]$chars = 100
    )

    process {
        return $slug -replace '[^\-.\w\s]', '' `
                     -replace '[^a-zA-Z0-9-_ ]', '' `
                     -replace '^[\s.]+|[\s.]+$', '' `
                     -replace '[-.\s]+', '-' `
                     | ForEach-Object { $_.ToLower().Substring(0, [Math]::Min($_.Length, $chars)) }
    }
}