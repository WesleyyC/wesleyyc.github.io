(function (root, factory) {
    const api = factory();
    if (typeof module === "object" && module.exports) module.exports = api;
    else root.PhotoSelection = api;
}(typeof globalThis !== "undefined" ? globalThis : this, function () {
    const selectRandom = (items, count, random = Math.random) => {
        const shuffled = Array.from(items);
        for (let index = shuffled.length - 1; index > 0; index -= 1) {
            const swapIndex = Math.floor(random() * (index + 1));
            [shuffled[index], shuffled[swapIndex]] = [shuffled[swapIndex], shuffled[index]];
        }
        return shuffled.slice(0, Math.min(Math.max(count, 0), shuffled.length));
    };

    return { selectRandom };
}));
