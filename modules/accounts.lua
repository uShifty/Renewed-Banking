local db = require('modules.db')
local Framework = require('modules.framework')

local account = {}

local function getAccountById(id)
    for test, acc in pairs(account) do
        if type(acc) ~= "table" then goto skip end
        if acc.id == id then
            return acc
        end
        ::skip::
    end
    return false
end

setmetatable(account, {
    __call = function(_, id)
        return account[id] or getAccountById(id)
    end
})

CreateThread(function()
    local resourceName = GetCurrentResourceName()
    if not LoadResourceFile("Renewed-Banking", 'web/public/build/bundle.js') or resourceName ~= "Renewed-Banking" then
        error(locale("ui_not_built"))
        return StopResource(resourceName)
    end

    local legacyCheck = db.getLegacyAccounts()
    if legacyCheck then
        db.migrateData(legacyCheck)
    else
        local newSchema = db.checkDatabaseSchema()
        if not newSchema then
            db.createDatabaseSchema()
        end
    end

    if Config.purgeTransactions then
        pcall(MySQL.query.await, 'DELETE FROM bank_transactions WHERE date < (NOW() - INTERVAL 6 MONTH)')
    end

    local bankData = db.selectBankAccounts()
    for _, v in pairs(bankData) do
        local job = v.id
        account[job] = { --  cachedAccounts[#cachedAccounts+1]
            id = job,
            type = locale("org"),
            name = job,
            frozen = v.isFrozen == 1,
            amount = v.amount,
            transactions = db.getTransactions(job) or {},
            creator = v.creator
        }
    end
end)

function account.AddPlayer(source)
    if not source then return end

    source = tonumber(source)
    local id = Framework.getCharId(source)
    if not id then return print(locale("invalid_account", id)) end

    account[source] = {
        id = id,
        isPlayer = true,
        source = source,
        type = locale("personal"),
        name = Framework.getCharName(source),
        frozen = false,
        cash = 0,
        amount = 0,
        transactions = db.getTransactions(id) or {}
    }
end

function account.AddBank(id, cid)
    if not id or account[id] then return end

    account[id] = {
        id = id,
        type = locale("org"),
        name = id,
        frozen = false,
        cash = 0,
        amount = 0,
        transactions = db.getTransactions(id) or {},
        creator = cid
    }
    return account[id]
end

function account.changeName(id, newId)
    if not id or not account[id] then return end
    if not account[id] or account[newId] then return end

    account[newId] = account[id]
    account[newId].id = newId
    account[newId].name = newId
    account[id] = nil
end

function account.nuke(id)
    if not id or not account[id] then return end
    account[id] = nil
end

function account.addMoney(bank, amount, comment)
    local left = account(bank)
    if not left then print(locale("invalid_account", bank)) return end

    if left.isPlayer then
        local success = Framework.addMoney(left.source, amount, 'bank', comment)
        if not success then return false end
    else
        left.amount += amount
        db.setBankBalance(bank, left.amount)
        return {amount = left.amount, added = amount}
    end

    return true
end

function account.addCash(bank, amount, comment)
    local left = account(bank)
    if not left or not left.isPlayer then return end
    Framework.addMoney(bank, amount, 'cash', comment)

    return {amount = left.amount, added = amount}
end

function account.removeMoney(bank, amount, comment)
    local left = account(bank)
    if not left then return print(locale("invalid_account", bank)) end

    if left.isPlayer then
        local success = Framework.removeMoney(left.source, amount, 'bank', comment)
        if not success then return false end
    else
        if left.amount < amount then return end

        left.amount -= amount
        db.setBankBalance(bank, left.amount)

        return {amount = left.amount, added = amount}
    end

    return true
end

function account.removeCash(bank, amount, comment)
    local left = account[bank]
    if not left or not left.isPlayer then return end

    return Framework.removeMoney(left.source, amount, 'cash', comment)
end

return account
