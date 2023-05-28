
local function viewAccount(account)
    lib.registerContext({
        id = 'renewed_banking_account_view',
        title = locale('bank_name'),
        position = 'top-right',
        menu = 'renewed_banking_account_list',
        options = {
            {
                title = locale('manage_members'),
                icon = 'users-gear',
                metadata = {locale('manage_members_txt')},
                onSelect = function(data)
                    local members = lib.callback.await('Renewed-Banking:server:getMembers', false, account)

                    if not members then return end

                    local menuOpts = {}

                    if table.type(members) == 'array' then

                    else
                        menuOpts[#menuOpts+1] = {
                            title = members.name,
                            metadata = {locale("remove_member_txt")},
                            event = 'Renewed-Banking:client:removeMemberConfirmation',
                            args = {
                                account = account,
                                cid = members.charid,
                            },
                            arrow = true
                        }
                    end

                    menuOpts[#menuOpts+1] = {
                        title = locale("add_member"),
                        metadata = {locale("add_member_txt")},
                        event = 'Renewed-Banking:client:addAccountMember',
                        args = {
                            account = account
                        }
                    }
                    lib.registerContext({
                        id = 'renewed_banking_member_manage',
                        title = locale("bank_name"),
                        position = 'top-right',
                        menu = 'renewed_banking_account_view',
                        options = menuOpts
                    })
                    lib.showContext("renewed_banking_member_manage")
                end
            },
            {
                title = locale('edit_acc_name'),
                icon = 'users-gear',
                metadata = {locale('edit_acc_name_txt')},
                event = 'Renewed-Banking:client:changeAccountName',
                args = data
            },
            {
                title = locale('delete_account'),
                icon = 'users-gear',
                metadata = {locale('delete_account_txt')},
                serverEvent = 'Renewed-Banking:server:deleteAccount',
                args = data
            }
        }
    })
    lib.showContext("renewed_banking_account_view")
end


RegisterNetEvent("Renewed-Banking:client:accountManagmentMenu", function()
    lib.registerContext({
        id = 'renewed_banking_account_management',
        title = locale("bank_name"),
        position = 'top-right',
        options = {
            {
                title = locale("create_account"),
                icon = 'file-invoice-dollar',
                metadata = {locale("create_account_txt")},
                event = "Renewed-Banking:client:createAccountMenu"
            },
            {
                title = locale("manage_account"),
                icon = 'users-gear',
                metadata = {locale("manage_account_txt")},
                onSelect = function()
                    local accounts = lib.callback.await('Renewed-Banking:server:getPlayerAccounts', false)

                    local menuOpts = {}
                    if accounts then
                        if type(accounts) == 'table' then
                            for _, v in pairs(accounts) do
                                menuOpts[#menuOpts+1] = {
                                    title = v.id,
                                    icon = 'users-gear',
                                    metadata = {locale("view_members")},
                                    onSelect = function()
                                        viewAccount(v.id)
                                    end,
                                    arrow = true,
                                }
                            end
                        else
                            menuOpts[#menuOpts+1] = {
                                title = accounts,
                                icon = 'users-gear',
                                metadata = {locale("view_members")},
                                onSelect = function()
                                    viewAccount(accounts)
                                end,
                                arrow = true,
                            }
                        end
                    else
                        menuOpts[#menuOpts+1] = {
                            title = locale("no_account"),
                            metadata = {locale("no_account_txt")},
                        }
                    end

                    lib.registerContext({
                        id = 'renewed_banking_account_list',
                        title = locale('bank_name'),
                        position = 'top-right',
                        menu = 'renewed_banking_account_management',
                        options = menuOpts
                    })

                    lib.showContext('renewed_banking_account_list')
                end
            }
        }
    })
    lib.showContext("renewed_banking_account_management")
end)

RegisterNetEvent("Renewed-Banking:client:createAccountMenu", function()
    local input = lib.inputDialog(locale("bank_name"), {{
        type = "input",
        label = locale("account_id"),
        placeholder = "a_test_account"
    }})
    if input and input[1] then
        input[1] = input[1]:lower():gsub("%s+", "")
        TriggerServerEvent("Renewed-Banking:server:createNewAccount", input[1])
    end
end)


RegisterNetEvent("Renewed-Banking:client:viewMemberManagement", function(data)
    local menuOpts = {}
    local account = data.account
    for k,v in pairs(data.members) do
        menuOpts[#menuOpts+1] = {
            title = v,
            metadata = {locale("remove_member_txt")},
            event = 'Renewed-Banking:client:removeMemberConfirmation',
            args = {
                account = account,
                cid = k,
            }
        }
    end
    menuOpts[#menuOpts+1] = {
        title = locale("add_member"),
        metadata = {locale("add_member_txt")},
        event = 'Renewed-Banking:client:addAccountMember',
        args = {
            account = account
        }
    }
    lib.registerContext({
        id = 'renewed_banking_member_manage',
        title = locale("bank_name"),
        position = 'top-right',
        menu = 'renewed_banking_account_view',
        options = menuOpts
    })
    lib.showContext("renewed_banking_member_manage")
end)

RegisterNetEvent('Renewed-Banking:client:removeMemberConfirmation', function(data)
    lib.registerContext({
        id = 'renewed_banking_member_remove',
        title = locale('bank_name'),
        position = 'top-right',
        menu = 'renewed_banking_account_view',
        options = {
            {
                title = locale('remove_member'),
                metadata = {locale('remove_member_txt2', data.cid)},
                serverEvent = 'Renewed-Banking:server:removeAccountMember',
                args = data
            }
        }
    })
    lib.showContext('renewed_banking_member_remove')
end)

RegisterNetEvent('Renewed-Banking:client:addAccountMember', function(data)
    local input = lib.inputDialog(locale('add_account_member'), {{
        type = 'input',
        label = locale('citizen_id'),
        placeholder = '1001'
    }})
    if input and input[1] then
        input[1] = input[1]:upper():gsub("%s+", "")
        TriggerServerEvent('Renewed-Banking:server:addAccountMember', data.account, input[1])
    end
end)

RegisterNetEvent('Renewed-Banking:client:changeAccountName', function(data)
    local input = lib.inputDialog(locale('change_account_name'), {{
        type = 'input',
        label = locale('account_id'),
        placeholder = 'savings-1001'
    }})
    if input and input[1] then
        input[1] = input[1]:lower():gsub("%s+", "")
        TriggerServerEvent('Renewed-Banking:server:changeAccountName', data.account, input[1])
    end
end)