<script lang="ts">
    // Import necessary stores and functions
    import { accounts, activeAccount, popupDetails, atm, translations, Player } from "../../store/stores";
    import { formatMoney } from "../../utils/misc";
    import { fade } from 'svelte/transition';
    import Tooltip from "../Misc/Tooltip.svelte";
    import ContextMenu from "../Misc/ContextMenu.svelte";
    import { onMount, afterUpdate, onDestroy } from 'svelte';
  
    // Export the account prop
    export let account: any;
  
    // Handle account click event
    function handleAccountClick(id: any) {
      activeAccount.update(() => id);
    }
    

    let isAtm: boolean;
    let options = [$translations.ui_remove_member, $translations.ui_add_member, $translations.ui_update_account, $translations.ui_delete_account];
    let menuX = 0;
    let menuY = 0;
    let showContextMenu = false;

    function handleButton(id:string, type:string) {
        let account = $accounts.find((accountItem: any) => id === accountItem.id);
        popupDetails.update(() => ({ actionType: type, account }));
    }
  
    function handleClick(event: MouseEvent) {
      event.stopPropagation(); // Prevent event propagation to the parent elements
  
      menuX = event.clientX;
      menuY = event.clientY;
      showContextMenu = true;
    }
    const optionMap: { [key: string]: string } = {
      [$translations.ui_add_member]: "addmember",
      [$translations.ui_remove_member]: "removemember",
      [$translations.ui_update_account]: "updateaccountid",
      [$translations.ui_delete_account]: "deleteaccount",
    };
    function handleOptionClick(event: CustomEvent) {
      // Handle option click event here
      const actionType = optionMap[event.detail];

      if (actionType) {
          popupDetails.update(() => ({ actionType, account }));
      }

      showContextMenu = false;
    }
  
    function handleOutsideClick() {
      showContextMenu = false;
    }

    atm.subscribe((usingAtm: boolean) => {
        isAtm = usingAtm;
    });
  
    // Add event listeners for clicks outside the context menu
    onMount(() => {
      window.addEventListener("click", handleOutsideClick);
      return () => {
        window.removeEventListener("click", handleOutsideClick);
      };
    });
  
    // Ensure that the context menu is closed when the component updates or is destroyed
    afterUpdate(() => {
      if (showContextMenu) {
        window.addEventListener("click", handleOutsideClick);
      } else {
        window.removeEventListener("click", handleOutsideClick);
      }
    });
  
    onDestroy(() => {
      window.removeEventListener("click", handleOutsideClick);
    });
  </script>
  
  <section class="account" on:click={() => handleAccountClick(account.id)} on:keydown={function() {}}>
    <!-- Print the account details -->
    <div class="account-item-header">
      <h4>{account.type} {$translations.account} / {account.id}</h4>
      
      {#if account.id !== $Player.id && account.id === $activeAccount && (account.creator && account.creator === $Player.id)}
        <Tooltip tip="Manage Account">
          <i class="fa-regular fa-users-gear fa-xl" on:click={handleClick} on:keydown={function() {}}/>
        </Tooltip>
      {/if}
    </div>
    <h5>{account.type} {$translations.account}<br /><span>{account.name}</span></h5>
  
    <div class="price">
      <!-- Print the account balance -->
      <strong>{formatMoney(account.amount)}</strong> <br />
      <span>{$translations.balance}</span>
    </div>
  
    {#if account.id === $activeAccount}
      <!-- Add fade transition to the button group -->
      <div transition:fade class:btns-group={account.id === $activeAccount}>
        {#if !account.isFrozen}
          {#if !isAtm}
            <!-- Render the deposit button -->
            <button class="btn btn-green" on:click={() => handleButton(account.id, "deposit")}>
              {$translations.deposit_but}
            </button>
          {/if}
          <!-- Render the withdraw button -->
          <button class="btn btn-orange" on:click={() => handleButton(account.id, "withdraw")}>
            {$translations.withdraw_but}
          </button>
          <!-- Render the transfer button -->
          <button class="btn btn-grey" on:click={() => handleButton(account.id, "transfer")}>
            {$translations.transfer_but}
          </button>
        {:else}
          <!-- Render the frozen message -->
          <p>{$translations.frozen}</p>
        {/if}
      </div>
    {/if}
  
    {#if showContextMenu}
      <ContextMenu
        bind:options={options}
        bind:x={menuX}
        bind:y={menuY}
        bind:showMenu={showContextMenu}
        on:optionClick={handleOptionClick}
      />
    {/if}
  </section>
  
  <style>
    .account {
      background-color: var(--clr-primary-light);
      padding: 1rem;
      border-radius: 10px;
      cursor: pointer;
      box-shadow: 3px 5px 37px 4px rgba(48, 48, 48, 0.38);
      -webkit-box-shadow: 3px 5px 37px 4px rgba(48, 48, 48, 0.38);
      -moz-box-shadow: 3px 5px 37px 4px rgba(48, 48, 48, 0.38);
    }
  
    .account:not(:last-child) {
      margin-bottom: 1.5rem;
    }
  
    .account-item-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
  
    .account-item-header h4 {
      font-size: 1.5rem;
      margin: 0;
    }
  
    .account-item-header i {
      color: #ffffff;
    }
  
    .account-item-header i:hover {
      color: #7A7A7A;
    }
  
    h5 {
      font-size: 1.2rem;
    }
  
    h5 span {
      margin-top: 0.3rem;
    }
  
    .price {
      text-align: right;
      margin-bottom: 1rem;
    }
  
    .price strong {
      font-size: 1.6rem;
    }
  
    /* make first btn in btn-group take up the whole first row */
    .btns-group > :first-child {
      grid-column: 1 / -1;
    }
  
    .btns-group {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      grid-gap: 0.5rem;
      transition: opacity 1.5s;
    }
  
    .btns-group.animate {
      opacity: 1;
    }
  </style>