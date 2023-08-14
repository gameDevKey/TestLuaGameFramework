using UnityEngine;
using Game.Asset;

namespace EditorTools.AssetBundle {
    public class AssetBridgeHelper {
        public static void AddEntry(GameObject go, string asset, string[] tokens) {
            AssetBridge bridge = go.GetComponent<AssetBridge>();
            if (bridge == null) {
                bridge = go.AddComponent<AssetBridge>();
            }
            AssetEntry entry = new AssetEntry();
            entry.asset = asset;
            entry.tokens = tokens;
            AssetBridge.AddEntry(bridge, entry);
        }

        public static void RemoveEntry(GameObject go, string asset) {
            AssetBridge bridge = go.GetComponent<AssetBridge>();
            if (bridge == null) {
                return;
            }
            AssetBridge.RemoveEntry(bridge, asset);
        }

        public static string[] GetEntryTokens(GameObject go, string asset) {
            AssetBridge bridge = go.GetComponent<AssetBridge>();
            if (bridge == null) {
                return null;
            }
            for (int i = 0; i < bridge.entries.Length; i++) {
                AssetEntry entry = bridge.entries[i];
                if (entry.asset == asset) {
                    return entry.tokens;
                }
            }
            return null;
        }

    }
}
