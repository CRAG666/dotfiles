import Quickshell
import QtQuick
import qs

// Desktop apps, most launched first (Apps.search), and the actions their
// desktop entries declare ("New Private Window"), which Commands lists.
Scope {
    id: root

    function items(query) {
        return Apps.search(query).map(app => ({ key: "app:" + app.id, kind: "app", store: root, app, title: app.name, icon: app.icon, uses: Apps.launches[app.id + ".desktop"] ?? 0 }));
    }

    function actionItems(tokens) {
        const list = [];
        for (const app of DesktopEntries.applications.values)
            for (const action of app.actions)
                if (Spot.matches(action.name + " " + app.name, tokens))
                    list.push({ key: "act:" + app.id + ":" + action.id, kind: "appAction", store: root, action, app, title: action.name, hint: app.name, icon: action.icon || app.icon });
        return list;
    }

    function describe(item) {
        if (item.kind === "appAction")
            return { icon: item.icon, title: item.title, subtitle: "Action of " + item.app.name, actions: [["Enter", "Run action"]] };
        const uses = Apps.launches[item.app.id + ".desktop"] ?? 0;
        return { icon: item.icon, title: item.title, subtitle: item.app.genericName, details: [item.app.comment], metadata: [["Opened", uses ? `${uses} ${uses === 1 ? "time" : "times"}` : "Never from the launcher"]], actions: [["Enter", "Open"]] };
    }

    function activate(item, keys) {
        if (item.kind === "appAction")
            item.action.execute();
        else
            Apps.launch(item.app);
        return true;
    }
}
