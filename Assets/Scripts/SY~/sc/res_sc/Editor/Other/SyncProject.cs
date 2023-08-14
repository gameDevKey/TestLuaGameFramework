using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class SyncProject
{
	[MenuItem("工具库/同步/协议", false, 100)]
    static private void SyncProtoFile()
    {
        string srcFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../tools/gen_proto/cli/");
        string destFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../client/data/proto/");
        IOUtils.SyncFolder(srcFolder, destFolder,"","",false);
        IOUtils.DeleteFile(IOUtils.GetAbsPath(Application.dataPath + "/../../../client/data/proto_mate.lua"));
        Debug.Log(string.Format("同步协议完成:{0} => {1}", srcFolder, destFolder));
    }

    [MenuItem("工具库/同步/配置", false, 101)]
    static private void SyncConfigFile()
    {
        string srcFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../client/data_update/");
        string destFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../client/data/");
        IOUtils.SyncFolder(srcFolder, destFolder, ".git/", "lua,pb",false);
        Debug.Log(string.Format("同步配置完成:{0} => {1}",srcFolder,destFolder));
    }

    [MenuItem("工具库/同步/Icon", false, 102)]
    static private void SyncIcon()
    {
        string srcIconPath = IOUtils.GetAbsPath(Application.dataPath + "/../../docs_res/ui_sync/图标/");
        if(!IOUtils.ExistFolder(srcIconPath))
        {
            Debug.LogError("不存在的图标目录:" + srcIconPath);
            return;
        }
        string destRootIconPath = IOUtils.GetAbsPath(Application.dataPath + "/Things/ui/icon/");

        string[] destFolders = IOUtils.GetFolders(destRootIconPath);
        HashSet<string> hashDestFolders = new HashSet<string>();
        foreach (string folder in destFolders)
        {
            if(IOUtils.GetFiles(folder,"png",false).Length > 0)
            {
                string localFolder = IOUtils.SubPath(folder, destRootIconPath);
                hashDestFolders.Add(localFolder);
            }
        }

        string[] iconFolders = IOUtils.GetFolders(srcIconPath,false);
        foreach (string folder in iconFolders)
        {
            string localFolder = IOUtils.SubPath(folder, srcIconPath);

            string syncFolder = string.Empty;

            int beginIndex = localFolder.IndexOf("[");
            int endIndex = localFolder.IndexOf("]");

            if (beginIndex != -1 && endIndex != -1)
            {
                syncFolder = localFolder.Substring(beginIndex + 1, endIndex - beginIndex - 1) + "/";
                syncFolder = syncFolder.Replace("$", "/");
            }

            if (syncFolder.Equals(string.Empty))
            {
                continue;
            }

            hashDestFolders.Remove(syncFolder);

            string destFolder = string.Format("{0}{1}", destRootIconPath, syncFolder);
            IOUtils.SyncFolder(folder, destFolder,"","png",false);
        }

        foreach (string folder in hashDestFolders)
        {
            IOUtils.RemoveFolder(destRootIconPath + folder);
            IOUtils.DeleteFile(destRootIconPath + folder.Substring(0, folder.Length - 1) + ".meta");
        }

        IOUtils.DeleteEmptyFolder(destRootIconPath);

        AssetDatabase.Refresh();

        Debug.Log(string.Format("同步图标完成:{0} => {1}", srcIconPath, destRootIconPath));
    }


    [MenuItem("工具库/同步/通用纹理", false, 103)]
    static private void SyncCommonTex() 
    {
        string srcCommonPath = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/ui_sync/通用图片/");
        if (!IOUtils.ExistFolder(srcCommonPath))
        {
            Debug.LogError("不存在的通用图片路径:" + srcCommonPath);
            return;
        }

        if (!EditorUtility.DisplayDialog("确认框", "是否确定同步通用图片？", "同步", "取消"))
        {
            return;
        }

        string destRootCommonPath = IOUtils.GetAbsPath(Application.dataPath + "/Res/ui/texture/");

        Func<string,string> onSrcFile = delegate (string file)
        {
            string name = IOUtils.GetFileName(file);

            int beginIndex = name.IndexOf("(");
            if (beginIndex == -1)
            {
                beginIndex = name.IndexOf("（");
            }

            int endIndex = name.IndexOf(")");
            if (endIndex == -1)
            {
                endIndex = name.IndexOf("）");
            }

            if(beginIndex == -1 || endIndex == -1)
            {
                return file;
            }

            name = name = name.Substring(0, beginIndex);

            string newFile = string.Format("{0}{1}.png", IOUtils.GetPathDirectory(file), name);

            return newFile;
        };

        string[] commonFolders = IOUtils.GetFolders(srcCommonPath, false);
        foreach (string folder in commonFolders)
        {
            string localFolder = IOUtils.SubPath(folder, srcCommonPath);
            string destFolder = destRootCommonPath + localFolder;
            IOUtils.SyncFolder(folder, destFolder, "", "png", false, onSrcFile);
        }

        AssetDatabase.Refresh();

        Debug.Log(string.Format("同步通用图片完成:{0} => {1}", srcCommonPath, destRootCommonPath));
    }

    [MenuItem("工具库/同步/Shader", false, 105)]
    static private void SyncShader()
    {
        string srcShaderFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Res/shader/");
        string destShaderFolder = IOUtils.GetAbsPath(Application.dataPath + "/Res/shader/");

        if (!IOUtils.ExistFolder(srcShaderFolder))
        {
            Debug.LogError("不存srcShader目录:" + srcShaderFolder);
            return;
        }

        IOUtils.SyncFolder(srcShaderFolder, destShaderFolder, "", "", true);

        AssetDatabase.Refresh();

        Debug.Log(string.Format("同步Shader完成:{0} => {1}", srcShaderFolder, destShaderFolder));
    }


    [MenuItem("工具库/同步/场景", false, 105)]
    static private void SyncScene()
    {
        string srcSceneFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Res/scene/");
        string destSceneFolder = IOUtils.GetAbsPath(Application.dataPath + "/Res/scene/");

        if (!IOUtils.ExistFolder(srcSceneFolder))
        {
            Debug.LogError("不存src场景目录:" + srcSceneFolder);
            return;
        }

        IOUtils.SyncFolder(srcSceneFolder, destSceneFolder, "", "", true);

        AssetDatabase.Refresh();

        Debug.Log(string.Format("同步场景完成:{0} => {1}", srcSceneFolder, destSceneFolder));
    }


    [MenuItem("工具库/同步/特效", false, 105)]
    static private void SyncEffect()
    {
        string srcArtFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../docs_res/assets_sync/Assets/Art/effect");
        string destArtFolder = IOUtils.GetAbsPath(Application.dataPath + "/Art/effect");
        IOUtils.SyncFolder(srcArtFolder, destArtFolder, "", "", true);
        Debug.Log(string.Format("同步特效Art完成:{0} => {1}", srcArtFolder, destArtFolder));

        string srcPrefabFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../docs_res/assets_sync/Assets/Res/effect");
        string destPrefabFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/effect");
        IOUtils.SyncFolder(srcPrefabFolder, destPrefabFolder, "", "prefab", true);

        AssetDatabase.Refresh();

        Debug.Log(string.Format("同步特效Prefab完成:{0} => {1}", srcPrefabFolder, destPrefabFolder));
    }

    [MenuItem("工具库/同步/模型", false, 106)]
    static private void SyncModel()
    {
        string srcUnitFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../docs_res/assets_sync/Assets/Res/unit/");
        string destUnitFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/unit/");

        if (!IOUtils.ExistFolder(srcUnitFolder))
        {
            Debug.LogError("不存src单位目录:" + srcUnitFolder);
            return;
        }

        IOUtils.SyncFolder(srcUnitFolder, destUnitFolder, "", "", true);

        AssetDatabase.Refresh();

        Debug.Log(string.Format("同步模型完成:{0} => {1}", srcUnitFolder, destUnitFolder));
    }

    [MenuItem("工具库/同步/动画", false, 106)]
    static private void SyncAnim()
    {
        string srcAnimFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../docs_res/assets_sync/Assets/Res/anim/");
        string destAnimFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/anim/");

        if (!IOUtils.ExistFolder(srcAnimFolder))
        {
            Debug.LogError("不存src动画目录:" + srcAnimFolder);
            return;
        }

        IOUtils.SyncFolder(srcAnimFolder, destAnimFolder, "", "", true);

        AssetDatabase.Refresh();

        Debug.Log(string.Format("同步动画完成:{0} => {1}", srcAnimFolder, destAnimFolder));
    }


    [MenuItem("工具库/同步/同步到主工程", false, 104)]
    static private void SyncCoreProject()
    {
        string coreProjectPath = IOUtils.GetAbsPath(Application.dataPath + "/../../client_core/");
        if (!IOUtils.ExistFolder(coreProjectPath))
        {
            Debug.LogError("不存在主工程:" + coreProjectPath);
            return;
        }

        if (!EditorUtility.DisplayDialog("确认框", "是否确定同步到主工程？", "同步", "取消"))
        {
            return;
        }

        string curProjectPath = IOUtils.GetAbsPath(Application.dataPath + "/../");

        string curEditor = curProjectPath + "Assets/Editor/";
        string destEditor = coreProjectPath + "Assets/Editor/";
        IOUtils.SyncFolder(curEditor, destEditor, "", "", true);

        string curEditorEx = curProjectPath + "Assets/EditorEx/";
        string destEditorEx = coreProjectPath + "Assets/EditorEx/";
        IOUtils.SyncFolder(curEditorEx, destEditorEx, "", "", true);

        string curPlugins = curProjectPath + "Assets/Plugins/";
        string destPlugins = coreProjectPath + "Assets/Plugins/";
        IOUtils.SyncFolder(curPlugins, destPlugins, "", "", true);

        //resources
        string curResourcesLog = curProjectPath + "Assets/Resources/log";
        string destResourcesLog = coreProjectPath + "Assets/Resources/log";
        IOUtils.SyncFolder(curResourcesLog, destResourcesLog, "", "", true);

        string curResourcesMaterial = curProjectPath + "Assets/Resources/material";
        string destResourcesMaterial = coreProjectPath + "Assets/Resources/material";
        IOUtils.SyncFolder(curResourcesMaterial, destResourcesMaterial, "", "", true);

        string curResourcesStartWindow = curProjectPath + "Assets/Resources/start_window";
        string destResourcesStartWindow = coreProjectPath + "Assets/Resources/start_window";
        IOUtils.SyncFolder(curResourcesStartWindow, destResourcesStartWindow, "", "", true);

        string curResourcesUrp = curProjectPath + "Assets/Resources/urp";
        string destResourcesUrp = coreProjectPath + "Assets/Resources/urp";
        IOUtils.SyncFolder(curResourcesUrp, destResourcesUrp, "", "", true);

        string curResourcesShader = curProjectPath + "Assets/Res/shader/builtin";
        string destResourcesShader = coreProjectPath + "Assets/Resources/shader";
        IOUtils.SyncFolder(curResourcesShader, destResourcesShader, "", "", true);
        //


        string curScenes = curProjectPath + "Assets/Scenes/";
        string destScenes = coreProjectPath + "Assets/Scenes/";
        IOUtils.SyncFolder(curScenes, destScenes, "", "", true);

        string curScripts = curProjectPath + "Assets/Scripts/";
        string destScripts = coreProjectPath + "Assets/Scripts/";
        IOUtils.SyncFolder(curScripts, destScripts, "", "", true);

        string curPackages = curProjectPath + "Packages";
        string destPackages = coreProjectPath + "Packages";
        IOUtils.SyncFolder(curPackages, destPackages, "", "", true);

        string curPackagesEx = curProjectPath + "PackagesEx";
        string destPackagesEx = coreProjectPath + "PackagesEx";
        IOUtils.SyncFolder(curPackagesEx, destPackagesEx, "", "", true);

        string curXLuaEditor = curProjectPath + "Assets/XLua/Editor/";
        string destXLuaEditor = coreProjectPath + "Assets/XLua/Editor/";
        IOUtils.SyncFolder(curXLuaEditor, destXLuaEditor, "", "", true);

        string curXLuaCustom = curProjectPath + "Assets/XLua/Custom/";
        string destXLuaCustom = coreProjectPath + "Assets/XLua/Custom/";
        IOUtils.SyncFolder(curXLuaCustom, destXLuaCustom, "", "", true);
        IOUtils.CopyFile(curProjectPath + "Assets/XLua/Custom.meta", coreProjectPath + "Assets/XLua/Custom.meta");

        string curXLuaSrc = curProjectPath + "Assets/XLua/Src/";
        string destXLuaSrc = coreProjectPath + "Assets/XLua/Src/";
        IOUtils.SyncFolder(curXLuaSrc, destXLuaSrc, "", "", true);

        string cur3rd = curProjectPath + "Assets/3rd";
        string dest3rd = coreProjectPath + "Assets/3rd/";
        IOUtils.SyncFolder(cur3rd, dest3rd, "", "", true);



        string curWebGLTemplates = curProjectPath + "Assets/WebGLTemplates/";
        string destWebGLTemplates = coreProjectPath + "Assets/WebGLTemplates/";
        IOUtils.SyncFolder(curWebGLTemplates, destWebGLTemplates, "", "", true);
        IOUtils.CopyFile(curProjectPath + "Assets/WebGLTemplates.meta", coreProjectPath + "Assets/WebGLTemplates.meta");

        string curWX_WASM_SDK = curProjectPath + "Assets/WX-WASM-SDK/";
        string destWX_WASM_SDK = coreProjectPath + "Assets/WX-WASM-SDK/";
        IOUtils.SyncFolder(curWX_WASM_SDK, destWX_WASM_SDK, "", "", true);
        IOUtils.CopyFile(curProjectPath + "Assets/WX-WASM-SDK.meta", coreProjectPath + "Assets/WX-WASM-SDK.meta");


        string curPurets = curProjectPath + "Assets/Purets/";
        string destPurets = coreProjectPath + "Assets/Purets/";
        IOUtils.SyncFolder(curPurets, destPurets, "", "", true);
        IOUtils.CopyFile(curProjectPath + "Assets/Purets.meta", coreProjectPath + "Assets/Purets.meta");

        IOUtils.CopyFile(curProjectPath + "Assets/link.xml", coreProjectPath + "Assets/link.xml");
        IOUtils.CopyFile(curProjectPath + "Assets/link.xml.meta", coreProjectPath + "Assets/link.xml.meta");

        Debug.Log(string.Format("同步到主工程完成:{0} => {1}", curProjectPath, coreProjectPath));
    }


    [MenuItem("工具库/同步/同步工具到资源同步工程", false, 106)]
    static private void SyncAssetsSyncEditor()
    {
        string srcFolder = IOUtils.GetAbsPath(Application.dataPath + "/Editor/ImportAsset/");
        string destFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Editor/ImportAsset/");
        if (!IOUtils.ExistFolder(srcFolder))
        {
            Debug.LogError("不存src目录:" + srcFolder);
            return;
        }
        IOUtils.SyncFolder(srcFolder, destFolder, "", "", true);


        srcFolder = IOUtils.GetAbsPath(Application.dataPath + "/Editor/ImportAssetSetting/");
        destFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Editor/ImportAssetSetting/");
        if (!IOUtils.ExistFolder(srcFolder))
        {
            Debug.LogError("不存src目录:" + srcFolder);
            return;
        }
        IOUtils.SyncFolder(srcFolder, destFolder, "", "", true);

        srcFolder = IOUtils.GetAbsPath(Application.dataPath + "/Scripts/Common/");
        destFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Scripts/Common/");
        if (!IOUtils.ExistFolder(srcFolder))
        {
            Debug.LogError("不存src目录:" + srcFolder);
            return;
        }
        IOUtils.SyncFolder(srcFolder, destFolder, "", "", true);

        srcFolder = IOUtils.GetAbsPath(Application.dataPath + "/Plugins/");
        destFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Plugins/");
        if (!IOUtils.ExistFolder(srcFolder))
        {
            Debug.LogError("不存src目录:" + srcFolder);
            return;
        }
        IOUtils.SyncFolder(srcFolder, destFolder, "", "", true);


        Debug.Log("同步完成");
        //Debug.Log(string.Format("同步模型完成:{0} => {1}", srcFolder, destFolder));
    }



    [MenuItem("工具库/同步/同步UI到资源同步工程", false, 106)]
    static private void SyncUIToAssetsSyncEditor()
    {
        string srcPrefabFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/ui/prefab/");
        string destPrefabFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Res/ui/prefab/");
        if (!IOUtils.ExistFolder(srcPrefabFolder))
        {
            Debug.LogError("不存src prefab目录:" + srcPrefabFolder);
            return;
        }
        IOUtils.SyncFolder(srcPrefabFolder, destPrefabFolder, "", "", true);


        string srcTexFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/ui/texture/");
        string destTexFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Res/ui/texture/");
        if (!IOUtils.ExistFolder(srcTexFolder))
        {
            Debug.LogError("不存src texture目录:" + srcTexFolder);
            return;
        }
        IOUtils.SyncFolder(srcTexFolder, destTexFolder, "", "", true);


        string srcIconFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/ui/icon/");
        string destIconFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Res/ui/icon/");
        if (!IOUtils.ExistFolder(srcIconFolder))
        {
            Debug.LogError("不存src icon目录:" + srcIconFolder);
            return;
        }
        IOUtils.SyncFolder(srcIconFolder, destIconFolder, "", "", true);

        string srcSingleFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/ui/single/");
        string destSingleFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Res/ui/single/");
        if (!IOUtils.ExistFolder(srcSingleFolder))
        {
            Debug.LogError("不存src single目录:" + srcSingleFolder);
            return;
        }
        IOUtils.SyncFolder(srcSingleFolder, destSingleFolder, "", "", true);

        string srcMixedFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/ui/mixed/");
        string destMixedFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Res/ui/mixed/");
        if (!IOUtils.ExistFolder(srcMixedFolder))
        {
            Debug.LogError("不存src mixed目录:" + srcMixedFolder);
            return;
        }
        IOUtils.SyncFolder(srcMixedFolder, destMixedFolder, "", "", true);


        string srcFontFolder = IOUtils.GetAbsPath(Application.dataPath + "/Things/font/");
        string destFontFolder = IOUtils.GetAbsPath(Application.dataPath + "/../../../trunk/assets_sync/Assets/Res/font/");
        if (!IOUtils.ExistFolder(srcFontFolder))
        {
            Debug.LogError("不存src font目录:" + srcFontFolder);
            return;
        }
        IOUtils.SyncFolder(srcFontFolder, destFontFolder, "", "", true);


        Debug.Log("同步完成");
        //Debug.Log(string.Format("同步模型完成:{0} => {1}", srcFolder, destFolder));
    }
}
