<script>
    import { createEventDispatcher, onMount, afterUpdate, onDestroy } from "svelte";
  
    export let options = []; // Array of options for the context menu
    export let x = 0; // x-coordinate of the menu position
    export let y = 0; // y-coordinate of the menu position
    export let showMenu = false; // State to control menu visibility
  
    const dispatch = createEventDispatcher();
  
    function handleOptionClick(option) {
      // Emit the optionClick event with the selected option
      dispatch("optionClick", option);
      showMenu = false; // Close the menu when an option is clicked
    }
  
    function handleOutsideClick(event) {
      // Hide the menu if clicked outside
      if (!event.target.closest(".context-menu")) {
        showMenu = false;
      }
    }
  
    // Listen for click events on the entire document to handle clicks outside the menu
    onMount(() => {
      document.addEventListener("click", handleOutsideClick);
      return () => {
        document.removeEventListener("click", handleOutsideClick);
      };
    });
  
    // Ensure that the context menu is closed when the component updates or is destroyed
    afterUpdate(() => {
      if (showMenu) {
        document.addEventListener("click", handleOutsideClick);
      } else {
        document.removeEventListener("click", handleOutsideClick);
      }
    });
  
    onDestroy(() => {
      document.removeEventListener("click", handleOutsideClick);
    });
  </script>
  
  {#if showMenu}
  <div class="context-menu" style="top: {y}px; left: {x}px;">
    {#each options as option}
    <div class="option" on:click={() => handleOptionClick(option)}>
      {option}
    </div>
    {/each}
  </div>
  {/if}
  
  <style>
  .context-menu {
    position: fixed;
    z-index: 9999;
    background-color: #525364;
    border: 1px solid #1B1B21;
    border-radius: 4px;
    padding: 8px 0;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    font-family: Arial, sans-serif;
  }
  
  .option {
    padding: 8px 16px;
    cursor: pointer;
    transition: background-color 0.3s;
  }
  
  .option:hover {
    background-color: #f0f0f0;
  }
  </style>
  