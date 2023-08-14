using ShanShuo.EditorSdk.Utils;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class CheckUITex
{
    public const string PREFIX_UI_PREFAB_PATH = "Assets/Things/ui/prefab/";
    public const string PREFIX_UI_TEXTURE_PATH = "Assets/Things/ui/texture/";

    static void CheckAndHandleNotRefText(bool delete)
    {
        string[] selectPaths = Selection.assetGUIDs;
        if (selectPaths.Length <= 0)
        {
            Debug.LogError("选择检测目录异常，没有选择目录");
            return;
        }
        string selectPath = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);
        string absPath = IOUtils.GetAbsPath(Application.dataPath + "/../" + selectPath);

        Debug.Log("检测目录:" + selectPath);

        if (!IOUtils.IsFolder(absPath))
        {
            Debug.LogError("选择检测目录异常，不是文件夹目录");
            return;
        }

        List<string> notRelFiles = new List<string>();

        List<string> prefabFiles = new List<string>();
        string[] prefabGuids = AssetDatabase.FindAssets("t:GameObject", new string[] { PREFIX_UI_PREFAB_PATH });
        foreach (string guid in prefabGuids)
        {
            prefabFiles.Add(AssetDatabase.GUIDToAssetPath(guid));
        }

        HashSet<string> dependFiles = new HashSet<string>();
        string[] dependFileArray = AssetDatabase.GetDependencies(prefabFiles.ToArray(), true);
        foreach (string file in dependFileArray)
        {
            dependFiles.Add(file);
        }

        string code;
        StringBuilder stringBuilder = new StringBuilder();
        string[] luaFiles = IOUtils.GetFiles(Application.dataPath + "/../../lua/");
        foreach (string file in luaFiles)
        {
            stringBuilder.Append(IOUtils.ReadAllText(file));
        }
        code = stringBuilder.ToString();


        string[] texGuids = AssetDatabase.FindAssets("t:Texture2D", new string[] { selectPath });
        foreach (string guid in texGuids)
        {
            string texPath = AssetDatabase.GUIDToAssetPath(guid);

            string localPath = IOUtils.SubPath(texPath, PREFIX_UI_TEXTURE_PATH).Replace(".png", "\"");

            bool coreRef = code.IndexOf(localPath, 0, System.StringComparison.Ordinal) != -1;

            if (!coreRef && !dependFiles.Contains(texPath))
            {
                notRelFiles.Add(texPath);
            }
        }

        Debug.LogFormat("<color=#FF2F00FF>无引用资源信息[路径:{0}][数量:{1}]</color>", selectPath, notRelFiles.Count);
        
        if (delete)
        {
            foreach (string file in notRelFiles)
            {
                AssetDatabase.DeleteAsset(file);
                Debug.Log("删除图片:"+ file);
            }
            AssetDatabase.Refresh();
        }
        else
        {
            foreach (string file in notRelFiles)
            {
                Debug.Log(file, AssetDatabase.LoadAssetAtPath<Object>(file));
            }

            Debug.Log("检测完成");
        }
    }

    [MenuItem("Assets/工具/UI/检测/检测无引用图片")]
    public static void checkNotRefTex()
    {
        CheckAndHandleNotRefText(false);
    }

    [MenuItem("Assets/工具/UI/检测/删除无引用图片")]
    public static void checkNotRefTexAndDelete()
    {
        CheckAndHandleNotRefText(true);
    }

    [MenuItem("Assets/工具/UI/检测/检测图片被引用")]
    public static void checkTexDoRefInfo()
    {
        string[] selectPaths = Selection.assetGUIDs;
        if (selectPaths.Length <= 0)
        {
            Debug.LogError("选择检测目录异常，没有选择目录");
            return;
        }
        string selectPath = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);

        Debug.Log("检测路径:" + selectPath);

        string[] prefabGuids = AssetDatabase.FindAssets("t:GameObject", new string[] { PREFIX_UI_PREFAB_PATH });
        foreach (string guid in prefabGuids)
        {
            string prefabFile = AssetDatabase.GUIDToAssetPath(guid);
            GameObject cloneObj = AssetDatabase.LoadAssetAtPath<GameObject>(prefabFile);
            GameObject uiObject = GameObject.Instantiate(cloneObj, GameObject.Find("Canvas").transform);

            Dictionary<GameObject, string> relNodes = new Dictionary<GameObject, string>();

            Image[] images = uiObject.transform.GetComponentsInChildren<Image>(true);

            foreach (Image img in images)
            {
                string texPath = AssetDatabase.GetAssetPath(img.mainTexture);
                string folderPath = IOUtils.GetPathDirectory(texPath, false);
                if (folderPath.Equals(selectPath) || texPath.Equals(selectPath))
                {
                    relNodes.Add(img.gameObject, texPath);
                }
            }

            if(relNodes.Count > 0)
            {
                Debug.Log(string.Format("<color=#FF2F00FF>引用资源预设[路径:{0}][数量:{1}]</color>", prefabFile, relNodes.Count), uiObject);
                foreach (var v in relNodes)
                {
                    Debug.Log(string.Format("引用信息[路径:{0}][引用贴图:{1}]", UIUtils.GetTransformPath(v.Key.transform), v.Value), v.Key);
                }
            }
            else
            {
                GameObject.DestroyImmediate(uiObject);
            }
        }

        Debug.Log("检测完成");
    }
}
