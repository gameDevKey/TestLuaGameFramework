using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.U2D;
using UnityEngine;
using UnityEngine.U2D;

public class UISpriteImportSetting : ImportAssetSettingBase
{
    public static List<ImportSettingMatching> ImportHandles = new List<ImportSettingMatching>()
    {
        new ImportSettingMatching("Assets/Things/ui/texture/","png","UITexture"),
        new ImportSettingMatching("Assets/Things/ui/icon/","png","UITexture"),
        new ImportSettingMatching("Assets/Things/ui/single/","png","UITexture"),
    };

    static DateTime lastTime = DateTime.MinValue;

    public const string editorResPath = "Assets/Things/";
    public static string absResPath = IOUtils.GetAbsPath(Application.dataPath + "/../" + editorResPath);

    static void UITexture(AssetImporter importer, ImportFileInfo fileInfo)
    {
        DateTime nowTime = DateTime.Now;
        TimeSpan ts = nowTime - lastTime;

        lastTime = nowTime;

        TextureImporter textureImporter = importer as TextureImporter;
        textureImporter.textureType = TextureImporterType.Sprite;
        textureImporter.spritePixelsPerUnit = 100;
        textureImporter.spriteImportMode = SpriteImportMode.Single;
        textureImporter.alphaIsTransparency = true;
        textureImporter.mipmapEnabled = false;
        textureImporter.isReadable = true;
        //textureImporter.textureCompression = TextureImporterCompression.CompressedHQ;

        string localPath = IOUtils.SubPath(fileInfo.fullPath, absResPath);
        localPath = IOUtils.GetPathDirectory(localPath);

        bool isHighQuality = false;

        // 安卓设置
        TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
        androidSetting.name = "Android";
        androidSetting.format = isHighQuality ? TextureImporterFormat.RGBA32 : TextureImporterFormat.ASTC_6x6;
        androidSetting.textureCompression = isHighQuality ? TextureImporterCompression.Uncompressed : TextureImporterCompression.Compressed;
        androidSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(androidSetting);

        // ios设置
        TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "iPhone";
        iosSetting.format = isHighQuality ? TextureImporterFormat.RGBA32 : TextureImporterFormat.ASTC_6x6;
        iosSetting.textureCompression = isHighQuality ? TextureImporterCompression.Uncompressed : TextureImporterCompression.Compressed;
        iosSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(iosSetting);

        //pc
        TextureImporterPlatformSettings pcSetting = new TextureImporterPlatformSettings();
        pcSetting.name = "Standalone";
        pcSetting.format = TextureImporterFormat.RGBA32;
        pcSetting.textureCompression = TextureImporterCompression.Uncompressed;
        pcSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(pcSetting);

        //webgl
#if (UNITY_2021)
        TextureImporterPlatformSettings webglSetting = new TextureImporterPlatformSettings();
        webglSetting.name = "WebGL";
        webglSetting.format = TextureImporterFormat.ASTC_6x6;
        webglSetting.textureCompression = TextureImporterCompression.CompressedLQ;
        webglSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(webglSetting);
#endif


        //这两行必须要有，否则meta并没有实际保存
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    static void UITextureAtlas(AssetImporter importer, ImportFileInfo fileInfo)
    {
        spriteAtlasSettings(fileInfo);

        //SpriteAtlas spriteAtlas = AssetDatabase.LoadAssetAtPath<SpriteAtlas>(fileInfo.filePath);
        //var defaultAtlasSetting = spriteAtlas.GetPlatformSettings(ImportAssetSettingDefine.GetPlatformName(BuildTarget.NoTarget));
        //defaultAtlasSetting.maxTextureSize = 2048;
        //defaultAtlasSetting.textureCompression = TextureImporterCompression.CompressedHQ;
        //defaultAtlasSetting.format = TextureImporterFormat.RGBA32;
        //spriteAtlas.SetPlatformSettings(defaultAtlasSetting);

        //var androidAtlasSetting = spriteAtlas.GetPlatformSettings(ImportAssetSettingDefine.GetPlatformName(BuildTarget.Android));
        //androidAtlasSetting.maxTextureSize = 2048;
        //androidAtlasSetting.textureCompression = TextureImporterCompression.CompressedHQ;
        //androidAtlasSetting.format = TextureImporterFormat.ASTC_4x4;
        //spriteAtlas.SetPlatformSettings(androidAtlasSetting);
    }

    static void UIIconAtlas(AssetImporter importer, ImportFileInfo fileInfo)
    {
        spriteAtlasSettings(fileInfo);
    }

    static void spriteAtlasSettings(ImportFileInfo fileInfo)
    {
        string folderName = IOUtils.GetFolderNameByFile(fileInfo.assetPath);
        string fileName = IOUtils.GetFileName(fileInfo.assetPath);

        if (fileName.Equals(folderName))
        {
            SpriteAtlas atlas = AssetDatabase.LoadAssetAtPath<SpriteAtlas>(fileInfo.assetPath);
            string assetFolderPath = IOUtils.GetPathDirectory(fileInfo.assetPath,false);
            UnityEngine.Object[] existObjs = atlas.GetPackables();

            if (existObjs.Length == 0)
            {
                UnityEngine.Object folderObj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetFolderPath);
                atlas.Add(new UnityEngine.Object[] { folderObj });

                //设置属性
                atlas.SetIncludeInBuild(true);

                SpriteAtlasPackingSettings atlasPackingSettings = new SpriteAtlasPackingSettings();
                atlasPackingSettings.enableRotation = true;
                atlasPackingSettings.enableTightPacking = false;
                atlas.SetPackingSettings(atlasPackingSettings);
            }
            else if (existObjs.Length > 1)
            {
                atlas.Remove(existObjs);
                UnityEngine.Object folderObj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetFolderPath);
                atlas.Add(new UnityEngine.Object[] { folderObj });
            }
            else if (existObjs.Length == 1 && !AssetDatabase.GetAssetPath(existObjs[0]).Equals(assetFolderPath))
            {
                atlas.Remove(existObjs);
                UnityEngine.Object folderObj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetFolderPath);
                atlas.Add(new UnityEngine.Object[] { folderObj });
            }
        }
        else
        {
            Debug.LogErrorFormat("图集命名异常，应该跟文件夹名保持一致[{0}]", fileInfo.assetPath);
        }
    }
}
