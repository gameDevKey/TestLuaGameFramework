using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Text.RegularExpressions;

public class UITextureName
{
    [MenuItem("Assets/工具/UI/自动命名UI贴图", false, 100)]
    static private void AutoUITextureName()
    {
        string[] selectPaths = Selection.assetGUIDs;
        if (selectPaths.Length <= 0)
        {
            Debug.LogError("自动命名UI贴图异常，没有选择目录");
            return;
        }

        string selectPath = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);
        string absPath = IOUtils.GetAbsPath(Application.dataPath + "/../" + selectPath);
        string absFolder = IOUtils.GetPathDirectory(absPath,false);

        string assetsFolder = "Assets/" + IOUtils.SubPath(absFolder, Application.dataPath);

        string folderName = Path.GetFileNameWithoutExtension(assetsFolder).ToLower();

        if (folderName[folderName.Length - 1] == '_')
        {
            Debug.LogError("文件夹不能以[ _ ]结尾:" + selectPath);
            return;
        }

        var pngList = AssetDatabase.FindAssets("t:Texture2D", new string[] { assetsFolder });

        Dictionary<int, string> existIds = new Dictionary<int, string>();
        List<string> renameList = new List<string>();

        int maxID = 0;

        for (int i = 0; i < pngList.Length; i++)
        {
            var texPath = AssetDatabase.GUIDToAssetPath(pngList[i]);
            string fileName = Path.GetFileNameWithoutExtension(texPath);

            string ext = Path.GetExtension(texPath);
            if (ext != ".png")
            {
                continue;
            }

            int splitIndex = fileName.LastIndexOf("_");

            string prefixName = splitIndex >= 0 ? fileName.Substring(0, splitIndex) : string.Empty;
            if (!string.IsNullOrEmpty(prefixName) && !prefixName.Equals("i18n"))
            {
                renameList.Add(texPath);
                continue;
            }

            string idStr = splitIndex != -1 ? fileName.Substring(splitIndex + 1, fileName.Length - splitIndex - 1) : fileName;
            if (!Regex.IsMatch(idStr, @"^[+-]?\d*$") || idStr.Equals(""))
            {
                renameList.Add(texPath);
                continue;
            }

            int id;
            bool isNum = int.TryParse(idStr, out id);
            if (!isNum)
            {
                renameList.Add(texPath);
            }
            else if(id > maxID)
            {
                maxID = id;
            }
        }

        for (int i = maxID+1; i < maxID + 1000; i++)
        {
            if (renameList.Count <= 0)
            {
                break;
            }

            AssetDatabase.RenameAsset(renameList[0], i.ToString());
            renameList.RemoveAt(0);
        }

        AssetDatabase.Refresh();
        Debug.Log("自动命名完成");
    }

    
    [MenuItem("Assets/工具/UI/取消多级目录", false, 100)]
    private static void MakeSingleContentAndRename()
    {
        //递归找到多级目录，并把所有图片存到一级目录
        //自动命名UI贴图

        string[] selectPaths = Selection.assetGUIDs;
        if (selectPaths.Length <= 0)
        {
            Debug.LogError("取消多级目录异常，没有选择目录");
            return;
        }
        if(selectPaths.Length > 1)
        {
            Debug.LogError("取消多级目录异常，不可多选目录");
            return;
        }

        string selectPath = AssetDatabase.GUIDToAssetPath(Selection.assetGUIDs[0]);
        string absPath = IOUtils.GetAbsPath(Application.dataPath + "/../" + selectPath);
        string absFolder = IOUtils.GetPathDirectory(absPath,false);
        string assetsFolder = "Assets/" + IOUtils.SubPath(absFolder, Application.dataPath);

        Debug.Log("尝试取消多级目录："+assetsFolder);

        MakeSingleContent(assetsFolder, assetsFolder);

        AssetDatabase.Refresh();

        Debug.Log("取消多级目录完成");
    }

    private static void MakeSingleContent(string dstFolderPath, string curFolderPath)
    {
        string[] folderPaths = Directory.GetDirectories(curFolderPath);
        var rootName = IOUtils.GetFileName(dstFolderPath);
        var prefix = dstFolderPath.Replace(rootName,"");
        foreach (var v in folderPaths)
        {
            var dstName = string.Format("{0}_{1}",rootName,IOUtils.GetFileName(v));
            var dstFolder = string.Format("{0}/{1}",prefix,dstName).Replace(@"\", "/");
            // Debug.LogFormat("创建文件夹{0}",dstFolder);
            IOUtils.CreateFolder(dstFolder);
        }
        AssetDatabase.Refresh();
        foreach (var v in folderPaths)
        {
            var dstName = string.Format("{0}_{1}",rootName,IOUtils.GetFileName(v));
            var dstFolder = string.Format("{0}/{1}",prefix,dstName).Replace(@"\", "/");
            foreach (var filePath in Directory.GetFiles(v))
            {
                var path1 = filePath;
                var fileName = IOUtils.GetFileNameByExt(filePath);
                var path2 = string.Format("{0}/{1}",dstFolder,fileName);
                // Debug.LogFormat("复制{0}到{1}",path1, path2);
                var result = AssetDatabase.MoveAsset(path1, path2);
                if(!string.IsNullOrEmpty(result))
                {
                    Debug.LogError(result);
                }
            }
            MakeSingleContent(dstFolderPath, v);
        }
        IOUtils.DeleteFolder(curFolderPath);
    }
}
