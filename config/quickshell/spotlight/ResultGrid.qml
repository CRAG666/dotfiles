import QtQuick
import qs

// The results as Raycast's grid (emoji): square cells, `columns` to a row,
// under section headers with their count; the selected cell is outlined. Rows
// of cells are the list's model, so it stays virtual over thousands of emoji
Item {
    id: root
    property var host
    readonly property int columns: 8
    readonly property real gap: Spot.px(10)
    readonly property real cell: Math.floor((width - (columns - 1) * gap) / columns)

    // { section, count (on a section's first row), first, cells: [result index] };
    // none while the list shows the results, so no keystroke builds hidden cells
    readonly property var rows: {
        if (!host.gridView)
            return [];
        const counts = {};
        for (let index = 0; index < host.results.length; index++)
            counts[host.results[index].section] = (counts[host.results[index].section] ?? 0) + 1;
        const built = [];
        host.results.forEach((item, index) => {
            const last = built[built.length - 1];
            if (last && last.section === item.section && last.cells.length < columns) {
                last.cells.push(index);
                return;
            }
            const opens = !last || last.section !== item.section;
            built.push({ section: item.section, count: opens ? counts[item.section] : 0, first: index, cells: [index] });
        });
        return built;
    }

    // result index → its row, so moving through the grid scans no rows
    readonly property var rowAt: {
        const at = [];
        rows.forEach((row, index) => row.cells.forEach(() => at.push(index)));
        return at;
    }

    function rowOf(index) {
        return rowAt[index] ?? -1;
    }

    function reveal(index) {
        list.positionViewAtIndex(Math.max(0, rowOf(index)), ListView.Contain);
    }

    // the cell above or below, in the same column or the row's last
    function stepRow(delta) {
        const at = rowOf(host.current);
        if (at < 0)
            return;
        const target = rows[Math.max(0, Math.min(rows.length - 1, at + delta))];
        host.pick(target.first + Math.min(host.current - rows[at].first, target.cells.length - 1));
    }

    ListView {
        id: list
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: root.rows

        delegate: Column {
            id: gridRow
            required property var modelData
            required property int index
            width: ListView.view.width
            bottomPadding: root.gap

            Row {
                visible: gridRow.modelData.count > 0
                leftPadding: Spot.px(4)
                topPadding: gridRow.index ? Spot.px(8) : Spot.px(4)
                bottomPadding: Spot.px(8)
                spacing: Spot.px(10)

                Label {
                    text: gridRow.modelData.section
                    color: Theme.inkSoft
                    font.pixelSize: Spot.px(13)
                    font.weight: Font.DemiBold
                }
                Label {
                    text: gridRow.modelData.count
                    color: Theme.inkSoft
                    font.pixelSize: Spot.px(13)
                }
            }

            Row {
                spacing: root.gap

                Repeater {
                    model: gridRow.modelData.cells

                    Rectangle {
                        id: cell
                        required property int modelData
                        readonly property var item: root.host.results[modelData]
                        readonly property bool isCurrent: modelData === root.host.current
                        width: root.cell
                        height: root.cell
                        radius: Spot.px(10)
                        color: cellMouse.containsMouse ? Theme.hairline : Theme.fill
                        border.width: isCurrent ? Spot.px(2) : 0
                        border.color: Theme.ink

                        Label {
                            anchors.centerIn: parent
                            text: cell.item?.glyph ?? ""
                            font.family: "Noto Color Emoji"
                            font.pixelSize: Math.max(Spot.px(12), Math.round(root.cell * 0.4))
                        }
                        MouseArea {
                            id: cellMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.host.pick(cell.modelData)
                            onDoubleClicked: root.host.activate(cell.item, { ctrl: false, shift: false })
                        }
                    }
                }
            }
        }
    }
}
