using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

public delegate void ImportSettingDelegate(AssetImporter importer, ImportFileInfo fileInfo);
public delegate void ImportSettingAfterDelegate(AssetImporter importer, UnityEngine.Object importObj, ImportFileInfo fileInfo);

public class ImportAssetSettingBase : AssetPostprocessor
{
#if !OFF_ASSETS_IMPORT_SETTING
    static Dictionary<string, List<ImportSettingMatching>> importClassList = new Dictionary<string, List<ImportSettingMatching>>();
    //纹理导入之前调用
    void OnPreprocessTexture()
    {
        ImportAssetSetting(false);
    }

    //纹理导入之后调用
    public void OnPostprocessTexture(Texture2D tex)
    {
        ImportAssetSetting(true,tex);
    }

    //模型导入之前调用
    void OnPreprocessModel()
    {
        ImportAssetSetting(false);
    }

    //模型导入之后调用
    void OnPostprocessModel(GameObject obj)
    {
        ImportAssetSetting(true, obj);
    }

    //音频导入之前调用
    public void OnPreprocessAudio()
    {
        ImportAssetSetting(false);
    }

    //音频导入之后调用
    public void OnPostprocessAudio(AudioClip clip)
	{
        ImportAssetSetting(true, clip);
    }

    public static void OnPreprocessSpriteAtlas(string path)
    {
        GetImportClass();
        string assetPath = path;
        ImportAssetSettingCall(assetPath,false,null,null);
    }

    public static void OnPostprocessAllAssets(string[] importedAsset, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
    {
        foreach (string assetPath in importedAsset)
        {
            if (assetPath.EndsWith(".spriteatlas"))
            {
                OnPreprocessSpriteAtlas(assetPath);
            }
        }
    }


    void ImportAssetSetting(bool after,UnityEngine.Object importerObj = null)
    {
        GetImportClass();
        string assetPath = assetImporter.assetPath;
        ImportAssetSettingCall(assetPath,after,assetImporter,importerObj);
    }

    static void ImportAssetSettingCall(string assetPath,bool after, AssetImporter assetImporter, UnityEngine.Object importerObj = null)
    {
        string fullName = IOUtils.GetFileNameByExt(assetPath);
        string name = IOUtils.GetFileName(assetPath);
        string ext = IOUtils.GetExt(assetPath);


        ImportFileInfo fileInfo;
        fileInfo.assetPath = assetPath;
        fileInfo.fullPath = IOUtils.GetAbsPath(Application.dataPath + "/../" + assetPath);
        fileInfo.fileName = name;
        fileInfo.fileNameByExt = fullName;
        fileInfo.ext = ext;

        foreach (var v in importClassList)
        {
            foreach (var item in v.Value)
            {
                if (!item.folderPath.Equals(string.Empty) && !assetPath.StartsWith(item.folderPath))
                {
                    continue;
                }

                if(item.importTypes.Count > 0 && !item.importTypes.Contains(ext))
                {
                    continue;
                }

                if (!after && item.fun != null)
                {
                    item.fun(assetImporter, fileInfo);
                }
                else if (after && item.afterFun != null)
                {
                    item.afterFun(assetImporter, importerObj, fileInfo);
                }
            }
        }
    }

    static void GetImportClass(bool ignoreExist = false)
    {
        if (importClassList.Count > 0 && !ignoreExist)
        {
            return;
        }

        string[] files = IOUtils.GetFiles(Application.dataPath + "/Editor/ImportResouces", "cs");
        foreach (string file in files)
        {
            string className = IOUtils.GetFileName(file);
            if (className.Equals("ImportAssetSettingBase"))
            {
                continue;
            }
            if (className.Equals("ImportAssetSettingDefine"))
            {
                continue;
            }

            Type classType = Type.GetType(className);
            if (classType == null)
            {
                continue;
            }

            FieldInfo handles = classType.GetField("ImportHandles", BindingFlags.Static | BindingFlags.Public);
            if (handles == null)
            {
                continue;
            }

            List<ImportSettingMatching> handleList =  handles.GetValue(null) as List<ImportSettingMatching>;
            if (handleList == null)
            {
                continue;
            }

            foreach(var v in handleList)
            {
                MethodInfo method = classType.GetMethod(v.funName, BindingFlags.Static | BindingFlags.NonPublic);
                if (method != null)
                {
                    v.fun = (ImportSettingDelegate)Delegate.CreateDelegate(typeof(ImportSettingDelegate), method);
                }

                MethodInfo afterMethod = classType.GetMethod(v.funName + "After", BindingFlags.Static | BindingFlags.NonPublic);
                if (afterMethod != null)
                {
                    v.afterFun = (ImportSettingAfterDelegate)Delegate.CreateDelegate(typeof(ImportSettingAfterDelegate), afterMethod);
                }
            }

            importClassList.Add(className,handleList);
        }
    }
#endif
}

public class ImportSettingMatching
{
    public string folderPath = string.Empty;
    public HashSet<string> importTypes = new HashSet<string>();
    public string funName = string.Empty;
    public ImportSettingDelegate fun = null;
    public ImportSettingAfterDelegate afterFun = null;

    public ImportSettingMatching(string folderPath,string types, string funName)
    {
        this.folderPath = folderPath;
        this.funName = funName;
        foreach (var type in types.Split(","[0]))
        {
            importTypes.Add(type.Equals("*") ? "" : type);
        }
    }
}

public struct ImportFileInfo
{
    public string assetPath;
    public string fullPath;
    public string fileName;
    public string fileNameByExt;
    public string ext;
}