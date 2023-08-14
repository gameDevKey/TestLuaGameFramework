using System;
using System.Collections.Generic;
using UnityEngine;

namespace Game.Asset {
    public class MaterialScriptableObject : ScriptableObject {
        public string type = "Material";
        public string shaderKey;
        public string shaderFileName;
        public List<MaterialPropertyEntry> propertyTokenList;
    }

    [Serializable]
    public class MaterialPropertyEntry {
        [SerializeField]
        public string[] tokens;
    }

}
