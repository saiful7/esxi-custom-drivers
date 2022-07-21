##############################################################################################
#     ____________  __ _    _                               __          _ __    __         
#    / ____/ ___/ |/ /(_)  (_)___ ___  ____ _____ ____     / /_  __  __(_) /___/ /__  _____
#   / __/  \__ \|   // /  / / __ `__ \/ __ `/ __ `/ _ \   / __ \/ / / / / / __  / _ \/ ___/
#  / /___ ___/ /   |/ /  / / / / / / / /_/ / /_/ /  __/  / /_/ / /_/ / / / /_/ /  __/ /    
# /_____//____/_/|_/_/  /_/_/ /_/ /_/\__,_/\__, /\___/  /_.___/\__,_/_/_/\__,_/\___/_/     
#                                         /____/                                           
##############################################################################################
# Author: Jonas Werner
# Modified By: SAiful Islam Rokon Akon
# GitHub URL: https://github.com/saiful7/esxi-custom-drivers
# Video from the Author: https://youtu.be/DbqZI1V6TK4
# Version: 0.7.1
##############################################################################
# Prerequisites
# Only needs to be executed once, not every time an image is built
# Must be Administrator to execute prerequisites
#
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
Install-Module -Name VMware.PowerCLI -SkipPublisherCheck
##############################################################################

##############################################################################
# Get the base ESXi image
##############################################################################
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false

# Fetch ESXi image depot
Add-EsxSoftwareDepot https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml

# List avilable profiles if desired (show what images are available for download)
#Get-EsxImageProfile

# Download desired image
Export-ESXImageProfile -ImageProfile "ESXi-6.7.0-8169922-standard" -ExportToBundle -filepath ESXi-6.7.0-8169922-standard.zip

# Remove the depot
Remove-EsxSoftwareDepot https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml

# Add default ESXi image files to installation media
Add-EsxSoftwareDepot .\ESXi-6.7.0-8169922-standard.zip


##############################################################################
# Download additional drivers (can be done via browser too, either is fine) 
##############################################################################

# Get Realtek RTL8111/8168/8411 network driver 
Invoke-WebRequest -Uri http://vibsdepot.v-front.de/depot/bundles/net55-r8168-8.045a-napi-offline_bundle.zip -OutFile esxi-net55-r8168-8.045a-napi-offline_bundle.zip

# Get Realtek RTL8169 network driver 
Invoke-WebRequest -Uri https://vibsdepot.v-front.de/depot/bundles/net51-r8169-6.011.00-2vft.510.0.0.799733-offline_bundle.zip -OutFile esxi-net51-r8169-6.011.00-2vft.510.0.0.799733-offline_bundle.zip

##############################################################################
# Add the additional drivers
##############################################################################

#  Get Realtek RTL8111/8168/8411 network driver
Add-EsxSoftwareDepot .\esxi-net55-r8168-8.045a-napi-offline_bundle.zip

# Get  Realtek RTL8169 network driver 
Add-EsxSoftwareDepot .\esxi-net51-r8169-6.011.00-2vft.510.0.0.799733-offline_bundle.zip

##############################################################################
# Create new installation media profile and add the additional drivers to it
##############################################################################

# Create new, custom profile
New-EsxImageProfile -CloneProfile "ESXi-6.7.0-8169922-standard" -name "ESXi-6.7.0-8169922-standard-SAASGLOBAL.NET" -Vendor "saasglobal.net"

#############
Set-EsxImageProfile -Name ESXi-6.7.0-8169922-standard-SAASGLOBAL.NET -AcceptanceLevel CommunitySupported 
#############

# Optionally remove existing driver package (example for ne1000)
#Remove-EsxSoftwarePackage -ImageProfile "ESXi-6.7.0-8169922-standard-SAASGLOBAL.NET" -SoftwarePackage "ne1000"

# Add Realtek RTL8111/8168/8411 network driver
Add-EsxSoftwarePackage -ImageProfile "ESXi-6.7.0-8169922-standard-SAASGLOBAL.NET" -SoftwarePackage "net55-r8168"

# Add  Realtek RTL8169 network driver
Add-EsxSoftwarePackage -ImageProfile "ESXi-6.7.0-8169922-standard-SAASGLOBAL.NET" -SoftwarePackage "net51-r8169"

##############################################################################
# Export the custom profile to ISO
##############################################################################
Export-ESXImageProfile -ImageProfile "ESXi-6.7.0-8169922-standard-SAASGLOBAL.NET" -ExportToIso -filepath ESXi-6.7.0-8169922-standard-SAASGLOBAL.NET.iso

## saasglobal.net