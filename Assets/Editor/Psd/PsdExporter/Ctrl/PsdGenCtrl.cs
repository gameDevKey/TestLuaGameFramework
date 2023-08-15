using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;

public class PsdGenCtrl : Controller
{
    public static PsdGenCtrl Instance => PsdExporterFacade.Instance.GetCtrl<PsdGenCtrl>() as PsdGenCtrl;

    public void ExportPrefab(PsdParse psdParse)
    {
        string outPath = PsdExporterProxy.Instance.UITexPath + psdParse.fileName + "/";

        FileUtil.DeleteFileOrDirectory(outPath);
        FileUtils.CreateFolder(outPath);

        GameObject root = createRootObject(psdParse.fileName);
        foreach (LayerNode node in psdParse.nodes)
        {
            GameObject nodeObject = createNodeObject(node);
            nodeObject.transform.SetParent(root.transform, false);

            if (node is ImageNode)
            {
                createImage(psdParse, node as ImageNode, nodeObject);
            }
            else if (node is TextNode)
            {
                createText(psdParse, node as TextNode, nodeObject);
            }
        }
    }

    public void ExportTexture(PsdParse psdParse)
    {
        string outPath = PsdExporterProxy.Instance.UITexPath + psdParse.fileName + "/";

        FileUtil.DeleteFileOrDirectory(outPath);
        FileUtils.CreateFolder(outPath);

        foreach (LayerNode node in psdParse.nodes)
        {
            if (node is ImageNode)
            {
                ImageNode imageNode = node as ImageNode;
                string texFile = outPath + node.name + ".png";
                imageNode.SaveTexture(texFile);
            }
        }
    }

    GameObject createRootObject(string name)
    {
        var proxy = PsdExporterProxy.Instance;

        GameObject root = new GameObject(name, typeof(RectTransform));
        root.layer = LayerMask.NameToLayer("UI");

        root.transform.SetParent(proxy.UIRoot, false);
        root.GetComponent<RectTransform>().sizeDelta = proxy.Setting.CanvasSize;

        return root;
    }

    GameObject createNodeObject(LayerNode node)
    {
        GameObject go = new GameObject(node.objName);
        go.layer = LayerMask.NameToLayer("UI");

        RectTransform rectTrans = go.AddComponent<RectTransform>();
        rectTrans.pivot = new Vector2(0.5f, 0.5f);
        rectTrans.anchorMax = new Vector2(0.5f, 0.5f);
        rectTrans.anchorMin = new Vector2(0.5f, 0.5f);

        if (node.rect.width == 0 || node.rect.height == 0)
        {
            rectTrans.offsetMin = Vector2.zero;
            rectTrans.offsetMax = Vector2.zero;
            Debug.LogError($"图层【{node.name}】尺寸异常, 宽:{node.rect.width},高:{node.rect.height}");
        }
        else
        {
            rectTrans.sizeDelta = new Vector2(node.rect.width, node.rect.height);
        }
        rectTrans.anchoredPosition3D = new Vector3(node.rect.x, node.rect.y, 0);
        rectTrans.localScale = Vector3.one;
        return go;
    }

    void createText(PsdParse psdParse, TextNode node, GameObject obj)
    {
        RectTransform rectTrans = obj.GetComponent<RectTransform>();
        rectTrans.sizeDelta = new Vector2(rectTrans.sizeDelta.x + 2, rectTrans.sizeDelta.y + 2);
        rectTrans.anchoredPosition3D = new Vector3(node.rect.x - (node.rect.width * 0.5f), node.rect.y + (node.rect.height * 0.5f), 0);

        Text text = obj.AddComponent<Text>();
        text.raycastTarget = false;
        text.fontSize = node.fontSize;
        text.font = PsdExporterProxy.Instance.GetFont(node.fontName);
        if (text.font == null)
        {
            Debug.LogError($"图层【{node.name}】缺失字体:{node.fontName}");
            text.font = PsdExporterProxy.Instance.Setting.DefaultFont;
        }
        text.color = new Color(node.color.r, node.color.g, node.color.b, node.alpha);

        text.horizontalOverflow = HorizontalWrapMode.Overflow;
        text.verticalOverflow = VerticalWrapMode.Overflow;

        float preferredHeight = text.preferredHeight;
        text.text = node.textInfo.text.Replace("\r", "\n").Replace("\r\n", "\n");

        text.supportRichText = node.richText;

        rectTrans.pivot = new Vector2(0.0f, 1.0f);

        if (!node.isOneline)
        {
            text.lineSpacing = node.lineSpacing / preferredHeight;
        }

        if (node.outlineWidth > 0)
        {
            Outline outline = obj.AddComponent<Outline>();
            outline.effectDistance = new Vector2(node.outlineWidth, node.outlineWidth);
            outline.effectColor = node.outlineColor;
        }

        text.horizontalOverflow = node.isOneline ? HorizontalWrapMode.Overflow : HorizontalWrapMode.Wrap;

        //ContentSizeFitter sizeFitter = obj.AddComponent<ContentSizeFitter>();
        //sizeFitter.horizontalFit = ContentSizeFitter.FitMode.PreferredSize;
        //sizeFitter.verticalFit = ContentSizeFitter.FitMode.PreferredSize;
        //sizeFitter.SetLayoutHorizontal();
        //sizeFitter.SetLayoutVertical();
        //GameObject.DestroyImmediate(sizeFitter);
    }

    void createImage(PsdParse psdParse, ImageNode node, GameObject obj)
    {
        var setting = PsdExporterProxy.Instance.Setting;
        string outPath = PsdExporterProxy.Instance.UITexPath + psdParse.fileName + "/";

        string texFile = string.Empty;
        bool isGen = false;

        var suffixs = new List<string> { ".jpg", ".png" };
        foreach (var suffix in suffixs)
        {
            string commonPath = PsdExporterProxy.Instance.CommonTexPath + node.name + suffix;
            if (File.Exists(commonPath))
            {
                texFile = commonPath;
                break;
            }
        }

        if (texFile.Equals(string.Empty))
        {
            texFile = outPath + node.name + ".png";
            isGen = true;
        }

        string assetPath = PsdExporterProxy.Instance.GetAssetPath(texFile);

        if (isGen && !File.Exists(texFile))
        {
            //创建并保存纹理
            node.SaveTexture(texFile);
            AssetDatabase.ImportAsset(assetPath, ImportAssetOptions.ForceUpdate);
            //转换成Sprite纹理类型
            TextureImporter texture = AssetImporter.GetAtPath(assetPath) as TextureImporter;
            texture.textureType = TextureImporterType.Sprite;
            //texture.spritePixelsPerUnit = 1;
            //texture.filterMode = FilterMode.Trilinear;
            //texture.mipmapEnabled = false;
            //texture.textureFormat = TextureImporterFormat.AutomaticTruecolor;
            AssetDatabase.ImportAsset(assetPath);
        }

        Image image = obj.AddComponent<Image>();
        image.raycastTarget = false;
        image.color = new Color(1.0f, 1.0f, 1.0f, node.alpha);

        Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(assetPath);
        image.sprite = sprite;

        Vector4 border = sprite.border;
        if (border.x + border.y + border.z + border.w > 2)
        {
            image.type = Image.Type.Sliced;
        }
    }
}


