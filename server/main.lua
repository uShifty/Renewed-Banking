local cachedAccounts = {}
local cachedPlayers = {}

-- rewritten code --
local db = require('modules.db')
local tempAccount = require('server.accounts')
local Utils = require('modules.utils.server')
local Framework = require('server.newFramework')
local table = lib.table

local playerAccess = {}

function UpdatePlayerAccount(source)
    if not source then return end

    source = tonumber(source)

    tempAccount.addPlayerAccount(source)
    local left = tempAccount(source)
    if not left then return end -- A error happened and player didnt get added to the table

    local access = { left }
    local numAccounts = 1
    local playerAccounts = db.selectCharacterGroups(left.id)
    if playerAccounts then
        playerAccounts = type(playerAccounts) == 'string' and { playerAccounts } or playerAccounts

        for i = 1, #playerAccounts do
            local actualAccount = playerAccounts[i].account or playerAccounts[i]

            local acc = tempAccount(actualAccount)

            if acc then
                numAccounts += 1
                access[numAccounts] = acc
            end
        end
    end

    playerAccess[source] = access
end

lib.callback.register('renewed-banking:server:getPlayerData', function(source)
    local PlayerData = {
        name = Framework.getCharName(source),
        id = Framework.getCharId(source),
    }
    return PlayerData
end)

lib.callback.register('renewed-banking:server:initalizeBanking', function(source)
    return playerAccess[source]
end)

-- Events
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
        Notify(source, {title = locale("bank_name"), description = locale("invalid_amount", "deposit"), type = "error"})
        return false
    end

    local left = tempAccount(source)

    if not left then return end

    local secondAccount = left.id == data.fromAccount and source or data.fromAccount

    local right = secondAccount ~= source and tempAccount(secondAccount) or left

    if secondAccount ~= source and right == left then return end

    data.comment = data.comment and data.comment ~= "" and Utils.sanitizeMessage(data.comment) or locale("comp_transaction", left.name, "deposited", amount)

    local success = tempAccount.removeCash(source, amount, data.comment)

    if not success then Utils.sendNotif(source, locale("not_enough_money")) print("HERE MAYBE?") return end

    local transaction = handleTransaction(data.fromAccount, locale("personal_acc") .. data.fromAccount, amount, data.comment, left.name, right.id, "deposit")

    local newBank = tempAccount.addMoney(secondAccount, amount, data.comment)


    -- So this returnData needs to return the NEW BANK BALANCE of the ACCOUNT that you just deposited into
    local returnData = type(newBank) == 'table' and {trans = transaction, bank = newBank.amount} or {trans = transaction}

    return returnData
end)


function GetAccountMoney(account)
    local acc = tempAccount(account)
    if not acc then
        print(locale("invalid_account", account))
        return false
    end
    return acc.amount
end
exports('getAccountMoney', GetAccountMoney)

function AddAccountMoney(account, amount)
    local acc = tempAccount(account)
    if not acc then
        locale("invalid_account", account)
        return false
    end
    tempAccount.addMoney(account, amount)
    db.setBankBalance(account, acc.amount)
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

function RemoveAccountMoney(account, amount)
    local acc = tempAccount(account)
    if not acc then return print(locale("invalid_account", account)) end

    local withdraw = tempAccount.removeMoney(account, amount)
    if not withdraw then return print(locale("broke_account", account, amount)) end

    db.setBankBalance(account, acc.amount)
    return true
end
exports('removeAccountMoney', RemoveAccountMoney)

lib.callback.register('Renewed-Banking:server:withdraw', function(source, data)
    print('data', json.encode(data))
    local amount = tonumber(data.amount)
    if not amount or amount < 1 then
        Notify(source, {title = locale("bank_name"), description = locale("invalid_amount", "withdraw"), type = "error"})
        return false
    end

    local left = tempAccount(source)
    if not left then return end

    local secondAccount = left.id == data.fromAccount and source or data.fromAccount
    local right = secondAccount ~= source and tempAccount(secondAccount) or left

    if secondAccount ~= source and right == left then return end

    data.comment = data.comment and data.comment ~= "" and Utils.sanitizeMessage(data.comment) or locale("comp_transaction", right.name, "withdrawed", amount)
    local success = tempAccount.removeMoney(secondAccount, amount, data.comment)
    if not success then Utils.sendNotif(source, locale("not_enough_money")) return end

    tempAccount.addCash(source, amount, data.comment)
    local transaction = handleTransaction(data.fromAccount,locale("personal_acc") .. data.fromAccount, amount, data.comment, right.id, left.name, "withdraw")

    local money = GetFunds(source)
    local returnData = {player = { cash = money.cash, account = left.id}, primary = {bank = money.bank, account = secondAccount, trans = transaction}}
    print('returnData', json.encode(returnData))
    return returnData
end)

-- Im not even gonna attempt to wrap my head around this rn...

