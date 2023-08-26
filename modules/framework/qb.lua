return {
    initFramework = function()
        ExportHandler("qb-management", "GetAccount", GetAccountMoney)
        ExportHandler("qb-management", "GetGangAccount", GetAccountMoney)
        ExportHandler("qb-management", "AddMoney", AddAccountMoney)
        ExportHandler("qb-management", "AddGangMoney", AddAccountMoney)
        ExportHandler("qb-management", "RemoveMoney", RemoveAccountMoney)
        ExportHandler("qb-management", "RemoveGangMoney", RemoveAccountMoney)
        AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
            Wait(250)
            UpdatePlayerAccount(Player.PlayerData.source)
        end)
    end
}