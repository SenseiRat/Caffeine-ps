try {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
    # Load assemblies directly - no void casting
} catch {
    # If that fails, try Add-Type as a fallback
    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
    } catch {
        # Display error and exit if all assembly loading methods fail
        [Console]::WriteLine("Failed to load required assemblies: $_")
        exit 1
    }
}

# Get the executable path more reliably
$executablePath = $null
try {
    $executablePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    $scriptDir = [System.IO.Path]::GetDirectoryName($executablePath)
} catch {
    # Fallback for PowerShell execution
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
    if ([string]::IsNullOrEmpty($scriptDir)) {
        $scriptDir = [System.Environment]::CurrentDirectory
    }
}

# Define icon paths
$greenIconPath = [System.IO.Path]::Combine($scriptDir, "green.ico")
$grayIconPath = [System.IO.Path]::Combine($scriptDir, "gray.ico")

# More robust icon loading function
function Load-Icon($path) {
    if ([string]::IsNullOrEmpty($path)) {
        throw "Icon path is null or empty"
    }
    
    if (-not [System.IO.File]::Exists($path)) {
        [System.Windows.Forms.MessageBox]::Show("Missing icon file: $path")
        return $null
    }
    
    try {
        # Use FileStream to load icon for better reliability
        $stream = New-Object System.IO.FileStream($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
        $icon = New-Object System.Drawing.Icon($stream)
        $stream.Close()
        return $icon
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to load icon: $path. Error: $_")
        return $null
    }
}

# Create tray icon with error handling
$trayIcon = New-Object System.Windows.Forms.NotifyIcon
try {
    $icon = Load-Icon $grayIconPath
    if ($icon -ne $null) {
        $trayIcon.Icon = $icon
    } else {
        # Create a default icon if the file can't be loaded
        $bitmap = New-Object System.Drawing.Bitmap(16, 16)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Gray)), 0, 0, 16, 16)
        $graphics.Dispose()
        $iconHandle = $bitmap.GetHicon()
        $trayIcon.Icon = [System.Drawing.Icon]::FromHandle($iconHandle)
    }
} catch {
    [System.Windows.Forms.MessageBox]::Show("Failed to set icon: $_")
    exit 1
}

$trayIcon.Text = "Scroll Lock Toggler"
$trayIcon.Visible = $true

# Create timer for scroll lock toggling
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 60000  # 60 seconds

$timer.Add_Tick({
    try {
        $shell = New-Object -ComObject WScript.Shell
        $shell.SendKeys('{SCROLLLOCK 2}')
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to send Scroll Lock keys: $_")
    }
})

# Helper function to set icon
function Set-Icon($iconPath) {
    try {
        $icon = Load-Icon($iconPath)
        if ($icon -ne $null) {
            $trayIcon.Icon = $icon
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to update icon: $_")
    }
}

function Start-ScrollLock {
    if ($timer.Enabled) {
        [System.Windows.Forms.MessageBox]::Show("Scroll Lock is already running.")
        return
    }
    $timer.Start()
    Set-Icon $greenIconPath
    [System.Windows.Forms.MessageBox]::Show("Scroll Lock toggler started.")
}

function Stop-ScrollLock {
    if (-not $timer.Enabled) {
        [System.Windows.Forms.MessageBox]::Show("Scroll Lock is not running.")
        return
    }
    $timer.Stop()
    Set-Icon $grayIconPath
    [System.Windows.Forms.MessageBox]::Show("Scroll Lock toggler stopped.")
}

function Exit-App {
    if ($timer.Enabled) {
        $timer.Stop()
    }
    $trayIcon.Visible = $false
    [System.Windows.Forms.Application]::Exit()
}

# Create context menu
$contextMenu = New-Object System.Windows.Forms.ContextMenu
$menuStart = New-Object System.Windows.Forms.MenuItem
$menuStart.Text = "Enable (Start)"
$menuStart.Add_Click({ Start-ScrollLock })

$menuStop = New-Object System.Windows.Forms.MenuItem
$menuStop.Text = "Disable (Stop)"
$menuStop.Add_Click({ Stop-ScrollLock })

$menuExit = New-Object System.Windows.Forms.MenuItem
$menuExit.Text = "Exit"
$menuExit.Add_Click({ Exit-App })

$contextMenu.MenuItems.Add($menuStart)
$contextMenu.MenuItems.Add($menuStop)
$contextMenu.MenuItems.Add($menuExit)
$trayIcon.ContextMenu = $contextMenu

# Use a synchronization context for GUI operations
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# Start the application message loop
[System.Windows.Forms.Application]::Run()