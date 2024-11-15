
# Flame

A simple PowerShell tool to temporarily prevent your Windows system and display from going to sleep.

## Overview

`Flame` is a lightweight PowerShell function that temporarily prevents your system from going to sleep—ideal for long-running tasks, presentations, or any situation where you don't want your computer to interrupt you. `Flame` only overrides sleep settings while it’s running and restores your system’s default behavior once stopped. You can think of this as a lean version of the `caffeinate` command on macOS.

## Features

- **Blocks System Sleep**: Keeps your system and display awake as needed.
- **Simple Control**: Start with one command and stop by pressing Escape.
- **Temporary Override**: Respects your original sleep settings once stopped.

## Prerequisites

- **PowerShell Execution Policy**: The script requires setting the execution policy to allow local scripts. You may need to adjust your execution policy to run the script.
- **Administrator Privileges**: You *may* need to run PowerShell as **Administrator** to modify the execution policy.

## Installation

### Step 1: Download the Script

Save the `Flame.ps1` script to a convenient location on your computer.

### Step 2: Set Execution Policy (If Needed)

The script attempts to set the execution policy for the current user to `RemoteSigned`, which allows running local scripts. If you encounter any issues, you may need to set it manually:

1. Open PowerShell **as Administrator**.
2. Run the following command:

   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

   - **Note**: Changing the execution policy affects script execution for the current user. Ensure you understand the implications or consult your system administrator if on a managed system.

### Step 3: Run the Setup Script

1. Open PowerShell **as Administrator** (if not already open).
2. Navigate to the directory where you saved `Flame.ps1`:

   ```powershell
   cd path\to\your\script
   ```

3. Run the script:

   ```powershell
   .\Flame.ps1
   ```

   This will:

   - Create or back up your existing PowerShell profile.
   - Add the `Flame` function to your profile.
   - Attempt to set the execution policy to allow scripts (if not already set).
   - **Note**: If the `Flame` command is not recognized after running the script, you may need to manually reload your PowerShell profile or restart PowerShell. See the [Troubleshooting](#troubleshooting) section below.

## Usage

### Prevent Sleep

To start preventing your system and display from sleeping, run:

```powershell
Flame
```

The terminal will display:

```
[info] System and display sleep prevented. Press Escape to stop.
```

**Press the Escape key** to stop and restore normal sleep behavior.

### Get Help

For usage instructions and available options, run:

```powershell
Flame -Help
```

### Customize Key Check Interval (Optional)

By default, `Flame` checks for the Escape key press every second. You can adjust this interval (in seconds) using the `-IntervalSeconds` parameter:

```powershell
Flame -IntervalSeconds 5
```

## How It Works

`Flame` uses the Windows API function `SetThreadExecutionState` to temporarily override your system’s sleep settings. When you run `Flame`, it signals the system to stay awake. Once you stop `Flame` (by pressing Escape), it signals the system to resume its normal sleep behavior.

- **Start Prevention**: Calls `SetThreadExecutionState` with flags to keep the system and display awake.
- **Stop Prevention**: Calls `SetThreadExecutionState` to clear the flags, allowing normal sleep behavior.

## Safety and Privacy

- **No Permanent Changes**: The script makes no permanent changes to your system's power settings.
- **Open Source**: You can review the code to ensure it meets your requirements.

## Troubleshooting

### Flame Command Not Found

If you receive an error stating that `Flame` is not recognized as a cmdlet, function, script file, or operable program, you may need to manually reload your PowerShell profile or restart PowerShell.

#### Option 1: Manually Reload Your Profile

In your PowerShell session, run:

```powershell
. $PROFILE
```

- **Note**: There is a dot and a space before `$PROFILE`. This command reloads your profile, making the `Flame` function available.

#### Option 2: Restart PowerShell

- Close your current PowerShell session.
- Open a new PowerShell window (you don't need Administrator privileges for this step).
- Try running `Flame` again.

### Execution Policy Errors

If you encounter an error like:

```
File cannot be loaded because running scripts is disabled on this system.
```

This means your execution policy prevents running scripts. To fix this:

1. Open PowerShell **as Administrator**.
2. Run:

   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. Close and reopen PowerShell.

### Administrator Privileges

If you are unable to set the execution policy or run the script due to permission issues, you may need to run PowerShell as **Administrator**:

- **Windows 10/11**:

  1. Click the **Start** button.
  2. Type **PowerShell**.
  3. Right-click **Windows PowerShell** and select **Run as administrator**.

