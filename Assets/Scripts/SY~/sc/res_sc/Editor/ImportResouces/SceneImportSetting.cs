using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

public class SceneImportSetting : ImportAssetSettingBase
{
    public static List<ImportSettingMatching> ImportHandles = new List<ImportSettingMatching>()
    {
        new ImportSettingMatching("Assets/Things/scene/common/","exr","OnCubeTexSetting")
    };

    static void OnSceneTexture(AssetImporter importer, ImportFileInfo fileInfo)
    {
        TextureImporter textureImporter = importer as TextureImporter;
        textureImporter.filterMode = FilterMode.Bilinear;
        textureImporter.alphaIsTransparency = false;
        textureImporter.mipmapEnabled = false;

        string[] nameInfo = fileInfo.fileName.Split("_"[0]);
        string lastInfo = nameInfo[nameInfo.Length - 1];

        if(lastInfo.Equals("light"))
        {
            LightTextureSetting(textureImporter);
        }
        else if(lastInfo.Equals("shadowmask"))
        {
            ShadowmaskTextureSetting(textureImporter);
        }
        else if(lastInfo.Equals("normal"))
        {
            //NormalTextureSetting(textureImporter);
        }
        else
        {
            //ColorTexutreSetting(textureImporter);
        }

        //这两行必须要有，否则meta并没有实际保存
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    static void LightTextureSetting(TextureImporter textureImporter)
    {
        textureImporter.textureType = TextureImporterType.Lightmap;

        // 安卓设置
        TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
        androidSetting.name = "Android";
        androidSetting.maxTextureSize = textureImporter.maxTextureSize;
        androidSetting.format = TextureImporterFormat.ASTC_5x5;
        androidSetting.compressionQuality = 100;
        androidSetting.overridden = true;

        // ios设置
        TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "iPhone";
        iosSetting.maxTextureSize = textureImporter.maxTextureSize;
        iosSetting.format = TextureImporterFormat.ASTC_5x5;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;

        TextureImporterPlatformSettings pcSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "Standalone";
        iosSetting.maxTextureSize = textureImporter.maxTextureSize;
        iosSetting.format = TextureImporterFormat.RGBA32;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;

        textureImporter.SetPlatformTextureSettings(androidSetting);
        textureImporter.SetPlatformTextureSettings(iosSetting);
        textureImporter.SetPlatformTextureSettings(pcSetting);
    }

    static void ShadowmaskTextureSetting(TextureImporter textureImporter)
    {
        return;
        textureImporter.textureType = TextureImporterType.Shadowmask;

        // 安卓设置
        TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
        androidSetting.name = "Android";
        androidSetting.maxTextureSize = textureImporter.maxTextureSize;
        androidSetting.format = TextureImporterFormat.ASTC_8x8;
        androidSetting.compressionQuality = 100;
        androidSetting.overridden = true;

        // ios设置
        TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "iPhone";
        iosSetting.maxTextureSize = textureImporter.maxTextureSize;
        iosSetting.format = TextureImporterFormat.ASTC_8x8;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;

        TextureImporterPlatformSettings pcSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "Standalone";
        iosSetting.maxTextureSize = textureImporter.maxTextureSize;
        iosSetting.format = TextureImporterFormat.RGBA32;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;

        textureImporter.SetPlatformTextureSettings(androidSetting);
        textureImporter.SetPlatformTextureSettings(iosSetting);
        textureImporter.SetPlatformTextureSettings(pcSetting);
    }

    static void NormalTextureSetting(TextureImporter textureImporter)
    {
        textureImporter.textureType = TextureImporterType.NormalMap;

        // 安卓设置
        TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
        androidSetting.name = "Android";
        androidSetting.maxTextureSize = textureImporter.maxTextureSize;
        androidSetting.format = TextureImporterFormat.ASTC_5x5;
        androidSetting.compressionQuality = 100;
        androidSetting.overridden = true;

        // ios设置
        TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "iPhone";
        iosSetting.maxTextureSize = textureImporter.maxTextureSize;
        iosSetting.format = TextureImporterFormat.ASTC_5x5;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;

        TextureImporterPlatformSettings pcSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "Standalone";
        iosSetting.maxTextureSize = textureImporter.maxTextureSize;
        iosSetting.format = TextureImporterFormat.RGBA32;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;

        textureImporter.SetPlatformTextureSettings(androidSetting);
        textureImporter.SetPlatformTextureSettings(iosSetting);
        textureImporter.SetPlatformTextureSettings(pcSetting);
    }

    static void ColorTexutreSetting(TextureImporter textureImporter)
    {
        textureImporter.textureType = TextureImporterType.Default;

        // 安卓设置
        TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
        androidSetting.name = "Android";
        androidSetting.maxTextureSize = textureImporter.maxTextureSize;
        androidSetting.format = TextureImporterFormat.ASTC_6x6;
        androidSetting.compressionQuality = 100;
        androidSetting.overridden = true;

        // ios设置
        TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "iPhone";
        iosSetting.maxTextureSize = textureImporter.maxTextureSize;
        iosSetting.format = TextureImporterFormat.ASTC_6x6;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;

        TextureImporterPlatformSettings pcSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "Standalone";
        iosSetting.maxTextureSize = textureImporter.maxTextureSize;
        iosSetting.format = TextureImporterFormat.RGBA32;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;

        textureImporter.SetPlatformTextureSettings(androidSetting);
        textureImporter.SetPlatformTextureSettings(iosSetting);
        textureImporter.SetPlatformTextureSettings(pcSetting);
    }


    static void OnCubeTexSetting(AssetImporter importer, ImportFileInfo fileInfo)
    {
        TextureImporter textureImporter = importer as TextureImporter;

        textureImporter.textureShape = TextureImporterShape.TextureCube;
        textureImporter.mipmapEnabled = false;
        textureImporter.isReadable = false;


        // 安卓设置
        TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
        androidSetting.name = "Android";
        androidSetting.maxTextureSize = 128;
        androidSetting.format = TextureImporterFormat.ASTC_6x6;
        androidSetting.textureCompression = TextureImporterCompression.Compressed;
        androidSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(androidSetting);

        // ios设置
        TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "iPhone";
        iosSetting.maxTextureSize = 128;
        iosSetting.format = TextureImporterFormat.ASTC_6x6;
        iosSetting.textureCompression = TextureImporterCompression.Compressed;
        iosSetting.compressionQuality = 100;
        iosSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(iosSetting);

        //pc

        TextureImporterPlatformSettings pcSetting = new TextureImporterPlatformSettings();
        pcSetting.name = "Standalone";
        pcSetting.maxTextureSize = 128;
        pcSetting.format = TextureImporterFormat.DXT5Crunched;
        pcSetting.textureCompression = TextureImporterCompression.Uncompressed;
        pcSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(pcSetting);


        //webgl
#if (UNITY_2021)
        TextureImporterPlatformSettings webglSetting = new TextureImporterPlatformSettings();
        webglSetting.name = "WebGL";
        webglSetting.maxTextureSize = 128;
        webglSetting.format = TextureImporterFormat.ASTC_6x6;
        webglSetting.textureCompression = TextureImporterCompression.CompressedLQ;
        webglSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(webglSetting);
#endif

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
