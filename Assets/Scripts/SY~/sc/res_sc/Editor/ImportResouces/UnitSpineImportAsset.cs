using MiniJSON;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;

public class UnitSpineImportAsset: EditorWindow
{
    static string importPath = string.Empty;

    static string rootPath = "Assets/Things/unit/";
    static string absRootPath = IOUtils.GetAbsPath(Application.dataPath + "/../" + rootPath);
    static string projectPath = IOUtils.GetAbsPath(Application.dataPath + "/../");

    // static string settingFile = IOUtils.GetAbsPath(Application.dataPath + "/Editor/ImportAsset/UnitImportSetting.json");
    // static string defAnim;
    // static Dictionary<string, string> animTransitions = new Dictionary<string, string>(){};
    // static Dictionary<string, float> animExitTimes = new Dictionary<string, float>();

    [@MenuItem("工具库/资源导入/单位Spine")]
    static void AssetImport()
    {
        string folder = selectModelFolder();
        if(string.IsNullOrEmpty(folder))
        {
            return;
        }

        // readSetting();

        bool isAll = false;

        if(IOUtils.ExistFile(folder + "model_sync.json"))
        {
            isAll = true;
            importPath = folder;
        }
        else if(IOUtils.ExistFile(folder + "../model_sync.json"))
        {
            importPath = IOUtils.GetAbsPath(folder  + "../");
        }

        if(string.IsNullOrEmpty(importPath))
        {
            Debug.LogError("错误的模型导入路径:" + importPath);
            return;
        }

        if(isAll)
        {
            importPath = folder;
            ImportAll(folder);
        }
        else
        {
            ImportUnitSpine(folder);
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("导入模型Spine结束:" + folder);
    }

    static void readSetting()
    {/*
        animTransitions.Clear();
        animExitTimes.Clear();

        object root = Json.Deserialize(IOUtils.ReadAllText(settingFile));
        Dictionary<string, object> settingInfos = root as Dictionary<string, object>;

        defAnim = (string)settingInfos["defAnim"];

        Dictionary<string,object> transitions = (Dictionary<string, object>)settingInfos["transition"];
        foreach(var v in transitions)
        {
            animTransitions.Add(v.Key, v.Value.ToString());
        }

        Dictionary<string, object> exitTimes = (Dictionary<string, object>)settingInfos["exitTime"];
        foreach (var v in exitTimes)
        {
            animExitTimes.Add(v.Key, (float)v.Value);
        }*/
    }

    static string selectModelFolder()
    {
        string dir = EditorPrefs.GetString("select_model_folder", string.Empty);
        if (string.IsNullOrEmpty(dir))
        {
            dir = Application.dataPath;
        }

        string modelFolder = EditorUtility.OpenFolderPanel("选择要导入的Spine模型文件夹", dir, "");
        if (string.IsNullOrEmpty(modelFolder))
        {
            return string.Empty;
        }
        else
        {
            modelFolder = IOUtils.GetAbsPath(modelFolder);
            EditorPrefs.SetString("select_model_folder", modelFolder);
            return modelFolder;
        }
    }

    static void ImportAll(string folder)
    {
        string[] folders = IOUtils.GetFolders(folder);
        foreach (var childFolder in folders)
        {
            ImportUnitSpine(childFolder);
        }
    }

    static void ImportUnitSpine(string folder)
    {
        string unitId = IOUtils.GetFolderName(folder);
        string[] files = IOUtils.GetFiles(folder, "");

        foreach (var file in files)
        {
            handleFile(file, unitId);  // 处理美术输出的spine文件，修改后缀，以spine插件能识别并自动生成一些文件。
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        string spineFolder = string.Format("{0}{1}/spine", absRootPath,unitId);
        CreatePrefab(unitId, spineFolder);  // 利用spine插件自动生成的材质与数据生成一个spine预设。

        //FormatFolderFileName(spineFolder);  // spine插件自动生成后修改文件名，以通过编译检测。
    }

    static void handleFile(string file,string unitId)
    {
        string name = IOUtils.GetFileName(file);
        string ext = IOUtils.GetExt(file);
        if(!Regex.IsMatch(name, @"^[a-z0-9_]*$") || !Regex.IsMatch(ext, @"^[a-z]*$"))
        {
            Debug.LogError(string.Format("资源命名错误，只允许出现(小写字母和下划线)[{0}]",file));
            return;
        }

        if(ext == "atlas")
        {
            atlasHandle(file,name,unitId);
        }
        else if (ext == "skel")
        {
            skelHandle(file,name,unitId);
        }
        else if (ext == "png")
        {
            pngHandle(file,name,unitId);
        }
    }
    static void atlasHandle(string file,string fileName,string unitId)
    {
        string atlasFile = string.Format("{0}{1}/spine/{2}.atlas", absRootPath,unitId,fileName);

        bool isCopyAtlas = IOUtils.CopyAssetFile(file, atlasFile + ".txt");
    }
    static void skelHandle(string file,string fileName,string unitId)
    {
        string skelFile = string.Format("{0}{1}/spine/{2}.skel", absRootPath,unitId,fileName);

        bool isCopySkel = IOUtils.CopyAssetFile(file, skelFile + ".bytes");
    }
    static void pngHandle(string file,string fileName,string unitId)
    {
        string pngFile = string.Format("{0}{1}/spine/{2}.png", absRootPath,unitId,fileName);

        bool isCopyPng = IOUtils.CopyAssetFile(file, pngFile);
    }

    static void FormatFolderFileName(string folder)
    {
        string[] files = IOUtils.GetFiles(folder,"");
        foreach (var file in files)
        {
            FormatFileName(file);
        }
    }
    static void FormatFileName(string file)
    {
        string name = IOUtils.GetFileName(file);
        string ext = IOUtils.GetExt(file);
        string formatName = name;
        /*  // 小数点'.'转下划线'_'
        if (ext != "meta")
        {
            formatName = formatName.Replace(".","_");
        }
        else
        {
            int count = Regex.Matches(formatName,"[.]").Count;
            if (count > 1)
            {
                for (int i = count - 2; i >= 0; i--)
                {
                    int index = formatName.IndexOf('.');
                    formatName = formatName.Remove(index,1);
                    formatName = formatName.Insert(index,"_");
                }
            }

        }
        */
        formatName = formatName.ToLower() +"." + ext;
        IOUtils.ChangeFileName(file,formatName);
    }

    static void CreatePrefab(string unitId,string spineFolder)
    {
        string[] files = IOUtils.GetFiles(spineFolder, "asset", false, false, "_SkeletonData");
        if (files.Length <= 0)
        {
            Debug.LogError("找不到SkeletonData.asset文件，请检查资源");
            return;
        }
        string skeletonDataFile = files[0];
        string localSkeletonDataFile = IOUtils.SubPath(skeletonDataFile, projectPath);
        Object obj = AssetDatabase.LoadAssetAtPath(localSkeletonDataFile, typeof(Object));
        GameObject newObj = new GameObject(unitId);
        newObj.layer = LayerMask.NameToLayer("UI");

        GameObject body = new GameObject("body");
        body.transform.SetParent(newObj.transform);

        Spine.Unity.SkeletonAnimation skAnim = body.AddComponent<Spine.Unity.SkeletonAnimation>();
        skAnim.skeletonDataAsset = obj as Spine.Unity.SkeletonDataAsset;
        skAnim.AnimationName = "stand";
        skAnim.loop = true;
        MeshRenderer meshRender = body.GetComponent<MeshRenderer>();
        if (meshRender)
        {
            meshRender.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
            meshRender.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
            meshRender.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
            meshRender.receiveShadows = false;
        }

        string prefabFile = string.Format("{0}{1}/spine/{2}.prefab", absRootPath, unitId, unitId);

        if (IOUtils.ExistFile(prefabFile))
        {
            IOUtils.DeleteFile(prefabFile);
        }

        CreateBoneFollower(newObj);  // 创建BoneFollower节点

        PrefabUtility.SaveAsPrefabAssetAndConnect(newObj, prefabFile,InteractionMode.UserAction);

        Debug.Log("Spine预设生成成功");
    }

    static void CreateBoneFollower(GameObject root)
    {
        // GameObject bpRoot = new GameObject("bp_root");
        // bpRoot.transform.SetParent(root.transform);

        Spine.Unity.SkeletonRenderer skeletonRenderer = root.transform.GetChild(0).gameObject.GetComponent<Spine.Unity.SkeletonAnimation>();
        // Spine.Unity.BoneFollower rootBoneFollower = bpRoot.AddComponent<Spine.Unity.BoneFollower>();

        // rootBoneFollower.SkeletonRenderer = skeletonRenderer;

        // bool setBone = rootBoneFollower.SetBone("bp_root");
        Spine.Unity.BoneFollower boneFollower = createBoneNode(root, "bp_root", skeletonRenderer);

        if ( boneFollower == null )
        {
            Debug.LogError( root.name + "不存在骨骼[bp_root]，请检查");
        }
        else
        {
            // Spine.ExposedList<Spine.Bone> rootChildren = rootBoneFollower.bone.Children;
            Spine.Bone rootBone = boneFollower.bone;
            List<string> boneNames = new List<string>();
            Queue<Spine.Bone> queue = new Queue<Spine.Bone>();
            queue.Enqueue(rootBone);

            while (queue.Count > 0)
            {
                var currentNode = queue.Dequeue();

                foreach (var child in currentNode.Children)
                {
                    if (child.Data.Name.StartsWith("bp_"))
                    {
                        boneNames.Add(child.Data.Name);
                    }
                    queue.Enqueue(child);
                }
            }

            foreach (var boneName in boneNames)
            {
                createBoneNode(root, boneName, skeletonRenderer);
            }
        }
    }

    static Spine.Unity.BoneFollower createBoneNode(GameObject parent, string nodeName, Spine.Unity.SkeletonRenderer skeletonRenderer)
    {
        GameObject newObj = new GameObject(nodeName);
        newObj.transform.SetParent(parent.transform);

        Spine.Unity.BoneFollower boneFollower = newObj.AddComponent<Spine.Unity.BoneFollower>();
        boneFollower.SkeletonRenderer = skeletonRenderer;

        bool isSetBone = boneFollower.SetBone(nodeName);

        if (isSetBone)
        {
            return boneFollower;
        }
        else
        {
            Debug.LogError("添加骨骼节点[" + nodeName + "]失败");
            return null;
        }
    }
}
