const assert = require("node:assert/strict");
const fs = require("node:fs");
const test = require("node:test");
const vm = require("node:vm");

const source = fs.readFileSync("public/js/studio-video.js", "utf8");

// Thin browser API doubles exercise the shipped script's event wiring and effects.
// Native focus containment, Escape, and actual playback are checked in a browser.
function setup({ supported = true, rejectPlay = false } = {}) {
    const document = { activeElement: null };
    class Element extends EventTarget {
        attributes = new Map();
        setAttribute(name, value) { this.attributes.set(name, value); }
        removeAttribute(name) { this.attributes.delete(name); }
        hasAttribute(name) { return this.attributes.has(name); }
        get src() { return this.attributes.get("src") || ""; }
        set src(value) { this.setAttribute("src", value); }
        focus() { document.activeElement = this; }
    }
    const link = new Element();
    link.href = "http://localhost/media/osmo-studio-launch.mp4";
    const dialog = new Element();
    const video = new Element();
    const close = new Element();
    dialog.id = "studio-film";
    dialog.open = false;
    if (supported) dialog.showModal = () => { dialog.open = true; };
    dialog.close = () => {
        dialog.open = false;
        dialog.dispatchEvent(new Event("close"));
    };
    dialog.getBoundingClientRect = () => ({ left: 100, right: 600, top: 100, bottom: 500 });
    video.paused = true;
    video.playRequests = 0;
    video.loadRequests = 0;
    video.play = () => {
        video.playRequests += 1;
        if (rejectPlay) return Promise.reject(new Error("Playback requires another tap"));
        video.paused = false;
        return Promise.resolve();
    };
    video.pause = () => { video.paused = true; };
    video.load = () => { video.loadRequests += 1; };
    dialog.querySelector = (selector) => ({
        video, "[data-studio-close]": close,
    }[selector]);
    document.querySelector = (selector) => ({
        "[data-studio-video]": link, "#studio-film": dialog,
    }[selector]);
    vm.runInNewContext(source, { document });
    return { document, link, dialog, video, close };
}

function click(target, properties = {}) {
    const event = new Event("click", { cancelable: true });
    Object.assign(event, { button: 0, ...properties });
    target.dispatchEvent(event);
    return event;
}

test("loads and plays the film only after normal link activation", () => {
    const { link, dialog, video } = setup();
    assert.equal(video.src, "");
    assert.equal(video.playRequests, 0);
    assert.equal(click(link).defaultPrevented, true);
    assert.equal(dialog.open, true);
    assert.equal(video.src, "http://localhost/media/osmo-studio-launch.mp4");
    assert.equal(video.playRequests, 1);
});

test("closing pauses and unloads the film and returns focus to the link", () => {
    const { document, link, dialog, video, close } = setup();
    click(link);
    click(close);
    assert.equal(dialog.open, false);
    assert.equal(video.paused, true);
    assert.equal(video.hasAttribute("src"), false);
    assert.equal(video.loadRequests, 1);
    assert.equal(document.activeElement, link);
});

test("modified and non-primary clicks retain the ordinary file link", () => {
    for (const properties of [{ metaKey: true }, { ctrlKey: true }, { shiftKey: true }, { altKey: true }, { button: 1 }]) {
        const { link, dialog, video } = setup();
        assert.equal(click(link, properties).defaultPrevented, false);
        assert.equal(dialog.open, false);
        assert.equal(video.src, "");
    }
});

test("backdrop clicks dismiss the film while clicks inside the dialog do not", () => {
    const { link, dialog, video } = setup();
    click(link);
    click(dialog, { clientX: 200, clientY: 200 });
    assert.equal(dialog.open, true);
    click(dialog, { clientX: 50, clientY: 200 });
    assert.equal(dialog.open, false);
    assert.equal(video.hasAttribute("src"), false);
});

test("native dialog dismissal also cleans up and restores focus", () => {
    const { document, link, dialog, video } = setup();
    click(link);
    dialog.close();
    assert.equal(video.paused, true);
    assert.equal(video.src, "");
    assert.equal(document.activeElement, link);
});

test("browsers without native dialogs retain the direct link", () => {
    const { link, video } = setup({ supported: false });
    assert.equal(click(link).defaultPrevented, false);
    assert.equal(video.src, "");
});

test("a rejected play request leaves the dialog available for native controls", async () => {
    const { link, dialog, video } = setup({ rejectPlay: true });
    click(link);
    await Promise.resolve();
    assert.equal(dialog.open, true);
    assert.equal(video.src, "http://localhost/media/osmo-studio-launch.mp4");
});
