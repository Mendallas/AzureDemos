param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName = 'ADMIN_DAILY',

    [Parameter(Mandatory=$true)]
    [string]$Location ='WestEurope',
    
    [Parameter(Mandatory=$true)]
    [string]$Filepath,

    [string]$AutomationAccountName = 'SubscriptionAutomation'
)


## if the resource group already exist, we will delete it first
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

New-AzureRmResourceGroup -name $ResourceGroupName -Location $location
New-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName -Location $Location
Import-AzureRmAutomationRunbook -Path $filepath -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName -Type PowerShell