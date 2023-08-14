using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

public class UnitImportSetting : ImportAssetSettingBase
{
    public static int[] specAmin = { 32201 , 52202 };
    public static List<ImportSettingMatching> ImportHandles = new List<ImportSettingMatching>()
    {
        new ImportSettingMatching("Assets/Things/unit/","fbx","OnFbx"),
        new ImportSettingMatching("Assets/Things/unit/","tga","OnSkin"),
    };

    static Dictionary<string, bool> loopAnims = new Dictionary<string, bool>()
    {
        {"stand",true},
        {"move",true},
    };

    static Dictionary<string, bool> dynamicLoopAnims = new Dictionary<string, bool>();

    static void OnFbx(AssetImporter importer, ImportFileInfo fileInfo)
    {
        if(fileInfo.assetPath.Contains("model"))
        {
            OnModel(importer, fileInfo);
        }
        else if(fileInfo.assetPath.Contains("anim"))
        {
            OnAnim(importer,fileInfo);
        }
    }

    static void OnFbxAfter(AssetImporter importer, UnityEngine.Object importObj,ImportFileInfo fileInfo)
    {
        if (fileInfo.assetPath.Contains("model"))
        {
            OnModelAfter(importer, importObj, fileInfo);
        }
        else if (fileInfo.assetPath.Contains("anim"))
        {
            OnAnimAfter(importer, importObj,fileInfo);
        }
    }

    static void OnAnim(AssetImporter importer, ImportFileInfo fileInfo)
    {
        ModelImporter modelImporter = importer as ModelImporter;
        modelImporter.importAnimation = true;
        modelImporter.generateAnimations = ModelImporterGenerateAnimations.InOriginalRoots;
        //modelImporter.clipAnimations = GetClips(modelImporter.importedTakeInfos, fileInfo.fileName);

        modelImporter.animationCompression = ModelImporterAnimationCompression.KeyframeReduction;
        modelImporter.animationPositionError = 0.1f;
        modelImporter.animationRotationError = 0.1f;
        modelImporter.animationScaleError = 0.1f;
    }

    static void OnAnimAfter(AssetImporter importer, UnityEngine.Object importObj,ImportFileInfo fileInfo)
    {
        ModelImporter modelImporter = importer as ModelImporter;
        //modelImporter.importAnimation = true;
        //modelImporter.generateAnimations = ModelImporterGenerateAnimations.InOriginalRoots;
        modelImporter.clipAnimations = GetClips(modelImporter.importedTakeInfos, fileInfo.fileName);

        //modelImporter.animationCompression = ModelImporterAnimationCompression.KeyframeReduction;
        //modelImporter.animationPositionError = 0.1f;
        //modelImporter.animationRotationError = 0.1f;
        //modelImporter.animationScaleError = 0.1f;

        //AssetDatabase.SaveAssets();
        //AssetDatabase.Refresh();

        importer.SaveAndReimport();
        AssetDatabase.Refresh();
    }

    static ModelImporterClipAnimation[] GetClips(TakeInfo[] takeInfos, string name)
    {
        ModelImporterClipAnimation[] clips = new ModelImporterClipAnimation[takeInfos.Length];
        int index = -1;

        foreach (var v in takeInfos)
        {
            ModelImporterClipAnimation mica = new ModelImporterClipAnimation();
            mica.name = name;
            mica.takeName = name;
            mica.firstFrame = (float)((int)Mathf.Round(v.bakeStartTime * v.sampleRate));
            mica.lastFrame = (float)((int)Mathf.Round(v.bakeStopTime * v.sampleRate));

            mica.keepOriginalPositionY = true;
            mica.keepOriginalPositionXZ = true;
            mica.keepOriginalOrientation = true;
            mica.lockRootHeightY = true;
            mica.lockRootPositionXZ = true;
            mica.lockRootRotation = true;

            if (IsLoopAnim(mica.name))
            {
                mica.loop = true;
                mica.loopPose = true;
                mica.loopTime = true;
            }

            clips[++index] = mica;
        }

        return clips;
    }

