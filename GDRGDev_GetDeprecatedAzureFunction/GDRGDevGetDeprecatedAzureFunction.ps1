#Working with Az.Functions
Find-Module -Name Az.Functions  | Install-Module
Import-Module -Name Az.Functions 

#Connect to Azure Account
Connect-AzAccount

#Get subscriptions
Get-AzSubscription

#Set subscription to analyze
Set-AzContext -Subscription "<SubscriptionID>" 

#Identify function apps to migrate (Runtime Version)
$functionRuntime=@{l="FunctionRuntimeVersion";e={(Get-AzFunctionAppSetting -Name $_.Name -ResourceGroupName $_.ResourceGroupName)["FUNCTIONS_EXTENSION_VERSION"]}}
(Get-AzFunctionApp | Where-Object { $(if ((Get-AzFunctionAppSetting -Name $_.Name -ResourceGroupName $_.ResourceGroupName) -eq $null) {""} else {(Get-AzFunctionAppSetting -Name $_.Name -ResourceGroupName $_.ResourceGroupName)["FUNCTIONS_EXTENSION_VERSION"]}) -ne "~4" } ) | Select-Object Name,ResourceGroupname,$functionRuntime |Format-Table -AutoSize

#Identify function apps to migrate (Execution Model)
$functionRuntime=@{l="FunctionWorkerRuntime";e={(Get-AzFunctionAppSetting -Name $_.Name -ResourceGroupName $_.ResourceGroupName)["FUNCTIONS_WORKER_RUNTIME"]}}
(Get-AzFunctionApp | Where-Object { $(if ((Get-AzFunctionAppSetting -Name $_.Name -ResourceGroupName $_.ResourceGroupName) -eq $null) {""} else {(Get-AzFunctionAppSetting -Name $_.Name -ResourceGroupName $_.ResourceGroupName)["FUNCTIONS_WORKER_RUNTIME"]}) -ne "dotnet-isolated" } ) | Select-Object Name,ResourceGroupname,$functionRuntime |Format-Table -AutoSize