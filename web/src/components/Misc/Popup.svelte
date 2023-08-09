<script lang="ts">
    import { accounts, activeAccount, popupDetails, loading, translations } from "../../store/stores";
    import { fetchNui } from "../../utils/fetchNui";
    import TransactionPage from "../Misc/Popups/TransactionPage.svelte";
    import CreateAccountPage from "../Misc/Popups/CreateAccountPage.svelte";
    import AddMemberPage from "../Misc/Popups/AddMemberPage.svelte";
    import RemoveMemberPage from "./Popups/RemoveMemberPage.svelte";
    import UpdateAccountPage from "../Misc/Popups/UpdateAccountPage.svelte";
    import DeleteAccountPage from "../Misc/Popups/DeleteAccountPage.svelte";
    import type { SvelteComponent } from 'svelte';

    let account: any; 
  
    // Use reactive statement to update the 'account' variable when 'accounts' or 'activeAccount' change
    $: { account = $accounts.find((accountItem: any) => $activeAccount === accountItem.id) }
  
    function closePopup() {
        popupDetails.update((val: any) => ({
            ...val,
            actionType: ""
        }));
    }
    interface ComponentMapping {
        [key: string]: typeof SvelteComponent;
    }

    const componentMapping: ComponentMapping = {
        withdraw: TransactionPage,
        deposit: TransactionPage,
        transfer: TransactionPage,
        createaccount: CreateAccountPage,
        addmember: AddMemberPage,
        removemember: RemoveMemberPage,
        updateaccountid: UpdateAccountPage,
        deleteaccount: DeleteAccountPage,
    };
    
    let CurrentPage = componentMapping[$popupDetails.actionType] || null;
</script>

<section class="popup-container">
    {#if CurrentPage}
        <svelte:component this={CurrentPage} />
    {/if}
</section>

<style>
    .popup-container {
        position: fixed;
        top: 0;
        left: 0;
        bottom: 0;
        right: 0;
        background-color: rgba(255, 255, 255, 0.3);

        display: flex;
        align-items: center;
        justify-content: center;
    }
</style>
