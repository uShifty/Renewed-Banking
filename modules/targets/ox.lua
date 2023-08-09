local peds
local Target = {
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
        exports.ox_target:addModel(Config.atms, {{
            name = 'renewed_banking_openui',
            event = 'Renewed-Banking:client:openBankUI',
            icon = 'fas fa-money-check',
            label = locale('view_bank'),
            atm = true,
            canInteract = function(_, distance)
                return distance < 2.5
            end
        }})
        exports.ox_target:addLocalEntity(peds.basic, targetOpts)
        targetOpts[#targetOpts+1]={
            name = 'renewed_banking_accountmng',
            event = 'Renewed-Banking:client:accountManagmentMenu',
            icon = 'fas fa-money-check',
            label = locale('manage_bank'),
            atm = false,
            canInteract = function(_, distance)
                return distance < 4.5
            end
        }
        exports.ox_target:addLocalEntity(peds.adv, targetOpts)
    end,
    RemoveHook = function()
        exports.ox_target:removeModel(Config.atms, {'renewed_banking_openui'})
        exports.ox_target:removeEntity(peds.basic, {'renewed_banking_openui'})
        exports.ox_target:removeEntity(peds.adv, {'renewed_banking_openui','renewed_banking_accountmng'})
    end
}
return Target