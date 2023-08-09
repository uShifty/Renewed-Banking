
local peds
local Target = {
    AddHook = function(Peds)
        peds = Peds
        local targetOpts ={{
            event = 'Renewed-Banking:client:openBankUI',
            icon = 'fas fa-money-check',
            label = locale('view_bank'),
            atm = false
        }}
        exports['qb-target']:AddTargetModel(Config.atms,{
            options = {{
                event = "Renewed-Banking:client:openBankUI",
                icon = "fas fa-money-check",
                label = locale('view_bank'),
                atm = true
            }},
            distance = 2.5
        })

        exports['qb-target']:AddTargetEntity(peds.basic, { options = targetOpts, distance = 4.5 })
        targetOpts[#targetOpts+1]={
            event = 'Renewed-Banking:client:accountManagmentMenu',
            icon = 'fas fa-money-check',
            label = locale('manage_bank'),
            atm = false
        }
        exports['qb-target']:AddTargetEntity(peds.adv, { options = targetOpts, distance = 4.5 })
    end,
    RemoveHook = function()
        exports['qb-target']:RemoveTargetModel(Config.atms, locale('view_bank'))
        exports['qb-target']:RemoveTargetEntity(peds.basic, locale('view_bank'))
        exports['qb-target']:RemoveTargetEntity(peds.adv, {locale('view_bank'), locale('manage_bank')})
    end
}
return Target