using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class CustomFontTool
{
    static string artPath = "Assets/Art/font/";
    static string resPath = "Assets/Res/font/custom/";

    const int ATLAS_MAX_SIZE = 256;

    public const int BORDER = 2;

    [MenuItem("Assets/工具/UI/创建自定义字体", false, 100)]
    static private void CreateCustomFont()
    {
        var assetGUIDs = Selection.assetGUIDs;
        if (assetGUIDs.Length <= 0)
        {
            Debug.LogError("没有选择文件夹");
            return;
        }

        string folderPath = AssetDatabase.GUIDToAssetPath(assetGUIDs[0]);
        string absPath = IOUtils.GetAbsPath(Application.dataPath + "/../" + folderPath);

        if (!folderPath.StartsWith(artPath) || !IOUtils.ExistFolder(absPath))
        {
            Debug.LogErrorFormat("路径错误[{0}]（应该是 {1} 下面的文件夹）",folderPath,artPath);
            return;
        }

        Debug.Log("路径:" + folderPath);

        string folderName = IOUtils.GetFolderName(absPath);

        string fontPath = folderPath + "/" + folderName + ".fontsettings";
        IOUtils.DeleteFile(fontPath);

        string saveFile = absPath + "/" + folderName + ".png";
        IOUtils.DeleteFile(saveFile);

        string matPath = folderPath + "/" + folderName + ".mat";
        IOUtils.DeleteFile(matPath);

        AssetDatabase.Refresh();

        string[] files = IOUtils.GetFiles(absPath,"png");

        Dictionary<string, Dictionary<string, int>> texInfos = new Dictionary<string, Dictionary<string, int>>();

        Texture2D[] textures = new Texture2D[files.Length];
        string[] textureNames = new string[textures.Length];
        for (int i=0;i<files.Length;i++)
        {
            string file = files[i];
            string localPath = IOUtils.SubPath(file, IOUtils.GetAbsPath(Application.dataPath + "/../"));
            Sprite sprite = AssetDatabase.LoadAssetAtPath(localPath, typeof(Sprite)) as Sprite;
            string texName = sprite.texture.name;
            textureNames[i] = texName;
            textures[i] = Clamp(sprite.texture);
            texInfos.Add(texName, getTexInfo(sprite,texName));
        }

        Texture2D atlas = new Texture2D(ATLAS_MAX_SIZE, ATLAS_MAX_SIZE);
        Rect[] rects = atlas.PackTextures(textures, 0, ATLAS_MAX_SIZE, false);
        if(rects.Length <= 0)
        {
            Debug.LogErrorFormat("打包文件夹图集失败[{0}]", folderPath);
            return;
        }
       
        string saveLocalFile = IOUtils.SubPath(saveFile, IOUtils.GetAbsPath(Application.dataPath + "/../"));
       
        File.WriteAllBytes(saveFile, atlas.EncodeToPNG());
        AssetDatabase.ImportAsset(saveLocalFile, ImportAssetOptions.ForceUpdate);

        TextureImporter importer = AssetImporter.GetAtPath(saveLocalFile) as TextureImporter;
        importer.textureType = TextureImporterType.Sprite;
        importer.spriteImportMode = SpriteImportMode.Multiple;
        importer.spritePixelsPerUnit = 100;
        importer.alphaIsTransparency = true;

        SpriteMetaData[] metaDatas = new SpriteMetaData[textureNames.Length];
        for (int i = 0; i < metaDatas.Length; i++)
        {
            string texName = textureNames[i];
            SpriteMetaData metaData = new SpriteMetaData();
            metaData.name = texName;
            Rect rect = rects[i];
            if (rects.Length > 1)
            {
                Dictionary<string, int> infos = null;
                bool exist = texInfos.TryGetValue(texName, out infos);

                int left = 0, top = 0, right = 0, bottom = 0;
                if(exist && infos.ContainsKey("l")) {
                    left = infos["l"];
                }

                if (exist && infos.ContainsKey("t"))
                {
                    top = infos["t"];
                }

                if (exist && infos.ContainsKey("r"))
                {
                    right = infos["r"];
                }

                if (exist && infos.ContainsKey("b"))
                {
                    bottom = infos["b"];
                }

                float x = (rect.xMin * atlas.width + BORDER) + left;
                float y = (rect.yMin * atlas.height + BORDER) + bottom;
                float w = (rect.width * atlas.width - BORDER * 2) -left + right;
                float h = (rect.height * atlas.height - BORDER * 2) -bottom + top;

                metaData.rect = new Rect(x,y,w,h);
            }
            else
            {
                metaData.rect = new Rect(rect.xMin * atlas.width, rect.yMin * atlas.height, rect.width * atlas.width, rect.height * atlas.height);
            }

            metaData.border = new Vector4();
            metaData.pivot = new Vector2(0.5f, 0.5f);
            metaDatas[i] = metaData;
        }
        importer.spritesheet = metaDatas;
        importer.maxTextureSize = ATLAS_MAX_SIZE;
        importer.isReadable = false;
        importer.mipmapEnabled = false;
        importer.textureCompression = TextureImporterCompression.Compressed;
        
        //if (format == TextureImporterFormat.RGBA32)
        //{
        //    importer.SetPlatformTextureSettings(BuildTarget.Android.ToString(), 2048, format, 100, false);
        //    if (AssetPathHelper.GetBuildTarget() == BuildTarget.iOS)
        //    {`
        //        TextureImporterPlatformSettings importerSettings_IOS = new TextureImporterPlatformSettings();
        //        importerSettings_IOS.overridden = true;
        //        importerSettings_IOS.name = "iPhone";
        //        importerSettings_IOS.textureCompression = TextureImporterCompression.Uncompressed;
        //        importerSettings_IOS.maxTextureSize = 2048;
        //        importerSettings_IOS.format = format;
        //        importer.SetPlatformTextureSettings(importerSettings_IOS);
        //    }
        //}

        AssetDatabase.ImportAsset(saveLocalFile, ImportAssetOptions.ForceUpdate);

        float texWidth = atlas.width;
        float texHeight = atlas.height;

        List<CharacterInfo> datas = new List<CharacterInfo>();
        for (int i=0;i<textures.Length;i++)
        {
            string texName = textureNames[i];
            Rect rect = metaDatas[i].rect;
         
            CharacterInfo data = new CharacterInfo();

            data.index = texInfos[texName]["ascii"];

            data.advance = (int)rect.width;
            data.glyphWidth = (int)rect.width;
            data.glyphHeight = (int)-rect.height;

            data.uvTopLeft = new Vector2(rect.min.x / texWidth, rect.min.y / texHeight);
            data.uvTopRight = new Vector2(rect.max.x / texWidth, rect.min.y / texHeight);
            data.uvBottomLeft = new Vector2(rect.min.x / texWidth, rect.max.y / texHeight);
            data.uvBottomRight = new Vector2(rect.max.x / texWidth, rect.max.y / texHeight);

            data.minX = 0;
            data.maxX = (int)rect.width;
            data.minY = (int)(rect.height * 0.5f);
            data.maxY = (int)(-rect.height * 0.5f);

            datas.Add(data);
        }

        Font customFont = new Font();

        customFont.characterInfo = datas.ToArray();

        Material material = new Material(Shader.Find("UI/xProject-Default"));
        material.mainTexture = AssetDatabase.LoadAssetAtPath(saveLocalFile, typeof(Texture)) as Texture;
      
        AssetDatabase.CreateAsset(material, matPath);
        AssetDatabase.ImportAsset(matPath, ImportAssetOptions.ForceUpdate);

        customFont.material = AssetDatabase.LoadAssetAtPath<Material>(matPath) as Material;

        AssetDatabase.CreateAsset(customFont, fontPath);
        AssetDatabase.ImportAsset(fontPath, ImportAssetOptions.ForceUpdate);
    }

    static int getAscii(string text)
    {
        if(text == "space")
        {
            return 32;
        }
        else if(text == "colon")
        {
            return 58;
        }
        else if(text == "forwardSlash")
        {
            return 47;
        }
        else if(text == "dot")
        {
            return 46;
        }
        else if(text.Length > 1)
        {
            return -1;
        }
        else
        {
            return text[0];
        }
    }

    static Dictionary<string, int> getTexInfo(Sprite sprite, string texName)
    {
        Vector4 a = sprite.border;
        Dictionary<string, int> texInfos = new Dictionary<string, int>();

        string[] nameInfos = texName.Split("_"[0]);
        if (nameInfos.Length > 2)
        {
            throw new Exception(string.Format("图片命名格式异常[{0}](ascii_l = x, t = x, r = x, b = x)", texName));
        }

        string asciiInfo = nameInfos[0];
        int ascii = getAscii(asciiInfo);

        if (ascii == -1)
        {
            throw new Exception(string.Format("无法识别的ascii映射[{0}][{1}]", asciiInfo, texName));
        }

        texInfos.Add("ascii", ascii);

        if (nameInfos.Length == 2)
        {
            string[] offsetInfos = nameInfos[1].Split(","[0]);

            foreach (var v in offsetInfos)
            {
                string[] dirInfos = v.Split("="[0]);
                if (dirInfos.Length != 2)
                {
                    throw new Exception(string.Format("图片命名格式异常[{0}][{1}]", v, texName));
                }

                string key = dirInfos[0];
                if (!key.Equals("l") && !key.Equals("t") && !key.Equals("r") && !key.Equals("b"))
                {
                    throw new Exception(string.Format("图片命名格式异常[{0}][{1}]", v, texName));
                }

                int value;
                bool ok = int.TryParse(dirInfos[1], out value);
                if (!ok)
                {
                    throw new Exception(string.Format("图片命名格式异常[{0}][{1}]", v, texName));
                }

                texInfos.Add(key, value);
            }
        }

        return texInfos;
    }

    public static Texture2D Clamp(Texture2D sourceTexture)
    {
        int sourceWidth = sourceTexture.width;
        int sourceHeight = sourceTexture.height;
        Color32[] sourcePixels = sourceTexture.GetPixels32();
        int targetWidth = sourceWidth + BORDER * 2;
        int targetHeight = sourceHeight + BORDER * 2;
        Color32[] targetPixels = new Color32[targetWidth * targetHeight];
        Texture2D targetTexture = new Texture2D(targetWidth, targetHeight);
        for (int i = 0; i < sourceHeight; i++)
        {
            for (int j = 0; j < sourceWidth; j++)
            {
                targetPixels[(i + BORDER) * targetWidth + (j + BORDER)] = sourcePixels[i * sourceWidth + j];
            }
        }
        //左边缘
        for (int v = 0; v < sourceHeight; v++)
        {
            for (int k = 0; k < BORDER; k++)
            {
                targetPixels[(v + BORDER) * targetWidth + k] = sourcePixels[v * sourceWidth];
            }
        }
        //右边缘
        for (int v = 0; v < sourceHeight; v++)
        {
            for (int k = 0; k < BORDER; k++)
            {
                targetPixels[(v + BORDER) * targetWidth + (sourceWidth + BORDER + k)] = sourcePixels[v * sourceWidth + sourceWidth - 1];
            }
        }
        //上边缘
        for (int h = 0; h < sourceWidth; h++)
        {
            for (int k = 0; k < BORDER; k++)
            {
                targetPixels[(sourceHeight + BORDER + k) * targetWidth + BORDER + h] = sourcePixels[(sourceHeight - 1) * sourceWidth + h];
            }
        }
        //下边缘
        for (int h = 0; h < sourceWidth; h++)
        {
            for (int k = 0; k < BORDER; k++)
            {
                targetPixels[k * targetWidth + BORDER + h] = sourcePixels[h];
            }
        }
        targetTexture.SetPixels32(targetPixels);
        targetTexture.Apply();
        return targetTexture;
    }

}
