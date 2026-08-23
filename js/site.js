(() => {
    const menu = document.querySelector("[data-floating-menu]");
    const trigger = menu?.querySelector("[data-menu-trigger]");
    const links = menu?.querySelector("[data-menu-links]");
    let lastScrollY = window.scrollY;
    let ignoreNextFocusout = false;

    const setMenu = (open, { focusLinks = false, returnFocus = false } = {}) => {
        if (!menu || !trigger || !links) return;
        menu.classList.toggle("is-open", open);
        trigger.setAttribute("aria-expanded", String(open));
        trigger.setAttribute("aria-label", open ? "Menu open" : "Open menu");
        trigger.setAttribute("aria-hidden", String(open));
        trigger.inert = open;
        trigger.tabIndex = open ? -1 : 0;
        links.setAttribute("aria-hidden", String(!open));
        links.inert = !open;
        if (focusLinks) {
            const destination = links.querySelector(".active") || links.querySelector("a");
            destination?.focus();
        }
        if (returnFocus) trigger.focus();
    };

    const closeMenu = (returnFocus = false) => setMenu(false, { returnFocus });
    const revealMenu = () => menu?.classList.remove("scroll-hidden");

    const outside = (event) => {
        if (!menu?.classList.contains("is-open") || menu.contains(event.target)) return;
        closeMenu();
    };

    trigger?.addEventListener("keydown", (event) => {
        const opensMenu = event.key === "Enter" || event.key === " ";
        if (!opensMenu || menu.classList.contains("is-open")) return;
        event.preventDefault();
        setMenu(true, { focusLinks: true });
    });

    trigger?.addEventListener("click", (event) => {
        if (menu.classList.contains("is-open")) return;
        const openedFromKeyboard = event.detail === 0;
        if (!openedFromKeyboard) ignoreNextFocusout = true;
        setMenu(true, { focusLinks: openedFromKeyboard });
        if (!openedFromKeyboard) {
            trigger.blur();
            window.setTimeout(() => { ignoreNextFocusout = false; }, 0);
        }
    });

    document.addEventListener("click", outside);
    menu?.addEventListener("focusin", revealMenu);
    menu?.addEventListener("focusout", (event) => {
        if (ignoreNextFocusout) {
            ignoreNextFocusout = false;
            return;
        }
        const nextFocus = event.relatedTarget;
        if (nextFocus && menu.contains(nextFocus)) return;
        window.setTimeout(() => {
            if (menu.classList.contains("is-open") && !menu.contains(document.activeElement)) closeMenu();
        }, 0);
    });
    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && menu?.classList.contains("is-open")) {
            closeMenu(true);
        }
    });

    const photoFeed = document.querySelector("[data-photo-feed]");
    if (photoFeed && window.PhotoSelection) {
        const pool = Array.from(photoFeed.children);
        const images = window.PhotoSelection.selectRandom(pool, 12);
        const selected = new Set(images);
        pool.forEach((item) => {
            if (!selected.has(item)) item.remove();
        });
        images.forEach((item, index) => {
            photoFeed.appendChild(item);
            const image = item.querySelector("img");
            if (!image) return;
            image.loading = index === 0 ? "eager" : "lazy";
            if (index === 0) image.setAttribute("fetchpriority", "high");
            else image.removeAttribute("fetchpriority");
            const source = image.dataset.src;
            if (source) {
                image.src = source;
                image.removeAttribute("data-src");
            }
        });
    }

    document.querySelectorAll("img[loading='lazy']").forEach((image) => {
        const reveal = () => image.classList.add("loaded");
        if (image.complete) reveal();
        else image.addEventListener("load", reveal, { once: true });
    });

    const handleLongPageScroll = () => {
        if (!menu || !document.body.classList.contains("photo-page") || window.innerWidth > 720) return;
        const currentScrollY = window.scrollY;
        const scrollingDown = currentScrollY > lastScrollY && currentScrollY > 120;
        const menuBusy = menu.classList.contains("is-open") || menu.contains(document.activeElement);
        menu.classList.toggle("scroll-hidden", scrollingDown && !menuBusy);
        lastScrollY = currentScrollY;
    };

    window.addEventListener("scroll", handleLongPageScroll, { passive: true });
    window.addEventListener("resize", () => {
        if (window.innerWidth > 720) revealMenu();
    });
})();
