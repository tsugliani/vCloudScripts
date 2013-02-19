# 
# Name: Show-vCloudStats.ps1
# Version: 1.1
# Author: Timo Sugliani <timo.sugliani@gmail.com>
# Date: 22/01/2013
#
# Based on Show-PercentageGraph from vmdude available here :
# http://www.vmdude.fr/en/scripts-en/cluster-load-in-powercli/
# Added a Show-GuaranteeGraph function that adds more ascii goodness :-)
#

function Show-PercentageGraph([int]$percent, [int]$maxSize=20) {

    # Default values
    $warningThreshold   = 60         # percent
    $alertThreshold     = 80         # percent
    $textcolor          = "green"    # default text color
    
    [string]$bloc       = [char]9632 # Ascii code for block
    [string]$fill       = "-"        # Ascii code for smaller "-" [char]9472
    
    # save percentage, as values can be over 100% depending the calculation
    $percentage = $percent
    
    # to avoid the drawing the bar over 100%.
    if ($percent -gt 100) { 
        $percent = 100
    }
    
    write-host -nonewline " [ " 
  
    # calculate the bar value
    $barValue = [math]::floor($percent*$maxSize/100)
    
    # draw the bar using $bloc ascii char & color 
    for ($i=1; $i -le $barValue; $i++) {
        if ($i -le ($warningThreshold*$maxSize/100)) { 
            write-host -nonewline -foregroundcolor green $bloc
            $textcolor = "Green"
        }
        elseif ($i -le ($alertThreshold*$maxSize/100)) { 
            write-host -nonewline -foregroundcolor yellow $bloc
            $textcolor = "Yellow"
        }
        else {
            write-host -nonewline -foregroundcolor red $bloc
            $textcolor = "Red"
        }
    }
    
    # calculate the bar filler
    $traitValue = $maxSize-$barValue
    
    # draw the filler after bar
    for ($i=1; $i -le $traitValue; $i++) { 
        write-host -nonewline "$fill" 
    }
        
    # Dirty way of indenting ... works until 999%
    # I have no idea howto format this in PSH (%3d for example sprintf)
    if ($percentage -lt 10) { 
        write-host -nonewline " ]   " 
        write-host -nonewline -ForegroundColor $textcolor "$percentage%" 
    } 
    elseif ($percentage -ge 100) {
        write-host -nonewline " ] " 
        write-host -nonewline -ForegroundColor $textcolor "$percentage%" 
    }
    else { 
        write-host -nonewline " ]  " 
        write-host -nonewline -ForegroundColor $textcolor "$percentage%" 
    }
}

function Show-GuaranteeGraph([int]$percent, [int]$maxSize=20) {
    # Default values
    [string]$lbloc      = [char]9492 # Left Line Bloc
    [string]$rbloc      = [char]9496 # Right Line Bloc
    [string]$bloc       = [char]9472 # Ascii code for line   

    $warningThreshold   = 60         # percent
    $alertThreshold     = 80         # percent

    $textcolor          = "Green"
    $color              = "DarkYellow"
    
    # save percentage, as values can be over 100% depending the scalculation
    $percentage = $percent
    
    if ($percent -gt 100) { 
        $percent = 100
    }

    # calculate the bar value
    $barValue = [math]::floor($percent*$maxSize/100)
    
    # Display the left guide
    Write-Host -nonewline -ForegroundColor $color "   $lbloc" 

    # draw the guide horizontal line using $bloc ascii char & color 
    for ($i=1; $i -le ($barValue-2); $i++) {
        Write-Host -nonewline -foregroundcolor $color $bloc
    }

    # Display the right guide
    write-host -nonewline -foregroundcolor $color $rbloc

    
    # calculate the bar filler (I don't know how to do a sprint %3d equivalent)
    # Using 2 blocs here for lbloc / rbloc, so filler needs to be adjusted.
    if ($percent -lt 5) {
        $traitValue = $maxSize-($barValue+2)
    } 
    elseif ($percent -ge 5 -and $percent -lt 10) {
        $traitValue = $maxSize-($barValue+1)
    } 
    else {
        $traitValue = $maxSize-$barValue   
    }
   
    # draw the filler after bar
    for ($i=1; $i -le $traitValue; $i++) { 
        Write-Host -nonewline " " 
    }
        
    if ($percentage -ge $warningThreshold -and $percentage -le $alertThreshold) {
        $textcolor = "Yellow"
    }
    elseif ($percentage -gt $alertThreshold)
    {
        $textcolor = "Red"
    }


    # Dirty way of indenting ... works until 999%
    # I have no idea howto format this in PSH (%3d for example sprintf)
    if ($percentage -lt 10) { 
        Write-Host -nonewline -ForegroundColor $textcolor "     $percentage%" 
    }
    elseif ($percentage -ge 100) {
        Write-Host -nonewline -ForegroundColor $textcolor "   $percentage%"  
    }
    else { 
        Write-Host -nonewline -ForegroundColor $textcolor "    $percentage%" 
    }
}

