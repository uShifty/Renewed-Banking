local Type = type
return {
    genTransactionID = function()
        local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        return string.gsub(template, '[xy]', function (c)
            local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', v)
        end)
    end,
    sanitizeMessage = function(message)
        message = type(message) == 'string' and message or tostring(message)
        message = message:gsub("'", "''"):gsub("\\", "\\\\")

        return message
    end,
    sendNotif = function(source, label)
        TriggerClientEvent('Renewed-Banking:client:sendNotification', source, label)
    end,
    Notify = function(src, settings)
        TriggerClientEvent("ox_lib:notify", src, settings)
    end,
    validateTransaction = function(account, title, amount, message, issuer, receiver, transType, transID)
        if not account or Type(account) ~= 'string' then return print(locale("err_trans_account", account)) end
        if not title or Type(title) ~= 'string' then return print(locale("err_trans_title", title)) end
        if not amount or Type(amount) ~= 'number' then return print(locale("err_trans_amount", amount)) end
        if not message or Type(message) ~= 'string' then return print(locale("err_trans_message", message)) end
        if not issuer or Type(issuer) ~= 'string' then return print(locale("err_trans_issuer", issuer)) end
        if not receiver or Type(receiver) ~= 'string' then return print(locale("err_trans_receiver", receiver)) end
        if not transType or Type(transType) ~= 'string' then return print(locale("err_trans_type", transType)) end
        if transID and Type(transID) ~= 'string' then return print(locale("err_trans_transID", transID)) end
        return true
    end
}