#Get data from pcoip_server log file and returns PSObject with data
function global:Import-PCoIPLog {
	<#
		.SYNOPSIS
		This Cmdlet parses the PCoIP log file and returns an object with detailed information

		.PARAMETER FilePath
		Specifies the path to the pcoip_server log file.
		
		.EXAMPLE
		$PCoIPLog = Import-PCoIPLog -FilePath "C:\Logs\pcoip_server_2014_07_24_00000b8c.txt"
		Description
		
		-----------
		
		This command returns the PSObject which contains information about PCoIP session from the log file.
		
		.LINK
		https://github.com/omnimod/PCoIPLogAnalyzer
	#>
	
	[CmdletBinding(
		DefaultParameterSetName="FilePath"
	)]

	Param(
		[Parameter(Mandatory=$True,
		Position=0,
		HelpMessage="Please enter the path to the pcoip_server log file")]
		[String] $FilePath
	)

	#Return an array with network statistics (RX and TX packets for Audio, Image and Other traffic, and percentage of Loss)
	function Get-NetStats {
		$NetStats = @()
		
		#Pattern to match strings like: R=000000/000000/001999  T=000287/003728/000953 (A/I/O) Loss=0.00%/0.00% (R/T)
		$ValuePattern = 'R=([0-9]+)\/([0-9]+)\/([0-9]+)\s+T=([0-9]+)\/([0-9]+)\/([0-9]+)\s+\(A\/I\/O\)\s+Loss=([0-9.]+)\%\/([0-9.]+)\%\s+\(R\/T\)$'
		$Pattern = $DatePattern + $ValuePattern
		
		foreach($String in $Log) {
			if($String -match $Pattern) {
				$NetStats += [PsCustomObject]@{
					Date = [DateTime] $Matches[1]
					RXAudio = [Int] $Matches[2]
					RXImage = [Int] $Matches[3]
					RXOther = [Int] $Matches[4]
					TXAudio = [Int] $Matches[5]
					TXImage = [Int] $Matches[6]
					TXOther = [Int] $Matches[7]
					RXLoss = [System.Math]::Round([Float] $Matches[8], 2)
					TXLoss = [System.Math]::Round([Float] $Matches[9], 2)
				}
			}
		}
		return $NetStats
	}

	#Return an array with latency statistics
	function Get-BdwthStats {
		$BdwthStats = @()
		
		#Pattern to match strings like: Tx thread info: bw limit = 1165, avg tx = 52.3, avg rx = 4.7 (KBytes/s)
		$ValuePattern = 'bw limit =\s+(\d+).+avg tx =\s+([0-9.]+), avg rx =\s+([0-9.]+)\s+\(KBytes\/s\)$'
		$Pattern = $DatePattern + $ValuePattern
		foreach($String in $Log) {
			if($String -match $Pattern) {
				$BdwthStats += [PsCustomObject]@{
					Date = [DateTime] $Matches[1]
					BWLimit = [System.Math]::Round([Float] $Matches[2], 2) 
					AVGTX = [System.Math]::Round([Float] $Matches[3], 2)
					AVGRX = [System.Math]::Round([Float] $Matches[4], 2)				
				}
			}
		}	
		return $BdwthStats
	}

	#Return an array with latency statistics
	function Get-LatStats {
		$LatStats = @()
		
		#Pattern to match strings like: Tx thread info: round trip time (ms) =   5, variance =   2, rto = 107, last =   6, max =  52
		$ValuePattern = 'round trip time \(ms\) =\s+(\d+),\s+variance =\s+(\d+), rto =\s+(\d+),\slast =\s+(\d+), max =\s+(\d+)$'
		$Pattern = $DatePattern + $ValuePattern
		foreach($String in $Log) {
			if($String -match $Pattern) {
				$LatStats += [PsCustomObject]@{
					Date = [DateTime] $Matches[1]
					RTT = [Int] $Matches[2]
					Variance = [Int] $Matches[3]
					RTO = [Int] $Matches[4]
					Last = [Int] $Matches[5]
					Max = [Int] $Matches[6]
				}
			}
		}
		return $LatStats
	}

	#Return an array with quality statistics (TBL, FPS, Quality)
	function Get-QualityStats {
		$QualityStats = @()
		
		#Pattern to match strings like: tbl 2 fps 9.56 quality 70 
		$ValuePattern = 'tbl\s+(\d+)\s+fps\s([0-9.]+)\s+quality\s+(\d+)$'
		$Pattern = $DatePattern + $ValuePattern
		foreach($String in $Log) {
			if($String -match $Pattern) {
				$QualityStats += [PsCustomObject]@{
					Date = [DateTime] $Matches[1]
					TBL = [Int] $Matches[2]
					FPS = [System.Math]::Round([Float] $Matches[3], 2)
					Quality = [Int] $Matches[4]
				}
			}
		}	
		return $QualityStats
	}

	#Return an array with encoding statistics
	function Get-EncodStats {
		$EncodStats = @()
		
		#Pattern to match strings like: bits/pixel - 1.01, bits/sec - 391077.40, MPix/sec - 0.39
		$ValuePattern = 'bits\/pixel -\s+([0-9.]+),\s+bits\/sec -\s+([0-9.]+),\s+MPix\/sec -\s+([0-9.]+)$'
		$Pattern = $DatePattern + $ValuePattern
		foreach($String in $Log) {
			if($String -match $Pattern) {
				$EncodStats += [PsCustomObject]@{
					Date = [DateTime] $Matches[1]
					BitsPixel = [System.Math]::Round([Float] $Matches[2], 2)
					BitsSec = [System.Math]::Round([Float] $Matches[3], 2)
					MPixSec = [System.Math]::Round([Float] $Matches[4], 2)		
				}
			}
		}	
		return $EncodStats
	}

	#Return an array with advanced statistics
	function Get-AdvStats {
		$AdvStats = @()
		
		#Pattern to match strings like: cur_s   0 max_s  30 bwc 0.32 bwt 8.19 changed fps 19.5 decode rate est (MBit/sec) - 1.58
		$ValuePattern = 'cur_s\s+(\d)+\s+max_s\s+(\d+)\s+bwc\s+([0-9.]+)\s+bwt\s+([0-9.]+)\s+changed fps\s+([0-9.]+)\s+decode rate est \(MBit\/sec\) -\s+([0-9.]+)$'
		$Pattern = $DatePattern + $ValuePattern
		foreach($String in $Log) {
			if($String -match $Pattern) {
				$AdvStats += [PsCustomObject]@{
					Date = [DateTime] $Matches[1]
					Cur_s = [Int] $Matches[2]
					Max_s = [Int] $Matches[3]
					BWC = [System.Math]::Round([Float] $Matches[4], 2)
					BWT = [System.Math]::Round([Float] $Matches[5], 2)
					ChangedFPS = [System.Math]::Round([Float] $Matches[6], 2)
					DecodeRate = [System.Math]::Round([Float] $Matches[7], 2)		
				}
			}
		}	
		return $AdvStats
	}

	#Return an array with display statistics (number of displays and resolution)
	function Get-DisplayStats {
		$DisplayStats = @()
		
		#Pattern to match strings like: configure_display[0]--*  id: 1  mon_id: -1 pos: (0,0)  w: 1468   h: 826
		$ValuePattern = 'configure_display\[(\d)\].+w:\s+(\d+)\s+h:\s+(\d+)$'
		$Pattern = $DatePattern + $ValuePattern
		foreach($String in $Log) {
			if($String -match $Pattern) {
				$DisplayStats += [PsCustomObject]@{
					Date = [DateTime] $Matches[1]
					DisplayID = [Int] $Matches[2]
					Width = [Int] $Matches[3]
					Height = [Int] $Matches[4]
				}
			}
		}	
		return $DisplayStats
	}

	#Return an object with PCoIP protocol version
	#Horizon 5.3 - 3.12.3.26912
	#Horizon 6.0 - 3.18.0.33014
	#Horizon 6.1 - 3.30.0.6dc506
	#Horizon 6.2 - 3.32.0.c369d5
	#Horizon 7.3.1 - 3.40.0.31163
	function Get-ProtocolVersion {
	
		#Pattern to match strings like: Software Build ID: pcoip-soft.git-vmw-6299018 3.40.0.31163a
		$Pattern = 'MGMT_SYS :Software Build ID: (.+ (\d+).(\d+).(\d+).(.+))$'
		
		foreach($String in $Log) {
			if($String -match $Pattern) {
				$Full = [String] $Matches[1]
				$Major = [String] $Matches[2]
				$Minor = [String] $Matches[3]
				$Build = [String] $Matches[4]
				
				#Convert Revision from Hex to Decimal because [Version] type does not accept letters
				$Revision = [String] [convert]::toint32($Matches[5],16)
				$Short = [Version]($Major + "." + $Minor + "." + $Build + "." + $Revision)		
				
				$Version = [PsCustomObject]@{
					Full = $Full
					Short = $Short
					Major = $Major
					Minor = $Minor
					Build = $Build
					Revision = $Revision
				}
				return $Version
			}
		}
		return $null
	}

	#Retrieve single value from the array with pattern
	function Get-Value {
		param([String] $Pattern,
			[Array] $Log = $Log)
		
		foreach($String in $Log) {
			if($String -match $Pattern) {
				return $Matches[1]
			}
		}

		return $null
	}

	function Get-ServerName {
		$Pattern = 'pcoip.default_target_sni = (.+)$'
		
		return Get-Value $Pattern
	}

	function Get-ServerIP {
		$Pattern = 'pcoip.ip_address = ([0-9.]+)$'
		
		return Get-Value $Pattern
	}

	function Get-ClientIP {
		$Pattern = 'Incoming session with: ([0-9.]+)$'
		
		return Get-Value $Pattern
	}

	function Get-Encryption {
		$Pattern = 'Setting encryption to (.+).$'
		
		return Get-Value $Pattern
	}

	function Get-StartTime {
		return [DateTime] (Get-Value $DatePattern $Log[0])
	}

	function Get-EndTime {
		return [DateTime] (Get-Value $DatePattern $Log[$_.Count-1])
	}
	
	#Check if log file exists, if not - stop the script with error
	if (Test-Path $FilePath) {
		$LogFile = Get-Item $FilePath
		$Log = Get-Content $LogFile
	} else {
		Write-Error "File is not available"
		return $null
	}
	
	#PCoIP version previous to 3.32.0 (Horizon Agent 6.2) has an old date format
	#New date format: 2017-12-16T19:44:21.965+03:00
	#Old date format: 07/24/2014, 18:38:05.140
	$OldDatePattern = '^(\d\d\/\d\d\/\d{4}, \d\d:\d\d:\d\d.[0-9]+).+'
	$NewDatePattern = '^(\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.[0-9+:]+).+'

	$Version = Get-ProtocolVersion
	if($Version -eq $null) {
		Write-Error "Log file is damaged or has unsupported format"
		return $null
	}

	#Depends on version of the log file define the date pattern
	if($Version.Short -ge "3.32.0") {
		$DatePattern = $NewDatePattern
	} else {
		$DatePattern = $OldDatePattern
	}

	$StarTime = Get-StartTime
	$EndTime = Get-EndTime

	#Create PSObject with data from the log file
	$PCoIPLog = [PsCustomObject]@{
		LogFile = $LogFile.Name
		StartTime = $StarTime
		EndTime = $EndTime
		Duration = ($EndTime - $StarTime)
		Server = @{
			Name = (Get-ServerName)
			IP = (Get-ServerIP)
		}
		Client = @{
			IP = (Get-ClientIP)
		}
		Version = $Version
		Encryption = (Get-Encryption)
		NetStats = (Get-NetStats)
		BdwthStats = (Get-BdwthStats)
		LatStats = (Get-LatStats)
		QualityStats = (Get-QualityStats)
		EncodStats = (Get-EncodStats)
		AdvStats = (Get-AdvStats)
		DisplayStats = (Get-DisplayStats)
	}

	return $PCoIPLog	
}

