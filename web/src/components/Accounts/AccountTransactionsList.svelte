<script lang="ts">
    import {
        accounts,
        activeAccount,
        translations,
        atm,
        notify,
    } from "../../store/stores";
    import AccountTransactionItem from "./AccountTransactionItem.svelte";
    import { convertToCSV } from "../../utils/convertToCSV";
    import { setClipboard } from "../../utils/setClipboad";
    import { fetchNui } from "../../utils/fetchNui";
    import { isEnvBrowser } from "../../utils/misc";
    import type { accountType, transactionType } from "../../types/types";

    let transSearch = "";
    let account: accountType | undefined;
    let previousAccountId: string | undefined;
    let filteredTransactions: transactionType[] = [];

    async function fetchTransactions(accountId: string) {
        const transactions = await fetchNui("getTransactions", { account: accountId });
        accounts.update((arr) => {
            return arr.map((mapAccount: accountType) => {
                if (mapAccount.id === accountId) {
                    return {...mapAccount, transactions: Array.isArray(transactions)
                        ? [...transactions, ...(mapAccount.transactions || [])]
                        : [transactions, ...(mapAccount.transactions || [])],
                    };
                }
                return mapAccount;
            });
        });
    }

    $: {
        account = $accounts.find(
            (accountItem: accountType) => $activeAccount === accountItem.id
        );

        if (account && account.id && account.id !== previousAccountId) {
            if (!isEnvBrowser()) account.transactions = [];
            previousAccountId = account.id;
            fetchTransactions(account.id);
        }

        filteredTransactions = (account?.transactions ?? []).filter((item) =>
            item.message.toLowerCase().includes(transSearch.toLowerCase()) ||
            item.trans_id.toLowerCase().includes(transSearch.toLowerCase()) ||
            item.receiver.toLowerCase().includes(transSearch.toLowerCase())
        );
    }

    function handleClickExportData() {
        if (!account) {
            return console.log("No account selected");
        }

        if (account.transactions.length === 0) {
            notify.set("No transactions to export!");
            setTimeout(() => {
                notify.set("");
            }, 3500);
            return;
        }

        const csv = convertToCSV(account.transactions);
        setClipboard(csv);
        notify.set("Data copied to clipboard!");
        setTimeout(() => {
            notify.set("");
        }, 3500);
    }
</script>

<section class="transactions-container">
    <div class="heading">
        <div class="heading-row">
            <span class="left-span bigger-bold"
                >{$translations.transactions}</span
            >
            <div class="right-container">
                <img src="./img/bank.png" alt="bank icon" />
                <span class="right-span bigger-bold"
                    >{$translations.bank_name}</span
                >
            </div>
        </div>
    </div>
    <input type="text" class="transactions-search" placeholder={$translations.trans_search} bind:value={transSearch} />
    <section class="scroller">
        {#if account}
            {#if filteredTransactions.length > 0}
                {#each filteredTransactions as transaction (transaction.trans_id)}
                    <AccountTransactionItem {transaction} />
                {/each}
            {:else}
                <h3 style="text-align: left; color: #F3F4F5; margin-top: 1rem;">
                    {$translations.trans_not_found}
                </h3>
            {/if}
        {:else}
            <p>{$translations.select_account}</p>
        {/if}
    </section>
</section>

<style>
    .heading {
        display: flex;
        justify-content: space-between;
        align-items: center;
        height: 1rem;
        margin-bottom: 10px;
        width: 100%;
    }

    .heading-row {
        display: flex;
        align-items: center;
        width: 100%;
    }
    .transactions-container {
        padding: 0.5rem;
        flex-grow: 1;
    }
    .right-container {
        display: flex;
        align-items: center;
    }

    .left-span {
        margin-right: auto;
    }
    .left-span,
    .right-span {
        font-size: 2rem;
        font-weight: bold;
    }
    .heading img {
        width: 1.75rem;
        margin-right: 1rem;
    }

    .transactions-search {
        width: 100%;
        margin-top: -1px;
        border-radius: 5px;
        border: none;
        padding: 1rem;
        margin-bottom: 1rem;
        background-color: var(--clr-primary-light);
        color: #fff;
    }

    .scroller {
        flex-grow: 1;
    }
    
    .export-data {
        margin-top: 1rem;
        display: flex;
        justify-content: flex-end;
    }
    /* ------------------------- */
</style>