    static void OnModel(AssetImporter importer, ImportFileInfo fileInfo)
    {
        ModelImporter modelImporter = importer as ModelImporter;
        modelImporter.importAnimation = false;
        modelImporter.materialImportMode = ModelImporterMaterialImportMode.None;
        modelImporter.importNormals = ModelImporterNormals.Import;
        modelImporter.animationCompression = ModelImporterAnimationCompression.Off;
        modelImporter.animationPositionError = 0.5f;
        modelImporter.animationRotationError = 0.5f;
        modelImporter.animationScaleError = 0.5f;
        modelImporter.animationType = ModelImporterAnimationType.Generic;
        modelImporter.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
    }

    static void OnModelAfter(AssetImporter importer, UnityEngine.Object importObj,ImportFileInfo fileInfo)
    {
        ModelImporter modelImporter = importer as ModelImporter;
        bool isSave = modelImporter.optimizeGameObjects == false;
        modelImporter.optimizeGameObjects = true;
        modelImporter.extraExposedTransformPaths =  GetExportBone((GameObject)importObj);
        if (isSave)
        {
            importer.SaveAndReimport();
        }
        AssetDatabase.Refresh();
    }

    static void OnSkin(AssetImporter importer, ImportFileInfo fileInfo)
    {
        if(fileInfo.assetPath.Contains("/mixed/"))
        {
            return;
        }

        TextureImporter textureImporter = importer as TextureImporter;
        textureImporter.filterMode = FilterMode.Bilinear;
        textureImporter.alphaIsTransparency = false;
        textureImporter.mipmapEnabled = false;
        textureImporter.isReadable = false;

        string[] nameInfo = fileInfo.fileName.Split("_"[0]);
        string lastInfo = nameInfo[nameInfo.Length - 1];

        TextureImporterType texType = TextureImporterType.Default;
        //if (lastInfo.Equals("normal"))
        //{
        //    texType = TextureImporterType.NormalMap;
        //}
        textureImporter.textureType = texType;

        textureImporter.sRGBTexture = lastInfo.Equals("albedo");


        // 安卓设置
        TextureImporterPlatformSettings androidSetting = new TextureImporterPlatformSettings();
        androidSetting.name = "Android";
        androidSetting.maxTextureSize = 512;
        androidSetting.format = TextureImporterFormat.ASTC_6x6;
        androidSetting.textureCompression = TextureImporterCompression.Compressed;
        androidSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(androidSetting);

        // ios设置
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
        webglSetting.maxTextureSize = 256;
        webglSetting.format = TextureImporterFormat.ASTC_6x6;
        webglSetting.textureCompression = TextureImporterCompression.CompressedLQ;
        webglSetting.overridden = true;
        textureImporter.SetPlatformTextureSettings(webglSetting);
#endif

        //这两行必须要有，否则meta并没有实际保存
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }


    public static bool IsLoopAnim(string animName)
    {
        return loopAnims.ContainsKey(animName) || dynamicLoopAnims.ContainsKey(animName);
    }

    public static void AddDynamicLoopAnim(string animName)
    {
        if (dynamicLoopAnims.ContainsKey(animName)) return;
        dynamicLoopAnims.Add(animName, true);
    }

    public static void ClearDynamicLoopAnim()
    {
        dynamicLoopAnims.Clear();
    }

    public static string[] GetExportBone(GameObject obj)
    {
        List<string> bips = new List<string>();

        Transform[] childs = obj.transform.GetComponentsInChildren<Transform>(true);
        for (int i = 0; i < childs.Length; i++)
        {
            string boneName = childs[i].name;
            if(boneName.StartsWith("bp_"))
            {
                bips.Add(boneName);
            }
        }

        return bips.ToArray();
    }
}
