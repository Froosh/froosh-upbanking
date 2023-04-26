#Requires -Version 7

[CmdletBinding(PositionalBinding = $false)]

[OutputType([Object[]])]

Param (
  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [securestring]
  $PersonalAccessToken,

  [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
  [ValidateNotNullOrEmpty()]
  [uri]
  $Uri
)

Begin {
  Set-StrictMode -Version Latest
  $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
}

Process {
  $NextURI = $Uri

  do {
    $Parameters = @{
      Authentication          = [Microsoft.PowerShell.Commands.WebAuthenticationType]::Bearer
      Method                  = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
      ResponseHeadersVariable = 'ResponseHeaders'
      StatusCodeVariable      = 'ResponseStatusCode'
      Token                   = $PersonalAccessToken
      Uri                     = $NextURI
    }

    $Response = Invoke-RestMethod @Parameters

    if (Get-Member -InputObject $Response -Name data) {
      Write-Output -InputObject $Response.data
    }

    if ((Get-Member -InputObject $Response -Name links) -and (Get-Member -InputObject $Response.links -Name next)) {
      $NextURI = $Response.links.next
    } else {
      $NextURI = $null
    }

  } while ($NextURI)
}

End {
}