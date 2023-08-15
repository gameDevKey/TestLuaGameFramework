using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class EditorUtil
{
    public static List<T> FindAssets<T>(string filter, string findPath) where T : UnityEngine.Object
    {
        List<T> assets = new List<T>();
        string[] allPath = AssetDatabase.FindAssets(filter, new string[] { findPath });
        for (int i = 0; i < allPath.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(allPath[i]);
            var obj = AssetDatabase.LoadAssetAtPath<T>(path);
            assets.Add(obj);
        }
        return assets;
    }
}
