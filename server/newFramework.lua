local Renewed = exports['Renewed-Lib']:getLib()

local Framework = {}

function Framework.addMoney(source, amount, mType, reason)
    if not source or not amount or not mType then return false end

    return Renewed.addMoney(source, amount, mType, reason)
end

function Framework.removeMoney(source, amount, mType, reason)
    if not source or not amount or not mType then return false end

    return Renewed.removeMoney(source, amount, mType, reason)
end

function Framework.getCharId(source)
    if not source then return false end
    print("Framework.getCharId")
    return Renewed.getCharId(source)
end

function Framework.getCharName(source)
    if not source then return false end

    return Renewed.getCharName(source)
end

function Framework.getMoney(source, mType, all)
    return Renewed.getMoney(source, mType, all)
end

return Framework