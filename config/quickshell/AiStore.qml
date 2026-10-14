import Quickshell
import Quickshell.Io
import QtQuick

// pi with its default model: "Ask pi" answers any search in place, and the AI
// commands from spotlight.json rewrite the text selected in any window (the
// ones with output "paste" replace the selection). Enter asks; once the answer
// is in, Enter copies or pastes it.
Scope {
    id: root
    property var host
    readonly property string quickPrompt: "Quick-answer assistant inside a desktop launcher: be brief, use plain Markdown and answer in the user's language."
    readonly property string transformPrompt: "You transform text inside a desktop launcher. Follow the instruction exactly and return only the result, with no preamble."

    function reset() {
        pi.running = false;
        pi.key = "";
        pi.answer = "";
    }

    function askItems(text) {
        return [{ key: "ask:" + text, kind: "ai", store: root, title: `Ask pi “${text}”`, glyph: "✦", value: text }];
    }

    function commandItems(tokens) {
        return (host.userConfig.aiCommands ?? [])
            .filter(command => Spot.matches(command.name, tokens))
            .map(command => ({ key: "aicmd:" + command.name, kind: "aiCommand", store: root, command, title: command.name, hint: host.selectedText ? "on selection" : "nothing selected", glyph: "✦" }));
    }

    function describe(item) {
        const answered = pi.key === item.key;
        if (item.kind === "ai") {
            if (answered && !pi.answer)
                return { glyph: "✦", title: "Ask pi", subtitle: item.value, body: "Thinking…", footer: "pi is answering with your default model" };
            return { glyph: "✦", title: "Ask pi", subtitle: item.value, body: answered ? pi.answer : "", markdown: true, actions: answered ? [["Enter", "Copy answer"]] : [["Enter", "Ask pi"]] };
        }
        if (!host.selectedText)
            return { glyph: "✦", title: item.title, subtitle: "Select some text in any window, then open Spotlight", footer: "Nothing selected" };
        if (answered && !pi.answer)
            return { glyph: "✦", title: item.title, body: "Thinking…", footer: "pi is working on the selected text" };
        if (answered)
            return { glyph: "✦", title: item.title, body: pi.answer, markdown: true, actions: item.command.output === "paste" ? [["Enter", "Replace selection"], ["Ctrl+C", "Copy result"]] : [["Enter", "Copy result"]] };
        return { glyph: "✦", title: item.title, subtitle: "Selected text", body: host.selectedText.slice(0, 2000), actions: [["Enter", "Run with pi"]] };
    }

    function activate(item, keys) {
        if (item.kind === "aiCommand" && !host.selectedText) {
            host.notify("Select some text in any window first, then open Spotlight");
            return false;
        }
        if (pi.key !== item.key || !pi.answer) {
            if (item.kind === "ai")
                pi.ask(item.key, item.value, quickPrompt);
            else
                pi.ask(item.key, `${item.command.prompt}\n\n---\n${host.selectedText}`, transformPrompt);
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

        // pi -p waits on an open stdin, so it gets /dev/null
        function ask(forKey, prompt, system) {
            key = forKey;
            answer = "";
            exec(["sh", "-c", 'exec pi "$@" < /dev/null', "sh", "-p", "--no-session", "--no-tools", "--no-context-files", "--no-skills", "--no-prompt-templates", "--offline", "--system-prompt", system, "--", prompt]);
        }

        stdout: StdioCollector {
            onStreamFinished: pi.answer = text.trim()
        }
        onExited: exitCode => {
            if (exitCode !== 0 && !answer)
                answer = `pi exited with code ${exitCode}.`;
        }
    }
}
