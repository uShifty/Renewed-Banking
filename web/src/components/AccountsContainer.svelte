<script lang="ts">
    import AccountsList from "./Accounts/AccountsList.svelte";
    import AccountTransactionsList from "./Accounts/AccountTransactionsList.svelte";
    import { formatMoney } from "../utils/misc";
    import {
        accounts,
        activeAccount,
        translations,
        atm,
        notify,
    } from "../store/stores";
    import { convertToCSV } from "../utils/convertToCSV";
    import { setClipboard } from "../utils/setClipboad";
    import { isEnvBrowser } from "../utils/misc";
    import type { accountType, transactionType } from "../types/types";

    $: account = $accounts.find(
        (accountItem: accountType) => $activeAccount === accountItem.id
    );

    function handleClickExportData() {
        if (!account) {
            return console.log($translations.no_account);
        }

        if (account.transactions.length === 0) {
            notify.set($translations.trans_not_found);
            setTimeout(() => {
                notify.set("");
            }, 3500);
            return;
        }

        const csv = convertToCSV(account.transactions);
        setClipboard(csv);
        notify.set($translations.transactions_copied);
        setTimeout(() => {
            notify.set("");
        }, 3500);
    }
    let isAtm: boolean = false;
    atm.subscribe((usingAtm: boolean) => {
        isAtm = usingAtm;
    });
</script>

<div class="main">
    <section>
        <AccountsList />
        <AccountTransactionsList />
    </section>
    <div class="bottom-container">
        <div class="wallet-container">
            <i class="fa-solid fa-wallet fa-fw" />
            <h5>{formatMoney($accounts[0].cash)}</h5>
        </div>
        {#if !isAtm}
            <div class="export-data">
                <button class="btn btn-green" on:click|preventDefault={handleClickExportData}>
                    <i class="fa-solid fa-file-export fa-fw" />
                    {$translations.export_data}
                </button>
            </div>
        {/if}
    </div>
</div>

<style>
    .main {
        overflow: hidden;
        width: 90%;
        height: 90%;
        bottom: 5%;
        left: 5%;
        padding: 1rem;
        position: absolute;
        background-color: rgb(32, 41, 48);
        border-radius: 5px;
        border: 4px solid #393a45;
        background-size: cover;
        background-position: center;
        opacity: 1;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }

    section {
        display: flex;
        gap: 4rem;
        height: calc(100% - 5rem); /* Adjust the height */
    }

    .bottom-container {
        display: flex;
        align-items: flex-end;
        justify-content: space-between;
        margin-top: 4px; /* Adjust the margin-top as needed */
    }

    .wallet-container {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        margin-top: 4px; /* Adjust the margin-top as needed */
    }


    h5 {
        font-size: 1.4rem;
        margin-bottom: 0;
    }
</style>
