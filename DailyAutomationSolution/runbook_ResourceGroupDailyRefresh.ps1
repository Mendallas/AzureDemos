<#
    .DESCRIPTION
        Create an Azure Resource Group with the name specified. If the group already exists, it will delete it and recreate it.

    .NOTES
        AUTHOR: Charles Boudry
        LASTEDIT: 07/03/2018
#>

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
   [string]$ResourceGroupName,

   [Parameter(Mandatory=$True)]
   [string]$Location
)

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

#Get all ARM resources from all resource groups
$AzureResourceGroup = Get-AzureRmResourceGroup -name $ResourceGroupName -ErrorAction 'SilentlyContinue'
if($AzureResourceGroup)
{
    Remove-AzureRmResourceGroup -name $ResourceGroupName -Force
    $AzureResourceGroup = Get-AzureRmResourceGroup -name $ResourceGroupName -ErrorAction 'SilentlyContinue'
    if($AzureResourceGroup)
    {
        write-error "Not able to delete the Group"
    }
}
New-AzureRmResourceGroup -name $ResourceGroupName -Location $Location