(() => {
    const menu = document.querySelector("[data-floating-menu]");
    const trigger = menu?.querySelector("[data-menu-trigger]");
    const links = menu?.querySelector("[data-menu-links]");
    const label = menu?.querySelector("[data-menu-label]");
    const menuInner = menu?.querySelector(".floating-menu__inner");
    let resizeTimer;
    let lastScrollY = window.scrollY;
    let upwardDistance = 0;
    let keyboardInteraction = false;
    const mobileMenuQuery = window.matchMedia?.("(max-width: 720px)");

    const isMobileMenu = () => mobileMenuQuery?.matches ?? window.innerWidth <= 720;

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
        if (!label || !document.createRange) return;
        const labelRange = document.createRange();
        labelRange.selectNodeContents(label);
        const labelWidth = labelRange.getBoundingClientRect().width;
        if (labelWidth > 0) {
            menu.style.setProperty("--menu-collapsed-fit", `${labelWidth + 46}px`);
        }
        labelRange.detach?.();
    };

    const setScrollHidden = (hidden) => {
        if (!menu) return;
        const shouldHide = hidden && isMobileMenu();
        menu.classList.toggle("scroll-hidden", shouldHide);
        menu.inert = shouldHide;
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
        if (open) setScrollHidden(false);
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
    document.addEventListener("pointerdown", () => {
        keyboardInteraction = false;
    }, true);
    document.addEventListener("keydown", (event) => {
        keyboardInteraction = true;
        if (event.key === "Escape" && menu?.classList.contains("is-open")) {
            closeMenu(true);
        }
    });

    window.addEventListener("scroll", () => {
        const currentScrollY = window.scrollY;
        const delta = currentScrollY - lastScrollY;
        lastScrollY = currentScrollY;

        if (
            menu?.classList.contains("is-open")
            || currentScrollY <= 80
            || (keyboardInteraction && menu?.contains(document.activeElement))
        ) {
            upwardDistance = 0;
            setScrollHidden(false);
            return;
        }

        if (delta > 0) {
            upwardDistance = 0;
            setScrollHidden(true);
        } else if (delta < 0) {
            upwardDistance -= delta;
            if (upwardDistance >= 60) setScrollHidden(false);
        }
    }, { passive: true });

    measureMenu();

    window.addEventListener("resize", () => {
        menu?.classList.add("floating-menu--no-motion");
        if (!isMobileMenu()) setScrollHidden(false);
        measureMenu();
        window.clearTimeout(resizeTimer);
        resizeTimer = window.setTimeout(() => menu?.classList.remove("floating-menu--no-motion"), 150);
    });
})();
