.pragma library

// Matching and ranking for Spotlight and the launcher. Text and query are
// folded (lowercase, accents dropped), and every token of the query has to
// match: exactly, across spaces ("shutdown" finds "Shut Down"), as initials
// ("vsc"), as letters in order within a word ("frfx") or, from five letters,
// with one typo anywhere ("fierfox", "girefox"). score() says how well: from
// 1 down to 0 for no match, plus a tie-break within a tier (coverage).

// QML's JS engine looks Map keys up one by one and runs for…of loops several
// times slower than indexed ones: the caches are plain objects and the hot
// loops index. Each cache keeps two generations of up to `limit` entries:
// when the young one fills it becomes the old one, and an entry read from the
// old one moves back to the young, so what is in use survives and nothing is
// ever deleted (V4 puts a deleted key that comes back where it was)
function generations(limit) {
    return { young: Object.create(null), old: Object.create(null), size: 0, limit };
}

function cached(cache, key, make) {
    let value = cache.young[key];
    if (value === undefined) {
        value = cache.old[key];
        if (value === undefined)
            value = make(key);
        cache.young[key] = value;
        if (++cache.size >= cache.limit) {
            cache.old = cache.young;
            cache.young = Object.create(null);
            cache.size = 0;
        }
    }
    return value;
}

const folds = generations(10000);

// the young generation is read in place: a hit allocates nothing
function fold(text) {
    const known = folds.young[text];
    return known !== undefined ? known : cached(folds, text, foldText);
}

