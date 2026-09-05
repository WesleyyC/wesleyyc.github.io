const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");

class FakeClassList {
    constructor() {
        this.values = new Set();
    }

    add(value) {
        this.values.add(value);
    }

    remove(value) {
        this.values.delete(value);
    }

    contains(value) {
        return this.values.has(value);
    }

    toggle(value, force) {
        if (force === true) this.add(value);
        else if (force === false) this.remove(value);
        else if (this.contains(value)) this.remove(value);
        else this.add(value);
    }
}

const element = (properties = {}) => {
    const listeners = new Map();
    return {
        classList: new FakeClassList(),
        inert: false,
        style: { setProperty() {} },
        addEventListener(type, listener) {
            listeners.set(type, listener);
        },
        dispatch(type, event = {}) {
            listeners.get(type)?.(event);
        },
        setAttribute() {},
        contains(candidate) {
            return candidate === this;
        },
        ...properties,
    };
};

const label = element({ textContent: "Menu" });
const trigger = element({ focus() { fakeDocument.activeElement = trigger; } });
const currentLink = element({ focus() { fakeDocument.activeElement = currentLink; } });
const links = element({ querySelector() { return currentLink; } });
const menuInner = element({ scrollHeight: 198 });
const menu = element({
    querySelector(selector) {
        return {
            "[data-menu-trigger]": trigger,
            "[data-menu-links]": links,
            "[data-menu-label]": label,
            ".floating-menu__inner": menuInner,
        }[selector];
    },
    contains(candidate) {
        return [menu, trigger, links, currentLink, label, menuInner].includes(candidate);
    },
});

const windowListeners = new Map();
let isMobileViewport = true;
const fakeWindow = {
    scrollY: 0,
    innerWidth: 390,
    innerHeight: 844,
    matchMedia() {
        return {
            get matches() {
                return isMobileViewport;
            },
        };
    },
    addEventListener(type, listener) {
        windowListeners.set(type, listener);
    },
    clearTimeout() {},
    setTimeout() {
        return 1;
    },
};

const documentListeners = new Map();
const fakeDocument = {
    activeElement: null,
    documentElement: { scrollHeight: 2408 },
    querySelector(selector) {
        return selector === "[data-floating-menu]" ? menu : null;
    },
    addEventListener(type, listener) {
        documentListeners.set(type, listener);
    },
    dispatch(type, event = {}) {
        documentListeners.get(type)?.(event);
    },
};

const source = fs.readFileSync("public/js/site.js", "utf8");
vm.runInNewContext(source, {
    document: fakeDocument,
    window: fakeWindow,
});

const scroll = (y) => {
    fakeWindow.scrollY = y;
    windowListeners.get("scroll")();
};

assert.equal(typeof windowListeners.get("scroll"), "function", "menu should listen for scroll direction");

scroll(70);
assert.equal(menu.classList.contains("scroll-hidden"), false, "menu stays visible near the top");

scroll(100);
assert.equal(menu.classList.contains("scroll-hidden"), true, "downward scrolling hides the menu after 80px");
assert.equal(menu.inert, true, "a hidden menu leaves the interaction order");

scroll(80);
assert.equal(menu.classList.contains("scroll-hidden"), false, "returning to the top guard reveals the menu");
assert.equal(menu.inert, false, "a visible menu is interactive");

scroll(200);
scroll(160);
assert.equal(menu.classList.contains("scroll-hidden"), true, "less than 60px of upward travel keeps the menu hidden");

scroll(139);
assert.equal(menu.classList.contains("scroll-hidden"), false, "60px of upward travel reveals the menu");

fakeDocument.activeElement = trigger;
fakeDocument.dispatch("keydown", { key: "Tab" });
scroll(250);
assert.equal(menu.classList.contains("scroll-hidden"), false, "keyboard focus keeps the menu visible");

fakeDocument.dispatch("pointerdown");
scroll(270);
assert.equal(menu.classList.contains("scroll-hidden"), true, "pointer focus does not pin the menu after a tap");

fakeDocument.activeElement = null;
trigger.dispatch("click");
assert.equal(menu.classList.contains("scroll-hidden"), false, "opening the menu reveals it");

scroll(330);
assert.equal(menu.classList.contains("scroll-hidden"), false, "an open menu stays visible while scrolling");

trigger.dispatch("click");
isMobileViewport = false;
scroll(400);
assert.equal(menu.classList.contains("scroll-hidden"), false, "desktop keeps the visible menu free of mobile hidden state");
assert.equal(menu.inert, false, "desktop menu remains interactive after scrolling");

// Keyboard and pointer opening intentionally have different focus behavior.
fakeDocument.activeElement = trigger;
trigger.dispatch("click", { detail: 0 });
assert.equal(fakeDocument.activeElement, currentLink, "keyboard opening focuses the current route");
assert.equal(links.inert, false, "open links enter the interaction order");

menu.dispatch("focusout", { relatedTarget: trigger });
assert.equal(menu.classList.contains("is-open"), true, "moving within the menu keeps it open");
menu.dispatch("focusout", { relatedTarget: null });
assert.equal(menu.classList.contains("is-open"), false, "leaving the menu dismisses it");
assert.equal(links.inert, true, "dismissed links leave the interaction order");

fakeDocument.activeElement = trigger;
trigger.dispatch("click", { detail: 1 });
assert.equal(fakeDocument.activeElement, trigger, "pointer opening does not move focus");
fakeDocument.activeElement = currentLink;
fakeDocument.dispatch("keydown", { key: "Escape" });
assert.equal(fakeDocument.activeElement, trigger, "Escape returns focus to the trigger");
assert.equal(menu.classList.contains("is-open"), false, "Escape closes the menu");

// Switching from pointer scrolling to a keyboard must restore the Tab destination.
isMobileViewport = true;
fakeDocument.activeElement = null;
fakeDocument.dispatch("pointerdown");
scroll(900);
fakeDocument.dispatch("keydown", { key: "Tab" });
assert.equal(menu.classList.contains("scroll-hidden"), false, "Tab restores navigation hidden by pointer scrolling");
assert.equal(menu.inert, false, "Tab restores the menu to the focus order before focus advances");

fakeDocument.dispatch("pointerdown");
scroll(1000);
assert.equal(menu.classList.contains("scroll-hidden"), true, "pointer scrolling can hide the menu again");
scroll(1520);
assert.equal(menu.classList.contains("scroll-hidden"), false, "finishing a page reveals navigation within 48px of the bottom");
assert.equal(menu.inert, false, "navigation at the page ending is interactive");
scroll(1530);
assert.equal(menu.classList.contains("scroll-hidden"), false, "further downward travel near the bottom keeps navigation visible");
scroll(1400);
scroll(1410);
assert.equal(menu.classList.contains("scroll-hidden"), true, "normal downward hiding resumes away from the page ending");

console.log("menu behavior: 29 assertions passed");
