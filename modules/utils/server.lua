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
    end
}