function foldText(text) {
    return text.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function tokens(text) {
    return fold(text).split(/\s+/).filter(token => token);
}

// `loose` false keeps to exact matches, for long text where letters in order
// or a typo would match almost anything
function score(text, queryTokens, loose = true) {
    let total = 0;
    for (let index = 0; index < queryTokens.length; index++) {
        const token = queryTokens[index];
        const quality = tokenScore(text, token, loose);
        if (!quality)
            return 0;
        total += quality;
    }
    return queryTokens.length ? total / queryTokens.length + coverage(text, queryTokens) : 1;
}

// a tie-break within a tier, at most 0.04, below the 0.05 between tiers and
// the 0.5 a Top Hit needs: how much of the text the query covers, and whether
// it is the text, spaces and punctuation aside ("shutdown" is "Shut Down"), so
// "Config" leads "Reload Herdr Config" for "config"
function coverage(text, queryTokens) {
    const query = queryShape(queryTokens);
    return 0.03 * Math.min(1, query.typed / text.length) + (query.compact && query.compact === shape(text).compact ? 0.01 : 0);
}

// a query's length and compact form, kept on its token array: the same array
// is scored against every text of a keystroke, and no caller changes it
function queryShape(queryTokens) {
    let known = queryTokens.spotlightQuery;
    if (!known) {
        let typed = queryTokens.length - 1;
        let compact = "";
        for (let index = 0; index < queryTokens.length; index++) {
            typed += queryTokens[index].length;
            compact += tokenShape(queryTokens[index]).compact;
        }
        known = { typed, compact };
        Object.defineProperty(queryTokens, "spotlightQuery", { value: known });
    }
    return known;
}

const shapes = generations(10000);

// the compact form, words and initials of a text, kept between keystrokes
function shape(text) {
    return shapes.young[text] || cached(shapes, text, shapeOf);
}

function shapeOf(text) {
    const words = text.split(/[^a-z0-9]+/).filter(word => word).slice(0, 40);
    return { compact: text.replace(/[^a-z0-9]+/g, ""), words, wordMasks: words.map(charMask), initials: words.length <= 12 ? words.map(word => word[0]).join("") : "", mask: charMask(text) };
}

const tokenShapes = generations(1000);

// `positions`: for each of the token's letters, a bit at each place it holds,
// for the bit-parallel edit distance
function tokenShape(token) {
    return tokenShapes.young[token] || cached(tokenShapes, token, tokenShapeOf);
}

function tokenShapeOf(token) {
    const positions = Object.create(null);
    for (let index = 0; index < Math.min(token.length, 32); index++)
        positions[token[index]] = (positions[token[index]] | 0) | 1 << index;
    return { compact: token.replace(/[^a-z0-9]+/g, ""), mask: charMask(token), positions };
}

// a bit for each letter and digit a text holds (the digits share six bits):
// the bit-parallel character-set filter of fuzzy finders. Every letter of a
// token must be in the text for an exact, compact, initials or in-order match,
// and each typo accounts for at most one missing letter, so a text lacking
// more letters than the token's typos allow is dropped without looking further
function charMask(text) {
    let mask = 0;
    for (let index = 0; index < text.length; index++) {
        const code = text.charCodeAt(index);
        if (code >= 97 && code <= 122)
            mask |= 1 << code - 97;
        else if (code >= 48 && code <= 57)
            mask |= 1 << 26 + (code - 48) % 6;
    }
    return mask;
}

function bitCount(bits) {
    bits -= bits >>> 1 & 0x55555555;
    bits = (bits & 0x33333333) + (bits >>> 2 & 0x33333333);
    return Math.imul(bits + (bits >>> 4) & 0x0f0f0f0f, 0x01010101) >>> 24;
}

function typoLimit(token) {
    return token.length >= 8 ? 2 : token.length >= 5 ? 1 : 0;
}

function isAlphanumeric(code) {
    return code >= 97 && code <= 122 || code >= 48 && code <= 57;
}

function tokenScore(text, token, loose) {
    const at = text.indexOf(token);
    if (at === 0)
        return 1;
    if (at > 0)
        return isAlphanumeric(text.charCodeAt(at - 1)) ? 0.75 : 0.9;
    const wanted = tokenShape(token);
    const found = shape(text);
    const missing = bitCount(wanted.mask & ~found.mask);
    if (missing > (loose ? typoLimit(token) : 0))
        return 0;
    if (!missing && wanted.compact && found.compact.includes(wanted.compact))
        return 0.7;
    return loose ? looseScore(found, token, wanted.mask, missing) : 0;
}

// with letters `missing` from the text, only a typo can match
function looseScore({ words, wordMasks, initials }, token, tokenMask, missing) {
    if (!missing && token.length >= 2 && initials.includes(token))
        return 0.8;
    // letters in order (0.5) are the best a word can give here, so they end
    // the search, and once a word was a typo (0.45) only they could do better
    let quality = 0;
    const first = token.charCodeAt(0);
    for (let index = 0; index < words.length; index++) {
        const word = words[index];
        if (word.charCodeAt(0) === first && !missing && token.length >= 3 && word.length <= token.length * 2 && isSubsequence(token, word))
            return 0.5;
        if (!quality && token.length >= 5 && isTypo(token, word, tokenMask, wordMasks[index]))
            quality = 0.45;
    }
    return quality;
}

function isSubsequence(token, word) {
    let at = 0;
    for (let index = 0; index < word.length; index++)
        if (word.charCodeAt(index) === token.charCodeAt(at) && ++at === token.length)
            return true;
    return false;
}

// one edit away from the word or from its start, two for long tokens; a word
// lacking more of the token's letters than that is no typo of it, nor is its
// start (which holds fewer letters), so the masks drop it first
function isTypo(token, word, tokenMask, wordMask) {
    const limit = token.length >= 8 ? 2 : 1;
    if (word.length < token.length - limit || bitCount(tokenMask & ~wordMask) > limit)
        return false;
    return Math.abs(token.length - word.length) <= limit && within(token, word, limit, word.length)
        || word.length > token.length && within(token, word, 1, token.length);
}

// whether the optimal string alignment distance (insertions, deletions,
// substitutions and swaps of neighbours) of `token` and the first `length`
// letters of `word` is at most `limit`
function within(token, word, limit, length = word.length) {
    return token.length <= 32 ? distance(token, word, length) <= limit : withinTable(token, word.slice(0, length), limit);
}

// Hyyrö's bit-parallel optimal string alignment distance (2003, as RapidFuzz's
// osa_hyrroe2003): every row of the table for one letter of `word` at once, in
// 32-bit words, so the token can be up to 32 letters; JavaScript's bit
// operators wrap sums to 32 bits as the algorithm needs
// `closest`: the least distance to any start of `word` instead, the least
// value the bottom row of the table takes
function distance(token, word, length = word.length, closest = false) {
    const positions = tokenShape(token).positions;
    const last = 1 << token.length - 1;
    let vertical = ~0, verticalDown = 0, diagonal = 0, previousMatches = 0, score = token.length;
    let least = score;
    for (let index = 0; index < length; index++) {
        const matches = positions[word[index]] | 0;
        const swapped = (~diagonal & matches) << 1 & previousMatches;
        diagonal = ((matches & vertical) + vertical ^ vertical) | matches | verticalDown | swapped;
        let horizontal = verticalDown | ~(diagonal | vertical);
        let horizontalDown = diagonal & vertical;
        if (horizontal & last)
            score++;
        else if (horizontalDown & last)
            score--;
        horizontal = horizontal << 1 | 1;
        horizontalDown <<= 1;
        vertical = horizontalDown | ~(diagonal | horizontal);
        verticalDown = horizontal & diagonal;
        previousMatches = matches;
        least = Math.min(least, score);
    }
    return closest ? least : score;
}

// the same, row by row, for tokens too long for 32 bits, with Ukkonen's
// cutoff: once two rows in a row all exceed `limit`, no later cell can come
// back under it (a swap looks two rows back)
function withinTable(a, b, limit) {
    let twoBack = [];
    let previous = [];
    for (let column = 0; column <= b.length; column++)
        previous.push(column);
    let previousLeast = 0;
    for (let row = 1; row <= a.length; row++) {
        const current = [row];
        let least = row;
        for (let column = 1; column <= b.length; column++) {
            let value = Math.min(previous[column] + 1, current[column - 1] + 1, previous[column - 1] + (a.charCodeAt(row - 1) === b.charCodeAt(column - 1) ? 0 : 1));
            if (row > 1 && column > 1 && a.charCodeAt(row - 1) === b.charCodeAt(column - 2) && a.charCodeAt(row - 2) === b.charCodeAt(column - 1))
                value = Math.min(value, twoBack[column - 2] + 1);
            current.push(value);
            least = Math.min(least, value);
        }
        if (least > limit && previousLeast > limit)
            return false;
        previousLeast = least;
        twoBack = previous;
        previous = current;
    }
    return previous[b.length] <= limit;
}

// what having been picked `weight` times adds to a score: enough to reorder
// matches of a similar quality, never enough to lift a poor match over a good one
function boost(weight) {
    return Math.min(0.35, 0.07 * Math.log2(1 + weight));
}

const remembered = 16;

// items.filter(item => score(textOf(item), queryTokens, loose) > 0), textOf
// giving folded text, with the answers to the last queries kept on `items`
// itself under `name` (a reloaded list starts clean). The same query again, as
// when a source lands for the typed query, scores nothing. An exact match of a
// query is also one of every query it extends (the words so far, the last one
// shorter), so exact matching scans only the matches of the longest such
// query already answered, as fzf's query cache does. The answers are a short
// array, not an object: V4 puts a deleted key that comes back where it was,
// which would evict the newest answer
function matching(items, name, textOf, queryTokens, loose = true) {
    const answers = answersOf(items, name + (loose ? ":loose" : ":exact"));
    const key = queryTokens.join(" ");
    let candidates = items;
    let longest = -1;
    for (let index = 0; index < answers.length; index++) {
        const answer = answers[index];
        if (answer.key === key)
            return answer.found;
        if (answer.key.length > longest && extendsQuery(queryTokens, answer.tokens)) {
            candidates = answer.candidates;
            longest = answer.key.length;
        }
    }
    // a loose match is no monotone, but `possible` is: what may match a query
    // or any query extending it. Exact matching needs no such superset
    const narrowing = loose && queryTokens.some(token => token.length >= 3);
    const kept = [];
    const found = [];
    for (let index = 0; index < candidates.length; index++) {
        const text = textOf(candidates[index]);
        if (narrowing && !queryTokens.every(token => possible(text, token)))
            continue;
        kept.push(candidates[index]);
        if (score(text, queryTokens, loose) > 0)
            found.push(candidates[index]);
    }
    // frozen: callers share the cached answer, so changing it would be a bug
    Object.freeze(found);
    if (answers.push({ key, tokens: queryTokens, found, candidates: loose ? kept : found }) > remembered)
        answers.shift();
    return found;
}

// whether `text` may match `token` or a token extending it, loosely: each kind
// of loose match of a longer token implies one of these for the shorter one
// (a typo within 2 edits of a word leaves the shorter token within 2 edits of
// one of the word's starts). Two letters or fewer are within 2 edits of the
// empty start, so everything may match them
function possible(text, token) {
    if (token.length <= 2 || token.length > 32 || text.indexOf(token) >= 0)
        return true;
    const wanted = tokenShape(token);
    const found = shape(text);
    if (wanted.compact && found.compact.includes(wanted.compact) || found.initials.includes(token))
        return true;
    const first = token.charCodeAt(0);
    for (let index = 0; index < found.words.length; index++) {
        const word = found.words[index];
        if (word.charCodeAt(0) === first && isSubsequence(token, word))
            return true;
        if (bitCount(wanted.mask & ~found.wordMasks[index]) <= 2 && distance(token, word, word.length, true) <= 2)
            return true;
    }
    return false;
}

function answersOf(items, name) {
    if (!items.spotlightMatches)
        Object.defineProperty(items, "spotlightMatches", { value: Object.create(null) });
    return items.spotlightMatches[name] || (items.spotlightMatches[name] = []);
}

// whether a query with `queryTokens` extends one with `earlier`, so that each of
// its exact matches is one of the earlier's; a token of punctuation alone never
// matches as a compact form and stays out
function extendsQuery(queryTokens, earlier) {
    if (earlier.length > queryTokens.length)
        return false;
    for (let index = 0; index < earlier.length; index++) {
        const last = index === earlier.length - 1;
        if (!tokenShape(earlier[index]).compact || (last ? !queryTokens[index].startsWith(earlier[index]) : queryTokens[index] !== earlier[index]))
            return false;
    }
    return true;
}
