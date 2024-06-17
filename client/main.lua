local isVisible, FullyLoaded = false, false
local progressBar = Config.progressbar == 'circle' and lib.progressCircle or lib.progressBar
local PlayerPed = cache.ped
local require = lib.require

if Config.framework == 'qb'then
    FullyLoaded = LocalPlayer.state.isLoggedIn or false
elseif Config.framework == 'esx'then
    FullyLoaded = exports['es_extended']:getSharedObject().PlayerLoaded or false
else
    print(locale('unsupported_framework'))
end

local Target
local pedSpawned = false
local peds = {}
local blips = {}

AddStateBagChangeHandler('isLoggedIn', nil, function(_, _, value)
    FullyLoaded = value
end)

local function initializeBanking()
    local qbTarget = GetResourceState("qb-target") == "started"
    local oxTarget = GetResourceState("ox_target") == "started"

    if qbTarget then
        Target = require('modules.targets.qb')
    elseif oxTarget then 
        Target = require('modules.targets.ox')
    end

    CreatePeds()
    local locales = lib.getLocales()
    local PlayerData = lib.callback.await('renewed-banking:server:getPlayerData', false)
    SendNUIMessage({
        action = 'initializeInterface',
        translations = locales,
        currency = Config.currency,
        PlayerData= PlayerData
    })
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(100)
    FullyLoaded = true
    initializeBanking()
end)

RegisterNetEvent('esx:playerLoaded', function()
    Wait(100)
    FullyLoaded = true
    initializeBanking()
end)

AddEventHandler('onResourceStart', function(resourceName)
    Wait(100)
    if resourceName ~= GetCurrentResourceName() then return end
    if not FullyLoaded then return end
    initializeBanking()
end)

local function DeletePeds()
    if not pedSpawned then return end
    for k=1, #peds do
        DeletePed(peds[k])
        RemoveBlip(blips[k])
    end
    peds = {}
    pedSpawned = false
end

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    DeletePeds()
end)

AddEventHandler('esx:onPlayerLogout', function()
    DeletePeds()
end)

lib.onCache('ped', function(newPed)
	PlayerPed = newPed
end)

local function nuiHandler(val)
    isVisible = val
    SetNuiFocus(val, val)
end

local function openBankUI(isAtm)
    SendNUIMessage({action = 'setLoading', status = true})
    nuiHandler(true)

    local accounts = lib.callback.await('renewed-banking:server:initializeBanking', false)
    if not accounts then
        nuiHandler(false)
        lib.notify({title = locale('bank_name'), description = locale('loading_failed'), type = 'error'})
        return
    end

    SetTimeout(1000, function()
        SendNUIMessage({
            action = 'setVisible',
            status = isVisible,
            accounts = accounts,
            loading = false,
            atm = isAtm
        })
    end)
end

RegisterNetEvent('Renewed-Banking:client:openBankUI', function(data)
    local txt = data.atm and locale('open_atm') or locale('open_bank')
    TaskStartScenarioInPlace(PlayerPed, 'PROP_HUMAN_ATM', 0, true)
    if progressBar({
        label = txt,
        duration = math.random(3000,5000),
        position = 'bottom',
        useWhileDead = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true, mouse = false }
    }) then
        openBankUI(data.atm)
        Wait(500)
        ClearPedTasksImmediately(PlayerPed)
    else
        ClearPedTasksImmediately(PlayerPed)
        lib.notify({title = locale('bank_name'), description = locale('canceled'), type = 'error'})
    end
end)

RegisterNUICallback('closeInterface', function(_, cb)
    nuiHandler(false)
    cb('ok')
end)

RegisterNUICallback('getTransactions', function(data, cb)
    local transactions = lib.callback.await('renewed-banking:server:getAccountTransactions', false, data)
    cb(transactions)
end)

RegisterNUICallback('getMembers', function(data, cb)
    local members = lib.callback.await('Renewed-Banking:server:getMembers', false, data.account)
    cb(members)
end)

RegisterCommand('closeBankUI', function() nuiHandler(false) end, false)

local bankActions = {'deposit', 'withdraw', 'transfer'}
CreateThread(function ()
    for k=1, #bankActions do
        RegisterNUICallback(bankActions[k], function(data, cb)
            local newTransaction = lib.callback.await('Renewed-Banking:server:'..bankActions[k], false, data)
            if not newTransaction then return cb(false) end
            cb(newTransaction)
        end)
    end
end)

RegisterNUICallback('createaccount', function(data, cb)
    data.id = data.id:upper():gsub("%s+", "")
    local accountCreated = lib.callback.await('Renewed-Banking:server:createNewAccount', false, data.id)
    cb(accountCreated)
end)

RegisterNUICallback('deleteaccount', function(data, cb)
    local accountDeleted = lib.callback.await('Renewed-Banking:server:deleteAccount', false, data.accountID)
    cb(accountDeleted)
end)

RegisterNUICallback('addmember', function(data, cb)
    local memberAdded = lib.callback.await('Renewed-Banking:server:addAccountMember', false, data.memberID, data.accountID)
    cb(memberAdded)
end)

RegisterNUICallback('removemember', function(data, cb)
    local memberRemoved = lib.callback.await('Renewed-Banking:server:removeAccountMembers', false, data.accountID, data.members)
    cb(memberRemoved)
end)

RegisterNUICallback('updateaccountid', function(data, cb)
    local accountUpdated = lib.callback.await('Renewed-Banking:server:changeAccountName', false, data.accountID, data.newAccountID)
    cb(accountUpdated)
end)

function CreatePeds()
    if pedSpawned then return end
    for k=1, #Config.peds do
        local Ped = Config.peds[k]
        local model = joaat(Ped.model)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local coords = Ped.coords
        local bankPed = CreatePed(0, model, coords.x, coords.y, coords.z-1, coords.w, false, false)

        TaskStartScenarioInPlace(bankPed, Ped.scenario, 0, true)
        FreezeEntityPosition(bankPed, true)
        SetEntityInvincible(bankPed, true)
        SetBlockingOfNonTemporaryEvents(bankPed, true)

        peds[#peds+1] = bankPed

        blips[k] = AddBlipForCoord(coords.x, coords.y, coords.z-1)
        SetBlipSprite(blips[k], 108)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], 0.80)
        SetBlipColour (blips[k], 2)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Bank')
        EndTextCommandSetBlipName(blips[k])
    end
    pedSpawned = true
    Target.AddHook(peds)
end


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DeletePeds()
    Target.RemoveHook()
end)

RegisterNetEvent('Renewed-Banking:client:sendNotification', function(msg)
    if not msg then return end
    SendNUIMessage({
        action = 'notify',
        status = msg,
    })
end)

RegisterNetEvent('Renewed-Banking:client:viewAccountsMenu', function()
    TriggerServerEvent('Renewed-Banking:server:getPlayerAccounts')
end)