using System;
using System.Collections.Generic;
using UnityEngine;

namespace Game.Asset {
    public class AssetBridge : MonoBehaviour {
        [SerializeField]
        public AssetEntry[] entries = new AssetEntry[0];

        protected void Awake() {
            if (Parse != null) {
                Parse(gameObject, entries);
            }
        }

        public static Action<GameObject, AssetEntry[]> Parse;

        public static void AddEntry(AssetBridge bridge, AssetEntry entry) {
            Array.Resize<AssetEntry>(ref bridge.entries, bridge.entries.Length + 1);
            bridge.entries[bridge.entries.Length - 1] = entry;
        }

        public static void RemoveEntry(AssetBridge bridge, string asset) {
            int deleteIndex = -1;
            for (int i = 0; i < bridge.entries.Length; i++) {
                if (bridge.entries[i].asset == asset) {
                    deleteIndex = i;
                    break;
                }
            }
            if (deleteIndex > -1) {
                AssetEntry[] entries = new AssetEntry[bridge.entries.Length - 1];
                int index = 0;
                for (int i = 0; i < bridge.entries.Length; i++) {
                    if (i != deleteIndex) {
                        entries[index++] = bridge.entries[i];
                    }
                }
                bridge.entries = entries;
            }
        }
    }

    [Serializable]
    public class AssetEntry {
        [SerializeField]
        public string asset;
        [SerializeField]
        public string[] tokens = new string[0];

        public static void AddToken(AssetEntry entry, string token) {
            Array.Resize<string>(ref entry.tokens, entry.tokens.Length + 1);
            entry.tokens[entry.tokens.Length - 1] = token;
        }
    }
}
