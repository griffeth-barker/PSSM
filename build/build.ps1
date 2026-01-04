<#
    .SYNOPSIS
        Build script for PSSM
    .DESCRIPTION
        Build script using PS2EXE module to wrap the service manager script
        as a standalone executable file.
    .INPUTS
        pssm.ps1
    .OUTPUTS
        pssm.exe
    .NOTES

    .LINK
        TBD
#>

#requires -Module PS2EXE

$params = @{
    inputFile    = '.\src\pssm.ps1'
    outputFile   = '.\releases\pssm-0.1.0.exe'
    STA          = $true
    iconFile     = '.\images\icon-pssm.ico'
    noConsole    = $true
    title        = 'PowerShell Service Manager'
    description  = 'Another service manager for Microsoft Windows'
    company      = 'griff.systems'
    version      = '0.1.0'
    requireAdmin = $true
    configFile   = $false
}

Invoke-PS2EXE @params