using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class AddTextMultiLang
{
    private static string[] dirs = { "Assets/Things/Prefabs/UI" };

    [MenuItem("Tools/AddTextMultiLang", false, 150)]
    public static void Add()
    {
        EditorUtility.DisplayProgressBar("Progress", "Add TextMultiLang...", 0);
        var guids = AssetDatabase.FindAssets("t:Prefab", dirs);
        for (int i = 0; i < guids.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(guids[i]);
            var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            CheckOneGo(prefab);
            AssetDatabase.SaveAssets();
        }
        EditorUtility.ClearProgressBar();
    }

    public static void CheckOneGo(GameObject go)
    {
        Text text = go.GetComponent<Text>();
        if (text != null)
        {
            bool bChange = false;
            MultiLangHandler textEx = go.GetComponent<MultiLangHandler>();
            if (textEx == null)
            {
                textEx = go.AddComponent<MultiLangHandler>();
                bChange = true;
            }
            if (bChange)
            {
                EditorUtility.SetDirty(go);
            }            
        }
        int childCount = go.transform.childCount;
        for (int i = 0; i < childCount; i++)
        {
            CheckOneGo(go.transform.GetChild(i).gameObject);
        }
    }
}