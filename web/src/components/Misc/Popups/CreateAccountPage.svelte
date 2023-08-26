<script lang="ts">
    import { accounts, activeAccount, popupDetails, loading, translations, Player } from "../../../store/stores";
	import type  { accountType } from "../../../types/types";
    import { fetchNui } from "../../../utils/fetchNui";
    import { createEventDispatcher } from 'svelte';
    import { validateAccountID } from '../../../utils/misc';
    const dispatch = createEventDispatcher();

    let accountID: string = "";
    // Use reactive statement to update the 'account' variable when 'accounts' or 'activeAccount' change
    $:account = $accounts.find((accountItem: accountType) => $activeAccount === accountItem.id);
  
    function closePopup() {
        popupDetails.update((val: any) => ({
            ...val,
            actionType: ""
        }));
    }
  
    function validateInput(inputField:any) {
        let newInput: string = validateAccountID(inputField).toUpperCase();
        accountID = newInput;
        dispatch('input', newInput);
    }

    async function submitInput() {
        loading.set(true);
        const retData = await fetchNui($popupDetails.actionType, {
            id: accountID
        });
        try {
            if (retData !== false) {
                accounts.update((array) => {
                    return [...array, {
                        id: accountID,
                        type: $translations.org,
                        name: accountID,
                        amount: 0, 
                        citizen_id: $Player.id,
                        transactions: []
                    }]; 
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
    <h2>{$translations.create_account}</h2>
    <form action="#">
        <div class="form-row">
            <label for="accountID">{$translations.account_id}</label>
            <input bind:value={accountID} type="text" name="accountID" id="accountID" placeholder="" on:input={(event) => validateInput(event.target)} />
        </div>

        <div class="btns-group">
            <button type="button" class="btn btn-orange" on:click={closePopup}>{$translations.cancel}</button>
            <button type="button" class="btn btn-green" on:click={submitInput}>{$translations.confirm}</button>
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
