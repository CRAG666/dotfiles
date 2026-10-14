import Quickshell
import QtQuick

// Inline math ("sqrt(16)*2"); Enter copies the result.
Scope {
    id: root

    // arithmetic only: the input is whitelisted to numbers, operators and the
    // Math names below before it is evaluated
    function calculate(text) {
        const names = { sqrt: "Math.sqrt", sin: "Math.sin", cos: "Math.cos", tan: "Math.tan", log: "Math.log10", ln: "Math.log", abs: "Math.abs", round: "Math.round", floor: "Math.floor", ceil: "Math.ceil", pi: "Math.PI", e: "Math.E" };
        const expression = text.replace(/^=/, "").trim();
        const words = expression.match(/[a-z]+/gi) ?? [];
        if (!/\d/.test(expression) || !/^[\d\sa-z.+\-*/%^()]+$/i.test(expression) || !/[+\-*/%^(]/.test(expression))
            return null;
        if (words.some(word => !(word.toLowerCase() in names)))
            return null;
        const source = expression.replace(/[a-z]+/gi, word => names[word.toLowerCase()]).replace(/\^/g, "**");
        let value;
        try {
            value = Function(`"use strict"; return (${source});`)();
        } catch (error) {
            if (error instanceof SyntaxError)
                return null;
            throw error;
        }
        return typeof value === "number" && isFinite(value) ? String(Number(value.toPrecision(12))) : null;
    }

    function items(text) {
        const value = calculate(text);
        return value === null ? [] : [{ key: "calc", kind: "calc", store: root, title: value, icon: "accessories-calculator", value, expression: text }];
    }

    function describe(item) {
        return { glyph: item.value, title: item.expression + " =", actions: [["Enter", "Copy result"]] };
    }

    function activate(item, keys) {
        Spot.copy(item.value);
        return true;
    }
}
