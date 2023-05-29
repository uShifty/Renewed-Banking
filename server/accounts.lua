local db = require('modules.db')
local Framework = require 'server.newFramework'

local account = {}

setmetatable(account, {
	__call = function(_, id)
        return account[id] or false
	end
})

CreateThread(function()
    if not LoadResourceFile("Renewed-Banking", 'web/public/build/bundle.js') or GetCurrentResourceName() ~= "Renewed-Banking" then
        error(locale("ui_not_built"))
        return StopResource("Renewed-Banking")
    end


    pcall(MySQL.query.await, 'DELETE FROM bank_transactions WHERE date < (NOW() - INTERVAL 6 MONTH)')

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


function account.addPlayerAccount(source)
    if not source then return end

    source = tonumber(source)

    local id = Framework.getCharId(source)

    if not id then return end

    account[source] = {
        id = id,
        isPlayer = true,
        type = locale("personal"),
        name = Framework.getCharName(source),
        frozen = false,
        cash = 0,
        amount = 0,
        transactions = db.getTransactions(id) or {}
    }
end

function account.addMoney(bank, amount, comment)
    local left = account(bank)

    if not left then print("NO GOOD") return end

    if left.isPlayer then
        local success = Framework.addMoney(bank, amount, 'bank', comment)

        if not success then return false end
    else
        left.amount += amount
        db.setBankBalance(bank, left.amount)

        return {amount = left.amount, added = amount}
    end

    return true
end

function account.removeMoney(bank, amount, comment)
    local left = account[bank]

    if not left then return end


    if left.isPlayer then
        local success = Framework.removeMoney(bank, amount, 'bank', comment)

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


    return Framework.removeMoney(bank, amount, 'cash', comment)
end


return account