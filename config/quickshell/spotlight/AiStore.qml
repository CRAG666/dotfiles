import Quickshell
import Quickshell.Io
import QtQuick

// pi with the model and thinking level of spotlight.json's `ai`: "Ask pi"
// answers any search in place, and the AI commands from spotlight.json rewrite
// the text selected in any window (the ones with output "paste" replace the
// selection). Enter asks; once the answer is in, Enter copies or pastes it.
// Questions within 10 minutes of the last answer can follow up in the same
// chat, a pi session in the cache.
Scope {
    id: root
    property var host
    property var chat: null   // { id, turns: [{ key, question, answer }], at } that follow-ups continue
    readonly property string sessionDir: Spot.cacheDir + "/pi"
    readonly property string quickPrompt: "Quick-answer assistant inside a desktop launcher: be brief, use plain Markdown and answer in the user's language."
    readonly property string transformPrompt: "You transform text inside a desktop launcher. Follow the instruction exactly and return only the result, with no preamble."

    function reset() {
        pi.running = false;
        pi.key = "";
        pi.answer = "";
        pi.question = "";
    }

    function chatOpen() {
        return chat !== null && chat.turns.length > 0 && Date.now() - chat.at < 600000;
    }

    // the question just asked keeps its answer; otherwise an open chat offers a follow-up first
    function askItems(text) {
        const ask = { key: "ask:" + text, kind: "ai", store: root, title: `Ask pi “${text}”`, glyph: "✦", value: text };
        if (pi.key === ask.key || !chatOpen())
            return [ask];
        return [Object.assign({}, ask, { key: "follow:" + text, title: `Follow up with pi “${text}”`, follow: true }), Object.assign(ask, { title: `Ask pi in a new chat “${text}”` })];
    }

    // the chat's other turns, newest first, under the answer
    function earlierTurns(item) {
        const turns = item.follow && chat ? chat.turns.filter(turn => turn.key !== item.key).reverse() : [];
        return turns.map(turn => `\n\n---\n\n**${turn.question}**\n\n${turn.answer}`).join("");
    }

    function commandItems(tokens) {
        return (host.userConfig.aiCommands ?? [])
            .filter(command => Spot.matches(command.name, tokens))
            .map(command => ({ key: "aicmd:" + command.name, kind: "aiCommand", store: root, command, title: command.name, hint: host.selectedText ? "on selection" : "nothing selected", glyph: "✦" }));
    }

    function describe(item) {
        const answered = pi.key === item.key;
        if (item.kind === "ai") {
            const title = item.follow ? "Follow up with pi" : "Ask pi";
            const earlier = earlierTurns(item);
            if (answered && !pi.answer)
                return { glyph: "✦", title, subtitle: item.value, body: "Thinking…" + earlier, markdown: true, footer: `pi is answering with ${host.userConfig.ai.model}` };
            return { glyph: "✦", title, subtitle: item.value, body: (answered ? pi.answer : "") + earlier, markdown: true, actions: [["Enter", !answered ? title : pi.failed ? "Try again" : "Copy answer"]] };
        }
        if (!host.selectedText)
            return { glyph: "✦", title: item.title, subtitle: "Select some text in any window, then open Spotlight", footer: "Nothing selected" };
        if (answered && !pi.answer)
            return { glyph: "✦", title: item.title, body: "Thinking…", footer: "pi is working on the selected text" };
        if (answered)
            return { glyph: "✦", title: item.title, body: pi.answer, markdown: true, actions: pi.failed ? [["Enter", "Try again"]] : item.command.output === "paste" ? [["Enter", "Replace selection"], ["Ctrl+C", "Copy result"]] : [["Enter", "Copy result"]] };
        return { glyph: "✦", title: item.title, subtitle: "Selected text", body: host.selectedText.slice(0, 2000), actions: [["Enter", "Run with pi"]] };
    }

    function activate(item, keys) {
        if (item.kind === "aiCommand" && !host.selectedText) {
            host.notify("Select some text in any window first, then open Spotlight");
            return false;
        }
        if (pi.key !== item.key || !pi.answer || pi.failed) {
            if (item.kind === "ai") {
                if (!item.follow)
                    chat = { id: "spotlight-" + Date.now(), turns: [], at: Date.now() };
                pi.ask(item.key, item.value, quickPrompt, ["--session-dir", sessionDir, "--session-id", chat.id], item.value);
            } else {
                pi.ask(item.key, `${item.command.prompt}\n\n---\n${host.selectedText}`, transformPrompt, ["--no-session"], "");
            }
            return false;
        }
        if (item.kind === "aiCommand" && item.command.output === "paste")
            Spot.type(pi.answer);
        else
            Spot.copy(pi.answer);
        return true;
    }

    function copy(item) {
        Spot.copy(pi.key === item.key && pi.answer ? pi.answer : item.value ?? item.title);
    }

    Process {
        id: pi
        property string key: ""
        property string answer: ""
        property string question: ""   // a chat question, recorded as a turn once answered
        property bool failed: false   // `answer` holds pi's error, and Enter asks again
        property var queued: null   // the next question's command, while the previous pi is stopped

        // pi -p waits on an open stdin, so it gets /dev/null
        function ask(forKey, prompt, system, sessionArgs, chatQuestion) {
            key = forKey;
            answer = "";
            failed = false;
            question = chatQuestion;
            queued = ["sh", "-c", 'exec pi "$@" < /dev/null', "sh", "-p", "--model", root.host.userConfig.ai.model, "--thinking", root.host.userConfig.ai.thinking, ...sessionArgs, "--no-tools", "--no-context-files", "--no-skills", "--no-prompt-templates", "--offline", "--system-prompt", system, "--", prompt];
            if (running)
                running = false;   // its exit starts the queued one
            else
                startQueued();
        }

        function startQueued() {
            command = queued;
            queued = null;
            running = true;
        }

        stdout: StdioCollector {
            onStreamFinished: {
                if (pi.queued)
                    return;
                pi.answer = text.trim();
                if (pi.question && pi.answer)
                    root.chat = Object.assign({}, root.chat, { turns: [...root.chat.turns, { key: pi.key, question: pi.question, answer: pi.answer }], at: Date.now() });
            }
        }
        // pi writes its errors, after a warning about a new session, to stderr
        stderr: StdioCollector {
            id: piErrors
        }
        onExited: exitCode => {
            if (queued)
                startQueued();
            else if (exitCode !== 0 && !answer) {
                failed = true;
                answer = "pi failed: " + (piErrors.text.split("\n").filter(line => line.trim() && !line.startsWith("Warning:")).pop() ?? `exit code ${exitCode}`);
            }
        }
    }
}
