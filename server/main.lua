local db = require('modules.db')
local Accounts = require('modules.accounts')
local Framework = require('modules.framework')
local Utils = require('modules.utils.server')
local playerAccess = {}

function UpdatePlayerAccount(source)
    if not source then return end

    source = tonumber(source)

    Accounts.AddPlayer(source)
    local left = Accounts(source)
    if not left then return end -- A error happened and player didnt get added to the table

    local access = { left }
    local numAccounts = 1
    local playerAccounts = db.selectCharacterGroups(left.id)
    if playerAccounts then
        playerAccounts = type(playerAccounts) == 'string' and { playerAccounts } or playerAccounts

        for i = 1, #playerAccounts do
            local actualAccount = playerAccounts[i].account or playerAccounts[i]

            local acc = Accounts(actualAccount)

            if acc then
                numAccounts += 1
                access[numAccounts] = acc
            end
        end
    end

    local Groups = Framework.getGroups(source)
    for group, grade in pairs (Groups) do
        if Framework.isGroupAuth(group, grade) then
            local account = Accounts(group)
            if account then
                numAccounts += 1
                access[numAccounts] = account
            end
        end
    end

    playerAccess[source] = access
end

function ExportHandler(resource, name, cb)
    AddEventHandler(('__cfx_export_%s_%s'):format(resource, name), function(setCB)
        setCB(cb)
    end)
end

