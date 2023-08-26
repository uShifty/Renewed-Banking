local peds
return {
    AddHook = function(Peds)
        peds = Peds
        local targetOpts ={{
            name = 'renewed_banking_openui',
            event = 'Renewed-Banking:client:openBankUI',
            icon = 'fas fa-money-check',
            label = locale('view_bank'),
            atm = false,
            canInteract = function(_, distance)
                return distance < 4.5
            end
        }}
        exports.ox_target:addLocalEntity(peds, targetOpts)
        targetOpts[1].atm = true
        exports.ox_target:addModel(Config.atms, targetOpts)
    end,
    RemoveHook = function()
        exports.ox_target:removeModel(Config.atms, {'renewed_banking_openui'})
        exports.ox_target:removeEntity(peds, {'renewed_banking_openui'})
    end
}
