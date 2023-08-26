return {
    initFramework = function()
        ExportHandler("esx_society", "GetSociety", GetAccountMoney)
        RegisterServerEvent('esx_society:getSociety', GetAccountMoney)
        RegisterServerEvent('esx_society:depositMoney', AddAccountMoney)
        RegisterServerEvent('esx_society:withdrawMoney', RemoveAccountMoney)
        AddEventHandler('esx:playerLoaded', function(source)
            Wait(250)
            UpdatePlayerAccount(source)
        end)
    end
}