local MySQL = MySQL
local db = {}


local SELECT_BANKACCOUNTS = 'SELECT * FROM bank_accounts'
function db.selectBankAccounts()
    return MySQL.query.await(SELECT_BANKACCOUNTS)
end

local SELECT_OWNED_ACCOUNTS = 'SELECT `id` FROM bank_accounts WHERE `creator` = ?'
function db.selectOwnedAccounts(charId)
    return MySQL.prepare.await(SELECT_OWNED_ACCOUNTS, {charId})
end

local INSERT_ACCOUNT = 'INSERT INTO bank_accounts (id, amount, isFrozen, creator) VALUES (?, ?, ?, ?)'
function db.addAccount(id, amount, isFrozen, creator)
    MySQL.prepare(INSERT_ACCOUNT, {id, amount, isFrozen, creator})
end

local INSERT_ACCOUNTAUTH = 'INSERT INTO player_accounts (charid, account) VALUES (?, ?)'
function db.addAccountAuth(charid, account)
    MySQL.prepare(INSERT_ACCOUNTAUTH, {charid, account})
end

local UPDATE_ACCOUNTNAME = 'UPDATE bank_accounts SET id = ? WHERE id = ?'
function db.updateAccountName(newAccount, oldAccount)
    MySQL.prepare(UPDATE_ACCOUNTNAME, {newAccount, oldAccount})
end

local UPDATE_ACCOUNTMEMBERS = 'UPDATE player_accounts SET account = ? WHERE account = ?'
function db.updateAccountMembers(newAccount, oldAccount)
    MySQL.prepare(UPDATE_ACCOUNTMEMBERS, {newAccount, oldAccount})
end

local NUKE_ACCOUNT = 'DELETE FROM bank_accounts WHERE `id` = ?'
function db.nukeAccount(account)
    MySQL.prepare(NUKE_ACCOUNT, {account})
end

local NUKE_ACCOUNTMEMBERS = 'DELETE FROM player_accounts WHERE `account` = ?'
function db.nukeAccountMembers(account)
    MySQL.prepare(NUKE_ACCOUNTMEMBERS, {account})
end

local REMOVE_MEMBNER = 'DELETE FROM player_accounts WHERE `charid` = ? AND `account` = ?'
function db.removeAccountMembers(charid, account)
    MySQL.prepare(REMOVE_MEMBNER, {charid, account})
end

local SELECT_MEMBERS = 'SELECT `charid`, `name` FROM player_accounts WHERE `account` = ?'
function db.selectMembers(account)
    return MySQL.prepare.await(SELECT_MEMBERS, {account})
end

local INSERT_TRANSACTION = 'INSERT INTO bank_transactions (account, trans_id, title, message, amount, receiver, trans_type, issuer, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
function db.addTransaction(account, trans_id, title, message, amount, receiver, trans_type, issuer, time)
    MySQL.prepare(INSERT_TRANSACTION, {account, trans_id, title, message, amount, receiver, trans_type, issuer, time})
end

local GET_TRANSACTIONS = 'SELECT * FROM bank_transactions WHERE `account` = ? AND date < (NOW() - INTERVAL 1 WEEK) ORDER BY date DESC'
function db.getTransactions(account)
    return MySQL.prepare.await(GET_TRANSACTIONS, {account})
end

local SELECT_CHARACTER_ACCOUNTS = 'SELECT `account` FROM `player_accounts` WHERE `charid` = ?'
function db.selectCharacterGroups(charid)
    return MySQL.prepare.await(SELECT_CHARACTER_ACCOUNTS, { charid })
end

local UPDATE_BANK_BALANCE = 'UPDATE bank_accounts SET amount = ? WHERE id = ?'
function db.setBankBalance(account, balance)
    MySQL.prepare(UPDATE_BANK_BALANCE, { balance, account })
end

return db