#requires -RunAsAdministrator
param(
    [string]$ResourceGroupName = 'ADMIN_DAILY',

    [string]$Location = 'WestEurope',

    [string]$AutomationAccountName = 'Automation-Daily' + -join ((48..57) * 100 | Get-Random -Count 6 | %{[char]$_}),

    [string]$ApplicationDisplayName = "Admin-Daily" +  -join ((48..57) * 100 | Get-Random -Count 6 | %{[char]$_}),

    [string]$SelfSignedCertPlainPassword = -join ((33..126) * 100 | Get-Random -Count 32 | % {[char]$_}),

    [string]$AutomationRunbookName = "Runbook-Daily" +  -join ((48..57) * 100 | Get-Random -Count 6 | %{[char]$_}),

    [string]$AutomationScheduleName = "Each day",

    [string]$DailyResourceGroupName = "DEMO_DAILY",

    [string]$DailyLocation = 'WestEurope'
)

# If not already in Azure Environment we connect to it (graphical interface is then needed)
# Please note that if you are using Visual Studio Code the Authent windows will be on the foreground https://github.com/Microsoft/vscode/issues/42356
$AzureContext = Get-AzureRmContext
if(-not $AzureContext.Environment) {
    Connect-AzureRmAccount
    Get-AzureRmSubscription
    $SubName = Read-Host "Subscription Name"
    Select-AzureRmSubscription $SubName
}

# New Resource Group
New-AzureRmResourceGroup -name $ResourceGroupName -Location $location

# New Azure Automation Account
New-AzureRmAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName -Location $Location

# New Azure Automation Run as Account 
./New-RunAsAccount.ps1 -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName -SubscriptionId (Get-AzureRmContext).Subscription.Id -ApplicationDisplayName $ApplicationDisplayName -SelfSignedCertPlainPassword $SelfSignedCertPlainPassword -CreateClassicRunAsAccount $false

# New Azure Automation Runbook
Import-AzureRmAutomationRunbook -Name $AutomationRunbookName -Path .\runbook_ResourceGroupDailyRefresh.ps1 -ResourceGroup $ResourceGroupName -AutomationAccountName $AutomationAccountName -Type PowerShell -Published 

# New Azure Automation Schedule
$StartTime = (Get-Date "00:00:00").AddDays(1)
New-AzureRmAutomationSchedule -AutomationAccountName $AutomationAccountName -Name $AutomationScheduleName -StartTime $StartTime -DayInterval 1 -ResourceGroupName $ResourceGroupName -TimeZone (Get-TimeZone).ID

# Link the runbook to the schedule
$RunbookParameters = @{
    ResourceGroupName = $DailyResourceGroupName
    Location = $DailyLocation
}
Register-AzureRmAutomationScheduledRunbook -AutomationAccountName $AutomationAccountName -Name $AutomationRunbookName -ScheduleName $AutomationScheduleName -ResourceGroupName $ResourceGroupName -Parameters $RunbookParameters