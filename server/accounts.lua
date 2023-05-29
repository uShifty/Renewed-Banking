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

    local money = Framework.getMoney(source, nil, true)

    account[source] = {
        id = id,
        isPlayer = true,
        type = locale("personal"),
        name = Framework.getCharName(source),
        frozen = false,
        cash = money.cash,
        amount = money.bank,
        transactions = db.getTransactions(id) or {}
    }
end

function account.addMoney(bank, amount, comment)
    local left = account[bank]

    if not left then return end

    left.amount += amount

    if left.isPlayer then
        Framework.addMoney(bank, amount, 'bank', comment)
    else
        db.setBankBalance(bank, left.amount)
    end

    return { amount = left.amount }
end

function account.removeMoney(bank, amount, comment)
    local left = account[bank]

    if not left then return end

    if left.amount < amount then return end

    left.amount -= amount

    if left.isPlayer then
        Framework.removeMoney(bank, amount, 'bank', comment)
    else
        db.setBankBalance(bank, left.amount)
    end

    return { amount = left.amount }
end

function account.removeCash(bank, amount, comment)
    local left = account[bank]

    if not left or not left.isPlayer then return end

    if left.cash < amount then return end

    left.cash -= amount

    Framework.removeMoney(bank, left.cash, 'cash', comment)

    return { amount = left.cash }
end


AddEventHandler('Renewed-Lib:server:MoneyChange', function(source, mType, amount, changeType)
    print("ok")
    if mType ~= 'bank' and mType ~= 'cash' then return end

    local left = account(source)

    if not left then return end

    local setMoney = (changeType == 'set' and amount) or (changeType == 'add' and amount + amount) or amount - amount

    print(setMoney, mType)

    if mType == 'bank' then
        left.amount = setMoney
    else
        left.cash = setMoney
    end
end)

return account