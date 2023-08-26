<script lang="ts">
    import { accounts, activeAccount, popupDetails, loading, translations, Player } from "../../../store/stores";
    import { fetchNui } from "../../../utils/fetchNui";
	import type  { accountType } from "../../../types/types";
  
    let amount: number = 0;
    let comment: string = "";
    let stateid: string = "";
    let account: any; 
  
    // Use reactive statement to update the 'account' variable when 'accounts' or 'activeAccount' change
    $: { account = $accounts.find((accountItem: any) => $activeAccount === accountItem.id) }
  
    function closePopup() {
        popupDetails.update((val: any) => ({
            ...val,
            actionType: ""
        }));
    }
  
    async function submitInput() {
        loading.set(true);
        try {
            const retData = await fetchNui($popupDetails.actionType, {
                fromAccount: account.id,
                amount: amount,
                comment: comment,
                stateid: stateid
            });

            if (retData !== false) {
                const updateAccount = (arr: accountType[], id: string, updates: Partial<accountType>): accountType[] => {
                    return arr.map((account: accountType) => {
                        if (account.id === id) {
                            return { ...account, ...updates };
                        }
                        return account;
                    });
                };

                const sourceAccount = $accounts.find((a: accountType) => a.id === account.id) || { id: account.id, cash: 0, amount: 0, transactions: [] };
                const playerAccount = $accounts.find((a: accountType) => a.id === $Player.id) || { id: $Player.id, cash: 0, amount: 0, transactions: [] };

                if ($popupDetails.actionType === 'withdraw') {
                    const sourceUpdates = {
                        amount: (sourceAccount.amount || 0) - amount,
                        transactions: retData ? [retData, ...(sourceAccount.transactions || [])] : sourceAccount.transactions,
                    };

                    const playerUpdates = {
                        cash: (playerAccount.cash || 0) + amount,
                    };

                    accounts.update((arr: accountType[]) => updateAccount(arr, account.id, sourceUpdates));
                    accounts.update((arr: accountType[]) => updateAccount(arr, $Player.id, playerUpdates));
                } else if ($popupDetails.actionType === 'deposit') {
                    const sourceUpdates = {
                        cash: (sourceAccount.cash || 0) - amount,
                        amount: (sourceAccount.amount || 0) + amount,
                        transactions: retData ? [retData, ...(sourceAccount.transactions || [])] : sourceAccount.transactions,
                    };

                    const playerUpdates = {
                        cash: (playerAccount.cash || 0) - amount,
                    };

                    accounts.update((arr: accountType[]) => updateAccount(arr, account.id, sourceUpdates));
                    accounts.update((arr: accountType[]) => updateAccount(arr, $Player.id, playerUpdates));
                } else if ($popupDetails.actionType === 'transfer') {
                    const sourceUpdates = {
                        amount: (sourceAccount.amount || 0) - amount,
                        transactions: retData ? [retData, ...(sourceAccount.transactions || [])] : sourceAccount.transactions,
                    };

                    const targetAccount = $accounts.find((a: accountType) => a.id === stateid) || { id: stateid, cash: 0, amount: 0, transactions: [] };
                    const targetUpdates = {
                        amount: (targetAccount.amount || 0) + amount,
                    };

                    accounts.update((arr: accountType[]) => updateAccount(arr, account.id, sourceUpdates));
                    accounts.update((arr: accountType[]) => updateAccount(arr, stateid, targetUpdates));
                }
            }

        } catch (error) {
            console.error('Error:', error);
        } finally {
            loading.set(false);
            closePopup();
        }
    }
</script>

<section class="popup-content">
    <h2>{$popupDetails.account.type}{$translations.account} / {$popupDetails.account.id}</h2>
    <form action="#">
        <div class="form-row">
            <label for="amount">{$translations.amount}</label>
            <input bind:value={amount} type="number" name="amount" id="amount" placeholder="$" />
        </div>

        <div class="form-row">
            <label for="comment">{$translations.comment}</label>
            <input bind:value={comment} type="text" name="comment" id="comment" placeholder="//" />
        </div>

        {#if $popupDetails.actionType === "transfer"}
            <div class="form-row">
                <label for="stateId">{$translations.transfer}</label>
                <input bind:value={stateid} type="text" name="stateId" id="stateId" placeholder="#" />
            </div>
        {/if}

        <div class="btns-group">
            <button type="button" class="btn btn-orange" on:click={closePopup}>{$translations.cancel}</button>
            <button type="button" class="btn btn-green" on:click={() => submitInput()}>{$translations.confirm}</button>
        </div>
    </form>
</section>

<style>
    .popup-content {
        max-width: 60rem;
        width: 100%;
        background-color: var(--clr-primary);
        padding: 5rem;
        border-radius: 1rem;
    }

    h2 {
        margin-bottom: 3rem;
        text-align: center;
        font-size: 2rem;
    }

    .form-row {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
        color: #F3F4F5;
        margin-bottom: 2rem;
    }
    .form-row label,
    .form-row input {
        font-size: 1.4rem;
        color: inherit;
    }

    .form-row input {
        width: 100%;
        border-radius: 5px;
        background-color: transparent;
        border: none;
        padding: 1.4rem;
        margin-bottom: 1rem;
        background-color: #2a2b33;
        color: #fff;
    }
</style>
