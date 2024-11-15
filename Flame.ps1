# ------------------------ Start of Script ------------------------

# Function to set up the 'Flame' tool
function Setup-Flame {
    # Define the path to the main PowerShell profile
    $MainProfileDir = [System.IO.Path]::Combine($env:USERPROFILE, "Documents", "WindowsPowerShell")
    $MainProfilePath = [System.IO.Path]::Combine($MainProfileDir, "Microsoft.PowerShell_profile.ps1")

    # Ensure the profile directory exists
    if (-not (Test-Path -Path $MainProfileDir)) {
        try {
            New-Item -ItemType Directory -Path $MainProfileDir -Force
            Write-Host "[info] Created profile directory at $MainProfileDir"
        } catch {
            Write-Host "[error] Failed to create profile directory: $_"
            return
        }
    }

    # Ensure the profile file exists
    if (-not (Test-Path -Path $MainProfilePath)) {
        try {
            New-Item -ItemType File -Path $MainProfilePath -Force
            Write-Host "[info] Created profile file at $MainProfilePath"
        } catch {
            Write-Host "[error] Failed to create profile file: $_"
            return
        }
    }

    # Define the 'Flame' function content
    $FunctionContent = @'
# ------------------------ Flame Function ------------------------

function Flame {
    param(
        [switch]$Help,
        [int]$IntervalSeconds = 1
    )

    if ($Help) {
        Write-Host "Usage: Flame [options]"
        Write-Host "  -Help               Show this help message"
        Write-Host "  -IntervalSeconds    Specify interval in seconds between key checks (default is 1)"
        Write-Host "                       Example: Flame -IntervalSeconds 5"
        return
    }

    if ($IntervalSeconds -le 0) {
        Write-Host "[error] IntervalSeconds must be a positive integer. Defaulting to 1 second."
        $IntervalSeconds = 1
    }

    try {
        # Ensure SetThreadExecutionState is defined only once
        if (-not ([System.Management.Automation.PSTypeName]"Win32SetExecState").Type) {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32SetExecState {
    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern uint SetThreadExecutionState(uint esFlags);
}
"@
        }

        # Define flags with decimal values
        $ES_CONTINUOUS       = [UInt32]2147483648  # 0x80000000
        $ES_SYSTEM_REQUIRED  = [UInt32]1           # 0x00000001
        $ES_DISPLAY_REQUIRED = [UInt32]2           # 0x00000002
        $CombinedFlags       = $ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED -bor $ES_DISPLAY_REQUIRED

        $SetExecState = [Win32SetExecState]
        try {
            # Set the execution state to prevent sleep and display turn-off
            $Result = $SetExecState::SetThreadExecutionState($CombinedFlags)
            if ($Result -eq 0) {
                throw "SetThreadExecutionState failed. Error code: $(Get-LastError)"
            }

            Write-Host "[info] System and display sleep prevented. Press Escape to stop."

            # Loop to check for Escape key press
            while ($true) {
                if ([System.Console]::KeyAvailable) {
                    $key = [System.Console]::ReadKey($true)
                    if ($key.Key -eq 'Escape') {
                        break
                    }
                }
                Start-Sleep -Seconds $IntervalSeconds
            }
        }
        finally {
            # Clear the execution state to allow the system to sleep normally
            $SetExecState::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null
            Write-Host "[info] Flame stopped. Sleep behavior restored."
        }
    } catch {
        Write-Host "[error] An error occurred: $_"
    }
}

# ------------------------ End of Flame Function ------------------------
'@

    # Write the function content to the main profile
    try {
        Add-Content -Path $MainProfilePath -Value $FunctionContent
        Write-Host "[info] 'Flame' function added to your profile at $MainProfilePath"
    } catch {
        Write-Host "[error] Failed to write to profile: $_"
        return
    }

    # Attempt to set the execution policy to RemoteSigned for current user
    try {
        $ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
        if ($ExecutionPolicy -ne 'RemoteSigned' -and $ExecutionPolicy -ne 'Unrestricted') {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
            Write-Host "[info] Execution policy set to RemoteSigned for CurrentUser"
        } else {
            Write-Host "[info] Execution policy is already set to $ExecutionPolicy"
        }
    } catch {
        Write-Host "[warning] Failed to set execution policy: $_"
        Write-Host "[info] You may need to manually set the execution policy to run scripts."
    }

    # Reload the main profile
    try {
        . $MainProfilePath
        Write-Host "[info] Profile reloaded. 'Flame' function is now available."
    } catch {
        Write-Host "[error] Failed to reload profile: $_"
    }
}

# Run the Setup-Flame function
Setup-Flame

# ------------------------ End of Script ------------------------