function Show-StorageStats($storageUsed, $Storageallocated, $StorageTotal) {
    # Show storage stats
    if ($StorageAllocated -eq 0) {
        Show-PercentageGraph($StorageUsed/$StorageTotal*100)
        Write-Host -nonewline " Storage Used | PvDC Total Storage (No Quota) "
        Write-Host "- [$($StorageUsed)GB | $($StorageTotal)GB]"
    }
    else {
        Show-PercentageGraph($StorageUsed/$StorageAllocated*100)
        Write-Host -nonewline " Storage Used | Allocated Quota "
        Write-Host "- [$($StorageUsed)GB | $($StorageAllocated)GB]"
    }
}

function Show-ExternalNetworkStats() {
    $extNetworks = Get-ExternalNetwork 
    write-host "External Networks"
    Write-Host ""
    foreach($extNet in $extNetworks) {
        Show-PercentageGraph($extNet.UsedIpCount/$extNet.TotalIpCount*100)
        Write-Host " IP Allocation for $($extNet)"
    }
}

function Show-ProviderVDCStats($ProviderVDC) {
    
    Write-Host ""
    Write-Host " Provider VDC : $ProviderVDC"
    Write-Host ""
    
    $CpuAllocated       = [math]::Round($ProviderVDC.CpuAllocatedGHz, 2)
    $CpuUsed            = [math]::Round($ProviderVDC.CpuUsedGHz, 2)
    $CpuTotal           = [math]::Round($ProviderVDC.CpuTotalGHz, 2)
    
    $MemAllocated       = [math]::Round($ProviderVDC.MemoryAllocatedGB, 2)
    $MemUsed            = [math]::Round($ProviderVDC.MemoryUsedGB, 2)
    $MemTotal           = [math]::Round($ProviderVDC.MemoryTotalGB, 2)
    
    $StorageAllocated   = [math]::Round($ProviderVDC.StorageAllocatedGB, 2)
    $StorageUsed        = [math]::Round($ProviderVDC.StorageUsedGB, 2)
    $StorageTotal       = [math]::Round($ProviderVDC.StorageTotalGB, 2)
    
    Write-Host ""
    Write-Host " >> Resources Used & Allocated vs Total"
    Write-Host ""
    
    Show-PercentageGraph($CpuUsed/$CpuTotal*100)
    Write-Host " CPU Used | Total [$($CpuUsed)Ghz | $($CpuTotal)Ghz]"
    Show-GuaranteeGraph($CpuAllocated/$CpuTotal*100)
    Write-Host " CPU Allocated [$($CpuAllocated)Ghz]"
   
    
    Show-PercentageGraph($MemUsed/$MemTotal*100)
    Write-Host " MEM Used | Total [$($MemUsed)GB | $($MemTotal)GB]"
    Show-GuaranteeGraph($MemAllocated/$MemTotal*100)
    Write-Host " MEM Allocated [$($MemAllocated)GB]"
  
    Show-PercentageGraph($StorageUsed/$StorageTotal*100)
    Write-Host " Storage Used | Total [$($StorageUsed)GB | $($StorageTotal)GB]" 
    Show-GuaranteeGraph($StorageAllocated/$StorageTotal*100)
    Write-Host " Storage Allocated [$($StorageAllocated)GB]"
    
}

function Show-AllocationModelPAYGStats($OrganizationVDC, $ProviderVDC) {
    # Provider VDC Total Capacity
    $CpuTotal           = [math]::Round($ProviderVDC.CpuTotalGHz, 2)
    $MemTotal           = [math]::Round($ProviderVDC.MemoryTotalGB, 2)
    $StorageTotal       = [math]::Round($ProviderVDC.StorageTotalGB, 2)

    # Organization VDC Stats
    $CpuUsed            = [math]::Round($OrganizationVDC.CpuUsedGhz, 2)
    $CpuGuarantee       = $OrganizationVDC.CpuGuaranteedPercent
    $MemUsed            = [math]::Round($OrganizationVDC.MemoryUsedGB, 2)
    $MemGuarantee       = $OrganizationVDC.MemoryGuaranteedPercent
    $StorageUsed        = [math]::Round($OrganizationVDC.StorageUsedGB, 2)
    $StorageAllocated   = [math]::Round($OrganizationVDC.StorageLimitGB, 2)

    # Based on the Provider VDC stats as no allocation is done at the OvDC lvl
    # Maybe using used resources / sum(vApps allocated in vDC) would be better ?
    # TODO: Add vCPU Speed limit 
    Write-Host ""
    Write-Host "    * Resources Used vs Provider VDC Total"
    Write-Host ""
  
    Write-Host -nonewline "    " 
    Show-PercentageGraph($CpuUsed/$CpuTotal*100)
    Write-Host " CPU Used | Total [$($CpuUsed)Ghz|$($CpuTotal)Ghz]"

    Write-Host -nonewline "    " 
    Show-PercentageGraph($MemUsed/$MemTotal*100)
    Write-Host " MEM Used | Total [$($MemUsed)GB|$($MemTotal)GB]"
    
    Write-Host -nonewline "    " 
    Show-StorageStats $StorageUsed $StorageAllocated $StorageTotal
    #Write-Host -nonewline "    "
    #Show-StorageStats $StorageUsed 0 $StorageTotal
}

