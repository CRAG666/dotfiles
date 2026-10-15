import Quickshell
import Quickshell.Io
import QtQuick

// Inline math ("sqrt(16)*2") answered at once; anything else with a digit or a
// clock ("5 km to mi", "100 usd to mxn", "20% of 350", "0xff", "5pm cdmx in
// tokyo", "days until dec 25", "in 3 weeks") goes, debounced, to spotlight.py
// calc (qalc, date and zoneinfo). Enter copies the result.
Scope {
    id: root
    property string query: ""   // sent to spotlight.py, debounced; "" clears the answer
    property var answer: null   // { query, value, detail }

    onQueryChanged: debounce.restart()

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
        if (value !== null)
            return [{ key: "calc", kind: "calc", store: root, title: value, icon: "accessories-calculator", value, detail: text + " =" }];
        if (answer?.query === text)
            return [{ key: "calc", kind: "calc", store: root, title: answer.value, icon: "accessories-calculator", value: answer.value, detail: answer.detail }];
        return [];
    }

    function describe(item) {
        return { glyph: item.value, title: item.detail, actions: [["Enter", "Copy result"]] };
    }

    function activate(item, keys) {
        Spot.copy(item.value);
        return true;
    }

    Timer {
        id: debounce
        interval: 120
        onTriggered: {
            if (!/\d|^(now|time)\b/i.test(root.query) || root.calculate(root.query) !== null) {
                root.answer = null;
                return;
            }
            helper.forQuery = root.query;
            helper.exec(["python3", Spot.helper, "calc", root.query]);
        }
    }

    Process {
        id: helper
        property string forQuery: ""
        stdout: StdioCollector {
            onStreamFinished: {
                const answer = text.trim() ? JSON.parse(text) : null;
                if (helper.forQuery === root.query)
                    root.answer = answer ? Object.assign({ query: helper.forQuery }, answer) : null;
            }
        }
    }
}
