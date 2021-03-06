#
# vCloud Director - Fetch vApp/VMs, and display the network adapter types
# Author: Timo Sugliani <tsugliani@vmware.com>
# Version: 1.0
# Date: 23/04/2015
#
# This script will leverage PowerCLI cmdlets for vCloud Director, and switch
# to pure vCloud REST API call to fetch the non available information re-using
# the Authorization token from PowerCLI and parse XML results to display the
# Network Adapters, and print MAC/Type
#

# Global environment variables
$vcloud_hostname      = "<vclouddirector_dns>"
$vcloud_organization  = "<organization>"
$vcloud_username      = "<username>"
$vcloud_password      = "<password>"

# Construct headers with authentication data + expected Accept header (xml / json)
$headers = @{"Authorization" = "Basic $EncodedPassword"}
$headers.Add("Accept", "application/*+xml;version=5.5")

# Bypass SSL certificate verification
add-type @"
  using System.Net;
  using System.Security.Cryptography.X509Certificates;
  public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
      ServicePoint srvPoint, X509Certificate certificate,
      WebRequest request, int certificateProblem) {
      return true;
    }
  }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


# Small Function to execute a REST operations and return the XML response
function http-rest-vcloud
{
  <#
  .SYNOPSIS
    This function establishes a connection to the vCloud REST API
  .DESCRIPTION
    This function establishes a connection to the vCloud REST API
  .PARAMETER method
    Specify the REST Method to use (GET/PUT/POST/DELETE)"
  .PARAMETER uri
    Specify the REST URI that identifies the resource you want to interact with
  .PARAMETER body
    Specify the body content if required (PUT/POST)
  .INPUTS
    String: REST Method to use.
    String: URI that identifies the resource
    String: Body if required
	String: AuthToken
  .OUTPUTS
    XML: Request result in JSON
  .LINK
    None.
  #>

  [CmdletBinding()]
  param(
    [
      parameter(
        Mandatory = $true,
        HelpMessage = "Specify the REST Method to use (GET/PUT/POST/DELETE)",
        ValueFromPipeline = $false
      )
    ]
    [String]
    $method,
    [
      parameter(
        Mandatory = $true,
        HelpMessage = "Specify the REST URI that identifies the resource you want to interact with",
        ValueFromPipeline = $false
      )
    ]
    [String]
    $uri,
    [
	  parameter(
		Mandatory = $true,
		HelpMessage = "Specify the auth token for vCloud Director",
		ValueFromPipeline = $false
	  )
	]
	[String]
	$authtoken,
	[
      parameter(
        Mandatory = $false,
        HelpMessage = "Specify the body content if required (PUT/POST)",
        ValueFromPipeline = $false
      )
    ]
    [String]
    $body = $null
  )

  Begin {
    # Build Url from supplied uri parameter
    $Url = $uri
  }

  Process {
    # Construct headers with authentication data + expected Accept header (xml / json)
    $headers = @{"x-vcloud-authorization" = $authtoken}
    $headers.Add("Accept", "application/*+xml;version=5.5")

    # Build Invoke-RestMethod request
    try
    {
      if (!$body) {
        $HttpRes = Invoke-RestMethod -Uri $Url -Method $method -Headers $headers
      }
      else {
        $HttpRes = Invoke-RestMethod -Uri $Url -Method $method -Headers $headers -Body $body -ContentType "application/xml"
      }
    }
    catch {
      Write-Host -ForegroundColor Red "Error connecting to $Url"
      Write-Host -ForegroundColor Red $_.Exception.Message
    }

    # If the response to the HTTP request is OK,
    if ($HttpRes) {
      return $HttpRes
    }
  }
  End {
      # What to do here ?
  }
}

if (!(get-pssnapin -name VMware.VimAutomation.Core -erroraction silentlycontinue)) {
    add-pssnapin VMware.VimAutomation.Core
}

"# Connecting to $vcloud_hostname ..."
Connect-CIServer -Server $vcloud_hostname -Org $vcloud_organization -User $vcloud_username -Password $vcloud_password

foreach ($vApp in Get-CIVApp) {
	"vApp: $vApp"
	foreach ($vm in Get-CIVM -VApp $vApp) {
		" - VM: $vm"
		$restUrl = $vm.Href + "/virtualHardwareSection/networkCards"
		$authtoken = $vm.ExtensionData.Client.SessionKey

		[xml]$result = http-rest-vcloud "GET" $restUrl $authtoken
		foreach ($nic in $result.RasdItemsList.Item) {
			" |--> " + $nic.ElementName + " - " + $nic.Address + " - " + $nic.ResourceSubType
		}
	}
  ""
}

"# Disconnecting from $vcloud_hostname ..."
Disconnect-CIServer -Server $vcloud_hostname -Force -Confirm:$false