lib.callback.register('Renewed-Banking:server:transfer', function(source, data)
    print('Renewed-Banking:server:transfer')
    local amount = tonumber(data.amount)

    if not amount or amount < 1 then
        Notify(source, {title = locale("bank_name"), description = locale("invalid_amount", "transfer"), type = "error"})
        return false
    end

    local initiatorAcc = tempAccount(source)
    if not initiatorAcc then return print('initiatorAcc not found')end

    local fromAccount = tempAccount(data.fromAccount)
    if not fromAccount then return print('fromAccount not found') end

    local toAccount = tempAccount(data.stateid)
    if not toAccount then return print('toAccount not found') end

    local comment = data.comment and data.comment ~= "" and Utils.sanitizeMessage(data.comment) or locale("comp_transaction", initiatorAcc.name, "transferred", amount)

    local success = tempAccount.removeMoney(data.fromAccount, amount, comment)
    if not success then
        Utils.sendNotif(source, locale("not_enough_money"))
        print(locale("not_enough_money"))
        return false
    end

    tempAccount.addMoney(data.stateid, amount, comment)

    local transaction1 = handleTransaction(data.fromAccount, locale("personal_acc") .. data.fromAccount, amount, comment, initiatorAcc.name, toAccount.name, "transfer")
    handleTransaction(data.stateid, locale("personal_acc") .. data.stateid, amount, comment, toAccount.name, initiatorAcc.name, "transfer", transaction1.trans_id)

    local money = GetFunds(source)
    local returnData = {
        player = {cash = money.cash, account = initiatorAcc.id},
        primary = {bank = money.bank, account = fromAccount, trans = transaction1},
        secondary = {bank = toAccount.amount, account = toAccount.id}
    }

    print('ReturnData', json.encode(returnData))
    return returnData
end)

lib.callback.register('Renewed-Banking:server:createNewAccount', function(source, accountid)
    local acc = tempAccount(accountid)
    if acc then Notify(source, {title = locale("bank_name"), description = locale("account_taken"), type = "error"}) return false end

    local cid = Framework.getCharId(source)
    tempAccount.addBankAccount(accountid, cid)

    db.addAccount(accountid, 0, 0, cid)
    db.addAccountAuth(cid, accountid)
    return true
end)

lib.callback.register('Renewed-Banking:server:getPlayerAccounts', function(source)
    local account = Framework.getCharId(source)
    local ownedAccounts = db.selectOwnedAccounts(account)
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

local function addAccountMember(account, member)
    local bankAccount = tempAccount(account)
    if not bankAccount then print(locale("invalid_account", account)) return false end
    local Player2 = getPlayerData(source, member)
    if not Player2 then return false end
    local source = Player.source

    playerAccess[source][#playerAccess[source]+1] = bankAccount
    db.addAccountMembers(member, account)
    return true
end
exports("addAccountMember", addAccountMember)

lib.callback.register('Renewed-Banking:server:addAccountMember', function(source, accountName, member)
    if not accountName or not member then return false end

    local cid = Framework.getCharId(source)
    local bankAccount = tempAccount(accountName)

    if cid ~= bankAccount.creator then print(locale("illegal_action", GetPlayerName(source))) return end
    local Player2 = getPlayerData(source, member)
    if not Player2 then return false end
    local targetCID = GetIdentifier(Player2.source)
    if not targetCID then return false end

    playerAccess[source][#playerAccess[source]+1] = bankAccount
    db.addAccountMembers(member, accountName)
    return true
end)

lib.callback.register('Renewed-Banking:server:removeAccountMembers', function(source, accoundId, members)
    local cid = Framework.getCharId(source)
    local acc = tempAccount(accoundId)
    if cid ~= acc.creator then print(locale("illegal_action", GetPlayerName(source))) return false end
    for k=1,#members do
        db.removeAccountMembers(members[k].id, accoundId)
    end
    return true
end)

lib.callback.register('Renewed-Banking:server:deleteAccount', function(source, account)
    local acc = tempAccount(account)
    if not acc then return end

    local cid = Framework.getCharId(source)
    if acc.creator ~= cid then return end

    tempAccount.nukeBankAccount(account)
    db.nukeAccount(account)
    db.nukeAccountMembers(account)
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

    local acc = tempAccount(account)
    if not acc then
        local getTranslation = locale("invalid_account", account)
        if src then Notify(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"}) end
        return false
    end

    local newAcc = tempAccount(newName)
    if newAcc then
        local getTranslation = locale("existing_account", newName)
        if src then Notify(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"}) end
        return false
    end

    if src then
        local cid = Framework.getCharId(src)
        if cid ~= acc.creator then
            local getTranslation = locale("illegal_action", GetPlayerName(src))
            Notify(src, {title = locale("bank_name"), description = split(getTranslation, '0')[2], type = "error"})
            return false
        end
    end

    tempAccount.changeAccountName(account, newName)
    db.updateAccountName(newName, account)
    db.updateAccountMembers(newName, account)
    db.updateTransactions(account, newName)
    return true
end

lib.callback.register('Renewed-Banking:server:changeAccountName', function(source, account, newName)
    return updateAccountName(account, newName, source)
end)

exports("changeAccountName", updateAccountName)-- Should only use this on very secure backends to avoid anyone using this as this is a server side ONLY export --

local function removeAccountMember(account, member)
    local acc = tempAccount(account)
    if not acc then print(locale("invalid_account", account)) return end
    db.removeAccountMembers(member, account)
end
exports("removeAccountMember", removeAccountMember)

local function getAccountTransactions(account)
    local acc = tempAccount(account)
    if not acc then return print(locale("invalid_account", account)) end
    return db.getTransactions(data.account)
end
exports("getAccountTransactions", getAccountTransactions)

lib.callback.register('renewed-banking:server:getAccountTransactions', function(source, data)
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