#Export date from PSObject to TEXT, CSV or HTML format
function global:Export-PCoIPStatistics {
	<#
		.SYNOPSIS
		This Cmdlet exports information from the PCoIP log object to a file in text, csv or html format

		.PARAMETER PCoIPLog
		Specifies the PCoIPLog object which contains information about PCoIP session.
		
		.PARAMETER ResultPath
		Specifies the path to the file where results will be saved.
		
		.PARAMETER Format
		Specifies the format of the result file.
		
		.PARAMETER MaxSamples
		Specifies the maximum number of rows in the output.
		
		.EXAMPLE
		Export-PCoIPStatistics -PCoIPLog $PCoIPLog -ResultPath "C:\Results\report.txt"
		Description
		
		-----------
		
		This command exports information from the PCoIP log object to the text file.
	
		.EXAMPLE
		Export-PCoIPStatistics -PCoIPLog $PCoIPLog -ResultPath "C:\Results\report.html" -Format HTML
		Description
		
		-----------
		
		This command exports information from the PCoIP log object to the html file.		

		.EXAMPLE
		Export-PCoIPStatistics -PCoIPLog $PCoIPLog -ResultPath "C:\Results\report.csv" -Format CSV -MaxSamples 100
		Description
		
		-----------
		
		This command exports information from the PCoIP log object to the csv file limiting the number of rows to 100.
			
		.LINK
		https://github.com/omnimod/PCoIPLogAnalyzer
	#>

	Param(
		[Parameter(Mandatory=$True,
		Position=0,
		HelpMessage="Please enter the PCoIP log object which contains session information")]
		[PsCustomObject] $PCoIPLog,
		
		[Parameter(Mandatory=$True,
		Position=1,
		HelpMessage="Please enter the path where the result file will be saved")]
		[String] $ResultPath,
		
		[Parameter(
		HelpMessage="Please specify the format of the result file. Could be TEXT, HTML or CSV")]
		[ValidateSet("CSV", "HTML", "TEXT")]
		[String] $Format = "TEXT",
		
		[Parameter(
		HelpMessage="Please specify the maximum number of rows to output. If not defined, the default value is 1000")]
		[Int] $MaxSamples = 1000
	)

	#Reduce the size of array to limit number of exported/displayed values
	function Resize-Array {
		param([Array] $Arr, [Int] $MaxSamples)
		
		$size = $Arr.Count
		
		if ($size -lt $MaxSamples) {
			return $Arr
		}
		
		$ResizedArray = @()
		
		for ($i = 0; $i -lt $Size; $i += [math]::Ceiling($Size/($MaxSamples-1))) {
			$ResizedArray = $ResizedArray + $Arr[$i]
		}	

		$ResizedArray = $ResizedArray + $Arr[-1]	
		
		return $ResizedArray	
	}
	
	#Convert an array to the string with commas delimeter for HTML report
	function Serialize-Array {
		param([Array] $Arr)
		
		$Serial = ""
		$First = $true
		
		foreach($Num in $Arr) {
		
			if($First) {
				$First = $false
			} else {
				$Serial += ", "
			}
			
			# Format based on the Num type
			$NumFormat=""
			
			if($Num.GetType().Name -eq "DateTime") {
				$NumFormat = "g"
				$Serial += "'" + $Num.ToString($NumFormat, $enUS) + "'"
			} else {
				if($Num.GetType().Name -eq "Double") {
					$NumFormat = "f2"
				} else {
					$NumFormat = "f0"
				}
				$Serial += $Num.ToString($NumFormat, $enUS)			
			}
		}
		
		return $Serial
	}
	
	#Replace ${parameter} with value
	function Update-Template {
		param(
			[String] $SearchString,
			[String] $Value)

		$Template = $Template.Replace($SearchString, $Value)
		return $Template
	}
	
	#Create a string array with csv formatted data from PSObject
	function New-PCoIPCSVReport {
		param(
			[PsCustomObject] $PCoIPLog,
			[Int] $MaxSamples)
		
		$Result = @()
		$Result += Resize-Array -Arr $PCoIPLog.NetStats -MaxSamples $MaxSamples | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
		$Result += Resize-Array -Arr $PCoIPLog.BdwthStats -MaxSamples $MaxSamples | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
		$Result += Resize-Array -Arr $PCoIPLog.LatStats -MaxSamples $MaxSamples | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
		$Result += Resize-Array -Arr $PCoIPLog.QualityStats -MaxSamples $MaxSamples | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
		$Result += Resize-Array -Arr $PCoIPLog.EncodStats -MaxSamples $MaxSamples | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
		$Result += Resize-Array -Arr $PCoIPLog.AdvStats -MaxSamples $MaxSamples | ConvertTo-Csv -Delimiter ";" -NoTypeInformation
		$Result += Resize-Array -Arr $PCoIPLog.DisplayStats -MaxSamples $MaxSamples | ConvertTo-Csv -Delimiter ";" -NoTypeInformation		
		
		return $Result
	}
	
	#Create a HTML report from template filled with data from PSObject
	function New-PCoIPHTMLReport {
		param(
			[PsCustomObject] $PCoIPLog,
			[String] $Template,
			[Int] $MaxSamples)		
		
		#Define all parameters that should be replaced with values from PSObject in HTML template
		#In template all parameters are defined in '${parameter}' format and have the same names as PSObject parameters
		$Props = @(
				"LogFile",
				"StartTime",
				"EndTime",
				"Duration",
				"Encryption",
				"Server.Name",
				"Server.IP",
				"Client.IP",
				"Version.Full",
				"NetStats.Date",
				"NetStats.RXAudio",
				"NetStats.RXImage",
				"NetStats.RXOther",
				"NetStats.TXAudio",
				"NetStats.TXImage",
				"NetStats.TXOther",
				"NetStats.RXLoss",
				"NetStats.TXLoss",
				"BdwthStats.Date",
				"BdwthStats.BWLimit",
				"BdwthStats.AVGTX",
				"BdwthStats.AVGRX",
				"LatStats.Date",
				"LatStats.RTT",
				"LatStats.Max",
				"QualityStats.Date",
				"QualityStats.FPS",
				"QualityStats.Quality",
				"LAST.NetStats.RXAudio",
				"LAST.NetStats.RXImage",
				"LAST.NetStats.RXOther",
				"LAST.NetStats.TXAudio",
				"LAST.NetStats.TXImage",
				"LAST.NetStats.TXOther",
				"AVG.BdwthStats.AVGRX",
				"AVG.BdwthStats.AVGTX",
				"MAX.NetStats.RXLoss",
				"AVG.NetStats.RXLoss",
				"MAX.NetStats.TXLoss",
				"AVG.NetStats.TXLoss",	
				"MAX.LatStats.Max",
				"AVG.LatStats.RTT",
				"MAX.QualityStats.Quality",	
				"MIN.QualityStats.Quality",	
				"MAX.QualityStats.FPS",		
				"AVG.QualityStats.FPS",		
				"MIN.QualityStats.FPS")

		foreach($Prop in $Props) {
			#Determine the number of words separated with .dots in parameter
			$Vars = $Prop -split "\."

			Switch ($Vars.Count) {
				#Single word parameters are basically the strings which should be replaced as is
				1 {
					$Value = $PCoIPLog.($Vars[0]).ToString()		
				}

				#Two words parameters could be strings or arrays
				2 {
					if($PCoIPLog.($Vars[0]).($Vars[1]).GetType().BaseType -eq [Array]) {
						$Value = Serialize-Array (Resize-Array -Arr $PCoIPLog.($Vars[0]).($Vars[1]) -MaxSamples $MaxSamples)
					} else {
						$Value = $PCoIPLog.($Vars[0]).($Vars[1]).ToString()				
					}
				}
				3 {
				#Three words parameters are the phrases, the first word is math/logical operation, the second and the third is a parameter
					Switch($Vars[0]) {
						"AVG" {
							$Value = ($PCoIPLog.($Vars[1]).($Vars[2]) | Measure-Object -Average).Average
						}
						"MIN" {
							$Value = ($PCoIPLog.($Vars[1]).($Vars[2]) | Measure-Object -Minimum).Minimum					
						}
						"MAX" {
							$Value = ($PCoIPLog.($Vars[1]).($Vars[2]) | Measure-Object -Maximum).Maximum				
						}
						"FIRST" {
							$Value = ($PCoIPLog.($Vars[1]).($Vars[2])[0])
						}
						"LAST" {
							$Value = ($PCoIPLog.($Vars[1]).($Vars[2])[-1])
						}
						Default {
							$Value = 0
						}
					}
					
					#Format output depends of the value type
					if($PCoIPLog.($Vars[1]).($Vars[2])[0].GetType() -eq [Int]) {
						$Value = $Value.ToString("f0", $enUS)
					}

					if($PCoIPLog.($Vars[1]).($Vars[2])[0].GetType() -eq [Double]) {
						$Value = $Value.ToString("f2", $enUS)
					}
				}
			}
			
			$SearchString = '${' + $Prop + '}'
			$Template = Update-Template -SearchString $SearchString -Value $Value	
		}

		return $Template
	}
	
	#Define variables
	#Contains the HTML template string encoded in a BASE64 format
	$EncodedTemplate = "PAAhAEQATwBDAFQAWQBQAEUAIABoAHQAbQBsAD4APABoAHQAbQBsAD4ACQA8AGgAZQBhAGQAPgAJAAkAPABtAGUAdABhACAAYwBoAGEAcgBzAGUAdAA9ACIAVQBUAEYALQA4ACIAPgAJAAkAPAB0AGkAdABsAGUAPgBDAGgAYQByAHQAcwA8AC8AdABpAHQAbABlAD4ACQAJADwAbABpAG4AawAgAHIAZQBsAD0AIgBzAHQAeQBsAGUAcwBoAGUAZQB0ACIAIAB0AHkAcABlAD0AIgB0AGUAeAB0AC8AYwBzAHMAIgAgAGgAcgBlAGYAPQAiAGgAdAB0AHAAcwA6AC8ALwBjAGQAbgBqAHMALgBjAGwAbwB1AGQAZgBsAGEAcgBlAC4AYwBvAG0ALwBhAGoAYQB4AC8AbABpAGIAcwAvAHMAZQBtAGEAbgB0AGkAYwAtAHUAaQAvADIALgAyAC4AMQAzAC8AcwBlAG0AYQBuAHQAaQBjAC4AbQBpAG4ALgBjAHMAcwAiAD4ACQAJADwAcwBjAHIAaQBwAHQAIABzAHIAYwA9ACIAaAB0AHQAcABzADoALwAvAGMAbwBkAGUALgBqAHEAdQBlAHIAeQAuAGMAbwBtAC8AagBxAHUAZQByAHkALQAzAC4AMQAuADEALgBtAGkAbgAuAGoAcwAiAD4APAAvAHMAYwByAGkAcAB0AD4ACQAJADwAcwBjAHIAaQBwAHQAIABzAHIAYwA9ACIAaAB0AHQAcABzADoALwAvAGMAZABuAGoAcwAuAGMAbABvAHUAZABmAGwAYQByAGUALgBjAG8AbQAvAGEAagBhAHgALwBsAGkAYgBzAC8AcwBlAG0AYQBuAHQAaQBjAC0AdQBpAC8AMgAuADIALgAxADMALwBzAGUAbQBhAG4AdABpAGMALgBtAGkAbgAuAGoAcwAiAD4APAAvAHMAYwByAGkAcAB0AD4ACQAJADwAcwBjAHIAaQBwAHQAIABzAHIAYwA9ACIAaAB0AHQAcABzADoALwAvAGMAbwBkAGUALgBoAGkAZwBoAGMAaABhAHIAdABzAC4AYwBvAG0ALwBoAGkAZwBoAGMAaABhAHIAdABzAC4AagBzACIAPgA8AC8AcwBjAHIAaQBwAHQAPgAJAAkAPABzAGMAcgBpAHAAdAAgAHMAcgBjAD0AIgBoAHQAdABwAHMAOgAvAC8AYwBvAGQAZQAuAGgAaQBnAGgAYwBoAGEAcgB0AHMALgBjAG8AbQAvAG0AbwBkAHUAbABlAHMALwBlAHgAcABvAHIAdABpAG4AZwAuAGoAcwAiAD4APAAvAHMAYwByAGkAcAB0AD4ACQAJADwAcwB0AHkAbABlAD4ACQAJAAkAaAAzACwAIABwACAAewAJAAkACQAJAGYAbwBuAHQALQBmAGEAbQBpAGwAeQA6ACAAIgBMAHUAYwBpAGQAYQAgAEcAcgBhAG4AZABlACIALAAgACIATAB1AGMAaQBkAGEAIABTAGEAbgBzACAAVQBuAGkAYwBvAGQAZQAiACwAIABBAHIAaQBhAGwALAAgAEgAZQBsAHYAZQB0AGkAYwBhACwAIABzAGEAbgBzAC0AcwBlAHIAaQBmADsACQAJAAkACQBmAG8AbgB0AC0AdwBlAGkAZwBoAHQAOgAgAG4AbwByAG0AYQBsADsACQAJAAkACQBsAGkAbgBlAC0AaABlAGkAZwBoAHQAOgAgADEAOwAJAAkACQB9AAkACQA8AC8AcwB0AHkAbABlAD4ACQAJADwALwBoAGUAYQBkAD4ACQA8AGIAbwBkAHkAPgAJAAkAPAAhAC0ALQBHAGUAbgBlAHIAYQBsACAAaQBuAGYAbwAgAGIAbABvAGMAawAtAC0APgAJAAkACQA8AGQAaQB2ACAAYwBsAGEAcwBzAD0AIgB1AGkAIABvAG4AZQAgAGMAbwBsAHUAbQBuACAAcwB0AGEAYwBrAGEAYgBsAGUAIABnAHIAaQBkACAAYwBlAG4AdABlAHIAIABhAGwAaQBnAG4AZQBkACAAYwBvAG4AdABhAGkAbgBlAHIAIABzAGUAZwBtAGUAbgB0ACIAPgAJAAkACQA8AGQAaQB2ACAAYwBsAGEAcwBzAD0AIgBjAG8AbAB1AG0AbgAiAD4ACQAJAAkACQA8AGgAMwA+AEcAZQBuAGUAcgBhAGwAIABJAG4AZgBvADwALwBoADMAPgAJAAkACQAJADwAZABpAHYAIABjAGwAYQBzAHMAPQAiAHUAaQAgAGwAZQBmAHQAIABhAGwAaQBnAG4AZQBkACAAYwBvAG4AdABhAGkAbgBlAHIAIgA+AAkACQAJAAkACQA8AHAAPgBMAG8AZwAgAGYAaQBsAGUAOgAgACQAewBMAG8AZwBGAGkAbABlAH0APAAvAHAAPgAJAAkACQAJAAkAPABwAD4AUwBlAHIAdgBlAHIAIABuAGEAbQBlADoAIAAkAHsAUwBlAHIAdgBlAHIALgBOAGEAbQBlAH0APAAvAHAAPgAJAAkACQAJAAkAPABwAD4AUwBlAHIAdgBlAHIAIABJAFAAIABhAGQAZAByAGUAcwBzADoAIAAkAHsAUwBlAHIAdgBlAHIALgBJAFAAfQA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBDAGwAaQBlAG4AdAAgAEkAUAAgAGEAZABkAHIAZQBzAHMAOgAgACQAewBDAGwAaQBlAG4AdAAuAEkAUAB9ADwALwBwAD4ACQAJAAkACQAJADwAcAA+AFAAQwBvAEkAUAAgAHMAbwBmAHQAdwBhAHIAZQAgAHYAZQByAHMAaQBvAG4AOgAgACQAewBWAGUAcgBzAGkAbwBuAC4ARgB1AGwAbAB9ADwALwBwAD4ACQAJAAkACQAJADwAcAA+AEUAbgBjAHIAeQBwAHQAaQBvAG4AIABhAGwAZwBvAHIAeQB0AGgAbQA6ACAAJAB7AEUAbgBjAHIAeQBwAHQAaQBvAG4AfQA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBTAGUAcwBzAGkAbwBuACAAcwB0AGEAcgB0ACAAdABpAG0AZQA6ACAAJAB7AFMAdABhAHIAdABUAGkAbQBlAH0APAAvAHAAPgAJAAkACQAJAAkAPABwAD4AUwBlAHMAcwBpAG8AbgAgAGUAbgBkACAAdABpAG0AZQA6ACAAJAB7AEUAbgBkAFQAaQBtAGUAfQA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBTAGUAcwBzAGkAbwBuACAAZAB1AHIAYQB0AGkAbwBuADoAIAAkAHsARAB1AHIAYQB0AGkAbwBuAH0APAAvAHAAPgAJAAkACQAJADwALwBkAGkAdgA+AAkACQAJAAkACQAJAAkACQA8AGQAaQB2ACAAaQBkAD0AIgBOAGUAdAB3AG8AcgBrAEMAaABhAHIAdAAiACAAcwB0AHkAbABlAD0AIgBoAGUAaQBnAGgAdAA6ACAANAAwADAAcAB4ADsAIABtAGEAcgBnAGkAbgA6ACAAMAAgAGEAdQB0AG8AIgA+ADwALwBkAGkAdgA+AAkACQAJAAkACQAJAAkACQA8AGQAaQB2ACAAYwBsAGEAcwBzAD0AIgB1AGkAIABsAGUAZgB0ACAAYQBsAGkAZwBuAGUAZAAgAGMAbwBuAHQAYQBpAG4AZQByACIAPgAJAAkACQAJAAkAPABwAD4AUgBYACAAQQB1AGQAaQBvACAAKABQAGEAYwBrAGUAdABzACkAOgAgADwAcwBwAGEAbgAgAGkAZAA9ACIAUgBYAEEAdQBkAGkAbwAiAD4AJAB7AEwAQQBTAFQALgBOAGUAdABTAHQAYQB0AHMALgBSAFgAQQB1AGQAaQBvAH0APAAvAHMAcABhAG4APgA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBSAFgAIABJAG0AYQBnAGUAIAAoAFAAYQBjAGsAZQB0AHMAKQA6ACAAPABzAHAAYQBuACAAaQBkAD0AIgBSAFgASQBtAGEAZwBlACIAPgAkAHsATABBAFMAVAAuAE4AZQB0AFMAdABhAHQAcwAuAFIAWABJAG0AYQBnAGUAfQA8AC8AcwBwAGEAbgA+ADwALwBwAD4ACQAJAAkACQAJADwAcAA+AFIAWAAgAE8AdABoAGUAcgAgACgAUABhAGMAawBlAHQAcwApADoAIAA8AHMAcABhAG4AIABpAGQAPQAiAFIAWABPAHQAaABlAHIAIgA+ACQAewBMAEEAUwBUAC4ATgBlAHQAUwB0AGEAdABzAC4AUgBYAE8AdABoAGUAcgB9ADwALwBzAHAAYQBuAD4APAAvAHAAPgAJAAkACQAJAAkAPABwAD4AVABvAHQAYQBsACAAUgBYACAAKABQAGEAYwBrAGUAdABzACkAOgAgADwAcwBwAGEAbgAgAGkAZAA9ACIAUgBYAFQAbwB0AGEAbAAiAD4APAAvAHMAcABhAG4APgA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBUAFgAIABBAHUAZABpAG8AIAAoAFAAYQBjAGsAZQB0AHMAKQA6ACAAPABzAHAAYQBuACAAaQBkAD0AIgBUAFgAQQB1AGQAaQBvACIAPgAkAHsATABBAFMAVAAuAE4AZQB0AFMAdABhAHQAcwAuAFQAWABBAHUAZABpAG8AfQA8AC8AcwBwAGEAbgA+ADwALwBwAD4ACQAJAAkACQAJADwAcAA+AFQAWAAgAEkAbQBhAGcAZQAgACgAUABhAGMAawBlAHQAcwApADoAIAA8AHMAcABhAG4AIABpAGQAPQAiAFQAWABJAG0AYQBnAGUAIgA+ACQAewBMAEEAUwBUAC4ATgBlAHQAUwB0AGEAdABzAC4AVABYAEkAbQBhAGcAZQB9ADwALwBzAHAAYQBuAD4APAAvAHAAPgAJAAkACQAJAAkAPABwAD4AVABYACAATwB0AGgAZQByACAAKABQAGEAYwBrAGUAdABzACkAOgAgADwAcwBwAGEAbgAgAGkAZAA9ACIAVABYAE8AdABoAGUAcgAiAD4AJAB7AEwAQQBTAFQALgBOAGUAdABTAHQAYQB0AHMALgBUAFgATwB0AGgAZQByAH0APAAvAHMAcABhAG4APgA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBUAG8AdABhAGwAIABUAFgAIAAoAFAAYQBjAGsAZQB0AHMAKQA6ACAAPABzAHAAYQBuACAAaQBkAD0AIgBUAFgAVABvAHQAYQBsACIAPgA8AC8AcwBwAGEAbgA+ADwALwBwAD4ACQAJAAkACQAJAAkACQAJADwALwBkAGkAdgA+AAkACQAJAAkACQAJAAkACQA8AGQAaQB2ACAAaQBkAD0AIgBCAGEAbgBkAHcAaQBkAHQAaABDAGgAYQByAHQAIgAgAHMAdAB5AGwAZQA9ACIAaABlAGkAZwBoAHQAOgAgADQAMAAwAHAAeAA7ACAAbQBhAHIAZwBpAG4AOgAgADAAIABhAHUAdABvACIAPgA8AC8AZABpAHYAPgAJAAkACQAJAAkACQAJAAkACQAJADwAZABpAHYAIABjAGwAYQBzAHMAPQAiAHUAaQAgAGwAZQBmAHQAIABhAGwAaQBnAG4AZQBkACAAYwBvAG4AdABhAGkAbgBlAHIAIgA+AAkACQAJAAkACQA8AHAAPgBBAHYAZQByAGEAZwBlACAAUgBYACAAKABLAEIAeQB0AGUAcwAvAHMAKQA6ACAAJAB7AEEAVgBHAC4AQgBkAHcAdABoAFMAdABhAHQAcwAuAEEAVgBHAFIAWAB9ADwALwBwAD4ACQAJAAkACQAJADwAcAA+AEEAdgBlAHIAYQBnAGUAIABUAFgAIAAoAEsAQgB5AHQAZQBzAC8AcwApADoAIAAkAHsAQQBWAEcALgBCAGQAdwB0AGgAUwB0AGEAdABzAC4AQQBWAEcAVABYAH0APAAvAHAAPgAJAAkACQAJAAkACQAJADwALwBkAGkAdgA+AAkACQAJAAkAPABkAGkAdgAgAGkAZAA9ACIATABvAHMAcwBDAGgAYQByAHQAIgAgAHMAdAB5AGwAZQA9ACIAaABlAGkAZwBoAHQAOgAgADQAMAAwAHAAeAA7ACAAbQBhAHIAZwBpAG4AOgAgADAAIABhAHUAdABvACIAPgA8AC8AZABpAHYAPgAJAAkACQAJAAkACQA8AGQAaQB2ACAAYwBsAGEAcwBzAD0AIgB1AGkAIABsAGUAZgB0ACAAYQBsAGkAZwBuAGUAZAAgAGMAbwBuAHQAYQBpAG4AZQByACIAPgAJAAkACQAJAAkAPABwAD4ATQBBAFgAIABSAFgAIABMAG8AcwBzACAAKAAmACMAMwA3ADsAKQA6ACAAJAB7AE0AQQBYAC4ATgBlAHQAUwB0AGEAdABzAC4AUgBYAEwAbwBzAHMAfQA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBBAFYARwAgAFIAWAAgAEwAbwBzAHMAIAAoACYAIwAzADcAOwApADoAIAAkAHsAQQBWAEcALgBOAGUAdABTAHQAYQB0AHMALgBSAFgATABvAHMAcwB9ADwALwBwAD4ACQAJAAkACQAJAAkACQAJAAkACQA8AHAAPgBNAEEAWAAgAFQAWAAgAEwAbwBzAHMAIAAoACYAIwAzADcAOwApADoAIAAkAHsATQBBAFgALgBOAGUAdABTAHQAYQB0AHMALgBUAFgATABvAHMAcwB9ADwALwBwAD4ACQAJAAkACQAJADwAcAA+AEEAVgBHACAAUgBYACAATABvAHMAcwAgACgAJgAjADMANwA7ACkAOgAgACQAewBBAFYARwAuAE4AZQB0AFMAdABhAHQAcwAuAFQAWABMAG8AcwBzAH0APAAvAHAAPgAJAAkACQAJAAkACQAJAAkACQA8AC8AZABpAHYAPgAJAAkACQAJADwAZABpAHYAIABpAGQAPQAiAEwAYQB0AGUAbgBjAHkAQwBoAGEAcgB0ACIAIABzAHQAeQBsAGUAPQAiAGgAZQBpAGcAaAB0ADoAIAA0ADAAMABwAHgAOwAgAG0AYQByAGcAaQBuADoAIAAwACAAYQB1AHQAbwAiAD4APAAvAGQAaQB2AD4ACQAJAAkACQAJADwAZABpAHYAIABjAGwAYQBzAHMAPQAiAHUAaQAgAGwAZQBmAHQAIABhAGwAaQBnAG4AZQBkACAAYwBvAG4AdABhAGkAbgBlAHIAIgA+AAkACQAJAAkACQA8AHAAPgBNAGEAeABpAG0AdQBtACAAbABhAHQAZQBuAGMAeQAgACgAbQBzACkAOgAgACQAewBNAEEAWAAuAEwAYQB0AFMAdABhAHQAcwAuAE0AYQB4AH0APAAvAHAAPgAJAAkACQAJAAkAPABwAD4AQQB2AGUAcgBhAGcAZQAgAGwAYQB0AGUAbgBjAHkAIAAoAG0AcwApADoAIAAkAHsAQQBWAEcALgBMAGEAdABTAHQAYQB0AHMALgBSAFQAVAB9ADwALwBwAD4ACQAJAAkACQA8AC8AZABpAHYAPgAJAAkACQAJADwAZABpAHYAIABpAGQAPQAiAFEAdQBhAGwAaQB0AHkAQwBoAGEAcgB0ACIAIABzAHQAeQBsAGUAPQAiAGgAZQBpAGcAaAB0ADoAIAA0ADAAMABwAHgAOwAgAG0AYQByAGcAaQBuADoAIAAwACAAYQB1AHQAbwAiAD4APAAvAGQAaQB2AD4ACQAJAAkACQAJADwAZABpAHYAIABjAGwAYQBzAHMAPQAiAHUAaQAgAGwAZQBmAHQAIABhAGwAaQBnAG4AZQBkACAAYwBvAG4AdABhAGkAbgBlAHIAIgA+AAkACQAJAAkACQA8AHAAPgBNAGEAeABpAG0AdQBtACAAUQB1AGEAbABpAHQAeQAgACgAJgAjADMANwA7ACkAOgAgACQAewBNAEEAWAAuAFEAdQBhAGwAaQB0AHkAUwB0AGEAdABzAC4AUQB1AGEAbABpAHQAeQB9ADwALwBwAD4ACQAJAAkACQAJADwAcAA+AE0AaQBuAGkAbQB1AG0AIABRAHUAYQBsAGkAdAB5ACAAKAAmACMAMwA3ADsAKQA6ACAAJAB7AE0ASQBOAC4AUQB1AGEAbABpAHQAeQBTAHQAYQB0AHMALgBRAHUAYQBsAGkAdAB5AH0APAAvAHAAPgAJAAkACQAJADwALwBkAGkAdgA+AAkACQAJAAkACQAJAAkACQAJAAkACQAJADwAZABpAHYAIABpAGQAPQAiAEYAUABTAEMAaABhAHIAdAAiACAAcwB0AHkAbABlAD0AIgBoAGUAaQBnAGgAdAA6ACAANAAwADAAcAB4ADsAIABtAGEAcgBnAGkAbgA6ACAAMAAgAGEAdQB0AG8AIgA+ADwALwBkAGkAdgA+AAkACQAJAAkACQAJAAkACQAJADwAZABpAHYAIABjAGwAYQBzAHMAPQAiAHUAaQAgAGwAZQBmAHQAIABhAGwAaQBnAG4AZQBkACAAYwBvAG4AdABhAGkAbgBlAHIAIgA+AAkACQAJAAkACQA8AHAAPgBNAGEAeABpAG0AdQBtACAARgBQAFMAOgAgACQAewBNAEEAWAAuAFEAdQBhAGwAaQB0AHkAUwB0AGEAdABzAC4ARgBQAFMAfQA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBBAHYAZQByAGEAZwBlACAARgBQAFMAOgAgACQAewBBAFYARwAuAFEAdQBhAGwAaQB0AHkAUwB0AGEAdABzAC4ARgBQAFMAfQA8AC8AcAA+AAkACQAJAAkACQA8AHAAPgBNAGkAbgBpAG0AdQBtACAARgBQAFMAOgAgACQAewBNAEkATgAuAFEAdQBhAGwAaQB0AHkAUwB0AGEAdABzAC4ARgBQAFMAfQA8AC8AcAA+AAkACQAJAAkAPAAvAGQAaQB2AD4ACQAJAAkACQAJAAkACQA8AC8AZABpAHYAPgAJAAkAPAAvAGQAaQB2AD4ACQAJADwAcwBjAHIAaQBwAHQAPgAJAAkACQAkACgAZgB1AG4AYwB0AGkAbwBuACAAKAApACAAewAJAAkACQAJAHYAYQByACAAUgBYAFQAbwB0AGEAbAAgAD0AIABOAHUAbQBiAGUAcgAoACQAKAAnACMAUgBYAEEAdQBkAGkAbwAnACkALgB0AGUAeAB0ACgAKQApACAAKwAgAE4AdQBtAGIAZQByACgAJAAoACcAIwBSAFgASQBtAGEAZwBlACcAKQAuAHQAZQB4AHQAKAApACkAIAArACAATgB1AG0AYgBlAHIAKAAkACgAJwAjAFIAWABPAHQAaABlAHIAJwApAC4AdABlAHgAdAAoACkAKQA7AAkACQAJAAkAJAAoACcAIwBSAFgAVABvAHQAYQBsACcAKQAuAHQAZQB4AHQAKABSAFgAVABvAHQAYQBsACkAOwAJAAkACQAJAHYAYQByACAAVABYAFQAbwB0AGEAbAAgAD0AIABOAHUAbQBiAGUAcgAoACQAKAAnACMAVABYAEEAdQBkAGkAbwAnACkALgB0AGUAeAB0ACgAKQApACAAKwAgAE4AdQBtAGIAZQByACgAJAAoACcAIwBUAFgASQBtAGEAZwBlACcAKQAuAHQAZQB4AHQAKAApACkAIAArACAATgB1AG0AYgBlAHIAKAAkACgAJwAjAFQAWABPAHQAaABlAHIAJwApAC4AdABlAHgAdAAoACkAKQA7AAkACQAJAAkAJAAoACcAIwBUAFgAVABvAHQAYQBsACcAKQAuAHQAZQB4AHQAKABUAFgAVABvAHQAYQBsACkAOwAJAAkACQAJAEgAaQBnAGgAYwBoAGEAcgB0AHMALgBzAGUAdABPAHAAdABpAG8AbgBzACgAewAJAAkACQAJAAkAYwBoAGEAcgB0ADoAIAB7AAkACQAJAAkACQAJAAkAegBvAG8AbQBUAHkAcABlADoAIAAnAHgAJwAJAAkACQAJAAkACQB9ACwACQAJAAkACQAJAHMAdQBiAHQAaQB0AGwAZQA6ACAAewAJAAkACQAJAAkACQB0AGUAeAB0ADoAIABkAG8AYwB1AG0AZQBuAHQALgBvAG4AdABvAHUAYwBoAHMAdABhAHIAdAAgAD0APQA9ACAAdQBuAGQAZQBmAGkAbgBlAGQAIAA/AAkACQAJAAkACQAJAAkACQAnAEMAbABpAGMAawAgAGEAbgBkACAAZAByAGEAZwAgAGkAbgAgAHQAaABlACAAcABsAG8AdAAgAGEAcgBlAGEAIAB0AG8AIAB6AG8AbwBtACAAaQBuACcAIAA6ACAAJwBQAGkAbgBjAGgAIAB0AGgAZQAgAGMAaABhAHIAdAAgAHQAbwAgAHoAbwBvAG0AIABpAG4AJwAJAAkACQAJAAkAfQAsAAkACQAJAAkACQAJAAkACQAJAAkACQBsAGUAZwBlAG4AZAA6ACAAewAJAAkACQAJAAkACQBsAGEAeQBvAHUAdAA6ACAAJwB2AGUAcgB0AGkAYwBhAGwAJwAsAAkACQAJAAkACQAJAGEAbABpAGcAbgA6ACAAJwByAGkAZwBoAHQAJwAsAAkACQAJAAkACQAJAHYAZQByAHQAaQBjAGEAbABBAGwAaQBnAG4AOgAgACcAbQBpAGQAZABsAGUAJwAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB0AG8AbwBsAHQAaQBwADoAIAB7AAkACQAJAAkACQAJAGMAcgBvAHMAcwBoAGEAaQByAHMAOgAgAFsAdAByAHUAZQBdACwACQAJAAkACQAJAAkAYgBvAHIAZABlAHIAQwBvAGwAbwByADoAIAAnACMAMAAwADAAMAAwADAAJwAsAAkACQAJAAkACQAJAHMAaABhAHIAZQBkADoAIAB0AHIAdQBlAAkACQAJAAkACQB9ACwACQAJAAkACQAJAHAAbABvAHQATwBwAHQAaQBvAG4AcwA6ACAAewAJAAkACQAJAAkACQBsAGkAbgBlADoAIAB7AAkACQAJAAkACQAJAAkAbABpAG4AZQBXAGkAZAB0AGgAOgAgADAALgA1ACwACQAJAAkACQAJAAkACQBtAGEAcgBrAGUAcgA6ACAAewAJAAkACQAJAAkACQAJAAkAZQBuAGEAYgBsAGUAZAA6ACAAZgBhAGwAcwBlAAkACQAJAAkACQAJAAkAfQAJAAkACQAJAAkACQB9AAkACQAJAAkACQB9AAkACQAJAAkAfQApADsACQAJAAkACQAJAAkACQAJAHYAYQByACAATgBlAHQAdwBvAHIAawBDAGgAYQByAHQAIAA9ACAAbgBlAHcAIABIAGkAZwBoAGMAaABhAHIAdABzAC4AYwBoAGEAcgB0ACgAJwBOAGUAdAB3AG8AcgBrAEMAaABhAHIAdAAnACwAIAB7AAkACQAJAAkACQB0AGkAdABsAGUAOgAgAHsACQAJAAkACQAJAAkAdABlAHgAdAA6ACAAJwBOAGUAdAB3AG8AcgBrACAAUwB0AGEAdABpAHMAdABpAGMAcwAnAAkACQAJAAkACQB9ACwACQAJAAkACQAJAHgAQQB4AGkAcwA6ACAAewAJAAkACQAJAAkACQBjAGEAdABlAGcAbwByAGkAZQBzADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBEAGEAdABlAH0AXQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB5AEEAeABpAHMAOgAgAHsACQAJAAkACQAJAAkAdABpAHQAbABlADoAIAB7AAkACQAJAAkACQAJAAkAdABlAHgAdAA6ACAAJwBQAGEAYwBrAGUAdABzACcACQAJAAkACQAJAAkAfQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQBzAGUAcgBpAGUAcwA6ACAAWwB7AAkACQAJAAkACQAJAHQAeQBwAGUAOgAgACcAbABpAG4AZQAnACwACQAJAAkACQAJAAkAbgBhAG0AZQA6ACAAJwBSAFgAIABBAHUAZABpAG8AJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjAEYARgAwADAAMAAwACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBSAFgAQQB1AGQAaQBvAH0AXQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB7AAkACQAJAAkACQAJAHQAeQBwAGUAOgAgACcAbABpAG4AZQAnACwACQAJAAkACQAJAAkAbgBhAG0AZQA6ACAAJwBSAFgAIABJAG0AYQBnAGUAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjAEEAQQAwADAAMAAwACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBSAFgASQBtAGEAZwBlAH0AXQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB7AAkACQAJAAkACQAJAHQAeQBwAGUAOgAgACcAbABpAG4AZQAnACwACQAJAAkACQAJAAkAbgBhAG0AZQA6ACAAJwBSAFgAIABPAHQAaABlAHIAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjADYANgAwADAAMAAwACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBSAFgATwB0AGgAZQByAH0AXQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB7AAkACQAJAAkACQAJAHQAeQBwAGUAOgAgACcAbABpAG4AZQAnACwACQAJAAkACQAJAAkAbgBhAG0AZQA6ACAAJwBUAFgAIABBAHUAZABpAG8AJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjADAAMAAwADAARgBGACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBUAFgAQQB1AGQAaQBvAH0AXQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB7AAkACQAJAAkACQAJAHQAeQBwAGUAOgAgACcAbABpAG4AZQAnACwACQAJAAkACQAJAAkAbgBhAG0AZQA6ACAAJwBUAFgAIABJAG0AYQBnAGUAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjADAAMAAwADAAQQBBACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBUAFgASQBtAGEAZwBlAH0AXQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB7AAkACQAJAAkACQAJAHQAeQBwAGUAOgAgACcAbABpAG4AZQAnACwACQAJAAkACQAJAAkAbgBhAG0AZQA6ACAAJwBUAFgAIABPAHQAaABlAHIAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjADAAMAAwADAANgA2ACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBUAFgATwB0AGgAZQByAH0AXQAJAAkACQAJAAkAfQBdAAkACQAJAAkAfQApADsACQAJAAkACQAJAHYAYQByACAAQgBhAG4AZAB3AGkAZAB0AGgAQwBoAGEAcgB0ACAAPQAgAG4AZQB3ACAASABpAGcAaABjAGgAYQByAHQAcwAuAGMAaABhAHIAdAAoACcAQgBhAG4AZAB3AGkAZAB0AGgAQwBoAGEAcgB0ACcALAAgAHsACQAJAAkACQAJAHQAaQB0AGwAZQA6ACAAewAJAAkACQAJAAkACQB0AGUAeAB0ADoAIAAnAEIAYQBuAGQAdwBpAGQAdABoACAAUwB0AGEAdABpAHMAdABpAGMAcwAnAAkACQAJAAkACQB9ACwACQAJAAkACQAJAHgAQQB4AGkAcwA6ACAAewAJAAkACQAJAAkACQBjAGEAdABlAGcAbwByAGkAZQBzADoAIABbACQAewBCAGQAdwB0AGgAUwB0AGEAdABzAC4ARABhAHQAZQB9AF0ACQAJAAkACQAJAH0ALAAJAAkACQAJAAkAeQBBAHgAaQBzADoAIAB7AAkACQAJAAkACQAJAHQAaQB0AGwAZQA6ACAAewAJAAkACQAJAAkACQAJAHQAZQB4AHQAOgAgACcASwBCAHkAdABlAHMALwBzACcACQAJAAkACQAJAAkAfQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQBzAGUAcgBpAGUAcwA6ACAAWwB7AAkACQAJAAkACQAJAHQAeQBwAGUAOgAgACcAbABpAG4AZQAnACwACQAJAAkACQAJAAkAbgBhAG0AZQA6ACAAJwBCAFcAIABMAGkAbQBpAHQAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjADAAMABGAEYAMAAwACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBCAGQAdwB0AGgAUwB0AGEAdABzAC4AQgBXAEwAaQBtAGkAdAB9AF0ACQAJAAkACQAJAH0ALAAJAAkACQAJAAkAewAJAAkACQAJAAkACQB0AHkAcABlADoAIAAnAGwAaQBuAGUAJwAsAAkACQAJAAkACQAJAG4AYQBtAGUAOgAgACcAQQB2AGUAcgBhAGcAZQAgAFIAWAAnACwACQAJAAkACQAJAAkAYwBvAGwAbwByADoAIAAnACMARgBGADAAMAAwADAAJwAsAAkACQAJAAkACQAJAGQAYQB0AGEAOgAgAFsAJAB7AEIAZAB3AHQAaABTAHQAYQB0AHMALgBBAFYARwBSAFgAfQBdAAkACQAJAAkACQB9ACwACQAJAAkACQAJAHsACQAJAAkACQAJAAkAdAB5AHAAZQA6ACAAJwBsAGkAbgBlACcALAAJAAkACQAJAAkACQBuAGEAbQBlADoAIAAnAEEAdgBlAHIAYQBnAGUAIABUAFgAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjADAAMAAwADAARgBGACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBCAGQAdwB0AGgAUwB0AGEAdABzAC4AQQBWAEcAVABYAH0AXQAJAAkACQAJAAkAfQBdAAkACQAJAAkAfQApADsACQAJAAkACQAJAHYAYQByACAATABvAHMAcwBDAGgAYQByAHQAIAA9ACAAbgBlAHcAIABIAGkAZwBoAGMAaABhAHIAdABzAC4AYwBoAGEAcgB0ACgAJwBMAG8AcwBzAEMAaABhAHIAdAAnACwAIAB7AAkACQAJAAkACQB0AGkAdABsAGUAOgAgAHsACQAJAAkACQAJAAkAdABlAHgAdAA6ACAAJwBMAG8AcwBzACAAUwB0AGEAdABpAHMAdABpAGMAcwAnAAkACQAJAAkACQB9ACwACQAJAAkACQAJAHgAQQB4AGkAcwA6ACAAewAJAAkACQAJAAkACQBjAGEAdABlAGcAbwByAGkAZQBzADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBEAGEAdABlAH0AXQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB5AEEAeABpAHMAOgAgAHsACQAJAAkACQAJAAkAdABpAHQAbABlADoAIAB7AAkACQAJAAkACQAJAAkAdABlAHgAdAA6ACAAJwAlACcACQAJAAkACQAJAAkAfQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQBzAGUAcgBpAGUAcwA6ACAAWwB7AAkACQAJAAkACQAJAHQAeQBwAGUAOgAgACcAbABpAG4AZQAnACwACQAJAAkACQAJAAkAbgBhAG0AZQA6ACAAJwBSAFgAIABMAG8AcwBzACcALAAJAAkACQAJAAkACQBjAG8AbABvAHIAOgAgACcAIwBBAEEAMAAwADAAMAAnACwACQAJAAkACQAJAAkAZABhAHQAYQA6ACAAWwAkAHsATgBlAHQAUwB0AGEAdABzAC4AUgBYAEwAbwBzAHMAfQBdAAkACQAJAAkACQB9ACwACQAJAAkACQAJAHsACQAJAAkACQAJAAkAdAB5AHAAZQA6ACAAJwBsAGkAbgBlACcALAAJAAkACQAJAAkACQBuAGEAbQBlADoAIAAnAFQAWAAgAEwAbwBzAHMAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjADAAMAAwADAAQQBBACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBOAGUAdABTAHQAYQB0AHMALgBUAFgATABvAHMAcwB9AF0ACQAJAAkACQAJAH0AXQAJAAkACQAJAH0AKQA7AAkACQAJAAkAdgBhAHIAIABMAGEAdABlAG4AYwB5AEMAaABhAHIAdAAgAD0AIABuAGUAdwAgAEgAaQBnAGgAYwBoAGEAcgB0AHMALgBjAGgAYQByAHQAKAAnAEwAYQB0AGUAbgBjAHkAQwBoAGEAcgB0ACcALAAgAHsACQAJAAkACQAJAHQAaQB0AGwAZQA6ACAAewAJAAkACQAJAAkACQB0AGUAeAB0ADoAIAAnAEwAYQB0AGUAbgBjAHkAIABTAHQAYQB0AGkAcwB0AGkAYwBzACcACQAJAAkACQAJAH0ALAAJAAkACQAJAAkAeABBAHgAaQBzADoAIAB7AAkACQAJAAkACQAJAGMAYQB0AGUAZwBvAHIAaQBlAHMAOgAgAFsAJAB7AEwAYQB0AFMAdABhAHQAcwAuAEQAYQB0AGUAfQBdAAkACQAJAAkACQB9ACwACQAJAAkACQAJAHkAQQB4AGkAcwA6ACAAewAJAAkACQAJAAkACQB0AGkAdABsAGUAOgAgAHsACQAJAAkACQAJAAkACQB0AGUAeAB0ADoAIAAnAG0AcwAnAAkACQAJAAkACQAJAH0ACQAJAAkACQAJAH0ALAAJAAkACQAJAAkAcwBlAHIAaQBlAHMAOgAgAFsAewAJAAkACQAJAAkACQB0AHkAcABlADoAIAAnAGwAaQBuAGUAJwAsAAkACQAJAAkACQAJAG4AYQBtAGUAOgAgACcATQBhAHgAaQBtAHUAbQAgAGwAYQB0AGUAbgBjAHkAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjAEEAQQAwADAAQQBBACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBMAGEAdABTAHQAYQB0AHMALgBNAGEAeAB9AF0ACQAJAAkACQAJAH0ALAAJAAkACQAJAAkAewAJAAkACQAJAAkACQB0AHkAcABlADoAIAAnAGwAaQBuAGUAJwAsAAkACQAJAAkACQAJAG4AYQBtAGUAOgAgACcAQQB2AGUAcgBhAGcAZQAgAGwAZQB0AGUAbgBjAHkAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjAEYARgAwADAARgBGACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBMAGEAdABTAHQAYQB0AHMALgBSAFQAVAB9AF0ACQAJAAkACQAJAH0AXQAJAAkACQAJAH0AKQA7AAkACQAJAAkAdgBhAHIAIABRAHUAYQBsAGkAdAB5AEMAaABhAHIAdAAgAD0AIABuAGUAdwAgAEgAaQBnAGgAYwBoAGEAcgB0AHMALgBjAGgAYQByAHQAKAAnAFEAdQBhAGwAaQB0AHkAQwBoAGEAcgB0ACcALAAgAHsACQAJAAkACQAJAHQAaQB0AGwAZQA6ACAAewAJAAkACQAJAAkACQB0AGUAeAB0ADoAIAAnAFEAdQBhAGwAaQB0AHkAIABTAHQAYQB0AGkAcwB0AGkAYwBzACcACQAJAAkACQAJAH0ALAAJAAkACQAJAAkAeABBAHgAaQBzADoAIAB7AAkACQAJAAkACQAJAGMAYQB0AGUAZwBvAHIAaQBlAHMAOgAgAFsAJAB7AFEAdQBhAGwAaQB0AHkAUwB0AGEAdABzAC4ARABhAHQAZQB9AF0ACQAJAAkACQAJAH0ALAAJAAkACQAJAAkAeQBBAHgAaQBzADoAIAB7AAkACQAJAAkACQAJAHQAaQB0AGwAZQA6ACAAewAJAAkACQAJAAkACQAJAHQAZQB4AHQAOgAgACcAJQAnAAkACQAJAAkACQAJAH0ACQAJAAkACQAJAH0ALAAJAAkACQAJAAkAcwBlAHIAaQBlAHMAOgAgAFsAewAJAAkACQAJAAkACQB0AHkAcABlADoAIAAnAGwAaQBuAGUAJwAsAAkACQAJAAkACQAJAG4AYQBtAGUAOgAgACcAUQB1AGEAbABpAHQAeQAnACwACQAJAAkACQAJAAkAYwBvAGwAbwByADoAIAAnACMARgBGADYANgAwADAAJwAsAAkACQAJAAkACQAJAGQAYQB0AGEAOgAgAFsAJAB7AFEAdQBhAGwAaQB0AHkAUwB0AGEAdABzAC4AUQB1AGEAbABpAHQAeQB9AF0ACQAJAAkACQAJAH0AXQAJAAkACQAJAH0AKQA7AAkACQAJAAkACQAJAAkACQB2AGEAcgAgAEYAUABTAEMAaABhAHIAdAAgAD0AIABuAGUAdwAgAEgAaQBnAGgAYwBoAGEAcgB0AHMALgBjAGgAYQByAHQAKAAnAEYAUABTAEMAaABhAHIAdAAnACwAIAB7AAkACQAJAAkACQB0AGkAdABsAGUAOgAgAHsACQAJAAkACQAJAAkAdABlAHgAdAA6ACAAJwBGAFAAUwAgAFMAdABhAHQAaQBzAHQAaQBjAHMAJwAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB4AEEAeABpAHMAOgAgAHsACQAJAAkACQAJAAkAYwBhAHQAZQBnAG8AcgBpAGUAcwA6ACAAWwAkAHsAUQB1AGEAbABpAHQAeQBTAHQAYQB0AHMALgBEAGEAdABlAH0AXQAJAAkACQAJAAkAfQAsAAkACQAJAAkACQB5AEEAeABpAHMAOgAgAHsACQAJAAkACQAJAAkAdABpAHQAbABlADoAIAB7AAkACQAJAAkACQAJAAkAdABlAHgAdAA6ACAAJwBGAHIAYQBtAGUAcwAgAHAAZQByACAAcwBlAGMAbwBuAGQAJwAJAAkACQAJAAkACQB9AAkACQAJAAkACQB9ACwACQAJAAkACQAJAHMAZQByAGkAZQBzADoAIABbAHsACQAJAAkACQAJAAkAdAB5AHAAZQA6ACAAJwBsAGkAbgBlACcALAAJAAkACQAJAAkACQBuAGEAbQBlADoAIAAnAFEAdQBhAGwAaQB0AHkAJwAsAAkACQAJAAkACQAJAGMAbwBsAG8AcgA6ACAAJwAjADAAMABBAEEAMAAwACcALAAJAAkACQAJAAkACQBkAGEAdABhADoAIABbACQAewBRAHUAYQBsAGkAdAB5AFMAdABhAHQAcwAuAEYAUABTAH0AXQAJAAkACQAJAAkAfQBdAAkACQAJAAkAfQApADsACQAJAAkACQB9ACkAOwAJAAkAPAAvAHMAYwByAGkAcAB0AD4ACQA8AC8AYgBvAGQAeQA+ADwALwBoAHQAbQBsAD4A"
	
	$Template = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($EncodedTemplate))
	$enUS = New-Object System.Globalization.CultureInfo("en-US")
		
	if ($MaxSamples -lt 2) {
		Write-Warning -Message "-MaxSamples cannot be less than 2. Set -MaxSamples to 2."
		$MaxSamples = 2
	}
	
	if($Format -eq "TEXT") {
		$Result = Show-PCoIPStatistics -PCoIPLog $PCoIPLog -MaxSamples $MaxSamples		
	}
	
	if($Format -eq "CSV") {
		$Result = New-PCoIPCSVReport -PCoIPLog $PCoIPLog -MaxSamples $MaxSamples

	}

	if($Format -eq "HTML") {
		$Result = New-PCoIPHTMLReport -PCoIPLog $PCoIPLog -Template $Template -MaxSamples $MaxSamples
	}
	
	Write-Output $Result | Out-File -Encoding utf8 $ResultPath	
}

