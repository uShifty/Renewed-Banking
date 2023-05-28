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

local SELECT_MEMBERS = 'SELECT `charid`, `name` FROM player_accounts WHERE `account` = ?'
function db.selectMembers(account)
    return MySQL.prepare.await(SELECT_MEMBERS, {account})
end



local INSERT_TRANSACTION = 'INSERT INTO bank_transactions (account, trans_id, title, message, amount, receiver, trans_type, issuer, time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
function db.addTransaction(account, trans_id, title, message, amount, receiver, trans_type, issuer, time)
    MySQL.prepare(INSERT_TRANSACTION, {account, trans_id, title, message, amount, receiver, trans_type, issuer, time})
end

local GET_TRANSACTIONS = 'SELECT * FROM bank_transactions WHERE `account` = ?'
function db.getTransactions(account)
    return MySQL.prepare.await(GET_TRANSACTIONS, {account})
end

local SELECT_CHARACTER_ACCOUNTS = 'SELECT `account`, `withdraw`, `deposit` FROM `player_accounts` WHERE `charid` = ?'
function db.selectCharacterGroups(charid)
    return MySQL.prepare.await(SELECT_CHARACTER_ACCOUNTS, { charid })
end

local UPDATE_BANK_BALANCE = 'UPDATE bank_accounts SET amount = ? WHERE id = ?'
function db.setBankBalance(account, balance)
    MySQL.prepare(UPDATE_BANK_BALANCE, { balance, account })
end

return db