using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class AddButtonEx
{
    private static string[] dirs = { "Assets/Things/Prefabs/UI" };

    [MenuItem("Tools/AddButtonEx", false, 140)]
    public static void Add()
    {
        EditorUtility.DisplayProgressBar("Progress", "Add ButtonEx...", 0);
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
        Button btn = go.GetComponent<Button>();
        if (btn != null)
        {
            bool bChange = false;
            TransitionButton btnEx = go.GetComponent<TransitionButton>();
            if (btnEx == null)
            {
                btnEx = go.AddComponent<TransitionButton>();
                bChange = true;
            }
            if (go.name.Equals("Panel") && btnEx.scaleSetting)
            {
                btnEx.scaleSetting = false;
                bChange = true;
            }
            if (btnEx.soundId == 1005)
            {
                btnEx.soundId = 214;
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