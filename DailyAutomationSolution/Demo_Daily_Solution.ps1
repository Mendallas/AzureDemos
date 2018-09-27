#requires -RunAsAdministrator
param(
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = 'ADMIN_DAILY',

    [ValidateNotNullOrEmpty()]
    [string]$Location = 'WestEurope',
    
    [ValidateNotNullOrEmpty()]
    [string]$RunbookURL = 'https://raw.githubusercontent.com/Mendallas/AzureDemos/master/DailyAutomationSolution/Sources/runbook_ResourceGroupDailyRefresh.ps1',

    [ValidateNotNullOrEmpty()]
    [string]$AutomationAccountName = 'SubscriptionAutomation',

    [ValidateNotNullOrEmpty()]
    [string]$AutomationConnectionName = "test",

    [ValidateNotNullOrEmpty()]
    [string]$KeyVaultName = "kv89232390"
)

function Check-AzurePrerequisites{
    $AzureContext = Get-AzureRmContext
    if(-not $AzureContext.Environment) {
        Connect-AzureRmAccount
        Get-AzureRmSubscription
        $SubName = Read-Host "Subscription Name"
        Select-AzureRmSubscription $SubName
    }
}

function CustomImport-AzureRmAutomationRunbook{
}

# If not already in Azure Environment we connect to it (graphical interface is then needed)
# Please note that if you are using Visual Studio Code the Authent windows will be on the foreground https://github.com/Microsoft/vscode/issues/42356
Check-AzurePrerequisites

# New Resource Group
New-AzureRmResourceGroup -name $ResourceGroupName -Location $location

# New Azure Automation Account
New-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName -Location $Location

# new Azure Automation Run as Account 
./New-RunAsAccount.ps1 -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName -SubscriptionId (Get-AzureRmContext).Subscription.Id -ApplicationDisplayName "fjsdjflsdfjlksdf" -SelfSignedCertPlainPassword "msjfklsdjflksjdfl2030123¨!!?" -CreateClassicRunAsAccount $false

# $SubscriptionID = (Get-AzureRmContext).Subscription.Id
# $FieldValues = @{"AutomationCertificateName"="ContosoCertificate";"SubscriptionID"=$SubscriptionID}
# New-AzureRmAutomationConnection -Name $AutomationConnectionName -ConnectionTypeName Azure -ConnectionFieldValues $FieldValues -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

# I won't be using Import-AzureRmAutomationRunbook from the AzureRM module because it is not yet able to import from url, only drive path https://github.com/Azure/azure-powershell/issues/1640 
# Import-AzureRmAutomationRunbook -Path $filepath -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName -Type PowerShell
# However thanks to the Azure CmdLet being open source, we can easily recreate our own import function
# https://github.com/Azure/azure-powershell/blob/preview/src/ResourceManager/Automation/Commands.Automation/Cmdlet/ImportAzureAutomationRunbook.cs
# https://github.com/Azure/azure-powershell/blob/preview/src/ResourceManager/Automation/Commands.Automation/Common/AutomationClient.cs 
CustomImport-AzureRmAutomationRunbook -Url $RunbookURL -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName -Type PowerShell