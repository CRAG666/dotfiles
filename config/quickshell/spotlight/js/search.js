.pragma library

// Matching and ranking for Spotlight and the launcher. Text and query are
// folded (lowercase, accents dropped), and every token of the query has to
// match: exactly, across spaces ("shutdown" finds "Shut Down"), as initials
// ("vsc"), as letters in order within a word ("frfx") or, from five letters,
// with one typo ("fierfox"). score() says how well, from 1 down to 0 for no match.

function fold(text) {
    return text.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function tokens(text) {
    return fold(text).split(/\s+/).filter(token => token);
}

// `loose` false keeps to exact matches, for long text where letters in order
// or a typo would match almost anything
function score(text, queryTokens, loose = true) {
    let total = 0;
    for (const token of queryTokens) {
        const quality = exactScore(text, token) || loose && looseScore(shape(text), token);
        if (!quality)
            return 0;
        total += quality;
    }
    return queryTokens.length ? total / queryTokens.length : 1;
}

const shapes = new Map();

// the compact form, words and initials of a text, kept between keystrokes
function shape(text) {
    let found = shapes.get(text);
    if (!found) {
        if (shapes.size > 20000)
            shapes.clear();
        const words = text.split(/[^a-z0-9]+/).filter(word => word).slice(0, 40);
        found = { compact: text.replace(/[^a-z0-9]+/g, ""), words, initials: words.length <= 12 ? words.map(word => word[0]).join("") : "" };
        shapes.set(text, found);
    }
    return found;
}

function exactScore(text, token) {
    const at = text.indexOf(token);
    if (at === 0)
        return 1;
    if (at > 0)
        return /[a-z0-9]/.test(text[at - 1]) ? 0.75 : 0.9;
    const compactToken = token.replace(/[^a-z0-9]+/g, "");
    return compactToken && shape(text).compact.includes(compactToken) ? 0.7 : 0;
}

function looseScore({ words, initials }, token) {
    if (token.length >= 2 && initials.includes(token))
        return 0.8;
    let quality = 0;
    for (const word of words) {
        if (word[0] !== token[0])
            continue;
        if (token.length >= 3 && word.length <= token.length * 2 && isSubsequence(token, word))
            quality = Math.max(quality, 0.5);
        else if (token.length >= 5 && isTypo(token, word))
            quality = Math.max(quality, 0.45);
    }
    return quality;
}

function isSubsequence(token, word) {
    let at = 0;
    for (const letter of word)
        if (letter === token[at] && ++at === token.length)
            return true;
    return false;
}

// one edit away from the word or from its start, two for long tokens
function isTypo(token, word) {
    const limit = token.length >= 8 ? 2 : 1;
    return Math.abs(token.length - word.length) <= limit && distance(token, word) <= limit
        || word.length > token.length && distance(token, word.slice(0, token.length)) <= 1;
}

// optimal string alignment distance: insertions, deletions, substitutions and
// swaps of neighbours
function distance(a, b) {
    let twoBack = [];
    let previous = Array.from({ length: b.length + 1 }, (_, column) => column);
    for (let row = 1; row <= a.length; row++) {
        const current = [row];
        for (let column = 1; column <= b.length; column++) {
            let value = Math.min(previous[column] + 1, current[column - 1] + 1, previous[column - 1] + (a[row - 1] === b[column - 1] ? 0 : 1));
            if (row > 1 && column > 1 && a[row - 1] === b[column - 2] && a[row - 2] === b[column - 1])
                value = Math.min(value, twoBack[column - 2] + 1);
            current.push(value);
        }
        twoBack = previous;
        previous = current;
    }
    return previous[b.length];
}

// what having been picked `weight` times adds to a score: enough to reorder
// matches of a similar quality, never enough to lift a poor match over a good one
function boost(weight) {
    return Math.min(0.35, 0.07 * Math.log2(1 + weight));
}