#Format and return values from PSObject
function global:Show-PCoIPStatistics {
	<#
		.SYNOPSIS
		This Cmdlet outputs information from the PCoIP log object to the screen

		.PARAMETER PCoIPLog
		Specifies the PCoIPLog object which contains information about PCoIP session.
		
		.PARAMETER MaxSamples
		Specifies the maximum number of rows in the output.		
		
		.EXAMPLE
		Show-PCoIPStatistics -PCoIPLog $PCoIPLog
		Description
		
		-----------
		
		This command outputs the information from the PCoIP log object to the screen		
		
		.LINK
		https://github.com/omnimod/PCoIPLogAnalyzer
	#>

	Param(
		[Parameter(Mandatory=$True,
		Position=0,
		HelpMessage="Please enter the PCoIP log object which contains session information")]
		[PsCustomObject] $PCoIPLog,
		
		[Parameter(
		HelpMessage="Please specify the maximum number of rows to output. If not defined, the default value is 1000")]
		[Int] $MaxSamples = 1000
	)

	function Resize-Array {
		param([Array] $Arr, [Int] $MaxSamples)
		
		$size = $Arr.Count
		
		if ($size -lt $MaxSamples) {
			return $Arr
		}
		
		$ResizedArray = @()
		
		for ($i = 0; $i -lt $Size; $i += [math]::Ceiling($Size/($MaxSamples-1))) {
			$ResizedArray = $ResizedArray + $Arr[$i]
		}	

		$ResizedArray = $ResizedArray + $Arr[-1]	
		
		return $ResizedArray	
	}

	#Define variables

	if ($MaxSamples -lt 2) {
		Write-Warning -Message "-MaxSamples cannot be less than 2. Set -MaxSamples to 2."
		$MaxSamples = 2
	}	

	$Result = @()
	
	$Result += "====================================General Info====================================="
	$Result += "Log file:               " + $PCoIPLog.LogFile
	$Result += "Server name:            " + $PCoIPLog.Server.Name
	$Result += "Server IP address:      " + $PCoIPLog.Server.IP
	$Result += "Client IP address:      " + $PCoIPLog.Client.IP
	$Result += "PCoIP software version: " + $PCoIPLog.Version.Full
	$Result += "Encryption algorythm:   " + $PCoIPLog.Encryption
	$Result += "Session start time:     " + $PCoIPLog.StartTime
	$Result += "Session end time:       " + $PCoIPLog.EndTime
	$Result += "Session duration:       " + $PCoIPLog.Duration.ToString()
	$Result += ""
	
	$Result += "=================================Network statistics=================================="
	
	$NetStats = Resize-Array -Arr $PCoIPLog.NetStats -MaxSamples $MaxSamples
	
	$Result += $NetStats | ft  Date,
	@{Label="RX Audio"; Expression={$_.RXAudio}},
	@{Label="RX Image"; Expression={$_.RXImage}},
	@{Label="RX Other"; Expression={$_.RXOther}},
	@{Label="RX Total"; Expression={$_.RXAudio + $_.RXImage + $_.RXOther}},
	@{Label="TX Audio"; Expression={$_.TXAudio}},
	@{Label="TX Image"; Expression={$_.TXImage}},
	@{Label="TX Other"; Expression={$_.TXOther}},
	@{Label="TX Total"; Expression={$_.TXAudio + $_.TXImage + $_.TXOther}} -AutoSize 4>&1
	
	$Result += "Total RX Audio: " + "{0:N2}" -f ($PCoIPLog.NetStats[$_.Count-1].RXAudio) + " Packets"
	$Result += "Total RX Image: " + "{0:N2}" -f ($PCoIPLog.NetStats[$_.Count-1].RXImage) + " Packets"
	$Result += "Total RX Other: " + "{0:N2}" -f ($PCoIPLog.NetStats[$_.Count-1].RXOther) + " Packets"
	$Result += "Total RX:       " + "{0:N2}" -f ($PCoIPLog.NetStats[$_.Count-1].RXAudio + $PCoIPLog.NetStats[$_.Count-1].RXImage + $PCoIPLog.NetStats[$_.Count-1].RXOther) + " Packets"
	$Result += ""

	$Result += "Total TX Audio: " + "{0:N2}" -f ($PCoIPLog.NetStats[$_.Count-1].TXAudio) + " Packets"
	$Result += "Total TX Image: " + "{0:N2}" -f ($PCoIPLog.NetStats[$_.Count-1].TXImage) + " Packets"
	$Result += "Total TX Other: " + "{0:N2}" -f ($PCoIPLog.NetStats[$_.Count-1].TXOther) + " Packets"
	$Result += "Total TX:       " + "{0:N2}" -f ($PCoIPLog.NetStats[$_.Count-1].TXAudio + $PCoIPLog.NetStats[$_.Count-1].TXImage + $PCoIPLog.NetStats[$_.Count-1].TXOther) + " Packets"
	$Result += ""	
	
	$Result += "================================Bandwidth statistics================================="
	
	$BdwthStatistics = Resize-Array -Arr $PCoIPLog.BdwthStats -MaxSamples $MaxSamples

	$Result += $BdwthStatistics | ft Date,
	@{Label="BW Limit, KB/s"; Expression={$_.BWLimit}},
	@{Label="AVG RX, KB/s"; Expression={$_.AVGRX}},
	@{Label="AVG TX, KB/s"; Expression={$_.AVGTX}} 4>&1

	$Result += "MAX BW limit: " + "{0:N2}" -f [System.Math]::Round(($PCoIPLog.BdwthStats.BWLimit | Measure-Object -Maximum).Maximum, 2) + " KBytes/s"
	$Result += "AVG BW limit: " + "{0:N2}" -f [System.Math]::Round(($PCoIPLog.BdwthStats.BWLimit | Measure-Object -Average).Average, 2) + " KBytes/s"
	$Result += "MIN BW limit: " + "{0:N2}" -f [System.Math]::Round(($PCoIPLog.BdwthStats.BWLimit | Measure-Object -Minimum).Minimum, 2) + " KBytes/s"
	$Result += ""
	$Result += "AVG RX:       " + "{0:N2}" -f [System.Math]::Round(($PCoIPLog.BdwthStats.AVGRX | Measure-Object -Average).Average, 2) + " KBytes/s"
	$Result += "AVG TX:       " + "{0:N2}" -f [System.Math]::Round(($PCoIPLog.BdwthStats.AVGTX | Measure-Object -Average).Average, 2) + " KBytes/s"
	$Result += ""
	
	$Result += "==================================Loss statistics===================================="

	$Result += $NetStats | ft Date,
	@{Label="RX Loss, %"; Expression={"{0:P2}" -f ($_.RXLoss/100)}},
	@{Label="TX Loss, %"; Expression={"{0:P2}" -f ($_.TXLoss/100)}} 4>&1
	
	$Result += "MAX RX Loss: " + "{0:P2}" -f (($PCoIPLog.NetStats.RXLoss | Measure-Object -Maximum).Maximum/100)
	$Result += "AVG RX Loss: " + "{0:P2}" -f ([System.Math]::Round(($PCoIPLog.NetStats.RXLoss | Measure-Object -Average).Average, 2)/100)
	$Result += ""
	$Result += "MAX TX Loss: " + "{0:P2}" -f (($PCoIPLog.NetStats.TXLoss | Measure-Object -Maximum).Maximum/100)
	$Result += "AVG TX Loss: " + "{0:P2}" -f ([System.Math]::Round(($PCoIPLog.NetStats.TXLoss | Measure-Object -Average).Average, 2)/100)
	$Result += ""	
	
	$Result += "=================================Latency statistics=================================="	
	
	$LatStats = Resize-Array -Arr $PCoIPLog.LatStats -MaxSamples $MaxSamples

	$Result += $LatStats | ft Date,
	@{Label="AVG Latency, ms"; Expression={$_.RTT}},
	@{Label="MAX Latency, ms"; Expression={$_.Max}} 4>&1
	
	$Result += "MAX Latency: " + "{0:N0}" -f ($PCoIPLog.LatStats.Max | Measure-Object -Maximum).Maximum + " ms"
	$Result += "AVG Latency: " + "{0:N0}" -f [System.Math]::Round(($PCoIPLog.LatStats.RTT | Measure-Object -Average).Average, 2) + " ms"
	$Result += ""

	$Result += "=================================Quality statistics=================================="
	
	$QualityStats = Resize-Array -Arr $PCoIPLog.QualityStats -MaxSamples $MaxSamples

	$Result += $QualityStats | ft Date,
	@{Label="TBL";Expression={"{0:N0}" -f ($_.TBL)}},
	@{Label="FPS";Expression={"{0:N2}" -f ($_.FPS)}},
	@{Label="Quality, %";Expression={"{0:P0}" -f ($_.Quality/100)}} 4>&1

	$Result += "MAX TBL: " + "{0:N0}" -f (($PCoIPLog.QualityStats.TBL | Measure-Object -Maximum).Maximum)
	$Result += "MIN TBL: " + "{0:N0}" -f (($PCoIPLog.QualityStats.TBL | Measure-Object -Minimum).Minimum)
	$Result += ""		
	
	$Result += "MAX FPS: " + "{0:N2}" -f (($PCoIPLog.QualityStats.FPS | Measure-Object -Maximum).Maximum)
	$Result += "AVG FPS: " + "{0:N2}" -f (($PCoIPLog.QualityStats.FPS | Measure-Object -Average).Average)
	$Result += "MIN FPS: " + "{0:N2}" -f (($PCoIPLog.QualityStats.FPS | Measure-Object -Minimum).Minimum)
	$Result += ""
	
	$Result += "MAX Quality: " + "{0:P0}" -f (($PCoIPLog.QualityStats.Quality | Measure-Object -Maximum).Maximum/100)
	$Result += "MIN Quality: " + "{0:P0}" -f (($PCoIPLog.QualityStats.Quality | Measure-Object -Minimum).Minimum/100)
	$Result += ""
	
	$Result += "================================Encoding statistics=================================="

	$EncodStats = Resize-Array -Arr $PCoIPLog.EncodStats -MaxSamples $MaxSamples
	
	$Result += $EncodStats | ft Date,
	@{Label="Bits per pixel";Expression={"{0:N2}" -f ($_.BitsPixel)}},
	@{Label="Bits per second";Expression={"{0:N0}" -f ($_.BitsSec)}},
	@{Label="Megapixels per second";Expression={"{0:N2}" -f ($_.MPixSec)}} 4>&1	
	
	$Result += "MAX Bits per pixel:        " + "{0:N2}" -f (($PCoIPLog.EncodStats.BitsPixel | Measure-Object -Maximum).Maximum)
	$Result += "AVG Bits per pixel:        " + "{0:N2}" -f (($PCoIPLog.EncodStats.BitsPixel | Measure-Object -Average).Average)
	$Result += "MIN Bits per pixel:        " + "{0:N2}" -f (($PCoIPLog.EncodStats.BitsPixel | Measure-Object -Minimum).Minimum)
	$Result += ""	
	
	$Result += "MAX Bits per second:       " + "{0:N0}" -f (($PCoIPLog.EncodStats.BitsSec | Measure-Object -Maximum).Maximum)
	$Result += "AVG Bits per second:       " + "{0:N0}" -f (($PCoIPLog.EncodStats.BitsSec | Measure-Object -Average).Average)
	$Result += "MIN Bits per second:       " + "{0:N0}" -f (($PCoIPLog.EncodStats.BitsSec | Measure-Object -Minimum).Minimum)
	$Result += ""
	
	$Result += "MAX Megapixels per second: " + "{0:N2}" -f (($PCoIPLog.EncodStats.MPixSec | Measure-Object -Maximum).Maximum)
	$Result += "AVG Megapixels per second: " + "{0:N2}" -f (($PCoIPLog.EncodStats.MPixSec | Measure-Object -Average).Average)
	$Result += "MIN Megapixels per second: " + "{0:N2}" -f (($PCoIPLog.EncodStats.MPixSec | Measure-Object -Minimum).Minimum)
	$Result += ""
	
	$Result += "================================Advanced statistics=================================="

	$AdvStats = Resize-Array -Arr $PCoIPLog.AdvStats -MaxSamples $MaxSamples

	$Result += $AdvStats | ft Date,
	@{Label="Cur_s";Expression={"{0:N0}" -f ($_.Cur_s)}},
	@{Label="Max_s";Expression={"{0:N0}" -f ($_.Max_s)}},
	@{Label="BWC";Expression={"{0:N2}" -f ($_.BWC)}},
	@{Label="BWT";Expression={"{0:N2}" -f ($_.BWT)}},
	@{Label="Changed FPS";Expression={"{0:N2}" -f ($_.ChangedFPS)}},
	@{Label="Decode Rate, MBit/s";Expression={"{0:N2}" -f ($_.DecodeRate)}} 4>&1	
	
	return $Result
}

