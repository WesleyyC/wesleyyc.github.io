(() => {
    const menu = document.querySelector("[data-floating-menu]");
    const trigger = menu?.querySelector("[data-menu-trigger]");
    const links = menu?.querySelector("[data-menu-links]");
    const label = menu?.querySelector("[data-menu-label]");
    const menuInner = menu?.querySelector(".floating-menu__inner");
    let lastScrollY = window.scrollY;
    let resizeTimer;

    const randomizeMenuTiming = () => {
        if (!menu) return;
        const vary = () => 0.85 + (0.3 * Math.random());
        menu.style.setProperty("--menu-width-duration-retract", `${Math.round(655 * vary())}ms`);
        menu.style.setProperty("--menu-height-duration-retract", `${Math.round(475 * vary())}ms`);
        menu.style.setProperty("--menu-width-duration-expand", `${Math.round(590 * vary())}ms`);
        menu.style.setProperty("--menu-height-duration-expand", `${Math.round(428 * vary())}ms`);
    };

    const measureMenu = () => {
        if (!menu || !menuInner) return;
        menu.style.setProperty("--menu-open-height", `${menuInner.scrollHeight + 18}px`);
    };

    const setMenu = (open, { returnFocus = false } = {}) => {
        if (!menu || !trigger || !links || !label) return;
        randomizeMenuTiming();
        menu.classList.toggle("is-open", open);
        label.textContent = open ? "Close" : "Menu";
        trigger.setAttribute("aria-expanded", String(open));
        trigger.setAttribute("aria-label", open ? "Close menu" : "Open menu");
        links.setAttribute("aria-hidden", String(!open));
        links.inert = !open;
        if (returnFocus) trigger.focus();
    };

    const closeMenu = (returnFocus = false) => setMenu(false, { returnFocus });
    const revealMenu = () => menu?.classList.remove("scroll-hidden");

    const outside = (event) => {
        if (!menu?.classList.contains("is-open") || menu.contains(event.target)) return;
        closeMenu();
    };

    trigger?.addEventListener("click", () => {
        setMenu(!menu.classList.contains("is-open"));
    });

    links?.addEventListener("click", (event) => {
        if (event.target.closest("a")) closeMenu();
    });

    document.addEventListener("click", outside);
    menu?.addEventListener("focusin", revealMenu);
    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && menu?.classList.contains("is-open")) {
            closeMenu(true);
        }
    });

    measureMenu();

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
        menu?.classList.add("floating-menu--no-motion");
        measureMenu();
        window.clearTimeout(resizeTimer);
        resizeTimer = window.setTimeout(() => menu?.classList.remove("floating-menu--no-motion"), 150);
        if (window.innerWidth > 720) revealMenu();
    });
})();
