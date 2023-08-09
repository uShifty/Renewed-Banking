<script lang="ts">
	import { accounts, translations, popupDetails, activeAccount } from "../../store/stores";
	import Tooltip from "../Misc/Tooltip.svelte";
	import type  { accountType } from "../../types/types";
	import AccountListItem from "./AccountListItem.svelte";
	import { onMount, onDestroy, setContext } from "svelte";
	let accSearch = "";
	let accountList: accountType[] = [];
	
	let tooltipVisible = false;
	setContext('tooltip', { tooltipVisible });

	function createAccountClick() {
        const selectedAccount = $accounts.find((accountItem: any) => $activeAccount === accountItem.id);
		console.log('activeAccount', $activeAccount)
		console.log('selectedAccount', selectedAccount)
		popupDetails.update(() => ({ actionType: "createaccount", account: selectedAccount }))
	}

	let unsubscribe: any;
	onMount(() => {
		unsubscribe = accounts.subscribe((value) => {
			accountList = value;
		});
	});

	onDestroy(() => {
		unsubscribe();
	});
</script>

<aside>
	<h3 class="heading">{$translations.accounts}</h3>
	<div class="accounts-list-search">
		<input type="text" class="acc-search" placeholder={$translations.account_search} bind:value={accSearch}/>
		<Tooltip tip="Create Account" >
			<i on:click={() => createAccountClick() } class="fa-sharp fa-light fa-folder-plus fa-xl" on:keydown={function() {}} />
		</Tooltip>
	</div>
	<section class="scroller">
		{#if accountList.filter((item) => item.name.toLowerCase().includes(accSearch.toLowerCase())).length > 0}
			{#each accountList.filter((item) => item.name.toLowerCase().includes(accSearch.toLowerCase())) as account (account.id)}
				<AccountListItem {account} />
			{/each}
		{:else}
			<h3 style="text-align: left; color: #F3F4F5; margin-top: 1rem;">
				{$translations.account_not_found}
			</h3>
		{/if}
	</section>
</aside>

<style>
	aside {
		flex: 0 0 25%;
		padding-left: 1rem;
		padding-top: 0.4rem;
	}
	.heading {
		display: flex;
		justify-content: space-between;
		align-items: center;
		height: 1rem;
		margin-bottom: 10px;
		width: 100%;
	}
	.accounts-list-search {
		display: flex;
		align-items: center;
		gap: 1rem;
	}
	.fa-folder-plus {
		color: #fff;
		margin-right: 13px;
		margin-bottom: 20px;
	}
	
    .fa-folder-plus:hover {
        color: #7A7A7A;
    }

    .scroller {
        flex-grow: 1;
    }
	
	.acc-search {
		flex: 1;
		border-radius: 5px;
		border: none;
		padding: 1rem;
		margin-bottom: 1rem;
		background-color: var(--clr-primary-light);
		color: #fff;
	}
</style>
