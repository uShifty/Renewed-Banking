<script lang="ts">
    import { accounts, activeAccount, popupDetails, loading, translations } from "../../../store/stores";
    import type { accountType } from "../../../types/types";
    import { fetchNui } from "../../../utils/fetchNui";
    import { createEventDispatcher } from 'svelte';
  
    const dispatch = createEventDispatcher();
  
    let memberId: string = "";
  
    // Use reactive statement to update the 'account' variable when 'accounts' or 'activeAccount' change
    $: account = $accounts.find((accountItem: accountType) => $activeAccount === accountItem.id);
  
    function closePopup() {
      popupDetails.update((val: any) => ({
        ...val,
        actionType: ""
      }));
    }
  
    async function submitInput() {
      loading.set(true);
      try {
        console.log('AddMemberPage')
        console.log(account.id, memberId)
        const retData = await fetchNui($popupDetails.actionType, {
          accountID: account.id,
          memberID: memberId
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
    <h2>{account.id}: Add Member</h2>
    <form action="#">
      <div class="form-row">
        <label for="memberId">Member ID (Character Or Server ID)</label>
        <input bind:value={memberId} type="text" name="memberId" id="memberId" placeholder="" />
      </div>
  
      <div class="btns-group">
        <button type="button" class="btn btn-orange" on:click={closePopup}>{$translations.cancel}</button>
        <button type="button" class={memberId !== '' ? 'btn btn-green' : 'btn btn-grey'} on:click={submitInput} disabled={memberId == ''}>{$translations.confirm}</button>
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
  