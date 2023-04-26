#Requires -Version 7

[CmdletBinding(PositionalBinding = $false)]

[OutputType([Object[]])]

Param (
  [ValidateNotNullOrEmpty()]
  [securestring]
  $PersonalAccessToken = (Import-Clixml -Path (Join-Path -Path $PSScriptRoot -ChildPath PAT.clixml)),

  [ValidateNotNullOrEmpty()]
  [timespan]
  $History = (New-TimeSpan -Days 14)
)

Begin {
  Set-StrictMode -Version Latest
  $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop

  $UPBaseURL = [uri] 'https://api.up.com.au/api/v1'

  $AccountsURI = [System.UriBuilder] $UPBaseURL
  $AccountsURI.Path += '/accounts'
  $AccountsURI = $AccountsURI.Uri

  $FilterSince = [datetime]::Now - $History
}

Process {
  Write-Verbose -Message ('Request: {0}' -f $AccountsURI)
  $Accounts = ./Invoke-UpAPI.ps1 -PersonalAccessToken $PersonalAccessToken -Uri $AccountsURI

  $Transactions = @()

  foreach ($Account in $Accounts) {
    $TransactionURI = [System.UriBuilder] $Account.relationships.transactions.links.related
    $TransactionURI.Query = ('filter[since]={0:yyyy-MM-ddTHH:mm:ssK}' -f $FilterSince) -replace '\+', '%2B'

    Write-Verbose -Message ('Request: {0}' -f $TransactionURI.Uri)
    $Transactions += ./Invoke-UpAPI.ps1 -PersonalAccessToken $PersonalAccessToken -Uri $TransactionURI.Uri
  }

  Write-Output -InputObject $Transactions
}

End {
}