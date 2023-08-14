using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Game.Asset {
    public class AssetRecordScriptableObject : ScriptableObject {
        public AssetDependencyEntry[] dependencyEntries;
    }

    /// <summary>
    /// 表示逻辑资源依赖的物理资源路径列表
    /// </summary>
    [Serializable]
    public class AssetDependencyEntry {
        public string path;
        public string[] physicalPaths;
    }
}


