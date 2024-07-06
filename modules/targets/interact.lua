local Peds
return {
    AddHook = function(peds)
        Peds = peds

        local targetOpts ={{
            label = locale('view_bank'),
            event = 'Renewed-Banking:client:openBankUI',
            args = {atm = false},
        }}

        for _, ped in pairs(Peds) do
            exports.interact:AddLocalEntityInteraction({
                entity = ped,
                id = 'renewed_banking_openui',
                distance = 3.0,
                interactDst = 2.0,
                ignoreLos = true,
                offset = vec3(0.0, 0.0, 0.3),
                options = targetOpts
            })
        end

        for _, model in pairs(Config.atms) do
            targetOpts[1].args = {atm = true}
            exports.interact:AddModelInteraction({
                model = model,
                offset = vec3(0.0, 0.0, 1.0),
                id = 'renewed_banking_openui',
                distance = 3.0,
                interactDst = 2.0,
                ignoreLos = true,
                options = targetOpts
            })
        end
    end,
    RemoveHook = function()
        for _, ped in pairs(Peds) do
            exports.interact:RemoveLocalEntityInteraction(ped, 'renewed_banking_openui')
        end
        for _, model in pairs(Config.atms) do
            exports.interact:RemoveModelInteraction(model, 'renewed_banking_openui')
        end
    end
}
