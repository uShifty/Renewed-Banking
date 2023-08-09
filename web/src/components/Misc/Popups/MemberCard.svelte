<script lang="ts">
    import type { accountType } from "../../../types/types";
    import { selectedMembers } from "../../../store/stores";
    export let member: any;
  
    function toggleMemberSelection() {
      selectedMembers.update((currentSelectedMembers) => {
        if (currentSelectedMembers.includes(member.id)) {
          return currentSelectedMembers.filter((id) => id !== member.id);
        } else {
          return [...currentSelectedMembers, member.id];
        }
      });
    }
  </script>

  
  <div class="member-card" class:selected={$selectedMembers.includes(member.id)} on:click={toggleMemberSelection} on:keydown={() => {}}>
    <h3>{member.name}</h3>
    <p>{member.id}</p>
  </div>
  
  <style>
    .member-card {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 1rem;
      background-color: var(--clr-primary-lighest);
      color: #fff;
      border-radius: 0.5rem;
      cursor: pointer;
      transition: background-color 0.3s ease;
    }
  
    .member-card.selected {
      background-color: var(--clr-primary-light);
      border: 2px solid #000000; /* Add a border to selected member cards */
    }
  
    h3 {
      font-size: 1.6rem;
      margin-bottom: 0.5rem;
    }
  
    p {
      font-size: 1.2rem;
      opacity: 0.8;
    }
  </style>