# Renewed-Banking
<a href='https://ko-fi.com/ushifty' target='_blank'><img height='35' style='border:0px;height:46px;' src='https://az743702.vo.msecnd.net/cdn/kofi3.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' />
 
[Renewed Discord](https://discord.gg/P3RMrbwA8n)

## ⚠️ Warning
Before making any changes, please backup the following database tables:
* `bank_accounts_new`
* `player_transactions`
* `bank_transactions`
* `player_accounts`
* `bank_accounts`

**Note:** The resource will delete these tables and recreate them with a new schema, porting the existing data over to the new structure.

# Project Description
Renewed-Banking is a advanced banking resource created by uShifty and maintained by RenewedScripts. The design was inspired by the layout of NoPixel, it has been built from scratch. The 2.0 UI, originally reskined by [qwadebot](https://github.com/qw-scripts), has undergone significant modifications by RenewedScripts.

# Dependencies
* [oxmysql](https://github.com/overextended/oxmysql)
* [ox-lib](https://github.com/overextended/ox_lib)
* [Renewed-Lib](https://github.com/Renewed-Scripts/Renewed-Lib)
* [ox_target](https://github.com/overextended/ox_target) (Optional)
* [qb-target](https://github.com/qbcore-framework/qb-target) (Optional) **Supported not recommended**

**Supported Frameworks: QBCore and ESX.**
 
# Features
* Personal, Job, Gang, Shared Accounts
* Withdraw, Deposit, Transfer between accounts
* Optimized Resource (0.00ms Running At All Times)

# Installation
## Step 1: Integrate Exports
Integrate the following exports in any external resource that interacts with a player's bank account:
```lua
 -- Place this export anywhere that interacts with a Players bank account. (Where it adds or removes money from bank)
exports['Renewed-Banking']:handleTransaction(account, title, amount, message, issuer, receiver, type, transID)
 ---@param account<string> - job name or citizenid
 ---@param title<string> - Title of transaction example `Personal Account / ${Player.PlayerData.citizenid}`
 ---@param amount<number> - Amount of money being transacted
 ---@param message<string> - Description of transaction
 ---@param issuer<string> - Name of Business or Character issuing the bill
 ---@param receiver<string> - Name of Business or Character receiving the bill
 ---@param type<string> - "deposit" or "withdraw"
 ---@param transID<string> - (optional) Force a specific transaction ID instead of generating one.

---@return transaction<table> {
  ---@param trans_id<string> - Transaction ID for the created transaction
  ---@param amount<number> - Amount of money being transacted
  ---@param trans_type<string> - "deposit" or "withdraw"
  ---@param receiver<string> - Name of Business or Character receiving the bill
  ---@param message<string> - Description of transaction
  ---@param issuer<string> - Name of Business or Character issuing the bill
  ---@param time<number> - Epoch timestamp of transaction
---}


exports['Renewed-Banking']:getAccountMoney(account)
 ---@param account<string> - Job Name or Custom Account Name

---@return amount<number> - Amount of money account has or false

exports['Renewed-Banking']:addAccountMoney(account, amount)
 ---@param account<string> - Job Name or Custom Account Name
  ---@param amount<number> - Amount of money being transacted

---@return complete<boolean> - true or false

exports['Renewed-Banking']:removeAccountMoney(account, amount)
 ---@param account<string> - Job Name or Custom Account Name
  ---@param amount<number> - Amount of money being transacted

---@return complete<boolean> - true or false
```

# QBCore additional Installation Steps 
## qb-managment conversion
qb-management Conversion
```lua
exports['qb-management']:GetAccount => exports['Renewed-Banking']:getAccountMoney
exports['qb-management']:AddMoney => exports['Renewed-Banking']:addAccountMoney
exports['qb-management']:RemoveMoney => exports['Renewed-Banking']:removeAccountMoney
exports['qb-management']:GetGangAccount=> exports['Renewed-Banking']:getAccountMoney
exports['qb-management']:AddGangMoney=> exports['Renewed-Banking']:addAccountMoney
exports['qb-management']:RemoveGangMoney=> exports['Renewed-Banking']:removeAccountMoney
```
## Society Bank Access
*QBCore:* Checks if the grade has the isboss variable in their job table.
*ESX:* Checks if the grade name is "boss"

 ## Change Logs
<details>
 <summary>View History</summary>

 V3.0.0
 ```
 New Database Schema
 ox_lib menu ditch Fully UI based
 bunch of misc fixes.
 ```

 V2.0.2
 ```
 ESX Fix Jobs Error (2edf28e)
 Fix Native To Retrieve All Players, On Account Name Change
 Edited Deposit/Withdraw/Transfer Default Comment To Show Name Instead Of Identifier
 ```

 V2.0.1
 ```
 Fix QBCore/QBox Compatibility issues
 Fix Sanitizing Messages throwing errors for languages
 Fix Renewed QB Phone Multi Job not showing jobs
 ```

 V2.0.0
 ```
 New UI Design
 ESX Support Added
 QB Dependacies switched to OX
 Massive server side optimizations
 Rework inital codebase
 Delete created accounts
 ```
 
 V1.0.5
 ```
 Fix OX integration being ATM only
 Added Renewed Phones MultiJob Support (Enable in config)
 Fix onResourceStop errors for QB target users
 Fixed a couple Account Menu bugs from 1.0.4 OX integration
 Slight client side cleanup
 Fix exploit allowing players to highjack sub accounts
 ```
 
 v1.0.4
 ```
 Add server export to get an accounts transactions.
 Add /givecash command
 Added ox lib and target support
 ```
 
 V1.0.3
 ```
 Fixes the default message when no message is provided when transferring
 Added Bank Checks for those who dont like to configure their QBCore
 Added a check to ensure player cache exists
 Fixed bug with shared accounts and entering a negative value
 ```
 
 V1.0.2
 ```
 Added Gangs To SQL
 Disabled Deposit At ATM Machines
 Fix Error "Form Submission Canceled"
 QBCore Locale System Implementation
 Implemented Translations To UI (No Need To Edit UI Anymore)
 Fix Balance & Transactions Update
 Fix Transaction Default Message
 ```

 V1.0.1
 ```
 Added Banking Blips
 ```
</details>
