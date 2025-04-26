# Caffeine PowerShell

A simple system tray utility that prevents your computer from going to sleep by simulating a Scroll Lock key press at regular intervals.

## Features

- Runs in the system tray with minimal resource usage
- Visual indicator shows active/inactive status
- Easy to enable/disable with a simple right-click menu
- Prevents screen timeout and sleep mode without changing system settings

## Installation

1. Download the latest release from the Releases section
2. Extract the zip file to a folder of your choice
3. Run `Caffeine.exe` directly - no installation required!

## Usage

- Right-click the tray icon to access the menu
- Select "Enable (Start)" to begin preventing sleep
- Select "Disable (Stop)" to allow normal sleep behavior
- The icon turns green when active, gray when inactive

## How It Works

This utility works by simulating a Scroll Lock key press every 60 seconds. This keeps your computer awake without affecting your work or changing any system settings.

## Building from Source

If you want to build the executable yourself:

1. Install the PS2EXE module from PowerShell Gallery:
   ```
   Install-Module -Name PS2EXE
   ```

2. Run the following command from PowerShell:
   ```
   Invoke-ps2exe `
     -InputFile "path\to\caffeine.ps1" `
     -OutputFile "path\to\Caffeine.exe" `
     -noConsole `
     -STA `
     -noOutput `
     -noError `
     -iconFile "path\to\green.ico"
   ```

## Files

- `caffeine.ps1` - PowerShell script source code
- `Caffeine.exe` - Compiled executable
- `green.ico` - Icon for active state
- `gray.ico` - Icon for inactive state

## Requirements

- Windows 7/8/10/11
- No additional dependencies required

## License

MIT License

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.