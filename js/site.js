(() => {
    const menu = document.querySelector("[data-floating-menu]");
    const trigger = menu?.querySelector("[data-menu-trigger]");
    const label = menu?.querySelector("[data-menu-label]");
    const links = menu?.querySelector("[data-menu-links]");
    let lastScrollY = window.scrollY;

    const setMenu = (open, returnFocus = false) => {
        if (!menu || !trigger || !label || !links) return;
        menu.classList.toggle("is-open", open);
        trigger.setAttribute("aria-expanded", String(open));
        links.setAttribute("aria-hidden", String(!open));
        links.inert = !open;
        label.textContent = open ? "Close" : "Menu";
        if (returnFocus) trigger.focus();
    };

    const closeMenu = (returnFocus = false) => setMenu(false, returnFocus);
    const revealMenu = () => menu?.classList.remove("scroll-hidden");

    const outside = (event) => {
        if (!menu?.classList.contains("is-open") || menu.contains(event.target)) return;
        closeMenu(true);
    };

    trigger?.addEventListener("click", () => {
        setMenu(!menu.classList.contains("is-open"));
    });

    document.addEventListener("click", outside);
    menu?.addEventListener("focusin", revealMenu);
    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && menu?.classList.contains("is-open")) {
            closeMenu(true);
        }
    });

    const photoFeed = document.querySelector("[data-photo-feed]");
    if (photoFeed) {
        const images = Array.from(photoFeed.children);
        for (let index = images.length - 1; index > 0; index -= 1) {
            const swapIndex = Math.floor(Math.random() * (index + 1));
            [images[index], images[swapIndex]] = [images[swapIndex], images[index]];
        }
        images.forEach((item, index) => {
            photoFeed.appendChild(item);
            const image = item.querySelector("img");
            if (!image) return;
            image.loading = index === 0 ? "eager" : "lazy";
            if (index === 0) image.setAttribute("fetchpriority", "high");
            else image.removeAttribute("fetchpriority");
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
