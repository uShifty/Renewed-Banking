import { Writable, writable } from "svelte/store";
import type { PlayerData }from "../types/types";
export const visibility = writable(false);
export const loading = writable(false);
export const notify = writable("");
export let activeAccount = writable("1");
export const atm = writable(false);
export const currency = writable("USD");
export const selectedMembers = writable<string[]>([]);

export const Player: Writable<PlayerData> = writable({
    name: "Tyrese Jenkins",
    id: "1",
})

export let popupDetails = writable({
    account: {
        id: "",
        type: "",
        name: "",
        amount: 0, 
        citizen_id: "",
        transactions: []
    },
    actionType: ""
});

export const accountDeletionMessage: string = `
<p>Dear @{name},</p>
<p>This message is here to <strong>strongly</strong> inform you about your <em>urgent</em> request to delete your bank account. Before proceeding, we want to <strong>emphasize</strong> the significant consequences and potential risks associated with this <em>critical</em> action. Please <strong>carefully review</strong> the following <em>important</em> warning:</p>
<ol>
    <li><strong><i class="fas fa-exclamation-circle"></i> Irreversible Action:</strong> Deleting your bank account is a <em>permanent decision</em> that <strong>cannot be undone</strong>. Once the account is closed, all associated data, transaction history, and account details will be <strong>permanently erased</strong> from our system.</li>
    <li><strong><i class="fas fa-exclamation-circle"></i> Loss of Financial Services:</strong> By deleting your account, you will lose access to <em>everything</em> in relation to your account. You will no longer be able to perform any <strong>banking transactions</strong>.</li>
    <li><strong><i class="fas fa-exclamation-circle"></i> Missed Payments and Obligations:</strong> Deleting your bank account may lead to <em>severe disruptions</em> in your financial obligations. Any <strong>pending payments, automatic debits, standing orders, or direct deposits</strong> associated with your account will <strong>cease to function</strong>. It is <em>your responsibility</em> to <strong>update your financial information</strong> with relevant organizations and ensure a <strong>smooth transition</strong>.</li>
    <li><strong><i class="fas fa-exclamation-circle"></i> Loss of Transaction History:</strong> Deleting your account means the <em>permanent loss</em> of all <strong>transactional records</strong> associated with that account. This information could be <em>essential</em> for <strong>tax purposes, financial planning, or legal requirements</strong>. It is <strong>strongly recommended</strong> to <strong>obtain and securely store</strong> any necessary documentation <strong>before proceeding</strong>.</li>
</ol>
<p>We take your <strong>financial security</strong> and <strong>satisfaction</strong> <em>very seriously</em>, and we <strong>appreciate</strong> your <strong>continued trust</strong> in our services. If you still wish to proceed with the deletion of your bank account, please <strong>confirm your request</strong> by <strong>scrolling through this entire warning</strong> and <strong>checking the box below</strong>.</p>
`;

export const accounts = writable<any>();

