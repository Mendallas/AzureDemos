# DailyAutomationSolution

Purpose :
The aim of this solution is to delete everything you create in a specific resource group a the end of the day to limit Azure Consumption

Description :
Create a resource group containing a runbook that will execute daily to delete and recreate another resource group called by default "DEMO_DAILY"

How to use :
Download Folder solution and launch script Demo_Daily_Solution.ps1 as administrator (this is required for generating certificate for the run as account)
This solution can be launched from powershell, powershell ISE or Visual Studio Code