<script lang="ts">
  import { accounts, activeAccount, popupDetails, loading, translations, selectedMembers } from "../../../store/stores";
  import type { accountType } from "../../../types/types";
  import { fetchNui } from "../../../utils/fetchNui";
  import MemberCard from './MemberCard.svelte'; // Import the MemberCard component
  
  // Use reactive statement to update the 'account' variable when 'accounts' or 'activeAccount' change
  $: account = $accounts.find((accountItem: accountType) => $activeAccount === accountItem.id);
  
  let members = [
    {
      name: "Tyrese",
      id: '1'
    },
    {
      name: "Tyres",
      id: '2'
    },
    {
      name: "Tyre",
      id: '3'
    },
    {
      name: "Tyr",
      id: '4'
    },
    {
      name: "Ty",
      id: '5'
    },
    {
      name: "T",
      id: '6'
    },
    {
      name: "Ty",
      id: '7'
    },
    {
      name: "Tyr",
      id: '8'
    },
    {
      name: "Tyre",
      id: '9'
    },
    {
      name: "Tyrese",
      id: '10'
    },
    {
      name: "Tyrese",
      id: '1'
    },
    {
      name: "Tyres",
      id: '2'
    },
    {
      name: "Tyre",
      id: '3'
    },
    {
      name: "Tyr",
      id: '4'
    },
    {
      name: "Ty",
      id: '5'
    },
    {
      name: "T",
      id: '6'
    },
    {
      name: "Ty",
      id: '7'
    },
    {
      name: "Tyr",
      id: '8'
    },
    {
      name: "Tyre",
      id: '9'
    },
    {
      name: "Tyrese",
      id: '10'
    }
  ]
  function closePopup() {
    popupDetails.update((val: any) => ({
      ...val,
      actionType: ""
    }));
  }
  
  async function submitInput() {
    loading.set(true);
    try {
      console.log('selectedMembers')
      console.log($selectedMembers)
      const retData = await fetchNui($popupDetails.actionType, {
        accountID: account.id,
        members: $selectedMembers // Pass the array of selected member IDs
      });
  
      if (retData !== false) {
        accounts.update((arr) => {
          return arr.map((mapAccount: accountType) => {
            if (mapAccount.id === account.id) {
              return {
                ...mapAccount,
                members: retData.members
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
  <h2>Remove Member: {account.id}</h2>
  <form action="#">
    <!-- Add a container to hold the member cards -->
    <div class="member-cards">
      {#each members as member}
        <MemberCard
          member={member}
        />
      {/each}
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