export const translations = writable<any>({
    "weeks": "%s weeks ago",
    "aweek": "A week ago",
    "days": "%s days ago",
    "aday": "A day ago",
    "hours": "%s hours ago",
    "ahour": "A hour ago",
    "mins": "%s minutes ago",
    "amin": "A minute ago",
    "secs": "A few seconds ago",
    "renewed_banking": "^6[^4Renewed-Banking^6]^0",
    "invalid_account": "${renewed_banking} Account not found (%s)",
    "broke_account": "${renewed_banking} Account(%s) is too broke with balance of $%s",
    "illegal_action": "${renewed_banking} %s has attempted to perform an action to an account they didnt create.",
    "existing_account": "${renewed_banking} Account %s already exsist",
    "invalid_amount": "Invalid amount to %s",
    "not_enough_money": "Account does not have enough funds!",
    "comp_transaction": "%s has %s $%s",
    "fail_transfer": "Failed to transfer to unknown account!",
    "account_taken": "Account ID is already in use",
    "unknown_player": "Player with ID '%s' could not be found.",
    "loading_failed": "Failed to load Banking Data!",
    "dead": "Action failed, you're dead ",
    "too_far_away": "Action failed, too far away",
    "give_cash": "Successfully gave $%s to ID %s",
    "received_cash": "Successfully received $%s from ID %s",
    "missing_params": "You have not provided all the required parameters!",
    "bank_name": "Los Santos Banking",
    "view_members": "View All Account Members!",
    "no_account": "Account Not Found",
    "no_account_txt": "You need to be the creator",
    "manage_members": "Manage Account Members",
    "manage_members_txt": "View Existing & Add Members",
    "edit_acc_name": "Change Account Name",
    "edit_acc_name_txt": "Transactions wont update old names",
    "remove_member_txt": "Remove Account Member!",
    "add_member": "Add Citizen To Account",
    "add_member_txt": "Be careful who youu add(Requires Citizen ID)",
    "remove_member": "Are you sure you want to remove Citizen?",
    "remove_member_txt2": "CitizenID: %s; Their is no going back.",
    "back": "Go Back",
    "view_bank": "View Bank Account",
    "manage_bank": "Manage Bank Account",
    "create_account": "Create New Account",
    "create_account_txt": "Create a new sub bank account!",
    "manage_account": "Manage Existing Accounts",
    "manage_account_txt": "View existing accounts!",
    "account_id": "Account ID (NO SPACES)",
    "change_account_name": "Change Account Name",
    "citizen_id": "Citizen/State ID",
    "add_account_member": "Add Account Member",
    "givecash": "Usage /givecash [ID] [AMOUNT]",
    "account_title": " Account / ",
    "account": " Account ",
    "amount": "Amount",
    "comment": "Comment",
    "transfer": "Business or Citizen ID",
    "cancel": "Cancel",
    "confirm": "Submit",
    "cash": "Cash: $",
    "transactions": "Transactions",
    "select_account": "Select any Account",
    "message": "Message",
    "accounts": "Accounts",
    "balance": "Available Balance",
    "frozen": "Account Status: Frozen",
    "org": "Organization",
    "personal": "Personal",
    "personal_acc": "Personal Account / ",
    "deposit_but": "Deposit",
    "withdraw_but": "Withdraw",
    "transfer_but": "Transfer",
    "open_bank": "Opening Bank",
    "open_atm": "Opening ATM",
    "canceled": "Canceled...",
    "ui_not_built": "Unable to load UI. Build Renewed-Banking or download the latest release.\n   ^https://github.com/Renewed-Scripts/Renewed-Banking/releases/latest/download/Renewed-Banking.zip^0\n    If you are using a custom build of the UI, please make sure the resource name is Renewed-Banking (you may not rename the resource).",
    "cmd_plyr_id": "Target player's server id",
    "cmd_amount": "Amount of money to give",
    "delete_account": "Delete Account",
    "delete_account_txt": "Delete Created Account",
    "err_trans_account": "${renewed_banking} Invalid Account ID provided to handleTransaction! Account=%s",
    "err_trans_title": "${renewed_banking} Invalid Title provided to handleTransaction! Title=%s",
    "err_trans_amount": "${renewed_banking} Invalid Amount provided to handleTransaction! Amount=%s",
    "err_trans_message": "${renewed_banking} Invalid Message provided to handleTransaction! Message=%s",
    "err_trans_issuer": "${renewed_banking} Invalid Issuer provided to handleTransaction! Issuer=%s",
    "err_trans_receiver": "${renewed_banking} Invalid Receiver provided to handleTransaction! Receiver=%s",
    "err_trans_type": "${renewed_banking} Invalid Type provided to handleTransaction! Type=%s",
    "err_trans_transID": "${renewed_banking} Invalid TransID provided to handleTransaction! TransID=%s",
    "trans_search": "Transaction Search (Message, TransID, Receiver)...",
    "trans_not_found": "No transactions found",
    "export_data": "Export Transaction Data",
    "account_search": "Account Search...",
    "account_not_found": "No accounts found"
});
