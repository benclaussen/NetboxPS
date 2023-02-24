
function ThrowNetboxRESTError {
    $uriSegments = [System.Collections.ArrayList]::new(@('fake', 'url'))

    $URIParameters = @{
    }

    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters

    InvokeNetboxRequest -URI $uri -Raw
}