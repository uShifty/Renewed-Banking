<script>
    import { onMount, onDestroy, afterUpdate } from "svelte";

    export let tip = "";
    export let active = false;
    export let color = "#525364";

    let tooltipElement;
    let iconElement;
    let position = { x: 0, y: 0 };
    let tooltipWidth = 0;
    let tooltipHeight = 0;

    let style = `background-color: ${color};`;

    function handleMouseMove(event) {
        position = { x: event.clientX, y: event.clientY };
    }

    function calculateOffsets() {
        const windowWidth = window.innerWidth;
        const windowHeight = window.innerHeight;

        let left = position.x + 20;
        let top = position.y - 20;

        if (tooltipElement && iconElement) {
            tooltipWidth = tooltipElement.offsetWidth;
            tooltipHeight = tooltipElement.offsetHeight;

            left = Math.min(left, windowWidth - tooltipWidth);
            top = Math.min(top, windowHeight - tooltipHeight);

            left = Math.max(left, 0);
            top = Math.max(top, 0);

            tooltipElement.style.left = `${left}px`;
            tooltipElement.style.top = `${top}px`;
            tooltipElement.style.display = "block";

            const iconRect = iconElement.getBoundingClientRect();
            const isHoveringIcon = position.x >= iconRect.left && position.x <= iconRect.right && position.y >= iconRect.top && position.y <= iconRect.bottom;

            active = isHoveringIcon;
        }
    }

    onMount(() => {
        document.addEventListener("mousemove", handleMouseMove);
    });

    afterUpdate(() => {
        calculateOffsets();
    });

    onDestroy(() => {
        document.removeEventListener("mousemove", handleMouseMove);
    });
</script>

<div class="tooltip-wrapper">
    <span class="tooltip-slot" bind:this={iconElement}>
        <slot />
    </span>
    <div class="tooltip" class:active bind:this={tooltipElement} style="left: {position.x}px; top: {position.y}px;">
        {#if tip}
            <div class="default-tip" {style}>{tip}</div>
        {:else}
            <slot name="custom-tip" />
        {/if}
    </div>
</div>

<style>
    .tooltip-wrapper {
        position: relative;
        display: inline-block;
    }

    .tooltip {
        position: fixed;
        font-family: inherit;
        display: inline-block;
        white-space: nowrap;
        color: inherit;
        opacity: 0;
        visibility: hidden;
        transition: opacity 0.3s, visibility 0.3s;
        transform-style: preserve-3d;
        perspective: 1000px;
        z-index: 999;
        pointer-events: none;
    }

    .default-tip {
        display: inline-block;
        padding: 8px 16px;
        border-radius: 6px;
        color: inherit;
        background-color: #333;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        transform: translateZ(50px);
    }

    .tooltip.active {
        opacity: 1;
        visibility: visible;
        pointer-events: auto;
    }

    .tooltip-slot:hover + .tooltip {
        opacity: 1;
        visibility: visible;
        pointer-events: auto; /* Allow the tooltip to receive pointer events */
    }
</style>
