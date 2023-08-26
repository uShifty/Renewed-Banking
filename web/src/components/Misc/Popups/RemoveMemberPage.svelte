<script lang="ts">
  import { accounts, activeAccount, popupDetails, loading, translations, selectedMembers, Player } from "../../../store/stores";
  import type { accountType } from "../../../types/types";
  import { fetchNui } from "../../../utils/fetchNui";
  import MemberCard from './MemberCard.svelte'; // Import the MemberCard component
  import { isEnvBrowser } from "../../../utils/misc";
  // Use reactive statement to update the 'account' variable when 'accounts' or 'activeAccount' change
  let account: accountType; 
  let previousAccountId: any; 
  let members: any;
  let filteredTransactions
  async function fetchMembers(accountId: string) {
        try {
            members = await fetchNui("getMembers", { account: accountId });

        } catch (error) {
            console.error("Error fetching transactions:", error);
        }
    }

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
        accountID: account.id,
        members: $selectedMembers // Pass the array of selected member IDs
      });
      loading.set(false);
      closePopup();
      selectedMembers.set([])
    } catch (error) {
      console.error('Error:', error);
    }
  }
  
  $: {
        account = $accounts.find(
            (accountItem: accountType) => $activeAccount === accountItem.id
        );

        if (account && account.id && account.id !== previousAccountId) {
            previousAccountId = account.id;
            if (isEnvBrowser()) {
              members=[{name:"Tyrese",charid:'1'},{name:"Tyres",charid:'2'},{name:"Tyre",charid:'3'},{name:"Tyr",charid:'4'},{name:"Ty",charid:'5'},{name:"T",charid:'6'},{name:"Ty",charid:'7'},{name:"Tyr",charid:'8'},{name:"Tyre",charid:'9'},{name:"Tyrese",charid:'10'},{name:"Tyrese",charid:'1'},{name:"Tyres",charid:'2'},{name:"Tyre",charid:'3'},{name:"Tyr",charid:'4'},{name:"Ty",charid:'5'},{name:"T",charid:'6'},{name:"Ty",charid:'7'},{name:"Tyr",charid:'8'},{name:"Tyre",charid:'9'},{name:"Tyrese",charid:'10'}]
            }
            fetchMembers(account.id);
        }
    }
    
</script>

<section class="popup-content">
  <h2>{$translations.ui_remove_member}: {account.id}</h2>
  <form action="#">
    <!-- Add a container to hold the member cards -->
    <div class="member-cards">
      {#if members && typeof(members) !== "string"}
        {#each members as member}
          {#if member.charid !== undefined && member.charid !== $Player.id}
            <MemberCard
              member={member}
            />
          {/if}
        {/each}
      {:else}
        {$translations.no_member_found}
      {/if}
    </div>
  
    <div class="btns-group">
      <button type="button" class="btn btn-orange" on:click={closePopup}>{$translations.cancel}</button>
      <button type="button" class="btn btn-green" on:click={submitInput}>{$translations.confirm}</button>
    </div>
  </form>
</section>

<style>
  .btns-group {
    margin-top: 1rem;
    display: flex;
    margin-right: 8px;
    gap: 0.75rem; /* Optional: Add some gap between the buttons */
  }

  .btns-group button {
    flex-grow: 1;
  }
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

  .member-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(20rem, 1fr));
    grid-row-gap: 2rem;
    grid-column-gap: 0.75rem;
    max-height: 30rem;
    height: 100%;
    overflow-y: auto;
    scrollbar-width: thin;
    scrollbar-color: #888 #f5f5f5;
  }

  /* Modern scroll bar style for WebKit-based browsers (e.g., Chrome, Safari) */
  .member-cards::-webkit-scrollbar {
    width: 8px; /* Set the width of the scrollbar */
  }

  .member-cards::-webkit-scrollbar-thumb {
    background-color: #666;
    border-radius: 4px; /* Round the corners of the thumb */
  }

  .member-cards::-webkit-scrollbar-thumb:hover {
    background-color: #999;
  }

  .member-cards::-webkit-scrollbar-track {
    background-color: #333;
  }
</style>
