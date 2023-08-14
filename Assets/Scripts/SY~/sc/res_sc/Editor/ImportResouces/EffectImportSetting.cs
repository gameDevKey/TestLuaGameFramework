using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class EffectImportSetting : ImportAssetSettingBase
{
    public static List<ImportSettingMatching> ImportHandles = new List<ImportSettingMatching>()
    {
        new ImportSettingMatching("Assets/Art/effect/","tga,png,jpg,psd","OnTex"),
    };

    static void OnTex(AssetImporter importer, ImportFileInfo fileInfo)
    {
        TextureImporter textureImporter = importer as TextureImporter;
        textureImporter.mipmapEnabled = false;
        textureImporter.isReadable = false;

        // ��׿����
        TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
        androidSetting.name = "Android";
        androidSetting.maxTextureSize = 512;
        androidSetting.format = TextureImporterFormat.ASTC_6x6;
        androidSetting.textureCompression = TextureImporterCompression.Compressed;
        androidSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(androidSetting);

        // ios����
        TextureImporterPlatformSettings iosSetting = new TextureImporterPlatformSettings();
        iosSetting.name = "iPhone";
        iosSetting.maxTextureSize = 512;
        iosSetting.format = TextureImporterFormat.ASTC_6x6;
        iosSetting.textureCompression = TextureImporterCompression.Compressed;
        iosSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(iosSetting);

        //pc
        TextureImporterPlatformSettings pcSetting = new TextureImporterPlatformSettings();
        pcSetting.name = "Standalone";
        pcSetting.maxTextureSize = 512;
        pcSetting.format = TextureImporterFormat.DXT5Crunched;
        pcSetting.textureCompression = TextureImporterCompression.Uncompressed;
        pcSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(pcSetting);


        //webgl
#if (UNITY_2021)
        TextureImporterPlatformSettings webglSetting = new TextureImporterPlatformSettings();
        webglSetting.name = "WebGL";
        webglSetting.maxTextureSize = 512;
        webglSetting.format = TextureImporterFormat.ASTC_6x6;
        webglSetting.textureCompression = TextureImporterCompression.CompressedLQ;
        webglSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(webglSetting);
#endif


        //�����б���Ҫ�У�����meta��û��ʵ�ʱ���
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
