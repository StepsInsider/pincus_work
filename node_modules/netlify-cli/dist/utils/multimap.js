export class MultiMap {
    map = new Map();
    add(key, value) {
        this.map.set(key, [...(this.map.get(key) ?? []), value]);
    }
    get(key) {
        return this.map.get(key) ?? [];
    }
    keys() {
        return this.map.keys();
    }
}
//# sourceMappingURL=multimap.js.map