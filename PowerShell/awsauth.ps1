# *********************************************************************
# Script: awsauth.ps1
# Author: Richard Knechtel
# Date: 06/04/2021
# Description: This will get the AWS STS Session Token and set
#              necessary environmetn variables.
#
# Parameters: MFA Token Code
# Note: This comes from:
#  1Password --> One-Time Password
#  OR
#  Keepass --> <Key Name> --> KeeOtp2 --> Copy TOTP
#
# Note: You must have active AWS Access keys for this to work and MFA enabled and setup.
#
# Note: You MUST have mfa_serial set in your .aws/config file.
# Example:
# [default]
# region = us-east-1
# output = json
# mfa_serial=arn:aws:iam::123456789012:mfa/MyMFADevice
#
# Note: Requires program: jq
#       sudo apt-get install -y jq
#
#       Requires AWS CLI
#       Install on Windows:
#       https://awscli.amazonaws.com/AWSCLIV2.msi
#
#       Install AWS CLI in Linux:
#       curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
#       unzip awscliv2.zip
#       sudo ./aws/install
#
#
# Example Call (PowerShell)
# awsauth.ps1 <TOKEN_CODE>
#
# Note: TOKEN_CODE Comes from either:
# From Keepass --> <Key Name> --> KeeOtp2 --> Copy TOTP
# From 1Password <Key Name> --> One-=Time Password
# From your 2FA/MFA app.
#
# *********************************************************************

# *********************************************************************
# Note: 
# Replace: 123456789012
# With your AWS Account Number
# *********************************************************************

# Display current user
Write-Host ""
Write-Host "Running as user: $env:USERNAME"
Write-Host ""

# Get parameters
# $args[0] is equivalent to $1 in bash
$TOKEN_CODE = $args[0]
# Write-Host "TOKEN_CODE = $TOKEN_CODE"

function usage {
    Write-Host "[USAGE]: awsauth.ps1 arg1"
    Write-Host "arg1 = Token Code (Example: 123456)"
    Write-Host "NOTE: Requires AWS CLI and program jq!"
	Write-Host "NOTE2: You must have active AWS Access keys for this to work and MFA enabled and setup."
    Write-Host "NOTE3: You MUST have mfa_serial set in your .aws/config file - see script for example."
}

# Check if we got ALL parameters
if ($args.Count -eq 0 -and -not $TOKEN_CODE) {
    usage
    return 1
}

$OS_TYPE = $env:OSTYPE
$UNSUPPORTED_OS = 0


function checkostype {
    if ($env:OSTYPE -like "linux-gnu*") {
        # Linux
        $OS_TYPE = "linux"
    } elseif ($env:OSTYPE -like "darwin*") {
        # Mac OSX
        $OS_TYPE = "mac"
    } elseif ($env:OSTYPE -eq "cygwin") {
        # POSIX compatibility layer and Linux environment emulation for Windows
        $OS_TYPE = "cygwin"
    } elseif ($env:OSTYPE -eq "msys") {
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        $OS_TYPE = "windows"
    } elseif ($env:OS -eq "win32") {
        $OS_TYPE = "windows"
    } elseif ($env:OS -eq "Windows_NT") {
        $OS_TYPE = "windows"
    } elseif ([System.Environment]::OSVersion.Platform -eq "Win32NT") {
        Write-Host "OS Type is Windows"
        $OS_TYPE = "windows"
    } elseif ($env:OSTYPE -like "freebsd*") {
        # FreeBSD
        $OS_TYPE = "freebsd"
    } else {
        # Unknown.
        $OS_TYPE = "unknown"
    }

    return $OS_TYPE
}


function checkforjq {
    <#
    .SYNOPSIS
    Check if jq is installed and install it if necessary based on the OS type.

    .NOTES
    Author: [Your Name]
    Date: [Current Date]
    #>

    # Set default values
	$UNSUPPORTED_OS = 0
    $IS_INSTALLED = "NULL"
    $SKIP_LIBJQL_CHECK = "no"
    $OS_TYPE = checkostype

    # Write-Host "OS Type = $OS_TYPE"

    if ($OS_TYPE -eq "linux") {
        $IS_INSTALLED = (dpkg -l | Select-String "jq")
    }
    elseif ($OS_TYPE -eq "mac") {
        $IS_INSTALLED = (pkgutil --pkgs=.\+Xjq.\+)
    }
    elseif ($OS_TYPE -eq "windows") {
        $IS_INSTALLED = (winget list jq)
    }

    if (-not $IS_INSTALLED) {
        $INSTALL_JQ = "yes"
    }
    else {
        if ($IS_INSTALLED -like "*jq*") {
            Write-Host "jq is installed - continuing"
            $INSTALL_JQ = "no"
            $SKIP_LIBJQL_CHECK = "yes"
        }

        if (($SKIP_LIBJQL_CHECK -eq "no") -and ($IS_INSTALLED -notlike "*libjql*")) {
            $INSTALL_JQ = "yes"
        }
    }

    # Check if JQ is installed, if not install it (based on OS Type)
    if ($INSTALL_JQ -eq "yes") {
        Write-Host "Required jq is not installed, installing"

        if ($OS_TYPE -eq "linux") {
            sudo apt install jq
        }
        elseif ($OS_TYPE -eq "mac") {
            brew install jq
        }
        elseif ($OS_TYPE -eq "windows") {
            # Note: This only works on:
            # WinGet the Windows Package Manager is available on Windows 11, modern versions of Windows 10, and Windows Server 2025 as a part of the App Installer.
            # Ref: https://learn.microsoft.com/en-us/windows/package-manager/winget/
            winget install jqlang.jq
        }
        else {
            # We are not running on a supported OS
            Write-Host "ALERT! This script does not support your OS yet. It only supports Ubuntu Linux, MAC OS and Windows. Exiting!"
            $UNSUPPORTED_OS = 1
        }
    }

    return $UNSUPPORTED_OS
}


# Requires program: jq
# Uncomment to check if you have jq installed, if not it will install for you (on Ubuntu)
# Note: Also picks up libjq1
Write-Host "Checking if required jq command is installed"
$UNSUPPORTED_OS = checkforjq

#Write-Host "Unsupoprted OS = $UNSUPPORTED_OS"

if ($UNSUPPORTED_OS -eq 0) {
	aws iam list-mfa-devices
    $MFA_SERIAL_NUMBER = (aws iam list-mfa-devices | jq -r .MFADevices[0].SerialNumber)
    $STS_CREDS = (aws sts get-session-token --serial-number "$MFA_SERIAL_NUMBER" --token-code "$TOKEN_CODE" --duration-seconds 43200)

    $env:AWS_MFA_SERIAL_NUMBER = $MFA_SERIAL_NUMBER
    $env:AWS_ACCESS_KEY_ID = ($STS_CREDS | jq -r .Credentials.AccessKeyId)
    $env:AWS_SECRET_ACCESS_KEY = ($STS_CREDS | jq -r .Credentials.SecretAccessKey)
    $env:AWS_SESSION_TOKEN = ($STS_CREDS | jq -r .Credentials.SessionToken)
} else {
    Write-Host "Exiting!"
}

# END
