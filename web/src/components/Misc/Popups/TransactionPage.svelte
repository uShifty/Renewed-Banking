<script lang="ts">
    import { accounts, activeAccount, popupDetails, loading, translations } from "../../../store/stores";
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
            const accountId = $popupDetails.account.id;
            const retData = await fetchNui($popupDetails.actionType, {
                fromAccount: accountId,
                amount: amount,
                comment: comment,
                stateid: stateid
            });
            
            if (retData !== false) {
                accounts.update((arr) => {
                    return arr.map((mapAccount: accountType) => {
                        if (mapAccount.id === retData.player.account) {
                            if (retData.cash) {
                                return { ...mapAccount, cash: retData.player.cash };
                            }
                        }
                        if (retData.primary && mapAccount.id === retData.primary.account) {
                            return {
                                ...mapAccount,
                                amount: retData.primary.bank,
                                transactions: retData.primary.trans ? [retData.primary.trans, ...(mapAccount.transactions || [])] : mapAccount.transactions,
                            };
                        }
                        if (retData.secondary && mapAccount.id === retData.secondary.account) {
                            return {
                                ...mapAccount,
                                amount: retData.secondary.bank,
                                transactions: retData.secondary.trans ? [retData.secondary.trans, ...(mapAccount.transactions || [])] : mapAccount.transactions,
                            };
                        }
                        return mapAccount;
                    });
                });
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
