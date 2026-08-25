(() => {
    const menu = document.querySelector("[data-floating-menu]");
    const trigger = menu?.querySelector("[data-menu-trigger]");
    const links = menu?.querySelector("[data-menu-links]");
    const label = menu?.querySelector("[data-menu-label]");
    const menuInner = menu?.querySelector(".floating-menu__inner");
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
    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && menu?.classList.contains("is-open")) {
            closeMenu(true);
        }
    });

    measureMenu();

    window.addEventListener("resize", () => {
        menu?.classList.add("floating-menu--no-motion");
        measureMenu();
        window.clearTimeout(resizeTimer);
        resizeTimer = window.setTimeout(() => menu?.classList.remove("floating-menu--no-motion"), 150);
    });
})();
