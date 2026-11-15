pragma Singleton

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root

    function isPinned(appId) {
        return Config.options.dock.pinnedApps.indexOf(appId) !== -1;
    }

    function togglePin(appId) {
        if (root.isPinned(appId)) {
            Config.options.dock.pinnedApps = Config.options.dock.pinnedApps.filter(id => id !== appId)
        } else {
            Config.options.dock.pinnedApps = Config.options.dock.pinnedApps.concat([appId])
        }
    }

    function movePinned(appId, toIndex) {
        const list = Config.options.dock.pinnedApps.slice();
        const from = list.findIndex(id => id.toLowerCase() === appId.toLowerCase());
        if (from < 0) return;
        toIndex = Math.max(0, Math.min(list.length - 1, toIndex));
        if (from === toIndex) return;
        const [item] = list.splice(from, 1);
        list.splice(toIndex, 0, item);
        Config.options.dock.pinnedApps = list;
    }

    property list<var> apps: {
        var map = new Map();

        // Pinned apps
        const pinnedApps = Config.options?.dock.pinnedApps ?? [];
        for (const appId of pinnedApps) {
            if (!map.has(appId.toLowerCase())) map.set(appId.toLowerCase(), ({
                pinned: true,
                toplevels: []
            }));
        }

        // Separator
        if (pinnedApps.length > 0) {
            map.set("SEPARATOR", { pinned: false, toplevels: [] });
        }

        // Ignored apps
        const ignoredRegexStrings = Config.options?.dock.ignoredAppRegexes ?? [];
        const ignoredRegexes = ignoredRegexStrings.map(pattern => new RegExp(pattern, "i"));
        // Open windows
        for (const toplevel of ToplevelManager.toplevels.values) {
            if (ignoredRegexes.some(re => re.test(toplevel.appId))) continue;
            const key = root.matchPinnedKey(map, toplevel.appId);
            if (!map.has(key)) map.set(key, ({
                pinned: false,
                toplevels: []
            }));
            map.get(key).toplevels.push(toplevel);
        }

        var values = [];

        for (const [key, value] of map) {
            values.push(appEntryComp.createObject(null, { appId: key, toplevels: value.toplevels, pinned: value.pinned }));
        }

        return values;
    }

    component TaskbarAppEntry: QtObject {
        id: wrapper
        required property string appId
        required property list<var> toplevels
        required property bool pinned
    }
    Component {
        id: appEntryComp
        TaskbarAppEntry {}
    }

    // 起動中ウィンドウの appId を、同じアプリを指すピン留めのキーに寄せる。
    // 例: ピン留めが "com.vscodium.codium"、ウィンドウが "codium" のとき
    function matchPinnedKey(map, appId) {
        const lower = appId.toLowerCase();
        if (map.has(lower)) return lower;

        const entry = DesktopEntries.heuristicLookup(appId);
        if (!entry) return lower;

        for (const [key, value] of map) {
            if (!value.pinned) continue;
            const pinnedEntry = DesktopEntries.heuristicLookup(key);
            if (pinnedEntry && pinnedEntry.id === entry.id) return key;
            if (pinnedEntry?.startupClass && pinnedEntry.startupClass.toLowerCase() === lower) return key;
        }
        return lower;
    }
}
