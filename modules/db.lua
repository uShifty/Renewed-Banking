local MySQL = MySQL

local SELECT_BANKACCOUNTS = 'SELECT * FROM bank_accounts'
local SELECT_OWNED_ACCOUNTS = 'SELECT `id` FROM bank_accounts WHERE `creator` = ?'
local INSERT_ACCOUNT = 'INSERT INTO bank_accounts (id, amount, isFrozen, creator) VALUES (?, ?, ?, ?)'
local INSERT_ACCOUNTAUTH = 'INSERT INTO player_accounts (charid, account) VALUES (?, ?)'
local UPDATE_ACCOUNTNAME = 'UPDATE bank_accounts SET id = ? WHERE id = ?'
local UPDATE_ACCOUNTMEMBERS = 'UPDATE player_accounts SET account = ? WHERE account = ?'
local NUKE_ACCOUNT = 'DELETE FROM bank_accounts WHERE `id` = ?'
local NUKE_ACCOUNTMEMBERS = 'DELETE FROM player_accounts WHERE `account` = ?'
local NUKE_TRANSACTION = 'DELETE FROM bank_transactions WHERE account = ?'
local ADD_MEMBER = 'INSERT INTO player_accounts (`charid`, `account`) VALUES (?, ?)'
local REMOVE_MEMBNER = 'DELETE FROM player_accounts WHERE `charid` = ? AND `account` = ?'
local SELECT_MEMBERS = 'SELECT `charid` FROM player_accounts WHERE `account` = ?'
local INSERT_TRANSACTION = 'INSERT INTO bank_transactions (account, trans_id, title, message, amount, receiver, trans_type, issuer, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
local GET_TRANSACTIONS = 'SELECT * FROM bank_transactions WHERE `account` = ? AND date >= DATE_SUB(NOW(), INTERVAL 1 WEEK) ORDER BY date DESC;'
local UPDATE_TRANSACTION = 'UPDATE bank_transactions SET account = ? WHERE account = ?'
local SELECT_CHARACTER_ACCOUNTS = 'SELECT `account` FROM `player_accounts` WHERE `charid` = ?'
local UPDATE_BANK_BALANCE = 'UPDATE bank_accounts SET amount = ? WHERE id = ?'
local GET_LEGACY_ACCOUNTS = 'SELECT * FROM bank_accounts_new'
local GET_LEGACY_TRANSACTIONS = 'SELECT * FROM player_transactions'
local DROP_LEGACY_ACCOUNTS = 'DROP TABLE IF EXISTS bank_accounts_new'
local DROP_LEGACY_PLAYERS = 'DROP TABLE IF EXISTS player_transactions'
local DROP_BANK_TRANSACTIONS_TABLE = 'DROP TABLE IF EXISTS bank_transactions'
local DROP_PLAYER_ACCOUNTS_TABLE = 'DROP TABLE IF EXISTS player_accounts'
local DROP_BANK_ACCOUNTS_TABLE = 'DROP TABLE IF EXISTS bank_accounts'
local CREATE_BANK_ACCOUNTS_TABLE = [[
CREATE TABLE `bank_accounts` (
    `id` VARCHAR(50) NOT NULL,
    `amount` INT(11) NULL DEFAULT '0',
    `isFrozen` INT(11) NULL DEFAULT '0',
    `creator` VARCHAR(50) NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE
);
]]
local CREATE_BANK_TRANSACTIONS_TABLE = [[
CREATE TABLE `bank_transactions` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `account` VARCHAR(50) NULL DEFAULT NULL,
    `trans_id` VARCHAR(50) NULL DEFAULT NULL,
    `title` VARCHAR(50) NULL DEFAULT NULL,
    `message` VARCHAR(255) NULL DEFAULT NULL,
    `amount` INT(11) NULL DEFAULT NULL,
    `trans_type` VARCHAR(50) NULL DEFAULT NULL,
    `receiver` VARCHAR(50) NULL DEFAULT NULL,
    `issuer` VARCHAR(50) NULL DEFAULT NULL,
    `time` INT(11) UNSIGNED ZEROFILL NULL DEFAULT NULL,
    `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`) USING BTREE
)
AUTO_INCREMENT=1;
]]
local CREATE_PLAYER_ACCOUNTS_TABLE = [[
CREATE TABLE `player_accounts` (
    `charid` VARCHAR(50) NULL DEFAULT NULL,
    `account` VARCHAR(50) NULL DEFAULT NULL,
    CONSTRAINT `unique_charid_account` UNIQUE (`charid`, `account`)
);
]]
local requiredTables = {
    "SHOW TABLES LIKE 'bank_accounts'",
    "SHOW TABLES LIKE 'bank_transactions'",
    "SHOW TABLES LIKE 'player_accounts'",
}
local db = {
    selectBankAccounts = function()
        return MySQL.query.await(SELECT_BANKACCOUNTS)
    end,
    selectOwnedAccounts = function(charId)
        return MySQL.prepare.await(SELECT_OWNED_ACCOUNTS, {charId})
    end,
    addAccount = function(id, amount, isFrozen, creator)
        MySQL.prepare(INSERT_ACCOUNT, {id, amount, isFrozen, creator})
    end,
    addAccountAuth = function(charid, account)
        MySQL.prepare(INSERT_ACCOUNTAUTH, {charid, account})
    end,
    updateAccountName = function(newAccount, oldAccount)
        MySQL.prepare(UPDATE_ACCOUNTNAME, {newAccount, oldAccount})
    end,
    updateAccountMembers = function(newAccount, oldAccount)
        MySQL.prepare(UPDATE_ACCOUNTMEMBERS, {newAccount, oldAccount})
    end,
    nukeAccount = function(account)
        MySQL.prepare(NUKE_ACCOUNT, {account})
    end,
    nukeAccountMembers = function(account)
        MySQL.prepare(NUKE_ACCOUNTMEMBERS, {account})
    end,
    nukeTransactions = function(account)
        MySQL.prepare(NUKE_TRANSACTION, {account})
    end,
    addAccountMembers = function(charid, account)
        MySQL.prepare(ADD_MEMBER, {charid, account})
    end,
    removeAccountMembers = function(charid, account)
        MySQL.prepare(REMOVE_MEMBNER, {charid, account})
    end,
    selectMembers = function(account)
        return MySQL.prepare.await(SELECT_MEMBERS, {account})
    end,
    addTransaction = function(account, trans_id, title, message, amount, receiver, trans_type, issuer, time)
        MySQL.prepare(INSERT_TRANSACTION, {account, trans_id, title, message, amount, receiver, trans_type, issuer, time})
    end,
    getTransactions = function(account)
        local transactions = MySQL.prepare.await(GET_TRANSACTIONS, {account})
        return transactions
    end,
    updateTransactions = function(account, newAccount)
        MySQL.prepare(UPDATE_TRANSACTION, {newAccount, account})
    end,
    selectCharacterGroups = function(charid)
        return MySQL.prepare.await(SELECT_CHARACTER_ACCOUNTS, { charid })
    end,
    setBankBalance = function(account, balance)
        MySQL.prepare(UPDATE_BANK_BALANCE, { balance, account })
    end,
    getLegacyAccounts = function()
        local success, result = pcall(MySQL.query.await, GET_LEGACY_ACCOUNTS)
        if success then
            return result
        else
            return nil
        end
    end,
    getLegacyTransactions = function()
        local success, result = pcall(MySQL.query.await, GET_LEGACY_TRANSACTIONS)
        if success then
            return result
        else
            return nil
        end
    end,
    checkDatabaseSchema = function()
        for k=1, #requiredTables do
            local success = pcall(MySQL.query.await, requiredTables[k])
            if not success then
                return nil
            end
        end
        return true
    end,
    createDatabaseSchema = function()
        print(locale('creating_db'))
        MySQL.query.await(DROP_BANK_TRANSACTIONS_TABLE)
        MySQL.query.await(DROP_PLAYER_ACCOUNTS_TABLE)
        MySQL.query.await(DROP_BANK_ACCOUNTS_TABLE)
        MySQL.query.await(CREATE_BANK_ACCOUNTS_TABLE)
        MySQL.query.await(CREATE_BANK_TRANSACTIONS_TABLE)
        MySQL.query.await(CREATE_PLAYER_ACCOUNTS_TABLE)
        print(locale('created_db'))
    end
}

