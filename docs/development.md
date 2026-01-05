## Development & Compilation

### Application Dependencies
There are no external dependencies for the wrapped application to run, apart from the `PresentationFramework` and `System.Windows.Forms` assemblies, which are theoretically included on all modern Windows systems.

### Build Dependencies
Wrapping the script as an executable is done using the [PS2EXE module](https://github.com/MScholtes/PS2EXE), which can be installed from the PSGallery:
```powershell
Install-Module -Name 'PS2EXE' -Repository PSGallery
```
You can use another method to wrap `pssm.ps1` as `pssm.exe` if you wish, provided the necessary threading requirements are met.

### Threading Requirements
This application uses the **Windows Presentation Framework (WPF)** and must be run in **Single-Threaded Apartment (STA)** mode. 
* If running via script: `powershell.exe -sta -file .\pssm.ps1`
* If buliding the executable: Be sure to include the `-sta` parameter in your `Invoke-PS2EXE` command.

### Wrapping/Compiling
To generate a standalone executable, use the following command structure:

```powershell
# Modify the values of the InputFile, OutputFile, and IconFile strings as necessary.
$buildParams = @{
    InputFile = '.\src\pssm.ps1'
    OutputFile = '.\releases\pssm.exe'
    IconFile = '.\images\pssm-gear-icon.ico'
    STA = $true
    NoConsole = $true
    NoConfigFile = $true
}

Invoke-PS2EXE @buildParams
```

### Contributing
Feedback and pull requests are welcome. 

### Functions
The following functions are used in the main script:

#### Core Logic & Analysis Functions
These functions handle the heavy lifting of data gathering and security auditing.

**Get-Uptime**: Calculates how long a service has been running by comparing the current date to the process start time of the Service PID.

**Get-CleanFolder**: Uses Regex and string manipulation to strip quotes and arguments from a service's ImagePath, returning only the parent directory path.

**Test-IsPermissive**: Checks the Access Control List (ACL) of the service's folder to identify if non-admin groups have Write or Modify permissions.

**Update-UI**: Orchestrates the data refresh by querying CIM instances, building a collection of custom objects, and binding them to the main window's list view.

#### Export & Portability Functions
These functions manage the data output and clipboard interaction.

**Export-CSV-Safe**: Opens a save file dialog and writes the current filtered list view data to a CSV file while using a state-gate to prevent recursive dialog loops.

**Export-JSON-Clipboard**: Converts the current service data into a JSON string and copies it directly to the Windows clipboard for external use.

#### UI & Modal Window Functions
These functions generate and manage the various themed pop-up windows.

**Show-DetailsModal**: Launches a themed secondary window that displays extended service information, including the full description and a "DIR" jump button.

**Show-DeleteModal**: Provides a safety-first confirmation window that requires the user to manually type the service name before the deletion command is issued.

**Show-InstallModal**: Presents a structured form to gather parameters like Service ID, Display Name, and Binary Path to create a new Windows service via sc.exe.

**Open-ServiceRegistry**: A helper function that updates the Registry Editor's "LastKey" value and launches regedit.exe to jump directly to the selected service's configuration.

### CIM vs. WMI
This script and application makes use of CIM instead of WMI, as has been the recommended practice for some time now.