function Show-AllocationModelAllocationStats($OrganizationVDC, $ProviderVDC) {

    # Provider VDC Total Capacity
    $CpuTotal           = [math]::Round($ProviderVDC.CpuTotalGHz, 2)
    $MemTotal           = [math]::Round($ProviderVDC.MemoryTotalGB, 2)
    $StorageTotal       = [math]::Round($ProviderVDC.StorageTotalGB, 2)

    # Organization VDC Stats
    $CpuUsed            = [math]::Round($OrganizationVDC.CpuUsedGhz, 2)
    $CpuAllocated       = [math]::Round($OrganizationVDC.CpuAllocationGhz, 2)
    # check this, and add it into the calculations if $CpuUsed isn't valid
    $CpuSpeedLimit      = [math]::Round($OrganizationVDC.CpuSpeedLimitGhz, 2)
    $CpuGuarantee       = $OrganizationVDC.CpuGuaranteedPercent
    $CpuGuaranteeTotal  = [math]::Round($CpuAllocated*$CpuGuarantee/100, 2)
    $MemUsed            = [math]::Round($OrganizationVDC.MemoryUsedGB, 2)
    $MemAllocated       = [math]::Round($OrganizationVDC.MemoryAllocationGB, 2)
    $MemGuarantee       = $OrganizationVDC.MemoryGuaranteedPercent
    $MemGuaranteeTotal  = [math]::Round($MemAllocated*$MemGuarantee/100, 2)
    $StorageUsed        = [math]::Round($OrganizationVDC.StorageUsedGB, 2)
    $StorageAllocated   = [math]::Round($OrganizationVDC.StorageLimitGB, 2)

    Write-Host ""
    Write-Host "    * Resources Used vs Org VDC Allocatation"
    Write-Host ""
    Write-Host -nonewline "    " 
    Show-PercentageGraph($CpuUsed/$CpuAllocated*100)
    Write-Host " CPU Used | Total [$($CpuUsed)Ghz | $($CpuAllocated)Ghz]" 
    Write-Host -nonewline "    " 
    Show-GuaranteeGraph($CpuGuarantee)
    Write-Host " Guarantee"
    
    
    Write-Host -nonewline "    " 
    Show-PercentageGraph($MemUsed/$MemAllocated*100)
    Write-Host " MEM Used | Total [$($MemUsed)GB | $($MemAllocated)GB]" 
    Write-Host -nonewline "    "
    Show-GuaranteeGraph($MemGuarantee)
    Write-Host " Guarantee"
    
    Write-Host -nonewline "    " 
    Show-StorageStats $StorageUsed $StorageAllocated $StorageTotal
    
    
    Write-Host ""
    Write-Host "    * Resources Used & Allocated vs Provider VDC Total"
    Write-Host ""
    Write-Host -nonewline "    " 
    Show-PercentageGraph($CpuUsed/$CpuTotal*100)
    Write-Host " CPU Used | Total [$($CpuUsed)Ghz | $($CpuTotal)Ghz]"
    Write-Host -nonewline "    "
    Show-GuaranteeGraph($CpuGuaranteeTotal/$CpuTotal*100)
    Write-Host " Guarantee [$($CpuGuaranteeTotal)Ghz]"

    
    Write-Host -nonewline "    " 
    Show-PercentageGraph($MemUsed/$MemTotal*100)
    Write-Host " MEM Used | Total [$($MemUsed)GB | $($MemTotal)GB]" 
    Write-Host -nonewline "    "
    
    Show-GuaranteeGraph($MemGuaranteeTotal/$MemTotal*100)
    Write-Host " Guarantee [$($MemGuaranteeTotal)GB]"
    
    Write-Host -nonewline "    " 
    Show-StorageStats $StorageUsed 0 $StorageTotal
}

