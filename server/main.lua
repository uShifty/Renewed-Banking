local cachedAccounts = {}
local cachedPlayers = {}

local db = require('modules.db')

CreateThread(function()
    if not LoadResourceFile("Renewed-Banking", 'web/public/build/bundle.js') or GetCurrentResourceName() ~= "Renewed-Banking" then
        error(locale("ui_not_built"))
        return StopResource("Renewed-Banking")
    end

    local bankData = db.selectBankAccounts()

    for _, v in pairs(bankData) do
        local job = v.id
        cachedAccounts[job] = { --  cachedAccounts[#cachedAccounts+1]
            id = job,
            type = locale("org"),
            name = job,
            frozen = v.isFrozen == 1,
            amount = v.amount,
            transactions = db.getTransactions(job),
            creator = v.creator
        }
    end
end)

function UpdatePlayerAccount(source)
    local Player = GetPlayerObject(source)
    local cid = GetIdentifier(Player)

    source = tonumber(source)

    cachedPlayers[source] = {
        charId = cid,
        name = GetCharacterName(Player),
        isFrozen = 0,
        transactions = db.getTransactions(cid) or {},
        accounts = db.selectCharacterGroups(cid) or {}
    }
    return cachedPlayers[source]
end

local function getBankData(source)
    local Player = GetPlayerObject(source)
    local cid = GetIdentifier(Player)
    if not cachedPlayers[source] then UpdatePlayerAccount(source) end
    local funds = GetFunds(Player)

    local bankData = {}

    bankData[#bankData+1] = {
        id = cid,
        type = locale("personal"),
        name = GetCharacterName(Player),
        frozen = cachedPlayers[source].isFrozen,
        amount = funds.bank,
        cash = funds.cash,
        transactions = cachedPlayers[source].transactions,
    }

    if type(cachedPlayers[source].accounts) == 'table' then
        for i = 1, #cachedPlayers[source].accounts do
            local v = cachedPlayers[source].accounts[i]
            bankData[#bankData+1] = cachedAccounts[v.account]
        end
    else
        bankData[#bankData+1] = cachedAccounts[cachedPlayers[source].accounts]
    end
    return bankData
end

lib.callback.register('renewed-banking:server:initalizeBanking', function(source)
    local bankData = getBankData(source)
    return bankData
end)

-- Events
local function genTransactionID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

local function sanitizeMessage(message)
    if type(message) ~= "string" then
        message = tostring(message)
    end
    message = message:gsub("'", "''"):gsub("\\", "\\\\")
    return message
end

local Type = type
local function handleTransaction(account, title, amount, message, issuer, receiver, transType, transID)
    if not account or Type(account) ~= 'string' then return print(locale("err_trans_account", account)) end
    if not title or Type(title) ~= 'string' then return print(locale("err_trans_title", title)) end
    if not amount or Type(amount) ~= 'number' then return print(locale("err_trans_amount", amount)) end
    if not message or Type(message) ~= 'string' then return print(locale("err_trans_message", message)) end
    if not issuer or Type(issuer) ~= 'string' then return print(locale("err_trans_issuer", issuer)) end
    if not receiver or Type(receiver) ~= 'string' then return print(locale("err_trans_receiver", receiver)) end
    if not transType or Type(transType) ~= 'string' then return print(locale("err_trans_type", transType)) end
    if transID and Type(transID) ~= 'string' then return print(locale("err_trans_transID", transID)) end

    --if not cachedAccounts[account] or not cachedPlayers[account] then print("GOES OFF HERE") return end
    local transaction = {
        trans_id = transID or genTransactionID(),
        title = title,
        amount = amount,
        trans_type = transType,
        receiver = receiver,
        message = sanitizeMessage(message),
        issuer = issuer,
        time = os.time()
    }

    db.addTransaction(account, transaction.trans_id, transaction.title, transaction.message, transaction.amount, transaction.receiver, transaction.trans_type, transaction.issuer, transaction.time)

    return transaction
end exports("handleTransaction", handleTransaction)

function GetAccountMoney(account)
    if not cachedAccounts[account] then
        locale("invalid_account", account)
        return false
    end
    return cachedAccounts[account].amount
end
exports('getAccountMoney', GetAccountMoney)

local function updateBalance(account)
    MySQL.prepare("UPDATE bank_accounts_new SET amount = ? WHERE id = ?",{ cachedAccounts[account].amount, account })
end

function AddAccountMoney(account, amount)
    if not cachedAccounts[account] then
        locale("invalid_account", account)
        return false
    end
    cachedAccounts[account].amount += amount

    db.setBankBalance(account, cachedAccounts[account].amount)
    return true
end
exports('addAccountMoney', AddAccountMoney)

local function getPlayerData(source, id)
    local Player = GetPlayerObject(tonumber(id))
    if not Player then Player = GetPlayerObjectFromID(id) end
    if not Player then
        local msg = ("Cannot Find Account(%s)"):format(id)
        print(locale("invalid_account", id))
        if source then
            Notify(source, {title = locale("bank_name"), description = msg, type = "error"})
        end
    end
    return Player
end

lib.callback.register('Renewed-Banking:server:deposit', function(source, data)
    print(source)
    local account = cachedPlayers[source]

    local Player = GetPlayerObject(source)
    local amount = tonumber(data.amount)

    if not amount or amount < 1 then
        Notify(source, {title = locale("bank_name"), description = locale("invalid_amount", "deposit"), type = "error"})
        return false
    end

    if not data.comment or data.comment == "" then data.comment = locale("comp_transaction", account.name, "deposited", amount) else sanitizeMessage(data.comment) end
    if RemoveMoney(Player, amount, 'cash', data.comment) then

        local accountCached = cachedAccounts[data.fromAccount]

        local Player2 = accountCached and data.fromAccount or account.name

        local transaction = handleTransaction(data.fromAccount, locale("personal_acc") .. data.fromAccount, amount, data.comment, account.name, Player2, "deposit")

        if accountCached then
            AddAccountMoney(data.fromAccount, amount)
            accountCached.transactions[#accountCached.transactions+1] = transaction
        else
            account.transactions[#account.transactions+1] = transaction
            AddMoney(Player, amount, 'bank', data.comment)
        end

        return {trans = transaction, cash = Player.PlayerData.money.cash, bank = Player.PlayerData.money.bank}
    else
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, locale("not_enough_money"))
        return false
    end
end)

function RemoveAccountMoney(account, amount)
    local accountCached = cachedAccounts[account]

    if not accountCached then
        print(locale("invalid_account", account))
        return false
    end
    if accountCached.amount < amount then
        print(locale("broke_account", account, amount))
        return false
    end

    accountCached.amount -= amount
    db.setBankBalance(account, accountCached.amount)
    return true
end
exports('removeAccountMoney', RemoveAccountMoney)

lib.callback.register('Renewed-Banking:server:withdraw', function(source, data)
    local account = cachedPlayers[source]
    local Player = GetPlayerObject(source)
    local amount = tonumber(data.amount)

    if not amount or amount < 1 then
        Notify(source, {title = locale("bank_name"), description = locale("invalid_amount", "withdraw"), type = "error"})
        return false
    end

    local name = GetCharacterName(Player)
    local funds = GetFunds(Player)
    if not data.comment or data.comment == "" then data.comment = locale("comp_transaction", account.name, "withdrawed", amount) else sanitizeMessage(data.comment) end

    local accountCached = cachedAccounts[data.fromAccount]

    local canWithdraw
    if accountCached then
        canWithdraw = RemoveAccountMoney(data.fromAccount, amount)
    else
        canWithdraw = funds.bank >= amount and RemoveMoney(Player, amount, 'bank', data.comment) or false
    end

    if not canWithdraw then
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, locale("not_enough_money"))
        return false
    end

    local Player2 = accountCached and data.fromAccount or account.name

    AddMoney(Player, amount, 'cash', data.comment)

    local transaction = handleTransaction(data.fromAccount,locale("personal_acc") .. data.fromAccount, amount, data.comment, Player2, name, "withdraw")
    if accountCached then
        accountCached.transactions[#accountCached.transactions+1] = transaction
    else
        account.transactions[#account.transactions+1] = transaction
    end


    return {trans = transaction, cash = Player.PlayerData.money.cash, bank = Player.PlayerData.money.bank}
end)

-- Im not even gonna attempt to wrap my head around this rn...
lib.callback.register('Renewed-Banking:server:transfer', function(source, data)
    local Player = GetPlayerObject(source)
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then
        Notify(source, {title = locale("bank_name"), description = locale("invalid_amount", "transfer"), type = "error"})
        return false
    end

    local name = GetCharacterName(Player)
    if not data.comment or data.comment == "" then data.comment = locale("comp_transaction", name, "transfered", amount) else sanitizeMessage(data.comment) end
    local transaction
    if cachedAccounts[data.fromAccount] then
        if cachedAccounts[data.stateid] then
            local canTransfer = RemoveAccountMoney(data.fromAccount, amount)
            if canTransfer then
                AddAccountMoney(data.stateid, amount)
                local title = ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount)
                transaction = handleTransaction(data.fromAccount, title, amount, data.comment, cachedAccounts[data.fromAccount].name, cachedAccounts[data.stateid].name, "withdraw")
                handleTransaction(data.stateid, title, amount, data.comment, cachedAccounts[data.fromAccount].name, cachedAccounts[data.stateid].name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, locale("not_enough_money"))
                return false
            end
        else
            local Player2 = getPlayerData(source, data.stateid)
            if not Player2 then
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, locale("fail_transfer"))
                return false
            end
            local canTransfer = RemoveAccountMoney(data.fromAccount, amount)
            if canTransfer then
                AddMoney(Player2, amount, 'bank', data.comment)
                local name = GetCharacterName(Player2)
                transaction = handleTransaction(data.fromAccount, ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount), amount, data.comment, cachedAccounts[data.fromAccount].name, name, "withdraw")
                handleTransaction(data.stateid, ("%s / %s"):format(cachedAccounts[data.fromAccount].name, data.fromAccount), amount, data.comment, cachedAccounts[data.fromAccount].name, name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, locale("not_enough_money"))
                return false
            end
        end
    else
        local funds = GetFunds(Player)
        if cachedAccounts[data.stateid] then
            if funds.bank >= amount and RemoveMoney(Player, amount, 'bank', data.comment) then
                AddAccountMoney(data.stateid, amount)
                transaction = handleTransaction(data.fromAccount, locale("personal_acc") .. data.fromAccount, amount, data.comment, name, cachedAccounts[data.stateid].name, "withdraw")
                handleTransaction(data.stateid, locale("personal_acc") .. data.fromAccount, amount, data.comment, name, cachedAccounts[data.stateid].name, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, locale("not_enough_money"))
                return false
            end
        else
            local Player2 = getPlayerData(source, data.stateid)
            if not Player2 then
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, locale("fail_transfer"))
                return false
            end

            if funds.bank >= amount and RemoveMoney(Player, amount, 'bank', data.comment) then
                AddMoney(Player2, amount, 'bank', data.comment)
                local name2 = GetCharacterName(Player2)
                transaction = handleTransaction(data.fromAccount, locale("personal_acc") .. data.fromAccount, amount, data.comment, name, name2, "withdraw")
                handleTransaction(data.stateid, locale("personal_acc") .. data.fromAccount, amount, data.comment, name, name2, "deposit", transaction.trans_id)
            else
                TriggerClientEvent('Renewed-Banking:client:sendNotification', source, locale("not_enough_money"))
                return false
            end
        end
    end

    return {trans = transaction, cash = Player.PlayerData.money.cash, bank = Player.PlayerData.money.bank}
end)

RegisterNetEvent('Renewed-Banking:server:createNewAccount', function(accountid)
    local account = cachedPlayers[source]
    local Player = GetPlayerObject(source)
    if cachedAccounts[accountid] then return Notify(source, {title = locale("bank_name"), description = locale("account_taken"), type = "error"}) end
    local cid = GetIdentifier(Player)
    cachedAccounts[accountid] = {
        id = accountid,
        type = locale("org"),
        name = accountid,
        frozen = 0,
        amount = 0,
        transactions = {},
        auth = { [cid] = true },
        creator = cid

    }
    account.accounts[#account.accounts+1] = {
        account = accountid,
        withdraw = true,
        deposit = true
    }
    db.addAccount(accountid, cachedAccounts[accountid].amount, cachedAccounts[accountid].frozen, cid)
    db.addAccountAuth(cid, accountid)
end)

lib.callback.register('Renewed-Banking:server:getPlayerAccounts', function(source)
    local account = cachedPlayers[source]

    local ownedAccounts = db.selectOwnedAccounts(account.charId)

    return ownedAccounts or false
end)

lib.callback.register('Renewed-Banking:server:getMembers', function(source, playerAccount)
    local account = cachedPlayers[source]

    local authorized
    for i = 1, #account.accounts do
        if account.accounts[i].account == playerAccount then
            authorized = true
            break
        end
    end

    if not authorized then return false end

    local members = db.selectMembers(playerAccount)

    print(members)

    return members or false
end)


RegisterNetEvent("Renewed-Banking:server:viewMemberManagement", function(data)
    local Player = GetPlayerObject(source)

    local account = data.account
    local retData = {
        account = account,
        members = {}
    }
    local cid = GetIdentifier(Player)

    for k,_ in pairs(cachedAccounts[account].auth) do
        local Player2 = getPlayerData(source, k)
        if cid ~= GetIdentifier(Player2) then
            retData.members[k] = GetCharacterName(Player2)
        end
    end

    TriggerClientEvent("Renewed-Banking:client:viewMemberManagement", source, retData)
end)

--[[RegisterNetEvent('Renewed-Banking:server:addAccountMember', function(account, member)
    local Player = GetPlayerObject(source)

    if GetIdentifier(Player) ~= cachedAccounts[account].creator then print(locale("illegal_action", GetPlayerName(source))) return end
    local Player2 = getPlayerData(source, member)
    if not Player2 then return end

    local targetCID = GetIdentifier(Player2)

    if cachedPlayers[member] then
        cachedPlayers[member].accounts[#cachedPlayers[member].accounts+1] = account
    end

    local auth = {}
    for k in pairs(cachedAccounts[account].auth) do auth[#auth+1] = k end
    auth[#auth+1] = targetCID
    cachedAccounts[account].auth[targetCID] = true
    MySQL.update('UPDATE bank_accounts_new SET auth = ? WHERE id = ?',{json.encode(auth), account})
end)

RegisterNetEvent('Renewed-Banking:server:removeAccountMember', function(data)
    local Player = GetPlayerObject(source)
    if GetIdentifier(Player) ~= cachedAccounts[data.account].creator then print(locale("illegal_action", GetPlayerName(source))) return end
    local Player2 = getPlayerData(source, data.cid)
    if not Player2 then return end

    local targetCID = GetIdentifier(Player2)
    local tmp = {}
    for k in pairs(cachedAccounts[data.account].auth) do
        if targetCID ~= k then
            tmp[#tmp+1] = k
        end
    end

    if cachedPlayers[targetCID] then
        local newAccount = {}
        if #cachedPlayers[targetCID].accounts >= 1 then
            for k=1, #cachedPlayers[targetCID].accounts do
                if cachedPlayers[targetCID].accounts[k] ~= data.account then
                    newAccount[#newAccount+1] = cachedPlayers[targetCID].accounts[k]
                end
            end
        end
        cachedPlayers[targetCID].accounts = newAccount
    end
    cachedAccounts[data.account].auth[targetCID] = nil
    MySQL.update('UPDATE bank_accounts_new SET auth = ? WHERE id = ?',{json.encode(tmp), data.account})
end)]]

RegisterNetEvent('Renewed-Banking:server:deleteAccount', function(data)
    local account = data.account
    local Player = GetPlayerObject(source)
    local cid = GetIdentifier(Player)

    if cachedAccounts[account].creator ~= cid then return end
    cachedAccounts[account] = nil

    if type(cachedPlayers[source].accounts) == 'table' then
        for i = 1, #cachedPlayers[source].accounts do
            if cachedPlayers[source].accounts[i].account == account then
                table.remove(cachedPlayers[source].accounts, i)
            end
        end
    else
        if cachedPlayers[source].accounts == account then
            cachedPlayers[source].accounts = {}
        end
    end

    db.nukeAccount(account)
    db.nukeAccountMembers(account)
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

local function cloneTable(source)
    if type(source) ~= "table" then return source end

    local clone = {}
    for key, value in pairs(source) do
        clone[key] = cloneTable(value)
    end
    return clone
end

local function updateAccountName(account, newName, src)
    if not account or not newName then return false end
    if not cachedAccounts[account] then
        local getTranslation = locale("invalid_account", account)
        print(getTranslation)
        if src then Notify(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"}) end
        return false
    end
    if cachedAccounts[newName] then
        local getTranslation = locale("existing_account", account)
        print(getTranslation)
        if src then Notify(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"}) end
        return false
    end
    if src then
        local Player = GetPlayerObject(src)
        if GetIdentifier(Player) ~= cachedAccounts[account].creator then
            local getTranslation = locale("illegal_action", GetPlayerName(src))
            print(getTranslation)
            Notify(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"})
            return false
        end
    end

    cachedAccounts[newName] = cloneTable(cachedAccounts[account])
    cachedAccounts[newName].id = newName
    cachedAccounts[newName].name = newName
    cachedAccounts[account] = nil
    for _, id in ipairs(GetPlayers()) do
        id = tonumber(id)
        local Player2 = GetPlayerObject(id)
        if not Player2 then goto Skip end
        local cid = GetIdentifier(Player2)
        if type(cachedPlayers[id].accounts) == 'table' then
            for i = 1, #cachedPlayers[id].accounts do
                if cachedPlayers[id].accounts[i].account == account then
                    table.remove(cachedPlayers[id].accounts, i)
                    cachedPlayers[id].accounts[#cachedPlayers[id].accounts+1] = newName
                end
            end
        else
            if cachedPlayers[id].accounts == account then
                cachedPlayers[id].accounts = newName
            end
        end
        ::Skip::
    end
    db.updateAccountName(newName, account)
    db.updateAccountMembers(newName, account)
    return true
end

RegisterNetEvent('Renewed-Banking:server:changeAccountName', function(account, newName)
    updateAccountName(account, newName, source)
end) exports("changeAccountName", updateAccountName)-- Should only use this on very secure backends to avoid anyone using this as this is a server side ONLY export --

local function addAccountMember(account, member)
    if not account or not member then return end

    if not cachedAccounts[account] then print(locale("invalid_account", account)) return end

    local Player2 = getPlayerData(false, member)
    if not Player2 then return end

    local source = Player.source
    if cachedPlayers[source] then
        if type(cachedPlayers[source].accounts) == 'table' then
            cachedPlayers[source].accounts[#cachedPlayers[source].accounts+1] = account
        else
            cachedPlayers[source].accounts[1] = cachedPlayers[source].accounts
            cachedPlayers[source].accounts[2] = account
        end
    end
    db.addAccountAuth(cachedPlayers[source].charId, account)
end exports("addAccountMember", addAccountMember)

local function removeAccountMember(account, member)
    local Player2 = getPlayerData(false, member)

    if not Player2 then return end
    local source = Player2.source
    if not cachedAccounts[account] then print(locale("invalid_account", account)) return end


    if cachedPlayers[source] then
        if type(cachedPlayers[source].accounts) == 'table' then
            for k=1, #cachedPlayers[source].accounts do
                if cachedPlayers[source].accounts[k] == account then
                    table.remove(cachedPlayers[source].accounts, k)
                end
            end
        else
            if cachedPlayers[source].accounts and cachedPlayers[source].accounts == account then
                cachedPlayers[source].accounts = {}
            end
        end
    end
    db.removeAccountMembers(cachedPlayers[source].charId, account)
end
exports("removeAccountMember", removeAccountMember)

local function getAccountTransactions(account)
    if cachedAccounts[account] then
        return cachedAccounts[account].transactions
    elseif cachedPlayers[account] then
        return cachedPlayers[account].transactions
    end
    print(locale("invalid_account", account))
    return false
end
exports("getAccountTransactions", getAccountTransactions)

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
        local Player = GetPlayerObject(source)
        if not Player then return end

        local iPlayer = GetPlayerObject(args.target)
        if not iPlayer then return Notify(source, {title = locale("bank_name"), description = locale('unknown_player', args.target), type = "error"}) end

        if IsDead(Player) then return Notify(source, {title = locale("bank_name"), description = locale('dead'), type = "error"}) end
        if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(args.target))) > 10.0 then return Notify(source, {title = locale("bank_name"), description = locale('too_far_away'), type = "error"}) end
        if args.amount < 0 then return Notify(source, {title = locale("bank_name"), description = locale('invalid_amount', "give"), type = "error"}) end

        if RemoveMoney(Player, args.amount, 'cash') then
            AddMoney(iPlayer, args.amount, 'cash')
            local nameA = GetCharacterName(Player)
            local nameB = GetCharacterName(iPlayer)
            Notify(source, {title = locale("bank_name"), description = locale('give_cash', nameB, tostring(args.amount)), type = "error"})
            Notify(args.target, {title = locale("bank_name"), description = locale('received_cash', nameA, tostring(args.amount)), type = "success"})
        else
            Notify(args.target, {title = locale("bank_name"), description = locale('not_enough_money'), type = "error"})
        end
    end)
end

function ExportHandler(resource, name, cb)
    AddEventHandler(('__cfx_export_%s_%s'):format(resource, name), function(setCB)
        setCB(cb)
    end)
end