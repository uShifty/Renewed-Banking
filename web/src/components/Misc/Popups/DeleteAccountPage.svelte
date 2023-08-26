<script lang="ts">
    import {
        accounts,
        activeAccount,
        popupDetails,
        translations,
        accountDeletionMessage,
        Player
    } from "../../../store/stores";
    import type { accountType } from "../../../types/types";
    import { fetchNui } from "../../../utils/fetchNui";
    import { onMount } from "svelte";


    // Use reactive statement to update the 'account' variable when 'accounts' or 'activeAccount' change
    $: account = $accounts.find((accountItem: accountType) => $activeAccount === accountItem.id);

    function closePopup() {
        popupDetails.update((val: any) => ({
            ...val,
            actionType: "",
        }));
    }

    let isConfirmed = false;

    async function confirmDeletion() {
       try {
            if (isConfirmed) {
                const retData = await fetchNui($popupDetails.actionType, { accountID: account.id });
                if (retData) {
                    accounts.update((accountList) => {
                        const updatedList = accountList.filter((accountItem: accountType) => {
                            return accountItem.id !== $activeAccount;
                        });
                        return updatedList;
                    });
                }              
            } else {
                console.log($translations.acc_del_scroll_warn);
            }
        } catch (error) {
            console.error("Error:", error);
        } finally {
            closePopup();
        }
    }
    let isTextBoxScrolled = false;
    onMount(() => {
        const checkbox = document.getElementById("confirmationCheckbox") as HTMLInputElement;
        const textbox = document.getElementsByClassName("textbox")[0] as HTMLElement;

        const handleScroll = () => {
            const { scrollTop, scrollHeight, clientHeight } = textbox;
            isTextBoxScrolled = scrollTop + clientHeight >= scrollHeight;
            if (checkbox.checked && !isTextBoxScrolled) {
                checkbox.checked = false;
                isConfirmed = false;
            }
        };

        handleScroll();

        textbox?.addEventListener("scroll", handleScroll);
    });

        
</script>

<section class="popup-content">
    <h2 style="color: red; text-align: center;"><i class="fas fa-exclamation-triangle"></i> {$translations.acc_del_title} <i class="fas fa-exclamation-triangle"></i></h2>
    <form action="#" style="display: flex; flex-direction: column;">
        <div class="form-row" style="margin-bottom: 1rem;">
            <pre class="textbox">{@html $translations.account_deletion_message.replace("@{name}", $Player.name)}</pre>
        </div>

        <div class="form-row" style="margin-bottom: 1rem; display: flex; justify-content: center; align-items: center;">
            <label class="custom-checkbox">
                <input type="checkbox" id="confirmationCheckbox" bind:checked={isConfirmed} disabled={!isTextBoxScrolled} />
                <span>{$translations.acc_deL_confirm}</span>
            </label>
        </div>

        <div class="btns-group">
            <button type="button" class="btn btn-orange" on:click={closePopup}>{$translations.cancel}</button>
            <button type="button" class={isConfirmed ? 'btn btn-green' : 'btn btn-grey'} on:click={confirmDeletion}  disabled={!isConfirmed} >{$translations.confirm}</button>
        </div>
    </form>
</section>

<style>
    .textbox {
      white-space: pre-wrap;
      font-family: inherit;
        width: 100%;
        max-height: 400px;
        overflow: auto;
        padding: 20px;
        border: 1px solid #ccc;
        border-radius: 5px;
        font-size: 16px;
        line-height: 1.5;
        resize: none;
        background-color: var(--clr-primary-light);
        color: #fff;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        transition: box-shadow 0.3s ease;
    }
    
  .textbox:hover,
  .textbox:focus {
    outline: none;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  }

  .textbox::-webkit-scrollbar {
    width: 8px;
  }

  .textbox::-webkit-scrollbar-track {
    background-color: #333;
  }

  .textbox::-webkit-scrollbar-thumb {
    background-color: #666;
    border-radius: 4px;
  }

  .textbox::-webkit-scrollbar-thumb:hover {
    background-color: #999;
  }
  .custom-checkbox {
    display: flex;
    align-items: center;
  }

  .custom-checkbox input[type="checkbox"] {
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
    width: 20px;
    height: 20px;
    position: relative;
    outline: none;
    transition: all 0.3s ease;
    margin-right: 10px; /* Add a right margin for gap */
    border: 2px solid var(--clr-primary-light);
    border-radius: 4px;
    background-color: #555;
    cursor: pointer;
  }

  .custom-checkbox input[type="checkbox"]:checked {
    background-color: #3498db;
    border-color: #3498db;
  }

  .custom-checkbox input[type="checkbox"]:checked::before {
    content: "\2713";
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    color: #fff;
    font-size: 16px;
    line-height: 1;
  }

  .custom-checkbox label {
    color: #fff;
    font-size: 14px;
    margin-left: 5px;
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

    .btns-group {
        display: flex;
        justify-content: center;
        gap: 2rem;
    }

    .btn {
        font-size: 1.4rem;
        padding: 1.2rem 2rem;
        border-radius: 5px;
        border: none;
        cursor: pointer;
    }

</style>
