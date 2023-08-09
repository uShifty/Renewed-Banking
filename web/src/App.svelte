<script lang="ts">
    import VisibilityProvider from "./providers/VisibilityProvider.svelte";
    import { debugData } from "./utils/debugData";
    import AccountsContainer from "./components/AccountsContainer.svelte";
    import Popup from "./components/Misc/Popup.svelte";
    import Loading from "./components/Misc/Loading.svelte";
    import Notification from "./components/Misc/Notification.svelte";
    import { popupDetails, loading, notify } from "./store/stores";

    debugData([
        {
            action: "setVisible",
            data: true,
        },
    ]);
</script>

<svelte:head>
    <link rel="stylesheet" href="https://site-assets.fontawesome.com/releases/v6.4.0/css/all.css" />
    <link rel="stylesheet" href="https://site-assets.fontawesome.com/releases/v6.4.0/css/sharp-solid.css">
    <link rel="stylesheet" href="https://site-assets.fontawesome.com/releases/v6.4.0/css/sharp-regular.css">
    <link rel="stylesheet" href="https://site-assets.fontawesome.com/releases/v6.4.0/css/sharp-light.css">
</svelte:head>
<VisibilityProvider>
    <AccountsContainer />
    {#if $popupDetails.actionType !== ""}
        <Popup />
    {/if}
    {#if $notify !== ""}
        <Notification />
    {/if}
</VisibilityProvider>

{#if $loading}
    <Loading />
{/if}