function db.migrateData(oldAccounts)
    print(locale('conversion_db'))
    db.createDatabaseSchema()

    local playerData = db.getLegacyTransactions()
    if playerData then
        playerData.transactions = json.decode(playerData.transactions)
        if playerData.transactions then
            for i = #playerData.transactions, 1, -1 do
                db.addTransaction(playerData.id, playerData.transactions[i].trans_id, playerData.transactions[i].title, playerData.transactions[i].message, playerData.transactions[i].amount, playerData.transactions[i].receiver, playerData.transactions[i].trans_type, playerData.transactions[i].issuer, playerData.transactions[i].time)
                Wait(0)
            end
        end
    end

    for _, account in ipairs(oldAccounts) do
        local accountId = account.id
        local amount = account.amount
        local isFrozen = account.isFrozen
        local isCreator = account.creator

        MySQL.prepare.await(INSERT_ACCOUNT, {accountId, amount, isFrozen, isCreator})

        local authData = json.decode(account.auth)
        for _, authId in ipairs(authData) do
            db.addAccountMembers(authId, accountId)
            Wait(0)
        end

        local transactionData = json.decode(account.transactions)
        for i = #transactionData, 1, -1 do
            db.addTransaction(accountId, transactionData[i].trans_id, transactionData[i].title, transactionData[i].message, transactionData[i].amount, transactionData[i].receiver, transactionData[i].trans_type, transactionData[i].issuer, transactionData[i].time)
            Wait(0)
        end
    end

    -- Drop the old tables
    MySQL.query(DROP_LEGACY_ACCOUNTS)
    MySQL.query(DROP_LEGACY_PLAYERS)
    print(locale('converted_db'))
end

return db