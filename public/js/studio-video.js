(() => {
    const link = document.querySelector("[data-studio-video]");
    const dialog = document.querySelector("#studio-film");
    const video = dialog?.querySelector("video");
    const close = dialog?.querySelector("[data-studio-close]");
    if (!link || !video || !close || typeof dialog.showModal !== "function") return;

    link.setAttribute("aria-haspopup", "dialog");
    link.setAttribute("aria-controls", dialog.id);

    link.addEventListener("click", (event) => {
        // Preserve the direct file link for new-tab and modified clicks.
        if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
        event.preventDefault();
        dialog.showModal();
        // No media source is attached until the visitor asks to watch.
        video.src = link.href;
        video.play().catch(() => {
            // Native controls remain available if the browser requires another tap.
        });
    });

    close.addEventListener("click", () => dialog.close());
    dialog.addEventListener("click", (event) => {
        if (event.target !== dialog) return;
        const bounds = dialog.getBoundingClientRect();
        if (event.clientX < bounds.left || event.clientX > bounds.right
            || event.clientY < bounds.top || event.clientY > bounds.bottom) dialog.close();
    });
    dialog.addEventListener("close", () => {
        video.pause();
        video.removeAttribute("src");
        video.load();
        link.focus({ preventScroll: true });
    });
})();
