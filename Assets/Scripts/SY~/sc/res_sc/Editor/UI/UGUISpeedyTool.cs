using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using System.IO;
using System.Text.RegularExpressions;
using System;
using System.Text;

public class UGUISpeedyTool : EditorWindow
{

    [MenuItem("GameObject/UI/拷贝路径 &c")]
    static void CopyPath()
    {
        if (Selection.activeTransform)
        {
            string path = string.Empty;
            Transform obj = Selection.activeTransform;
            while (true)
            {
                if (obj.parent == null || obj.parent.parent == null)
                {
                    path = path == string.Empty ? obj.name : obj.name + "/" + path;
                    break;
                }

                path = path == string.Empty ? obj.name : obj.name + "/" + path;
                obj = obj.parent;
            }

            TextEditor te = new TextEditor();
            te.text = path;
            te.SelectAll();
            te.Copy();
        }
    }

    static Transform moveParent;

    [MenuItem("GameObject/UI/设置为移动父节点")]
    static void setMoveParentObj()
    {
        if (Selection.activeTransform)
        {
            moveParent = Selection.activeTransform;
        }
    }

    [MenuItem("GameObject/UI/移动到标记节点")]
    static void moveToParentObj()
    {
        if (Selection.activeTransform)
        {
            if(moveParent == null)
            {
                Debug.Log("父节点为空");
                return;
            }
            Selection.activeTransform.SetParent(moveParent);
        }
    }

    [MenuItem("GameObject/UI/一键干掉ContentSizeFitter")]
    static void Clear()
    {
        if (Selection.activeTransform == null) return;
        Transform obj = Selection.activeTransform;

        ContentSizeFitter []sizeFitters = obj.GetComponentsInChildren<ContentSizeFitter>();

        for(int i=0;i<sizeFitters.Length;i++)
        {
            GameObject.DestroyImmediate(sizeFitters[i]);
        }
    }

    [MenuItem("Assets/Carp/拷贝路径")]
    static void CopyAssetsPath()
    {
        TextEditor te = new TextEditor();
        te.text = AssetDatabase.GetAssetPath(Selection.activeObject);
        te.SelectAll();
        te.Copy();
        Debug.Log(te.text);
    }

    [MenuItem("Assets/Carp/打包工具/清理资源错误引用")]
    public static void clearAssetMiss()
    {
        string[] selectFolders = Selection.assetGUIDs;
        if (selectFolders.Length <= 0)
        {
            Debug.Log("没有选择目录");
            return;
        }

        string folderPath = AssetDatabase.GUIDToAssetPath(selectFolders[0]);
        Debug.Log("处理目录:" + folderPath);

        if (!Directory.Exists(folderPath))
        {
            Debug.Log("请选择正确文件夹");
            return;
        }

        string[] imageAssets = AssetDatabase.FindAssets("t:Texture", new string[] { "Assets/Things/Textures/UI/common" });
        Sprite tempSprite = AssetDatabase.LoadAssetAtPath<Sprite>(AssetDatabase.GUIDToAssetPath(imageAssets[0]));

        string[] allPrefabs = AssetDatabase.FindAssets("t:Prefab", new string[] { folderPath });
        for (int i = 0; i < allPrefabs.Length; i++)
        {
            string prefabPath = AssetDatabase.GUIDToAssetPath(allPrefabs[i]);
            GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
            GameObject cloneObj = GameObject.Instantiate(obj);
            Image[] images = cloneObj.GetComponentsInChildren<Image>(true);
            bool isReplace = false;
            for (int j = 0; j < images.Length; j++)
            {
                string assetPath = AssetDatabase.GetAssetPath(images[j].mainTexture);

                int index = assetPath.IndexOf("Assets/Things/Textures/UI");
                Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(assetPath);
                if (index == -1 || sprite==null)
                {
                    images[j].sprite = tempSprite;
                    images[j].sprite = null;
                    isReplace = true;
                }
            }

            if (isReplace)
            {
                PrefabUtility.ReplacePrefab(cloneObj, obj);
            }
            GameObject.DestroyImmediate(cloneObj);
        }
      
        Debug.Log("清理完成");
    }