AddEventHandler('Renewed-Lib:server:JobUpdate', function(source, oldGroup, newGroup, grade)
    for k=1, #playerAccess[source] do
        if playerAccess[source][k].id == oldGroup then
            table.remove(playerAccess[source], k)
            local group = Accounts(newGroup)
            if group and Framework.isGroupAuth(newGroup, grade) then
                playerAccess[source][#playerAccess[source]+1] = group
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    Wait(250)
    if resourceName == GetCurrentResourceName() then
        Framework.init()
        for _, sourceId in ipairs(GetPlayers()) do
            UpdatePlayerAccount(sourceId)
            Wait(69)
        end
    end
end)

lib.callback.register('renewed-banking:server:getPlayerData', function(source)
    local PlayerData = {
        name = Framework.getCharName(source),
        id = Framework.getCharId(source),
    }
    return PlayerData
end)

lib.callback.register('renewed-banking:server:initializeBanking', function(source)
    local charID = Framework.getCharId(source)
    playerAccess[source][1].cash = Framework.getMoney(source, 'cash')
    playerAccess[source][1].amount = Framework.getMoney(source, 'bank')
    playerAccess[source][1].transactions = db.getTransactions(charID)
    return playerAccess[source]
end)

-- Events
local function handleTransaction(account, title, amount, message, issuer, receiver, transType, transID)
    if not Utils.validateTransaction(account, title, amount, message, issuer, receiver, transType, transID) then return end

    --if not cachedAccounts[account] or not cachedPlayers[account] then print("GOES OFF HERE") return end
    local transaction = {
        trans_id = transID or Utils.genTransactionID(),
        title = title,
        amount = amount,
        trans_type = transType,
        receiver = receiver,
        message = Utils.sanitizeMessage(message),
        issuer = issuer,
        time = os.time()
    }

    db.addTransaction(account, transaction.trans_id, transaction.title, transaction.message, transaction.amount, transaction.receiver, transaction.trans_type, transaction.issuer, transaction.time)

    return transaction
end exports("handleTransaction", handleTransaction)

lib.callback.register('Renewed-Banking:server:deposit', function(source, data)
    local amount = tonumber(data.amount)

    if not amount or amount < 1 then
        Utils.sendNotif(source, {title = locale("bank_name"), description = locale("invalid_amount", "deposit"), type = "error"})
        return false
    end

    local left = Accounts(source)

    if not left then
        return
    end

    local secondAccount = left.id == data.fromAccount and source or data.fromAccount

    local right = secondAccount ~= source and Accounts(secondAccount) or left

    if secondAccount ~= source and right == left then
        return
    end

    data.comment = data.comment and data.comment ~= "" and Utils.sanitizeMessage(data.comment) or locale("comp_transaction", left.name, "deposited", amount)

    local success = Accounts.removeCash(source, amount, data.comment)

    if not success then
        Utils.sendNotif(source, locale("not_enough_money"))
        return
    end

    local transaction = handleTransaction(data.fromAccount, locale("personal_acc") .. data.fromAccount, amount, data.comment, left.name, right.id, "deposit")

    Accounts.addMoney(secondAccount, amount, data.comment)

    -- So this returnData needs to return the NEW BANK BALANCE of the ACCOUNT that you just deposited into
    return transaction
end)


function GetAccountMoney(account)
    local acc = Accounts(account)
    if not acc then
        print(locale("invalid_account", account))
        return false
    end
    return acc.amount
end
exports('getAccountMoney', GetAccountMoney)

function AddAccountMoney(account, amount)
    local acc = Accounts(account)
    if not acc then
        locale("invalid_account", account)
        return false
    end
    Accounts.addMoney(account, amount)
    db.setBankBalance(account, acc.amount)
    return true
end
exports('addAccountMoney', AddAccountMoney)

function RemoveAccountMoney(account, amount)
    local acc = Accounts(account)
    if not acc then return print(locale("invalid_account", account)) end

    local withdraw = Accounts.removeMoney(account, amount)
    if not withdraw then return print(locale("broke_account", account, amount)) end

    db.setBankBalance(account, acc.amount)
    return true
end
exports('removeAccountMoney', RemoveAccountMoney)

lib.callback.register('Renewed-Banking:server:withdraw', function(source, data)
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then
        Utils.sendNotif(source, {title = locale("bank_name"), description = locale("invalid_amount", "withdraw"), type = "error"})
        return false
    end

    local left = Accounts(source)
    if not left then return end
    local secondAccount = left.id == data.fromAccount and source or data.fromAccount
    local right = secondAccount ~= source and Accounts(secondAccount) or left
    if secondAccount ~= source and right == left then return end

    data.comment = data.comment and data.comment ~= "" and Utils.sanitizeMessage(data.comment) or locale("comp_transaction", right.name, "withdrawed", amount)
    local success = Accounts.removeMoney(secondAccount, amount, data.comment)
    if not success then Utils.sendNotif(source, locale("not_enough_money")) return end

    Accounts.addCash(source, amount, data.comment)
    local transaction = handleTransaction(data.fromAccount,locale("personal_acc") .. data.fromAccount, amount, data.comment, right.id, left.name, "withdraw")
    return transaction
end)

lib.callback.register('Renewed-Banking:server:transfer', function(source, data)
    local amount = tonumber(data.amount)

    if not amount or amount < 1 then
        Utils.sendNotif(source, {title = locale("bank_name"), description = locale("invalid_amount", "transfer"), type = "error"})
        return false
    end

    local initiatorAcc = Accounts(source)
    if not initiatorAcc then return print(locale("invalid_account", source))end

    local fromAccount = Accounts(data.fromAccount)
    if not fromAccount then return print(locale("invalid_account", data.fromAccount)) end

    local toAccount = Accounts(data.stateid)
    local isOffline
    if not toAccount then
        if not Framework.getOfflineMoney(data.stateid) then
            return print(locale("invalid_account", data.stateid))
        end
        isOffline = true
    end

    local comment = data.comment and data.comment ~= "" and Utils.sanitizeMessage(data.comment) or locale("comp_transaction", initiatorAcc.name, "transferred", amount)

    local success = Accounts.removeMoney(data.fromAccount, amount, comment)
    if not success then
        Utils.sendNotif(source, locale("not_enough_money"))
        print(locale("not_enough_money"))
        return false
    end

    if isOffline then
        Framework.addOfflineMoney(data.stateid, amount, "bank")
        toAccount = {name = Framework.getCharNameById(data.stateid)}
    else
        Accounts.addMoney(data.stateid, amount, comment)
    end

    local transaction1 = handleTransaction(data.fromAccount, locale("personal_acc") .. data.fromAccount, amount, comment, initiatorAcc.name, toAccount.name, "transfer")
    handleTransaction(data.stateid, locale("personal_acc") .. data.stateid, amount, comment, toAccount.name, initiatorAcc.name, "transfer", transaction1.trans_id)

    return transaction1
end)

lib.callback.register('Renewed-Banking:server:createNewAccount', function(source, accountid)
    local acc = Accounts(accountid)
    if acc then Utils.sendNotif(source, {title = locale("bank_name"), description = locale("account_taken"), type = "error"}) return false end
    local cid = Framework.getCharId(source)

    local createdAccount = Accounts.AddBank(accountid, cid)

    playerAccess[source][#playerAccess[source]+1] = createdAccount

    db.addAccount(accountid, 0, 0, cid)
    db.addAccountAuth(cid, accountid)
    return true
end)

lib.callback.register('Renewed-Banking:server:getPlayerAccounts', function(source)
    local account = Framework.getCharId(source)
    local ownedAccounts = db.selectOwnedAccounts(account)
    return ownedAccounts or false
end)

lib.callback.register('Renewed-Banking:server:getMembers', function(_, accountid)
    local members = db.selectMembers(accountid)
    if type(members) ~= "string" then
        for k=1, #members do
            members[k].name = Framework.getCharNameById(members[k].charid)
        end
    end
    return members or false
end)

local function addAccountMember(account, member)
    local bankAccount = Accounts(account)
    if not bankAccount then print(locale("invalid_account", account)) return false end
    local Player = Accounts(member)
    if not Player then return false end
    local source = Player.source

    for _, acc in ipairs(playerAccess[source]) do
        if acc == bankAccount then
            return true
        end
    end

    playerAccess[source][#playerAccess[source] + 1] = bankAccount
    db.addAccountMembers(Player.id, account)
    return true
end
exports("addAccountMember", addAccountMember)

lib.callback.register('Renewed-Banking:server:addAccountMember', function(source, member, accountName)
    if not accountName or not member then return false end

    local cid = Framework.getCharId(source)
    local bankAccount = Accounts(accountName)

    if cid ~= bankAccount.creator then print(locale("illegal_action", GetPlayerName(source))) return end
    addAccountMember(accountName, member)
    return true
end)

local function removeBankAccess(account, member)
    local Player = Accounts(member)
    if type(Player) == "table" and Player.source then
        local accessTable = playerAccess[Player.source]
        if accessTable then
            for index, accObj in ipairs(accessTable) do
                if accObj == account then
                    table.remove(accessTable, index)
                    break
                end
            end
        end
    end
end

local function removeAccountMember(account, member)
    local acc = Accounts(account)
    if not acc then print(locale("invalid_account", account)) return end
    db.removeAccountMembers(member, account)
    removeBankAccess(account, member)
end
exports("removeAccountMember", removeAccountMember)

lib.callback.register('Renewed-Banking:server:removeAccountMembers', function(source, accountId, members)
    local cid = Framework.getCharId(source)
    local acc = Accounts(accountId)
    if cid ~= acc.creator then print(locale("illegal_action", GetPlayerName(source))) return false end
    for k=1,#members do
        db.removeAccountMembers(members[k], accountId)
        removeBankAccess(accountId, members[k])
    end
    return true
end)

lib.callback.register('Renewed-Banking:server:deleteAccount', function(source, account)
    local acc = Accounts(account)
    if not acc then return end

    local cid = Framework.getCharId(source)
    if acc.creator ~= cid then return end

    Accounts.nuke(account)
    for k=1, #playerAccess[source] do
        if playerAccess[source][k].id == acc.id then
            table.remove(playerAccess[source], k)
            break
        end
    end

    db.nukeAccount(account)
    db.nukeAccountMembers(account)
    db.nukeTransactions(account)
    return true
end)

local find = string.find
local sub = string.sub
local function split(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = find(str, delimiter, from)
    while delim_from do
        result[#result + 1] = sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = find(str, delimiter, from)
    end
    result[#result + 1] = sub(str, from)
    return result
end

local function updateAccountName(account, newName, src)
    if not account or not newName then return false end

    local acc = Accounts(account)
    if not acc then
        local getTranslation = locale("invalid_account", account)
        if src then Utils.sendNotif(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"}) end
        return false
    end

    local newAcc = Accounts(newName)
    if newAcc then
        local getTranslation = locale("existing_account", newName)
        if src then Utils.sendNotif(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"}) end
        return false
    end

    if src then
        local cid = Framework.getCharId(src)
        if cid ~= acc.creator then
            local getTranslation = locale("illegal_action", GetPlayerName(src))
            Utils.Notify(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"})
            return false
        end
    end

    Accounts.changeName(account, newName)
    db.updateAccountName(newName, account)
    db.updateAccountMembers(newName, account)
    db.updateTransactions(account, newName)
    return true
end
exports("changeAccountName", updateAccountName)-- Should only use this on very secure backends to avoid anyone using this as this is a server side ONLY export --

lib.callback.register('Renewed-Banking:server:changeAccountName', function(source, account, newName)
    local acc = Accounts(account)
    local cid = Framework.getCharId(source)
    if not acc then return false end
    if cid ~= acc.creator then return false end
    return updateAccountName(account, newName)
end)

local function getAccountTransactions(account)
    local acc = Accounts(account)
    if not acc then return print(locale("invalid_account", account)) end
    return db.getTransactions(account)
end
exports("getAccountTransactions", getAccountTransactions)

lib.callback.register('renewed-banking:server:getAccountTransactions', function(_, data)
    return db.getTransactions(data.account)
end)

local oxInventory = GetResourceState('ox_inventory') ~= 'missing'

if not oxInventory then
    lib.addCommand('givecash', {
        help = 'Gives an item to a player',
        params = {
            {
                name = 'target',
                type = 'playerId',
                help = locale("cmd_plyr_id"),
            },
            {
                name = 'amount',
                type = 'number',
                help = locale("cmd_amount"),
            }
        }
    }, function(source, args)
        local Player = Accounts(source)
        if not Player then return end

        local iPlayer = Accounts(args.target)
        if not iPlayer then return Utils.Notify(source, {title = locale("bank_name"), description = locale('unknown_player', args.target), type = "error"}) end

        if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(args.target))) > 10.0 then return Utils.Notify(source, {title = locale("bank_name"), description = locale('too_far_away'), type = "error"}) end
        if args.amount <= 0 then return Utils.Notify(source, {title = locale("bank_name"), description = locale('invalid_amount', "give"), type = "error"}) end

        if Accounts.removeCash(source, args.amount) then Accounts.removeCash(source, args.amount)
            Accounts.addCash(args.target, args.amount)
            Utils.Notify(source, {title = locale("bank_name"), description = locale('give_cash', iPlayer.name, tostring(args.amount)), type = "error"})
            Utils.Notify(args.target, {title = locale("bank_name"), description = locale('received_cash', Player.name, tostring(args.amount)), type = "success"})
        else
            Utils.Notify(args.target, {title = locale("bank_name"), description = locale('not_enough_money'), type = "error"})
        end
    end)
end
