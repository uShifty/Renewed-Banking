<script lang="ts">
    import {
        accounts,
        activeAccount,
        popupDetails,
        loading,
        translations,
    } from "../../../store/stores";
    import type { accountType } from "../../../types/types";
    import { fetchNui } from "../../../utils/fetchNui";
    import { createEventDispatcher } from "svelte";
    import { validateAccountID } from "../../../utils/misc";

    const dispatch = createEventDispatcher();

    let accountId: string = "";
    let accountId2: string = "";

    // Use reactive statement to update the 'account' variable when 'accounts' or 'activeAccount' change
    let account: any;
    let areInputsEqual = false;
    $: {
        account = $accounts.find(
            (accountItem: accountType) => $activeAccount === accountItem.id
        );
        areInputsEqual =
            accountId !== "" && accountId.trim() === accountId2.trim();
    }

    function closePopup() {
        popupDetails.update((val: any) => ({
            ...val,
            actionType: "",
        }));
    }

    function validateInput(inputField: any) {
        let newInput: string = validateAccountID(inputField);
        console.log(newInput);
        dispatch("input", newInput);
    }

    async function submitInput() {
        loading.set(true);
        try {
            const retData = await fetchNui($popupDetails.actionType, {
                accountID: $activeAccount,
                newAccountID: accountId,
            });

            if (retData !== false) {
                accounts.update((arr) => {
                    return arr.map((mapAccount: accountType) => {
                        if (mapAccount.id === $activeAccount)
                            mapAccount.id = accountId2;
                        return mapAccount;
                    });
                });
            }
        } catch (error) {
            console.error("Error:", error);
        } finally {
            loading.set(false);
            closePopup();
        }
    }
</script>

<section class="popup-content">
    <h2>Update Account ID: {account.id}</h2>
    <form action="#">
        <div class="form-row">
            <label for="accountId">New Account ID</label>
            <input
                bind:value={accountId}
                type="text"
                name="accountId"
                id="accountId"
                placeholder=""
                on:input={(event) => validateInput(event.target)}
            />
            <label for="accountId2">Confirm Account ID</label>
            <input
                bind:value={accountId2}
                type="text"
                name="accountId2"
                id="accountId2"
                placeholder=""
                on:input={(event) => validateInput(event.target)}
            />
        </div>

        <div class="btns-group">
            <button type="button" class="btn btn-orange" on:click={closePopup}
                >{$translations.cancel}</button
            >
            <button
                type="button"
                class={areInputsEqual ? "btn btn-green" : "btn btn-grey"}
                on:click={submitInput}
                disabled={!areInputsEqual}>{$translations.confirm}</button
            >
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
        color: #f3f4f5;
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
