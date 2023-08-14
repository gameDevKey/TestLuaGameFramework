using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace EditorTools.AssetBundle
{
    public class LightMapExrProcessor : ComponentProcessor
    {

        public LightMapExrProcessor()
        {
            this.Name = "LightMapRecord";
        }

        public override HashSet<string> Process(string entryPath, GameObject go, StrategyNode node)
        {
            HashSet<string> result = new HashSet<string>();
            LightMapRecord record = go.GetComponent<LightMapRecord>();
            if (record != null)
            {
                LightingMapData[] mapData = record.mapData;
                if (mapData != null && mapData.Length > 0)
                {
                    foreach (LightingMapData data in mapData)
                    {
                        if (data.lightMapFar != null)
                        {
                            string farPath = AssetDatabase.GetAssetPath(data.lightMapFar);
                            result.Add(farPath);
                        }

                        if (data.lightMapNear != null)
                        {
                            string nearPath = AssetDatabase.GetAssetPath(data.lightMapNear);
                            result.Add(nearPath);
                        }
                        if (data.lightMapShadowMask != null)
                        {
                            string shadowPath = AssetDatabase.GetAssetPath(data.lightMapShadowMask);
                            result.Add(shadowPath);
                        }
                    }
                }
            }
            return result;
        }
    }
}
