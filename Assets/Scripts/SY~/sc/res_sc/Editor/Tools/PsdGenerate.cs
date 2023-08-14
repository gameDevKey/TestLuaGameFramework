using MiniJSON;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class PsdGenerate
{
    [MenuItem("Assets/工具/UI/Psd生成预设", false, 100)]
    static private void PsdGeneratePrefab()
    {
        string[] selectFiles = Selection.assetGUIDs;
        if (selectFiles.Length <= 0)
        {
            Debug.LogError("没有选择(psdui)文件");
            return;
        }

        string filePath = AssetDatabase.GUIDToAssetPath(selectFiles[0]);
        Debug.Log("处理文件:" + filePath);

        string ext = IOUtils.GetExt(filePath);
        if (ext != "psdui")
        {
            Debug.LogErrorFormat("错误的资源类型[{0}]",ext);
            return;
        }

        Generate(filePath);
    }


    static string curPath = string.Empty;
    static string assetPath = string.Empty;

    static Dictionary<string, string> fonts = new Dictionary<string, string>();

    public static void Generate(string file)
    {
        Dictionary<string, object> psdInfos = new Dictionary<string, object>();

        try
        {
            string configStr = IOUtils.ReadAllText(file);
            psdInfos = Json.Deserialize(configStr) as Dictionary<string, object>;
        }
        catch (System.Exception e)
        {
            throw new Exception(string.Format("psd文件读取失败[{0}][error:{1}]", file, e.Message));
        }

        int width = int.Parse(psdInfos["width"].ToString()); //(int)((long)psdInfos["width"]);
        int height = int.Parse(psdInfos["height"].ToString()); //(int)((long)psdInfos["height"]);
        string uiRootName = (string)psdInfos["uiRoot"];

        GameObject uiRoot = GameObject.Find(uiRootName);
        if(uiRoot == null)
        {
            throw new Exception("UI根节点不存在");
        }

        System.Type T = System.Type.GetType("UnityEditor.GameView,UnityEditor");
        System.Reflection.MethodInfo GetMainGameView = T.GetMethod("GetSizeOfMainGameView", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static);
        System.Object Res = GetMainGameView.Invoke(null, null);
        Vector2 viewSize = (Vector2)Res;
        int screenWidth = (int)viewSize.x;
        int screenHeight = (int)viewSize.y;

        if (width != screenWidth || height != screenHeight)
        {
            throw new Exception(string.Format("分辨率异常[目标分辨率:{0}x{1}][编辑器分辨率:{2}x{3}]", width, height, screenWidth, screenHeight));
        }

        assetPath = IOUtils.GetAbsPath( Application.dataPath + "/../" );

        fonts.Clear();
        Dictionary<string, object> fontInfos = psdInfos["font"] as Dictionary<string, object>;
        foreach(var v in fontInfos)
        {
            fonts.Add(v.Key, IOUtils.SubPath(v.Value.ToString(),assetPath) );
        }

        curPath = IOUtils.GetPathDirectory(file) + "/";

      

        string fileName =IOUtils.GetFileName(file);

        GameObject root = new GameObject(fileName, typeof(RectTransform));

        root.transform.SetParent(uiRoot.transform,false);
        root.GetComponent<RectTransform>().sizeDelta = new Vector2(width,height);

        List<object> nodes = psdInfos["nodes"] as List<object>;
        foreach(var node in nodes)
        {
            Dictionary<string, object> nodeData = node as Dictionary<string, object>;

            string type = nodeData["type"].ToString();

            if(type == "image")
            {
                createImage(root.transform, nodeData);
            }
            else if(type == "text")
            {
                createText(root.transform, nodeData);
            }
        }
    }

    static void createImage(Transform parent,Dictionary<string,object> nodeData)
    {
        GameObject obj = new GameObject(nodeData["nodeName"].ToString(), typeof(Image));
        obj.transform.SetParent(parent);
        initRectTransform(obj);

        RectTransform rectTransform = obj.GetComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(float.Parse(nodeData["w"].ToString()), float.Parse(nodeData["h"].ToString()));
        rectTransform.localPosition = new Vector3(float.Parse(nodeData["x"].ToString()), float.Parse(nodeData["y"].ToString()),0.0f);

        string texPath = nodeData["texPath"].ToString();
        string spriteFile = IOUtils.SubPath(texPath,assetPath);

        Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(spriteFile);

        if(sprite ==null)
        {
            throw new Exception(string.Format("图片资源不存在[{0}]", spriteFile));
        }

        Image image = obj.GetComponent<Image>();
        image.sprite = sprite;
        image.color = new Color(1.0f,1.0f,1.0f, float.Parse(nodeData["alpha"].ToString()));
        image.raycastTarget = false;
        if (sprite.border.x != 0.0f || sprite.border.y != 0.0f || sprite.border.z != 0.0f || sprite.border.w != 0.0f)
        {
            image.type = Image.Type.Sliced;
        }
    }

    static void createText(Transform parent, Dictionary<string, object> nodeData)
    {
        GameObject obj = new GameObject(nodeData["nodeName"].ToString(), typeof(Text));
        obj.transform.SetParent(parent);
        initRectTransform(obj);

        RectTransform rectTransform = obj.GetComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(float.Parse(nodeData["w"].ToString()), float.Parse(nodeData["h"].ToString()));
        rectTransform.localPosition = new Vector3(float.Parse(nodeData["x"].ToString()), float.Parse(nodeData["y"].ToString()), 0.0f);



        Text text = obj.GetComponent<Text>();
        text.raycastTarget = false;
        text.supportRichText = (bool)nodeData["richText"];
        text.horizontalOverflow = HorizontalWrapMode.Overflow;
        text.verticalOverflow = VerticalWrapMode.Overflow;

        string fontName = nodeData["fontName"].ToString();
        if (fonts.ContainsKey(fontName))
        {
            text.font = (Font)AssetDatabase.LoadAssetAtPath(fonts[fontName], typeof(Font));
        }

        text.fontSize = int.Parse(nodeData["fontSize"].ToString()); //(int)((long)nodeData["fontSize"]);

        float lineSpacing = float.Parse(nodeData["lineSpacing"].ToString());

        text.lineSpacing = lineSpacing / text.preferredHeight;

        rectTransform.pivot = new Vector2(0, 1);
        rectTransform.localPosition = new Vector3(float.Parse(nodeData["x"].ToString()) - rectTransform.sizeDelta.x * 0.5f, float.Parse(nodeData["y"].ToString()) + rectTransform.sizeDelta.y * 0.5f, 0.0f);

        text.text = nodeData["text"].ToString().Replace("/r/n","\n");
        text.color = new Color(float.Parse(nodeData["r"].ToString()), float.Parse(nodeData["g"].ToString()), float.Parse(nodeData["b"].ToString()), float.Parse(nodeData["alpha"].ToString()));

        if (nodeData.ContainsKey("outline"))
        {
            Dictionary<string, object> outlineData = nodeData["outline"] as Dictionary<string, object>;
            Outline outline = obj.AddComponent<Outline>();
            outline.effectColor = new Color(float.Parse(outlineData["r"].ToString()), float.Parse(outlineData["g"].ToString()), float.Parse(outlineData["b"].ToString()),1.0f);
            outline.effectDistance = new Vector2(float.Parse(outlineData["size"].ToString()), float.Parse(outlineData["size"].ToString()));
        }

        ContentSizeFitter sizeFitter = obj.AddComponent<ContentSizeFitter>();
        sizeFitter.horizontalFit = ContentSizeFitter.FitMode.PreferredSize;
        sizeFitter.verticalFit = ContentSizeFitter.FitMode.PreferredSize;
        sizeFitter.SetLayoutHorizontal();
        sizeFitter.SetLayoutVertical();
        GameObject.DestroyImmediate(sizeFitter);
    }

    static void initRectTransform(GameObject obj)
    {
        RectTransform transform = obj.GetComponent<RectTransform>();
        transform.anchorMin = new Vector2(0.5f, 0.5f);
        transform.anchorMax = new Vector2(0.5f, 0.5f);
        transform.localScale = new Vector3(1, 1, 1);
        transform.pivot = new Vector2(0.5f, 0.5f);
    }


}
