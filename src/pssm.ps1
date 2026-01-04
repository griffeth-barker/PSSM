<#
    .SYNOPSIS
        Another service manager for Microsoft Windows
    .DESCRIPTION
        PSSM is another service manager for Microsoft Windows offering features such as opening File Explorer
        or Registry Editor directly to the page relevant to the service, checking for hardened service executable
        paths, overly permissive service directories, displaying uptime, exporting data to CSV or JSON, installing
        and deleting services, etc.
    .INPUTS
        None
    .OUTPUTS
        None
    .NOTES
        This application requires administrative permissions to run.
        This application is provided without warranty, guarantee, etc. Use at your own risk.
    .LINK
        TBD
#>

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

try {
    #region main xaml
    # --- XAML UI Definition ---
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PowerShell Service Manager" Height="650" Width="1250" 
        WindowStartupLocation="CenterScreen" Background="#2D2D2D">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#444444"/><Setter Property="Foreground" Value="White"/><Setter Property="BorderBrush" Value="#555555"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="border" BorderThickness="1" Padding="5" BorderBrush="{TemplateBinding BorderBrush}" Background="{TemplateBinding Background}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="Background" Value="#555555"/></Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Foreground" Value="#666666"/><Setter TargetName="border" Property="Background" Value="#252525"/><Setter TargetName="border" Property="BorderBrush" Value="#333333"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="ListViewItem">
            <Setter Property="Background" Value="Transparent" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ListViewItem">
                        <Border Name="InnerBorder" Background="{TemplateBinding Background}" BorderThickness="0" Padding="2"><GridViewRowPresenter VerticalAlignment="Center" /></Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="InnerBorder" Property="Background" Value="#333333" /></Trigger>
                            <Trigger Property="IsSelected" Value="True"><Setter TargetName="InnerBorder" Property="Background" Value="#444444" /><Setter Property="Foreground" Value="White" /></Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>
    <Grid Name="MainGrid" Margin="10" Background="Transparent">
        <Grid.RowDefinitions><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        
        <ListView Name="serviceListView" Grid.Row="0" SelectionMode="Single" Background="#181818" BorderBrush="#444444" Foreground="#E0E0E0">
            <ListView.ContextMenu>
                <ContextMenu Name="mainCtx">
                    <MenuItem Name="ctxStart" Header="Start" /><MenuItem Name="ctxStop" Header="Stop" /><MenuItem Name="ctxRestart" Header="Restart" />
                    <Separator />
                    <MenuItem Name="ctxOpenFolder" Header="Open File Location" />
                    <MenuItem Name="ctxOpenRegistry" Header="Open in Registry" />
                    <Separator />
                    <MenuItem Header="Harden service path" IsEnabled="False" />
                    <MenuItem Header="Harden service permissions" IsEnabled="False" />
                    <Separator />
                    <MenuItem Name="ctxDetails" Header="Details" FontWeight="Bold" />
                </ContextMenu>
            </ListView.ContextMenu>
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="Status" Width="80">
                        <GridViewColumn.CellTemplate>
                            <DataTemplate><TextBlock Text="{Binding Status}" FontWeight="Bold">
                                <TextBlock.Style><Style TargetType="TextBlock"><Style.Triggers>
                                    <DataTrigger Binding="{Binding Status}" Value="Running"><Setter Property="Foreground" Value="#81C784" /></DataTrigger>
                                    <DataTrigger Binding="{Binding Status}" Value="Stopped"><Setter Property="Foreground" Value="#E57373" /></DataTrigger>
                                </Style.Triggers></Style></TextBlock.Style>
                            </TextBlock></DataTemplate>
                        </GridViewColumn.CellTemplate>
                    </GridViewColumn>
                    <GridViewColumn Header="Name" DisplayMemberBinding="{Binding Name}" Width="140"/>
                    <GridViewColumn Header="Display Name" DisplayMemberBinding="{Binding DisplayName}" Width="180"/>
                    <GridViewColumn Header="Startup" DisplayMemberBinding="{Binding StartType}" Width="100"/>
                    <GridViewColumn Header="Log On As" DisplayMemberBinding="{Binding StartName}" Width="120"/>
                    <GridViewColumn Header="Uptime" DisplayMemberBinding="{Binding Uptime}" Width="110"/>
                    <GridViewColumn Header="Quoted" Width="60">
                        <GridViewColumn.CellTemplate>
                            <DataTemplate><TextBlock Text="{Binding IsQuoted}"><TextBlock.Style><Style TargetType="TextBlock"><Style.Triggers><DataTrigger Binding="{Binding IsQuoted}" Value="False"><Setter Property="Foreground" Value="Yellow" /><Setter Property="FontWeight" Value="Bold" /></DataTrigger></Style.Triggers></Style></TextBlock.Style></TextBlock></DataTemplate>
                        </GridViewColumn.CellTemplate>
                    </GridViewColumn>
                    <GridViewColumn Header="Permissive" Width="80">
                        <GridViewColumn.CellTemplate>
                            <DataTemplate><TextBlock Text="{Binding Permissive}"><TextBlock.Style><Style TargetType="TextBlock"><Style.Triggers><DataTrigger Binding="{Binding Permissive}" Value="True"><Setter Property="Foreground" Value="Yellow" /><Setter Property="FontWeight" Value="Bold" /></DataTrigger></Style.Triggers></Style></TextBlock.Style></TextBlock></DataTemplate>
                        </GridViewColumn.CellTemplate>
                    </GridViewColumn>
                </GridView>
            </ListView.View>
        </ListView>

        <Grid Grid.Row="1" Margin="0,10,0,0">
            <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <Button Name="btnRefresh" Content="Refresh List" Width="100" Height="30" Margin="0,0,5,0"/>
            <Button Name="btnExportMenu" Grid.Column="1" Content="Export Data" Width="110" Height="30">
                <Button.ContextMenu><ContextMenu Name="exportCtx"><MenuItem Name="menuExportCSV" Header="Save as CSV File..." /><MenuItem Name="menuExportJSON" Header="Copy JSON to Clipboard" /></ContextMenu></Button.ContextMenu>
            </Button>
            <StackPanel Orientation="Horizontal" Grid.Column="2" HorizontalAlignment="Center"><TextBlock Text="Search:" Foreground="#F0F0F0" VerticalAlignment="Center" Margin="20,0,5,0"/><TextBox Name="txtSearch" Width="300" Height="25" VerticalContentAlignment="Center" Background="#1E1E1E" Foreground="White" BorderBrush="#555555" CaretBrush="White"/></StackPanel>
            <StackPanel Orientation="Horizontal" Grid.Column="3">
                <Button Name="btnInstall" Content="Install Service" Width="110" Height="30" Margin="5,0"/><Button Name="btnDelete" Content="Delete Service" Width="110" Height="30" Margin="5,0" IsEnabled="False"/><Separator Width="20" Visibility="Hidden"/><Button Name="btnStart" Content="Start" Width="80" Height="30" Margin="5,0" IsEnabled="False"/><Button Name="btnStop" Content="Stop" Width="80" Height="30" Margin="5,0" IsEnabled="False"/><Button Name="btnRestart" Content="Restart" Width="80" Height="30" Margin="5,0" IsEnabled="False"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@
    #endregion main xaml

    #region state-mgmt
    $script:SortColumn = "DisplayName"; $script:SortDescending = $false
    $script:isExporting = $false
    $script:SearchTimer = New-Object System.Windows.Threading.DispatcherTimer
    $script:SearchTimer.Interval = [TimeSpan]::FromMilliseconds(500)
    #endregion state-mgmt

    #region functions
    function Get-Uptime {
        param($ServicePID)
        if ($ServicePID -le 0) { return "N/A" }
        try {
            $proc = Get-Process -Id $ServicePID -ErrorAction SilentlyContinue
            if ($proc) {
                $span = (Get-Date) - $proc.StartTime
                if ($span.TotalDays -ge 1) { return "{0:n0}d {1:D2}h {2:D2}m" -f $span.Days, $span.Hours, $span.Minutes }
                if ($span.TotalHours -ge 1) { return "{0:D2}h {1:D2}m {2:D2}s" -f $span.Hours, $span.Minutes, $span.Seconds }
                return "{0:D2}m {1:D2}s" -f $span.Minutes, $span.Seconds
            }
        } catch {}
        return "N/A"
    }

    function Get-CleanFolder {
        param([string]$rawPath)
        if ([string]::IsNullOrWhiteSpace($rawPath)) { return $null }
        $cleanPath = $rawPath.Trim().Replace('"', '')
        if ($cleanPath -match '^([a-zA-Z]:\\[^ ]+\.exe)') { $cleanPath = $matches[1] }
        elseif ($cleanPath.Contains(' ')) { $parts = $cleanPath -split '(?<=\.exe)\s'; $cleanPath = $parts[0] }
        return Split-Path $cleanPath -Parent
    }

    function Test-IsPermissive {
        param([string]$Path)
        $folder = Get-CleanFolder $Path
        if ($null -eq $folder -or -not (Test-Path $folder)) { return "False" }
        try {
            $acl = Get-Acl -Path $folder
            $badGroups = @("BUILTIN\Users", "Everyone", "Users")
            foreach ($access in $acl.Access) {
                if ($badGroups -contains $access.IdentityReference.Value) {
                    if ($access.FileSystemRights.ToString() -match "Write|Modify|FullControl") { return "True" }
                }
            }
        } catch {}
        return "False"
    }

    function Update-UI {
        $cimServices = Get-CimInstance -ClassName Win32_Service
        $services = $cimServices | ForEach-Object {
            [PSCustomObject]@{ 
                Name = [string]$_.Name; DisplayName = [string]$_.DisplayName; Status = [string]$_.State; StartType = [string]$_.StartMode; 
                StartName = [string]$_.StartName; Description = [string]$_.Description; 
                IsQuoted = [string]($_.PathName.StartsWith('"')); Permissive = [string](Test-IsPermissive -Path $_.PathName);
                Uptime = Get-Uptime -ServicePID $_.ProcessId; RawPath = [string]$_.PathName
            }
        }
        if ($txtSearch.Text) {
            $q = $txtSearch.Text
            $services = $services | Where-Object { $_.Name -match $q -or $_.DisplayName -match $q -or $_.Description -match $q -or $_.Permissive -match $q -or $_.IsQuoted -match $q }
        }
        $serviceListView.ItemsSource = $services | Sort-Object -Property $script:SortColumn -Descending:$script:SortDescending
    }

    # --- THEMED MODALS ---
    function Show-DetailsModal {
        param($Service)
        $details = Get-CimInstance -ClassName Win32_Service -Filter "Name='$($Service.Name)'"
        [xml]$pX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="$($Service.Name) Details" Height="530" Width="550" WindowStartupLocation="CenterOwner" Background="#2D2D2D">
            <Grid Margin="20">
                <Grid.ColumnDefinitions><ColumnDefinition Width="130"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <TextBlock Grid.Row="0" Text="Service Name:" Foreground="White" VerticalAlignment="Center"/><TextBox Grid.Row="0" Grid.Column="1" Text="$($details.Name)" IsReadOnly="True" Background="#1E1E1E" Foreground="White" BorderBrush="#555555" Margin="0,5"/>
                <TextBlock Grid.Row="1" Text="Uptime:" Foreground="White" VerticalAlignment="Center"/><TextBox Grid.Row="1" Grid.Column="1" Text="$($Service.Uptime)" IsReadOnly="True" Background="#1E1E1E" Foreground="White" BorderBrush="#555555" Margin="0,5"/>
                <TextBlock Grid.Row="2" Text="Security Status:" Foreground="White" VerticalAlignment="Center"/><TextBlock Grid.Row="2" Grid.Column="1" Text="Quoted: $($Service.IsQuoted) | Permissive: $($Service.Permissive)" Foreground="Yellow" FontWeight="Bold" VerticalAlignment="Center" Margin="0,5"/>
                <TextBlock Grid.Row="3" Text="Path to EXE:" Foreground="White" VerticalAlignment="Center"/><DockPanel Grid.Row="3" Grid.Column="1" Margin="0,5"><Button Name="btnDir" Content="DIR" Width="35" DockPanel.Dock="Right" Margin="5,0,0,0"/><TextBox Text="$($details.PathName)" IsReadOnly="True" TextWrapping="Wrap" Background="#1E1E1E" Foreground="White" BorderBrush="#555555"/></DockPanel>
                <TextBlock Grid.Row="8" Text="Description:" Foreground="White" VerticalAlignment="Center"/><TextBox Grid.Row="8" Grid.Column="1" Text="$($details.Description)" IsReadOnly="True" TextWrapping="Wrap" Background="#1E1E1E" Foreground="White" BorderBrush="#555555" Margin="0,5"/>
                <Button Name="btnOK" Grid.Row="10" Grid.Column="1" Content="Close" Width="80" Height="25" HorizontalAlignment="Right" Background="#444444" Foreground="White" Margin="0,10,0,0"/>
            </Grid>
        </Window>
"@
        $pW = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $pX)); $pW.Owner = $Window
        $pW.FindName("btnDir").Add_Click({ $dir = Get-CleanFolder $details.PathName; if($null -ne $dir -and (Test-Path $dir)){Start-Process explorer.exe $dir} })
        $pW.FindName("btnOK").Add_Click({ $pW.Close() }); $pW.ShowDialog() | Out-Null
    }

    function Show-DeleteModal {
        param([string]$ServiceName)
        [xml]$dX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Confirm Service Deletion" Height="260" Width="450" WindowStartupLocation="CenterOwner" Background="#2D2D2D">
            <Grid Margin="20">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <TextBlock Text="WARNING: PERMANENT DELETION" Foreground="Red" FontWeight="Bold" HorizontalAlignment="Center"/><TextBlock Grid.Row="1" Text="Confirm by typing name:" Foreground="White" Margin="0,10"/><TextBlock Grid.Row="2" Text="$ServiceName" Foreground="White" FontWeight="Bold" HorizontalAlignment="Center"/>
                <TextBox Name="txtC" Grid.Row="3" Height="25" Background="#1E1E1E" Foreground="White" BorderBrush="#555555"/><UniformGrid Grid.Row="4" Columns="2" Margin="0,10,0,0"><Button Name="btnD" Content="Delete" IsEnabled="False" Margin="0,0,5,0"/><Button Name="btnC" Content="Cancel" Margin="5,0,0,0"/></UniformGrid>
            </Grid>
        </Window>
"@
        $dW = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $dX)); $dW.Owner = $Window
        $tc = $dW.FindName("txtC"); $bd = $dW.FindName("btnD"); $tc.Add_TextChanged({ $bd.IsEnabled = ($tc.Text -ceq $ServiceName) })
        $script:res = $false; $bd.Add_Click({ $script:res=$true; $dW.Close() }); $dW.FindName("btnC").Add_Click({ $dW.Close() }); $dW.ShowDialog() | Out-Null
        return $script:res
    }

    function Show-InstallModal {
        [xml]$iX = @"
        <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Title="Install New Service" Height="500" Width="500" WindowStartupLocation="CenterOwner" Background="#2D2D2D">
            <Grid Margin="20">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                <TextBlock Text="Service ID (Name):" Foreground="White" Margin="0,5"/><TextBox Name="inN" Grid.Row="1" Height="25" Background="#1E1E1E" Foreground="White" BorderBrush="#555555"/>
                <TextBlock Grid.Row="2" Text="Display Name:" Foreground="White" Margin="0,5"/><TextBox Name="inD" Grid.Row="3" Height="25" Background="#1E1E1E" Foreground="White" BorderBrush="#555555"/>
                <TextBlock Grid.Row="4" Text="Path to Executable:" Foreground="White" Margin="0,5"/><DockPanel Grid.Row="5"><Button Name="btnB" Content="..." Width="30" DockPanel.Dock="Right" Margin="5,0,0,0"/><TextBox Name="inP" Height="25" Background="#1E1E1E" Foreground="White" BorderBrush="#555555"/></DockPanel>
                <TextBlock Grid.Row="6" Text="Startup Mode:" Foreground="White" Margin="0,5"/><ComboBox Name="inS" Grid.Row="7" Height="25" Background="#1E1E1E" Foreground="Black"><ComboBoxItem Content="Auto" IsSelected="True"/><ComboBoxItem Content="Demand"/><ComboBoxItem Content="Disabled"/></ComboBox>
                <TextBlock Grid.Row="8" Text="Log On As:" Foreground="White" Margin="0,5"/><TextBox Name="inU" Grid.Row="9" Height="25" Text="LocalSystem" Background="#1E1E1E" Foreground="White" BorderBrush="#555555"/>
                <UniformGrid Grid.Row="11" Columns="2" Margin="0,20,0,0"><Button Name="btnI" Content="Install" Height="30" Margin="0,0,5,0"/><Button Name="btnCan" Content="Cancel" Height="30" Margin="5,0,0,0"/></UniformGrid>
            </Grid>
        </Window>
"@
        $iW = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $iX)); $iW.Owner = $Window
        $iW.FindName("btnB").Add_Click({ $f=New-Object System.Windows.Forms.OpenFileDialog; if($f.ShowDialog()-eq"OK"){$iW.FindName("inP").Text=$f.FileName}})
        $iW.FindName("btnI").Add_Click({ sc.exe create "$($iW.FindName('inN').Text)" binpath= "$($iW.FindName('inP').Text)" displayname= "$($iW.FindName('inD').Text)" start= "$($iW.FindName('inS').SelectedItem.Content.ToString().ToLower())" obj= "$($iW.FindName('inU').Text)"; $iW.Close() })
        $iW.FindName("btnCan").Add_Click({ $iW.Close() }); $iW.ShowDialog() | Out-Null
    }

    # --- Export Logic ---
    function Export-CSV-Safe {
        if ($script:isExporting) { return }
        $script:isExporting = $true
        try {
            $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
            $saveDialog.Filter = "CSV files (*.csv)|*.csv"
            $saveDialog.FileName = "ServiceReport_$(Get-Date -Format 'yyyyMMdd_HHmm').csv"
            if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $serviceListView.ItemsSource | Export-Csv -Path $saveDialog.FileName -NoTypeInformation -Encoding utf8
                [System.Windows.MessageBox]::Show("CSV saved successfully.")
            }
        } finally { $script:isExporting = $false }
    }
    #endregion functions

    #region main-exec
    $Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
    $serviceListView = $Window.FindName("serviceListView"); $txtSearch = $Window.FindName("txtSearch")
    $btnRefresh = $Window.FindName("btnRefresh"); $btnExportMenu = $Window.FindName("btnExportMenu")
    $btnInstall = $Window.FindName("btnInstall"); $btnDelete = $Window.FindName("btnDelete")
    $btnStart = $Window.FindName("btnStart"); $btnStop = $Window.FindName("btnStop"); $btnRestart = $Window.FindName("btnRestart")

    # Mapping
    $btnExportMenu.Add_Click({ $btnExportMenu.ContextMenu.PlacementTarget = $btnExportMenu; $btnExportMenu.ContextMenu.IsOpen = $true })
    $Window.FindName("menuExportCSV").Add_Click({ Export-CSV-Safe })
    $Window.FindName("menuExportJSON").Add_Click({ [System.Windows.Clipboard]::SetText(($serviceListView.ItemsSource | ConvertTo-Json -Depth 5)); [System.Windows.MessageBox]::Show("JSON copied to clipboard.") })

    $Window.FindName("ctxDetails").Add_Click({ Show-DetailsModal -Service $serviceListView.SelectedItem })
    $Window.FindName("ctxOpenFolder").Add_Click({ if($serviceListView.SelectedItem){ $dir=Get-CleanFolder $serviceListView.SelectedItem.RawPath; if($null -ne $dir -and (Test-Path $dir)){Start-Process explorer.exe $dir} } })
    $Window.FindName("ctxOpenRegistry").Add_Click({ if($serviceListView.SelectedItem){ 
        $path = "Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$($serviceListView.SelectedItem.Name)"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" -Name "LastKey" -Value $path
        Start-Process "regedit.exe" 
    }})

    $btnRefresh.Add_Click({ Update-UI }); $btnInstall.Add_Click({ Show-InstallModal; Update-UI })
    $btnDelete.Add_Click({ if (Show-DeleteModal -ServiceName $serviceListView.SelectedItem.Name) { sc.exe delete $serviceListView.SelectedItem.Name; Update-UI } })
    
    $startAct = { try { Start-Service $serviceListView.SelectedItem.Name; Update-UI } catch { [System.Windows.MessageBox]::Show($_.Exception.Message) } }
    $stopAct = { try { Stop-Service $serviceListView.SelectedItem.Name -Force; Update-UI } catch { [System.Windows.MessageBox]::Show($_.Exception.Message) } }
    $restartAct = { try { Restart-Service $serviceListView.SelectedItem.Name -Force; Update-UI } catch { [System.Windows.MessageBox]::Show($_.Exception.Message) } }
    
    $btnStart.Add_Click($startAct); $btnStop.Add_Click($stopAct); $btnRestart.Add_Click($restartAct)
    $Window.FindName("ctxStart").Add_Click($startAct); $Window.FindName("ctxStop").Add_Click($stopAct); $Window.FindName("ctxRestart").Add_Click($restartAct)

    $serviceListView.Add_SelectionChanged({
        $s = $serviceListView.SelectedItem; $hasSel = $null -ne $s
        $btnStart.IsEnabled = $hasSel -and ($s.Status -eq "Stopped"); $btnStop.IsEnabled = $hasSel -and ($s.Status -eq "Running")
        $btnRestart.IsEnabled = $hasSel -and ($s.Status -eq "Running"); $btnDelete.IsEnabled = $hasSel
    })

    $txtSearch.Add_TextChanged({ $script:SearchTimer.Stop(); $script:SearchTimer.Start() })
    $script:SearchTimer.Add_Tick({ $script:SearchTimer.Stop(); Update-UI })

    Update-UI
    $Window.ShowDialog() | Out-Null
} catch { [System.Windows.Forms.MessageBox]::Show("Fatal Error: $($_.Exception.Message)") }
    #endregion main-exec