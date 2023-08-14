using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ShanShuo.EditorSdk.Utils
{
    public class UIUtils
    {
        public static string GetTransformPath(Transform target)
        {
            if (target == null)
            {
                return string.Empty;
            }

            string prefabFile = PrefabUtility.GetPrefabAssetPathOfNearestInstanceRoot(target);

            GameObject prefabRoot = target.root.gameObject;

            List<string> nodeNames = new List<string>();

            Transform curTransform = target;
            while (curTransform != prefabRoot.transform && curTransform.parent != null)
            {
                string curPrefabFile = PrefabUtility.GetPrefabAssetPathOfNearestInstanceRoot(curTransform);
                if (!prefabFile.Equals(string.Empty) && !curPrefabFile.Equals(prefabFile))
                {
                    break;
                }
                nodeNames.Add(curTransform.name);
                curTransform = curTransform.parent;
            }

            if (nodeNames.Count > 0)
            {
                nodeNames.RemoveAt(nodeNames.Count - 1);
            }

            nodeNames.Reverse();
            return string.Join("/", nodeNames.ToArray());
        }
    }
}

