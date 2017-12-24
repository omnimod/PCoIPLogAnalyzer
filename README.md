**About**
--------
PCoIP Log Analyzer is a PowerShell commandlet which allows you to analyze pcoip_server log files generated by VMware Horizon View Agent v 7.x.

**Installation**
--------
To install PCoIP Log Analyzer simply copy the Get-PCoIPLogDetails.ps1 file from the repository to your computer.

**Execution**
--------
PCoIP Log Analyzer has some addition parameters:
Get-PCoIPLogDetails.ps1 -FilePath \<string\> [-ResultPath \<string\>] [-ExportHTML] [-NoScreenOutput] [-MaxSamples \<int\>]
  
Parameters:
-  -FilePath \<string\>   - (mandatory) Specify path to the pcoip_server log file.
-  -ResultPath \<string\> - (optional) Specify path to export results to the file.
-  -ExportHTML          - (optional) Specify this parameter, if you want to export results in HTML format. By default data is saved in text format.
-  -NoScreenOutput      - (optional) Specify this parameter, if you want to skip output the result to the console.
-  -MaxSamples \<int\>    - (optional) Set the maximum number of rows to output. If not defined, the default value is 500.

Examples:
  #Analyze log file, and print the report to the console
  
  Get-PCoIPLogDetails.ps1 -FilePath "C:\Temp\pcoip_server_2017_12_19_000034d0.txt"
  
  #Analyze log file, generate the report and export it to the HTML file
  
  Get-PCoIPLogDetails.ps1 -FilePath "C:\Temp\pcoip_server_2017_12_16_00000230.txt" -ResultPath "C:\Temp\report.html" -ExportHTML
  

