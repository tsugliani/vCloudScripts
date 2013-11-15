# 
# Name: Show-vCloudStatsHtml.ps1
# Version: 1.2
# Author: Timo Sugliani <timo.sugliani@gmail.com>
# Date: 19/05/2013
#
# Based on Show-vCloudStats, and changing the display into an HTML htmlFile
# for better portability on generated report.

# Credits to Catalin Rosu for the html/css progress bars. 
# http://www.red-team-design.com/stylish-css3-progress-bars
# Have been slightly modified to create guarantee bars under the progress bars.
#
# Changelog
#
# 15/11/2013 - Version 1.2
# Added a new feature:
# - Number of VMs running vs Total VMs at the Provider VDC level
#
# 06/02/2013 - Version 1.1
# Added some new features:
# - Number of networks used per Org VDC vs allocation of network
#   (Will be enabled at next PowerCLI release)
# - Number of VMs vs max allowed per Org VDC
#
# 05/18/2013 - Version 1.0
# Initial commit (Show-vCloudHtmlStats port)


function Html-Header() {

$htmlFile += 
'<html>
 <head>
    <title>vCloud Director Stats Report</title>
    <style>
        body {
            background: #222;
            width: 800px;
            margin: 0 auto;  
            font: 13px "trebuchet MS",Arial,Helvetica;
            color: #fafafa;
        }
    
        p {
            text-align: center;
            color: #fafafa;
            text-shadow: 0 1px 0 #111; 
        }
        
        h1 {
          font-size: 36px;
          clear: both;
        }
 
        h2 {
          font-size: 30px;
          clear: both;

        }
 
        h3 {
            font-size: 24px;
            line-height: 40px;
            clear: both;
            padding-top: 10px;
            text-transform: uppercase;
        }
         
        h4 {
            padding-top: 10px;
            font-size: 16px;
            line-height: 20px;
            clear: both;
        }

 
        h5 {
            font-size: 14px;
            line-height: 20px;
            clear: both;
            text-decoration: underline;
        }

        a {
            color: rgb(255, 204, 0);
            font-weight: 400;
            text-decoration: none;
        }

        /*---------------------------*/       

        .footer {
            clear: both;
            text-align: center;
            padding-top: 20px;
            padding-bottom: 20px;
        }

        .progress-bar {
            float: left;
            background-color: #1a1a1a;
            height: 20px;
            padding: 3px; 
            width: 250px;
            margin-bottom: 5px; 
            border-top-left-radius: 5px;
            border-top-right-radius: 5px;
            clear: both;
        }

        .progress-bar span {
            display: inline-block;
            height: 100%;
            background-color: #777;
            border-top-left-radius: 3px;
            border-top-right-radius: 3px;

            -moz-box-shadow: 0 1px 0 rgba(255, 255, 255, .5) inset;
            -webkit-box-shadow: 0 1px 0 rgba(255, 255, 255, .5) inset;
            box-shadow: 0 1px 0 rgba(255, 255, 255, .5) inset;
            -webkit-transition: width .4s ease-in-out;
            -moz-transition: width .4s ease-in-out;
            -ms-transition: width .4s ease-in-out;
            -o-transition: width .4s ease-in-out;
            transition: width .4s ease-in-out;      
        }

        .progress-bar span p {
            float: left;
            text-align: left;
            margin-left:  260px;
            margin-top: 1px;
            font: 12px "trebuchet MS", Arial, Helvetica;
            width: 500px;
            
        }

        .guarantee-bar {
            background-color: #1a1a1a;
            float: left;
            height: 10px;
            padding: 3px; 
            width: 250px;
            margin-bottom: 10px; /* This will contain the change for guarantee */
            margin-top: -10px;
            clear: both;
            border-bottom-left-radius: 3px;
            border-bottom-right-radius: 3px;
        }

        .guarantee-bar span p {
            float: left;
            text-align: left;
            margin-left:  260px;
            margin-top: -2px;
            font: 10px "trebuchet MS", Arial, Helvetica;
            width: 500px;
        }

        .guarantee-bar span {
            display: inline-block;
            height: 100%;
            background-color: #777;
            border-bottom-left-radius: 3px;
            border-bottom-right-radius: 3px;
            -webkit-transition: width .4s ease-in-out;
            -moz-transition: width .4s ease-in-out;
            -ms-transition: width .4s ease-in-out;
            -o-transition: width .4s ease-in-out;
            transition: width .4s ease-in-out;       
        }

        /*---------------------------*/         
        
        .blue span {
            background-color: #34c2e3;   
        }

        .orange span {
              background-color: #fecf23;
              background-image: -webkit-gradient(linear, left top, left bottom, from(#fecf23), to(#fd9215));
              background-image: -webkit-linear-gradient(top, #fecf23, #fd9215);
              background-image: -moz-linear-gradient(top, #fecf23, #fd9215);
              background-image: -ms-linear-gradient(top, #fecf23, #fd9215);
              background-image: -o-linear-gradient(top, #fecf23, #fd9215);
              background-image: linear-gradient(top, #fecf23, #fd9215);  
        }   

        .green span {
              background-color: #a5df41;
              background-image: -webkit-gradient(linear, left top, left bottom, from(#a5df41), to(#4ca916));
              background-image: -webkit-linear-gradient(top, #a5df41, #4ca916);
              background-image: -moz-linear-gradient(top, #a5df41, #4ca916);
              background-image: -ms-linear-gradient(top, #a5df41, #4ca916);
              background-image: -o-linear-gradient(top, #a5df41, #4ca916);
              background-image: linear-gradient(top, #a5df41, #4ca916);  
        }       

        .red span {
              background-color: #C9364F;
              background-image: -webkit-gradient(linear, left top, left bottom, from(#C9364F), to(#DE5269));
              background-image: -webkit-linear-gradient(top, #C9364F, #DE5269);
              background-image: -moz-linear-gradient(top, #C9364F, #DE5269);
              background-image: -ms-linear-gradient(top, #C9364F, #DE5269);
              background-image: -o-linear-gradient(top, #C9364F, #DE5269);
              background-image: linear-gradient(top, #C9364F, #DE5269);  
        }     
        
        /*---------------------------*/     
        
        .stripes span {
            -webkit-background-size: 30px 30px;
            -moz-background-size: 30px 30px;
            background-size: 30px 30px;         
            background-image: -webkit-gradient(linear, left top, right bottom,
                                color-stop(.25, rgba(255, 255, 255, .15)), color-stop(.25, transparent),
                                color-stop(.5, transparent), color-stop(.5, rgba(255, 255, 255, .15)),
                                color-stop(.75, rgba(255, 255, 255, .15)), color-stop(.75, transparent),
                                to(transparent));
            background-image: -webkit-linear-gradient(135deg, rgba(255, 255, 255, .15) 25%, transparent 25%,
                                transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%,
                                transparent 75%, transparent);
            background-image: -moz-linear-gradient(135deg, rgba(255, 255, 255, .15) 25%, transparent 25%,
                                transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%,
                                transparent 75%, transparent);
            background-image: -ms-linear-gradient(135deg, rgba(255, 255, 255, .15) 25%, transparent 25%,
                                transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%,
                                transparent 75%, transparent);
            background-image: -o-linear-gradient(135deg, rgba(255, 255, 255, .15) 25%, transparent 25%,
                                transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%,
                                transparent 75%, transparent);
            background-image: linear-gradient(135deg, rgba(255, 255, 255, .15) 25%, transparent 25%,
                                transparent 50%, rgba(255, 255, 255, .15) 50%, rgba(255, 255, 255, .15) 75%,
                                transparent 75%, transparent);            
            
            -webkit-animation: animate-stripes 3s linear infinite;
            -moz-animation: animate-stripes 3s linear infinite;             
        }
        
        @-webkit-keyframes animate-stripes { 
            0% {background-position: 0 0;} 100% {background-position: 60px 0;}
        }
        
        
        @-moz-keyframes animate-stripes {
            0% {background-position: 0 0;} 100% {background-position: 60px 0;}
        }
        
        /*---------------------------*/  

        .shine span {
            position: relative;
        }
        
        .shine span::after {
            opacity: 0;
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            background: #fff;
            -moz-border-radius: 3px;
            -webkit-border-radius: 3px;
            border-radius: 3px;         
            
            -webkit-animation: animate-shine 2s ease-out infinite;
            -moz-animation: animate-shine 2s ease-out infinite;             
        }

        @-webkit-keyframes animate-shine { 
            0% {opacity: 0; width: 0;}
            50% {opacity: .5;}
            100% {opacity: 0; width: 95%;}
        }
        
        
        @-moz-keyframes animate-shine {
            0% {opacity: 0; width: 0;}
            50% {opacity: .5;}
            100% {opacity: 0; width: 95%;}
        }

        /*---------------------------*/  
        
        .glow span {
            -moz-box-shadow: 0 5px 5px rgba(255, 255, 255, .7) inset, 0 -5px 5px rgba(255, 255, 255, .7) inset;
            -webkit-box-shadow: 0 5px 5px rgba(255, 255, 255, .7) inset, 0 -5px 5px rgba(255, 255, 255, .7) inset;
            box-shadow: 0 5px 5px rgba(255, 255, 255, .7) inset, 0 -5px 5px rgba(255, 255, 255, .7) inset;
            
            -webkit-animation: animate-glow 1s ease-out infinite;
            -moz-animation: animate-glow 1s ease-out infinite;          
        }

        @-webkit-keyframes animate-glow {
         0% { -webkit-box-shadow: 0 5px 5px rgba(255, 255, 255, .7) inset, 0 -5px 5px rgba(255, 255, 255, .7) inset;} 
         50% { -webkit-box-shadow: 0 5px 5px rgba(255, 255, 255, .3) inset, 0 -5px 5px rgba(255, 255, 255, .3) inset;} 
         100% { -webkit-box-shadow: 0 5px 5px rgba(255, 255, 255, .7) inset, 0 -5px 5px rgba(255, 255, 255, .7) inset;}
         }

        @-moz-keyframes animate-glow {
         0% { -moz-box-shadow: 0 5px 5px rgba(255, 255, 255, .7) inset, 0 -5px 5px rgba(255, 255, 255, .7) inset;} 
         50% { -moz-box-shadow: 0 5px 5px rgba(255, 255, 255, .3) inset, 0 -5px 5px rgba(255, 255, 255, .3) inset;} 
         100% { -moz-box-shadow: 0 5px 5px rgba(255, 255, 255, .7) inset, 0 -5px 5px rgba(255, 255, 255, .7) inset;}
         }
    </style>
</head>

<body>
<br /><br />
<h2>vCloud Director - '+$global:DefaultCIServers[0].Name+' - '+$global:DefaultCIServers[0].Version+'</h2>'

Add-content $htmlFilename -value $htmlFile 
}

function Html-Footer() {
    $htmlFile +=
' <div class="footer">
  Support Open VMware Stats with <a href="http://www.vopendata.org">http://www.vopendata.org</a>
 </div>
 </body>
</html>'

Add-content $htmlFilename -value $htmlFile 
}

function Show-UnlimitedPercentageGraph($text) {
    $htmlFile = 
"<div class='progress-bar blue stripes'>
     <span style='width: 100%'><p>"+$text+"</p></span>
</div>
";

    Add-content $htmlFilename -value $htmlFile 
}

function Show-PercentageGraph($percent, $text) {
    $percent = [math]::Round($percent, 0)

    $value = $percent
    if ($percent -gt 100) { 
        $percent = 100
        $color = "red"
    }
    elseif ($percent -gt 90) { $color = "red" }
    elseif ($percent -le 60) { $color = "green" }
    else { $color = "orange"; }

    $htmlFile = 
"<div class='progress-bar "+$color+" stripes'>
     <span style='width: "+$percent+"%'><p>"+$value+"% "+$text+"</p></span>
</div>
";

    Add-content $htmlFilename -value $htmlFile 
}

function Show-GuaranteeGraph($percent, $text) {

    # Keep percent value simple
    $percent = [math]::Round($percent, 0)

    $value = $percent
    if ($percent -gt 100) { $percent = 100 }

    $htmlFile = 
"<div class='guarantee-bar blue stripes'>
     <span style='width: "+$percent+"%'><p>"+$value+"% "+$text+"</p></span>
</div>
";

    Add-content $htmlFilename -value $htmlFile 
}

function Get-VMStats($OrganizationVDC) {
    $OvDCVMsTotal           = ((Get-CIVM -OrgVdc $OrganizationVDC) | measure).Count
    if (!$OvDCVMsTotal) { $OvDCVMsTotal = 0 }

    $OvDCVMsRunning         = ((Get-CIVM -OrgVdc $OrganizationVDC) | ?{ $_.Status -eq "PoweredOn"} | measure).Count
    if (!$OvDCVMsRunning) { $OvDCVMsRunning = 0 }

    $VMStats = New-Object PsObject
    $VMStats | Add-Member -type NoteProperty -name VMsRunning -value $OvDCVMsRunning
    $VMStats | Add-Member -type NoteProperty -name VMsTotal -value $OvDCVMsTotal

    return $VMStats
}

function Show-VMStats($OrganizationVDC) {
    # Show VM stats (nb of VMs, VMs running against Quota)

    $OvDCVMsTotal           = ((Get-CIVM -OrgVdc $OrganizationVDC) | measure).Count
    if (!$OvDCVMsTotal) { $OvDCVMsTotal = 0 }

    $OvDCVMsRunning         = ((Get-CIVM -OrgVdc $OrganizationVDC) | ?{ $_.Status -eq "PoweredOn"} | measure).Count
    if (!$OvDCVMsRunning) { $OvDCVMsRunning = 0 }

    $OvDCVMsStoredQuota     = $OrganizationVDC.ExtensionData.VmQuota

    $OrgSettings            = $OrganizationVDC.Org.ExtensionData.Settings

    $OrgVMsDeployedQuota    = $OrgSettings.OrgGeneralSettings.DeployedVMQuota
    $OrgVMsStoredQuota      = $OrgSettings.OrgGeneralSettings.StoredVMQuota

    Add-content $htmlFilename -value "<br /><h5>Virtual Machine Stats</h5>"

    if ($OvDCVMsStoredQuota -eq 0) {
        $text = " VMs Count | Unlimited Quota"
        $text += "- [$($OvDCVMsTotal) | Unlimited]"
        Show-UnlimitedPercentageGraph $text

        $text = " Running VMs Count | Total VMs Count "
        $text += "- [$($OvDCVMsRunning) | $($OvDCVMsTotal)]"
        Show-PercentageGraph ($OvDCVMsRunning/$OvDCVMsTotal*100) $text
    }
    else {
        $text = " VMs Count | VMs Count Quota "
        $text += "- [$($OvDCVMsTotal) | $($OvDCVMsStoredQuota)]"
        Show-PercentageGraph ($OvDCVMsTotal/$OvDCVMsStoredQuota*100) $text

        $text = " Running VMs Count | VMs Total Count "
        $text += "- [$($OvDCVMsRunning) | $($OvDCVMsStoredQuota)]"
        Show-PercentageGraph ($OvDCVMsRunning/$OvDCVMsStoredQuota*100) $text
    }
}

function Show-NetworkStats($NetworksUsed, $NetworksTotal) {
    # Show Network stats (total should not be 0, but by default is 100000)
    # VMware tested until 5000 for VXLAN and 1000 for vCDNI
    # Need additional tests

    # In PowerCLI 5.1 R1 the $NetworkUsed metric doesn't exist.
    # ($OrganizationVDC.ExtensionData.UsedNetworkCount)

    if ($NetworksUsed -eq 0) {
        $text = " Networks Used | Network Quota (No Quota) "
        $text += "- [$($NetworksUsed) | 5000]"
        Show-PercentageGraph ($NetworksUsed/5000*100) $text
    }
    else {
        $text = " Networks Used | Network Quota "
        $text += "- [$($NetworksUsed) | $($NetworksTotal)]"
        Show-PercentageGraph ($NetworksUsed/$NetworksTotal*100) $text
    }
}

function Show-StorageStats($storageUsed, $Storageallocated, $StorageTotal) {
    # Show storage stats
    if ($StorageAllocated -eq 0) {
        $text = " Storage Used | PvDC Total Storage (No Quota) "
        $text += "- [$($StorageUsed)GB | $($StorageTotal)GB]"
        Show-PercentageGraph ($StorageUsed/$StorageTotal*100) $text
    }
    else {
        $text = " Storage Used | Allocated Quota "
        $text += "- [$($StorageUsed)GB | $($StorageAllocated)GB]"
        Show-PercentageGraph ($StorageUsed/$StorageAllocated*100) $text
    }
}

function Show-ExternalNetworkStats() {
    $extNetworks = Get-ExternalNetwork 
    
    Add-content $htmlFilename -value "<h3>External Networks</h3>"

    foreach($extNet in $extNetworks) {
        $text = " IP Allocation for $($extNet)"
        Show-PercentageGraph ($extNet.UsedIpCount/$extNet.TotalIpCount*100) $text
    }

    # Add Network Pool stats (VXLAN total OvDC Networks used / 5000*100)
}

function Show-ProviderVDCStats($ProviderVDC) {
    Add-content $htmlFilename -value "<h3>Provider VDC : $ProviderVDC</h3>"
    
    $CpuAllocated       = [math]::Round($ProviderVDC.CpuAllocatedGHz, 2)
    $CpuUsed            = [math]::Round($ProviderVDC.CpuUsedGHz, 2)
    $CpuTotal           = [math]::Round($ProviderVDC.CpuTotalGHz, 2)
    
    $MemAllocated       = [math]::Round($ProviderVDC.MemoryAllocatedGB, 2)
    $MemUsed            = [math]::Round($ProviderVDC.MemoryUsedGB, 2)
    $MemTotal           = [math]::Round($ProviderVDC.MemoryTotalGB, 2)
    
    $StorageAllocated   = [math]::Round($ProviderVDC.StorageAllocatedGB, 2)
    $StorageUsed        = [math]::Round($ProviderVDC.StorageUsedGB, 2)
    $StorageTotal       = [math]::Round($ProviderVDC.StorageTotalGB, 2)

    Add-content $htmlFilename -value "<h5>Resources Used & Allocated vs Total</h5>"
    
    $text = "CPU Used | Total [$($CpuUsed)Ghz | $($CpuTotal)Ghz]"
    Show-PercentageGraph ($CpuUsed/$CpuTotal*100) $text
    $text = "CPU Allocated [$($CpuAllocated)Ghz]"
    Show-GuaranteeGraph ($CpuAllocated/$CpuTotal*100) $text
   
    $text = "MEM Used | Total [$($MemUsed)GB | $($MemTotal)GB]"
    Show-PercentageGraph ($MemUsed/$MemTotal*100) $text
    $text = "MEM Allocated [$($MemAllocated)GB]"
    Show-GuaranteeGraph ($MemAllocated/$MemTotal*100) $text
    
    $text = "Storage Used | Total [$($StorageUsed)GB | $($StorageTotal)GB]" 
    Show-PercentageGraph ($StorageUsed/$StorageTotal*100) $text
    $text = "Storage Allocated [$($StorageAllocated)GB]"
    Show-GuaranteeGraph ($StorageAllocated/$StorageTotal*100) $text

    # Fetch All Organization VDC in the current Provider VDC.
    $OvDCs = Get-OrgVdc -ProviderVdc $PvDC
    
    $PvDCTotalVMs = 0
    $PvDCTotalVMsRunning = 0

    foreach ($OvDC in $OvDCs) {
        # Fetch VMs Stats in each Org vDC
        $OvDCVMStats = Get-VMStats $OvDC

        $PvDCTotalVMsRunning += $OvDCVMStats.VMsRunning
        $PvDCTotalVMs += $OvDCVMStats.VMsTotal
    }
    
    if ($PvDCTotalVMs -gt 0) { 
        $text = "VMs Running | Total [$($PvDCTotalVMsRunning)VMs | $($PvDCTotalVMs)VMs]"
        Show-PercentageGraph ($PvDCTotalVMsRunning/$PvDCTotalVMs*100) $text
    }
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

    $NetworksUsed       = $OrganizationVDC.ExtensionData.UsedNetworkCount
    $NetworksTotal      = $OrganizationVDC.ExtensionData.NetworkQuota
    $StorageUsed        = [math]::Round($OrganizationVDC.StorageUsedGB, 2)
    $StorageAllocated   = [math]::Round($OrganizationVDC.StorageLimitGB, 2)

    # Based on the Provider VDC stats as no allocation is done at the OvDC lvl
    # Maybe using used resources / sum(vApps allocated in vDC) would be better ?
    # TODO: Add vCPU Speed limit 
    Add-content $htmlFilename -value "<h5>Resources Used vs Provider VDC Total</h5>"
  
    $text = "CPU Used | Total [$($CpuUsed)Ghz|$($CpuTotal)Ghz]"
    Show-PercentageGraph ($CpuUsed/$CpuTotal*100) $text
    
    $text = "MEM Used | Total [$($MemUsed)GB|$($MemTotal)GB]"
    Show-PercentageGraph ($MemUsed/$MemTotal*100) $text

    # Waiting for next release of PowerCLI 5.x R3 ?
    # Show-NetworkStats $NetworksUsed $NetworksTotal        
    Show-StorageStats $StorageUsed $StorageAllocated $StorageTotal

    Show-VMStats $OrganizationVDC
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

    $NetworksUsed       = $OrganizationVDC.ExtensionData.UsedNetworkCount
    $NetworksTotal      = $OrganizationVDC.ExtensionData.NetworkQuota
    $StorageUsed        = [math]::Round($OrganizationVDC.StorageUsedGB, 2)
    $StorageAllocated   = [math]::Round($OrganizationVDC.StorageLimitGB, 2)

    Add-content $htmlFilename -value "<h5>Resources Used vs Org VDC Allocatation</h5>"
    
    $text = "CPU Used | Total [$($CpuUsed)Ghz | $($CpuAllocated)Ghz]" 
    Show-PercentageGraph ($CpuUsed/$CpuAllocated*100) $text
    $text = "Guarantee"
    Show-GuaranteeGraph $CpuGuarantee $text
    
    $text = "MEM Used | Total [$($MemUsed)GB | $($MemAllocated)GB]" 
    Show-PercentageGraph ($MemUsed/$MemAllocated*100) $text
    $text = "Guarantee"
    Show-GuaranteeGraph $MemGuarantee $text
    
    Show-StorageStats $StorageUsed $StorageAllocated $StorageTotal
    
    Add-content $htmlFilename -value "<h5>Resources Used & Allocated vs Provider VDC Total</h5>"
    
    $text = "CPU Used | Total [$($CpuUsed)Ghz | $($CpuTotal)Ghz]"
    Show-PercentageGraph ($CpuUsed/$CpuTotal*100) $text
    
    $text = "Guarantee [$($CpuGuaranteeTotal)Ghz]"
    Show-GuaranteeGraph ($CpuGuaranteeTotal/$CpuTotal*100) $text
    
    $text = "MEM Used | Total [$($MemUsed)GB | $($MemTotal)GB]" 
    Show-PercentageGraph ($MemUsed/$MemTotal*100) $text
    
    $text = "Guarantee [$($MemGuaranteeTotal)GB]"
    Show-GuaranteeGraph ($MemGuaranteeTotal/$MemTotal*100) $text
    
    # Waiting for next release of PowerCLI 5.x R3 ?
    # Show-NetworkStats $NetworksUsed $NetworksTotal 
    Show-StorageStats $StorageUsed 0 $StorageTotal

    Show-VMStats $OrganizationVDC
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

    $NetworksUsed       = $OrganizationVDC.ExtensionData.UsedNetworkCount
    $NetworksTotal      = $OrganizationVDC.ExtensionData.NetworkQuota
    $StorageUsed        = [math]::Round($OrganizationVDC.StorageUsedGB, 2)
    $StorageAllocated   = [math]::Round($OrganizationVDC.StorageLimitGB, 2)

    Add-content $htmlFilename -value "<h5>Resources Used vs Org VDC Allocatation</h5>"

    $text = "CPU Used | Allocated [$($CpuUsed)Ghz | $($CpuAllocated)Ghz]" 
    Show-PercentageGraph ($CpuUsed/$CpuAllocated*100) $text
    $text = "Guarantee [$($CpuAllocated)Ghz]"
    Show-GuaranteeGraph $CpuGuarantee $text
    
    $text = "MEM Used | Allocated [$($MemUsed)GB | $($MemAllocated)GB]" 
    Show-PercentageGraph ($MemUsed/$MemAllocated*100) $text
    $text = "Guarantee [$($MemAllocated)GB]"
    Show-GuaranteeGraph $MemGuarantee $text
    
    Show-StorageStats $StorageUsed $StorageAllocated $StorageTotal
       
    Add-content $htmlFilename -value "<h5>Resources Used & Allocated vs Provider VDC Total</h5>"

    $text = "CPU Used | Total [$($CpuUsed)Ghz | $($CpuTotal)Ghz]" 
    Show-PercentageGraph ($CpuUsed/$CpuTotal*100) $text
    $text = "Guarantee [$($CpuAllocated)Ghz]" 
    Show-GuaranteeGraph ($CpuAllocated/$CpuTotal*100) $text

    $text = "MEM Used | Total [$($MemUsed)GB | $($MemTotal)GB]"     
    Show-PercentageGraph ($MemUsed/$MemTotal*100) $text
    $text = "Guarantee [$($MemAllocated)GB]" 
    Show-GuaranteeGraph ($MemAllocated/$MemTotal*100) $text

    # Waiting for next release of PowerCLI 5.x R3 ?
    # Show-NetworkStats $NetworksUsed $NetworksTotal
    Show-StorageStats $StorageUsed 0 $StorageTotal

    Show-VMStats $OrganizationVDC
}

function Show-OrganizationVDCStats($OrganizationVDC, $ProviderVDC) {

    $AllocationModel = $OrganizationVDC.AllocationModel.toString()
    $Organization    = $OrganizationVDC.Org.Name
    
    $htmlFile = "<h4>"
    $htmlFile += "Organization VDC:$($OrganizationVDC)"
    $htmlFile += " - ($AllocationModel)"
    $htmlFile += " - Organization: $($Organization)"
    $htmlFile += "</h4>"
    
    Add-content $htmlFilename -value $htmlFile 

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


if ((Get-PowerCLIVersion).SnapinVersions[2].Build -gt 793505)
{
    Write-Host "Unfortunately VMware PowerCLI 5.1.0 R2 has a critical bug & vCloud Director. (Storage metrics are invalid)"
    Write-Host "To use this script you need the previous version of PowerCLI available here :"
    Write-Host "https://my.vmware.com/group/vmware/details?downloadGroup=VSP510-PCLI-510&productId=285"
    exit 1
}

# Connect to vCloud Director as System Administrator
Connect-CIServer

# Create filename accordingly 
$htmlFilename = $home+"\Desktop\Show-vCloudStats-"+$global:DefaultCIServers[0].Name+".html"
set-content $htmlFilename -value ""

# Set the HTML Header for the report 
Html-Header

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

# Set the HTML Footer for the report
Html-Footer

# Disconnect from all vCloud Instance
Disconnect-CIServer * -confirm:$false
