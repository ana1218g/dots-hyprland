pragma Singleton

import qs.modules.common
import QtQuick
import Quickshell

Singleton {
    id: root

    function isPinned(appId) {
        return Config.options.launcher.pinnedApps.indexOf(appId) !== -1;
    }

    function togglePin(appId) {
        if (root.isPinned(appId)) {
            Config.options.launcher.pinnedApps = Config.options.launcher.pinnedApps.filter(id => id !== appId)
        } else {
            Config.options.launcher.pinnedApps = Config.options.launcher.pinnedApps.concat([appId])
        }
    }

    function moveToFront(appId) {
        if (!root.isPinned(appId)) return;
        const pinnedApps = Config.options.launcher.pinnedApps;
        Config.options.launcher.pinnedApps = [appId].concat(pinnedApps.filter(id => id !== appId));
    }

    function moveLeft(appId) {
        const pinnedApps = Config.options.launcher.pinnedApps;
        const index = pinnedApps.indexOf(appId);
        if (index === -1 || index === 0) return;
        Config.options.launcher.pinnedApps = pinnedApps.slice(0, index - 1).concat([appId]).concat(pinnedApps[index - 1]).concat(pinnedApps.slice(index + 1));
    }

    function moveRight(appId) {
        const pinnedApps = Config.options.launcher.pinnedApps;
        const index = pinnedApps.indexOf(appId);
        if (index === -1 || index === pinnedApps.length - 1) return;
        Config.options.launcher.pinnedApps = pinnedApps.slice(0, index).concat(pinnedApps[index + 1]).concat([appId]).concat(pinnedApps.slice(index + 2));
    }

    function movePinned(appId, toIndex) {
        const list = Config.options.launcher.pinnedApps.slice();
        const from = list.indexOf(appId);
        if (from < 0) return;
        toIndex = Math.max(0, Math.min(list.length - 1, toIndex));
        if (from === toIndex) return;
        const [item] = list.splice(from, 1);
        list.splice(toIndex, 0, item);
        Config.options.launcher.pinnedApps = list;
    }
}