function Show-AllocationModelReservationStats($OrganizationVDC, $ProviderVDC) {

    # Provider VDC Total Capacity
    $CpuTotal           = [math]::Round($ProviderVDC.CpuTotalGHz, 2)
    $MemTotal           = [math]::Round($ProviderVDC.MemoryTotalGB, 2)
    $StorageTotal       = [math]::Round($ProviderVDC.StorageTotalGB, 2)

    # Organization VDC Stats
    $CpuUsed            = [math]::Round($OrganizationVDC.CpuUsedGhz, 2)
    $CpuAllocated       = [math]::Round($OrganizationVDC.CpuAllocationGhz, 2)
    $CpuGuarantee       = $OrganizationVDC.CpuGuaranteedPercent # 100 in RP
    $MemUsed            = [math]::Round($OrganizationVDC.MemoryUsedGB, 2)
    $MemAllocated       = [math]::Round($OrganizationVDC.MemoryAllocationGB, 2)
    $MemGuarantee       = $OrganizationVDC.MemoryGuaranteedPercent # 100 in RP
    $StorageUsed        = [math]::Round($OrganizationVDC.StorageUsedGB, 2)
    $StorageAllocated   = [math]::Round($OrganizationVDC.StorageLimitGB, 2)

    Write-Host ""
    Write-Host "    * Resources Used vs Org VDC Allocatation"
    Write-Host ""
    Write-Host -nonewline "    " 
    Show-PercentageGraph($CpuUsed/$CpuAllocated*100)
    Write-Host " CPU Used | Allocated [$($CpuUsed)Ghz | $($CpuAllocated)Ghz]" 
    Write-Host -nonewline "    " 
    Show-GuaranteeGraph($CpuGuarantee)
    Write-Host " Guarantee [$($CpuAllocated)Ghz]"

    Write-Host -nonewline "    " 
    Show-PercentageGraph($MemUsed/$MemAllocated*100)
    Write-Host " MEM Used | Allocated [$($MemUsed)GB | $($MemAllocated)GB]" 
    Write-Host -nonewline "    " 
    Show-GuaranteeGraph($MemGuarantee)
    Write-Host " Guarantee [$($MemAllocated)GB]"

    Write-Host -nonewline "    " 
    Show-StorageStats $StorageUsed $StorageAllocated $StorageTotal
       
    Write-Host ""
    Write-Host "    * Resources Used & Allocated vs Provider VDC Total"
    Write-Host ""
    Write-Host -nonewline "    " 
    Show-PercentageGraph($CpuUsed/$CpuTotal*100)
    Write-Host " CPU Used | Total [$($CpuUsed)Ghz | $($CpuTotal)Ghz]" 
    Write-Host -nonewline "    " 
    Show-GuaranteeGraph($CpuAllocated/$CpuTotal*100)
    Write-Host " Guarantee [$($CpuAllocated)Ghz]" 
    
    
    Write-Host -nonewline "    " 
    Show-PercentageGraph($MemUsed/$MemTotal*100)
    Write-Host " MEM Used | Total [$($MemUsed)GB | $($MemTotal)GB]" 
    Write-Host -nonewline "    " 
    Show-GuaranteeGraph($MemAllocated/$MemTotal*100)
    Write-Host " Guarantee [$($MemAllocated)GB]" 
    
    Write-Host -nonewline "    " 
    Show-StorageStats $StorageUsed 0 $StorageTotal
    Write-Host ""
}

function Show-OrganizationVDCStats($OrganizationVDC, $ProviderVDC) {

    $AllocationModel = $OrganizationVDC.AllocationModel.toString()
    $Organization    = $OrganizationVDC.Org.Name
    Write-Host ""
    Write-Host -NoNewline "  -> Organization VDC:$($OrganizationVDC)"
    Write-Host -NoNewline " - Allocation Model:$($AllocationModel)"
    Write-Host -NoNewline " - Organization:$($Organization)"
    Write-Host ""
    
    # Check Allocation Model and display accordingly
    switch ($AllocationModel) {
        "PayAsYouGo" {
            Show-AllocationModelPAYGStats $OrganizationVDC $ProviderVDC
        }
        "AllocationPool" {
            Show-AllocationModelAllocationStats $OrganizationVDC $ProviderVDC
        }
        "ReservationPool" {
            Show-AllocationModelReservationStats $OrganizationVDC $ProviderVDC
        }
    }
}

# Connect to vCloud Director as System Administrator
Connect-CIServer 

# Display some vCloud External Network stats
Show-ExternalNetworkStats

# Fetch Provider VDCs
$PvDCs = Get-ProviderVdc 

# Loop through each Provider VDC
foreach($PvDC in $PvDCs) {
    # Display some Provider VDC Stats
    Show-ProviderVDCStats $PvDC 
    
    # Fetch All Organization VDC in the current Provider VDC.
    $OvDCs = Get-OrgVdc -ProviderVdc $PvDC
    
    foreach ($OvDC in $OvDCs) {
        #Display some Organization VDC Stats
        Show-OrganizationVDCStats $OvDC $PvDC
    }
}

Disconnect-CIServer * -confirm:$false