    [MenuItem("Assets/Carp/自动剔除重复资源", false, 100)]
    static private void AutoRemoveSameAsset()
    {
        string folderPath = AssetDatabase.GetAssetPath(Selection.activeObject);
        if (!Directory.Exists(folderPath))
        {
            Debug.LogError("找不到文件夹:" + folderPath);
            return;
        }

        Dictionary<string, bool> removeFiles = new Dictionary<string, bool>();
        Dictionary<string, string> imageData = new Dictionary<string, string>();

        var imageList = AssetDatabase.FindAssets("t:Texture", new string[] { folderPath });
         for (int i = 0; i < imageList.Length; i++)
        {
            string imgPath = AssetDatabase.GUIDToAssetPath(imageList[i]);
            string imgFolderPath = Path.GetDirectoryName(imgPath);
            imgFolderPath = Path.GetFileNameWithoutExtension(imgFolderPath);
            string ext = Path.GetExtension(imgPath);
            if(ext !=".png") continue;

            string md5 = calMd5(imgPath);
            if (!imageData.ContainsKey(md5))
            {
                imageData.Add(md5, imgPath);
            }
            removeFiles.Add(imgPath, true);
        }

        var objList = AssetDatabase.FindAssets("t:GameObject", new string[] { folderPath });
        for (int i = 0; i < objList.Length; i++)
        {
            string objPath = AssetDatabase.GUIDToAssetPath(objList[i]);
            UnityEngine.Object obj = AssetDatabase.LoadAssetAtPath(objPath, typeof(GameObject));
            GameObject clone = GameObject.Instantiate(obj) as GameObject;
           
            Image[] images = clone.GetComponentsInChildren<Image>(true);

            int count = clone.transform.childCount;

            bool amend = false;
            for (int j = 0; j < images.Length; j++)
            {
                string imgPath = AssetDatabase.GetAssetPath(images[j].sprite).Replace(@"\", "/");
                if (imgPath.Equals("")) continue;
                string imgFolderPath = Path.GetDirectoryName(imgPath);
                imgFolderPath = Path.GetFileNameWithoutExtension(imgFolderPath);
                
                if(imgPath == "Resources/unity_builtin_extra")
                {
                    continue;
                }

                string md5 = calMd5(imgPath);

                if (!imageData.ContainsKey(md5))
                {
                    continue;
                }

                if(removeFiles.ContainsKey(imageData[md5]))
                {
                    removeFiles.Remove(imageData[md5]);
                }

                if (imageData[md5] == imgPath)
                {
                    continue;
                }

                images[j].sprite = AssetDatabase.LoadAssetAtPath<Sprite>(imageData[md5]);
                amend = true;
            }

            if (amend) PrefabUtility.ReplacePrefab(clone, obj);
            DestroyImmediate(clone);
        }

        foreach(var v in removeFiles)
        {
            //CarpEditorUtility.deleteAsset(v.Key);
        }

        AssetDatabase.Refresh();
        Debug.Log("自动剔除完成");
    }

    static List<string> getAssetsByExt(string path,string ext,bool isChild)
    {
        List<string> files = new List<string>();
   
        return files;
    }

    static string calMd5(string file)
    {
        System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
        byte[] data = File.ReadAllBytes(file);
        byte[] retVal = md5.ComputeHash(data);
        StringBuilder sb = new StringBuilder();
        for (int j = 0; j < retVal.Length; j++)
        {
            sb.Append(retVal[j].ToString("x2"));
        }
        return sb.ToString();
    }

    [MenuItem("GameObject/UI/替换字体", false, 100)]
    static private void replaceGameObjectFonts()
    {
        Font newFont = AssetDatabase.LoadAssetAtPath("Assets/Things/Font/carp.ttf", typeof(Font)) as Font;
        Text[] texts = Selection.activeTransform.gameObject.GetComponentsInChildren<Text>(true);
        bool amend = false;
        for (int j = 0; j < texts.Length; j++)
        {
            Text text = texts[j];
            string srcTextStr = text.text;
            RectTransform rectTrans = text.gameObject.GetComponent<RectTransform>();
            Font font = text.font;
            bool isExistFont = font != null;
            if (font != null && font.name != "wqy" && font.name != "txjldyj" && font.name != "Arial") continue;

            Vector2 min = rectTrans.anchorMin;
            Vector2 max = rectTrans.anchorMax;

            if (min.x == 0.0f && min.y == 0.0f && max.x == 1 && max.y == 1)
            {
                text.font = newFont;
                text.fontSize = text.fontSize + 1;
                text.verticalOverflow = VerticalWrapMode.Overflow;
                amend = true;
                continue;
            }

            float preferredHeight = text.preferredHeight;
            float sizeHeight = rectTrans.sizeDelta.y;
            float sizeWidth = rectTrans.sizeDelta.x;
            float offset = sizeHeight - preferredHeight;
            bool autoWidthSize = min.x == 0.0f && max.x == 1.0f;

            if (text.horizontalOverflow == HorizontalWrapMode.Wrap && !autoWidthSize)
            {
                text.text = "";
                float lineHeight = text.preferredHeight;

                string firstLineStr = "";
                string curStr = "";
                for (int n = 0; n < srcTextStr.Length; n++)
                {
                    curStr = curStr + srcTextStr[n];
                    text.text = curStr;
                    if (text.preferredHeight <= lineHeight)
                    {
                        firstLineStr = curStr;
                    }
                    else
                    {
                        break;
                    }
                }

                text.text = firstLineStr;
            }

            text.font = newFont;
            text.fontSize = text.fontSize + 1;

            if (sizeWidth < text.preferredWidth && !autoWidthSize && text.horizontalOverflow == HorizontalWrapMode.Wrap)
            {
                rectTrans.sizeDelta = new Vector2(text.preferredWidth, rectTrans.sizeDelta.y);
            }
            text.text = srcTextStr;

            text.verticalOverflow = VerticalWrapMode.Overflow;
            amend = true;
        }
    }

    [MenuItem("Assets/Carp/替换字体", false, 100)]
    static private void replaceFonts()
    {
        Font newFont = AssetDatabase.LoadAssetAtPath("Assets/Things/Font/carp.ttf", typeof(Font)) as Font;


        string[] selectFolders = Selection.assetGUIDs;
        for (int k = 0; k < selectFolders.Length; k++)
        {
            string path = AssetDatabase.GUIDToAssetPath(selectFolders[k]);
            if (!Directory.Exists(path))
            {
                continue;
            }

            Debug.Log("处理目录:" + path);

            string[] allPrefabs = AssetDatabase.FindAssets("t:Prefab", new string[] { path });
            for (int i = 0; i < allPrefabs.Length; i++)
            {
                string prefabPath = AssetDatabase.GUIDToAssetPath(allPrefabs[i]);

                string folder = System.IO.Path.GetDirectoryName(prefabPath);
                string folderName = System.IO.Path.GetFileNameWithoutExtension(folder);

                string[] nameInfo = folderName.Split("_"[0]);

                if (nameInfo[0] != "ml") continue;

                GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
                GameObject clone = GameObject.Instantiate(obj) as GameObject;


                Text[] texts = clone.GetComponentsInChildren<Text>(true);
                bool amend = false;

                for (int j = 0; j < texts.Length; j++)
                {
                    Text text = texts[j];
                    string srcTextStr = text.text;
                    RectTransform rectTrans = text.gameObject.GetComponent<RectTransform>();
                    Font font = text.font;
                    bool isExistFont = font != null;
                    if (font != null && font.name != "wqy" && font.name != "txjldyj" && font.name != "Arial") continue;

                    Vector2 min = rectTrans.anchorMin;
                    Vector2 max = rectTrans.anchorMax;

                    if (min.x == 0.0f && min.y == 0.0f && max.x == 1 && max.y == 1)
                    {
                        text.font = newFont;
                        text.fontSize = text.fontSize + 1;
                        text.verticalOverflow = VerticalWrapMode.Overflow;
                        amend = true;
                        continue;
                    }

                    float preferredHeight = text.preferredHeight;
                    float sizeHeight = rectTrans.sizeDelta.y;
                    float sizeWidth = rectTrans.sizeDelta.x;
                    float offset = sizeHeight - preferredHeight;
                    bool autoWidthSize = min.x == 0.0f && max.x == 1.0f;

                    if (text.horizontalOverflow == HorizontalWrapMode.Wrap && !autoWidthSize)
                    {
                        text.text = "";
                        float lineHeight = text.preferredHeight;

                        string firstLineStr = "";
                        string curStr = "";
                        for (int n = 0; n < srcTextStr.Length; n++)
                        {
                            curStr = curStr + srcTextStr[n];
                            text.text = curStr;
                            if (text.preferredHeight <= lineHeight)
                            {
                                firstLineStr = curStr;
                            }
                            else
                            {
                                break;
                            }
                        }

                        text.text = firstLineStr;
                    }

                    text.font = newFont;
                    text.fontSize = text.fontSize + 1;

                    if (sizeWidth < text.preferredWidth && !autoWidthSize && text.horizontalOverflow == HorizontalWrapMode.Wrap)
                    {
                        rectTrans.sizeDelta = new Vector2(text.preferredWidth, rectTrans.sizeDelta.y);
                    }
                    text.text = srcTextStr;

                    text.verticalOverflow = VerticalWrapMode.Overflow;
                    amend = true;
                }

                if(prefabPath != "Assets/Things/Prefabs/UI/ml_mainui/ml_worldMapArea.prefab")
                {
                    if (amend) PrefabUtility.ReplacePrefab(clone, obj);
                    DestroyImmediate(clone);
                }
            }
        }
        Debug.Log("替换完成");
    }
}
