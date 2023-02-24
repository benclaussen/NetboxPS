
function GetNetboxAPIErrorBody {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Net.HttpWebResponse]$Response
    )

    # This takes the $Response stream and turns it into a useable object... generally a string.
    # If the body is JSON, you should be able to use ConvertFrom-Json

    $reader = New-Object System.IO.StreamReader($Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $reader.ReadToEnd()
}