#Retrieve data from pcoip_server log file and display it on the screen and/or export to the log file
function global:Get-PCoIPStatistics {
	<#
		.SYNOPSIS
		This Cmdlet parses the PCoIP log file and exports information to a file or outputs it to the screen

		.PARAMETER FilePath
		Specifies the path to the pcoip_server log file.

		.PARAMETER ResultPath
		Specifies the path to the file where results will be saved.
		
		.PARAMETER Format
		Specifies the format of the result file.
		
		.PARAMETER MaxSamples
		Specifies the maximum number of rows in the output.
		
		.PARAMETER NoScreenOutput
		Specifies to skip output the result to the screen.
		
		.EXAMPLE
		Get-PCoIPStatistics -FilePath "C:\Logs\pcoip_server_2014_07_24_00000b8c.txt" -ResultPath "C:\Results\report.txt"
		Description
		
		-----------
		
		This command gets information about the PCoIP session from the PCoIP log file, exports it to a text file and outputs to the screen.

		.EXAMPLE
		Get-PCoIPStatistics -FilePath "C:\Logs\pcoip_server_2014_07_24_00000b8c.txt" -ResultPath "C:\Results\report.txt" -Format HTML
		Description
		
		-----------
		
		This command gets information about the PCoIP session from the PCoIP log file, exports it to a html file and outputs to the screen.
		
		.LINK
		https://github.com/omnimod/PCoIPLogAnalyzer
	#>

	[CmdletBinding(
		DefaultParameterSetName="FilePath"
	)]

	Param(
		[Parameter(Mandatory=$True,
		Position=0,
		HelpMessage="Please enter the path to the pcoip_server log file")]
		[String] $FilePath,
		
		[Parameter(Position=1,
		HelpMessage="Please enter the path where the result file will be saved")]	
		[String] $ResultPath,

		[Parameter(
		HelpMessage="Please specify the format of the result file. Could be TEXT, HTML or CSV")]		
		[ValidateSet("CSV", "HTML", "TEXT")]
		[String]$Format = "TEXT",
	
		[Parameter(
		HelpMessage="Please specify the maximum number of rows to output. If not defined, the default value is 1000")]
		[Int] $MaxSamples = 1000,
		
		[switch] $NoScreenOutput
	)
			
	if ($MaxSamples -lt 2) {
		Write-Warning -Message "-MaxSamples cannot be less than 2. Set -MaxSamples to 2."
		$MaxSamples = 2
	}

	$PCoIPLog = Import-PCoIPLog -FilePath $FilePath

	if($ResultPath) {
		Export-PCoIPStatistics -PCoIPLog $PCoIPLog -ResultPath $ResultPath -Format $Format -MaxSamples $MaxSamples
	}
	
	if(!$NoScreenOutput) {
		Show-PCoIPStatistics -PCoIPLog $PCoIPLog -MaxSamples $MaxSamples	
	}
}
