using System.Linq;
using System.IO;
using UnityEditor;
using UnityEditor.AddressableAssets;
using UnityEditor.AddressableAssets.Settings;
using UnityEngine;
using System;

public class AddressableGroupSetter
{
    static AddressableAssetSettings Settings
    {
        get { return AddressableAssetSettingsDefaultObject.Settings; }
    }

    //TODO 配置化
    public static void InitGroups()
    {
        ResetGroup<GameObject>("Lua", BuildConfig.LUA_OUTPUT_PATH, "t:textasset", assetPath =>
        {
            var path = assetPath.Replace(BuildConfig.LUA_OUTPUT_PATH + "/", "")
                .Replace("/", ".")
                .Replace(".lua.txt", "");
            return path;
        });
        ResetGroup<GameObject>("UIPrefab", BuildConfig.UI_PREFAB_PATH, "t:prefab", assetPath =>
        {
            return BuildUtils.GetLastName(assetPath).Replace(".prefab","");
        });
        ResetGroup<GameObject>("GamePrefab", BuildConfig.GAME_PREFAB_PATH, "t:prefab", assetPath =>
        {
            return BuildUtils.GetLastName(assetPath).Replace(".prefab","");
        });
    }


    /// <summary>
    /// 重置某分组
    /// </summary>
    /// <typeparam name="T">资源类型</typeparam>
    /// <param name="groupName">组名</param>
    /// <param name="assetFolder">资源目录</param>
    /// <param name="filter">过滤器：
    /// 若以t:开头，表示用unity的方式过滤;
    /// 若以f:开头，表示用windows的SearchPattern方式过滤;
    /// 若以r:开头，表示用正则表达式的方式过滤。</param>
    /// <param name="getAddress">通过 asset path 得到地址名</param>
    static void ResetGroup<T>(string groupName, string assetFolder, string filter, Func<string, string> getAddress)
    {
        string[] assets = GetAssets(assetFolder, filter);
        AddressableAssetGroup group = CreateGroup<T>(groupName);
        foreach (var assetPath in assets)
        {
            string address = getAddress(assetPath);
            AddAssetEntry(group, assetPath, address);
        }
        //Debug.Log($"重建分组完成, 分组: {groupName}, 资源目录: {assetFolder}, 过滤器: {filter}, 资源数: {assets.Length}");
    }


    // 创建分组
    public static AddressableAssetGroup CreateGroup<T>(string groupName)
    {
        AddressableAssetGroup group = Settings.FindGroup(groupName);
        if (group == null)
            group = Settings.CreateGroup(groupName, false, false, false, null, typeof(T));
        Settings.AddLabel(groupName, false);
        return group;
    }


    // 给某分组添加资源
    static AddressableAssetEntry AddAssetEntry(AddressableAssetGroup group, string assetPath, string address)
    {
        string guid = AssetDatabase.AssetPathToGUID(assetPath);
        AddressableAssetEntry entry = AddressableAssetSettingsDefaultObject.Settings.FindAssetEntry(guid);

        // entry = group.entries.FirstOrDefault(e => e.guid == guid);
        if (entry == null)
        {
            entry = Settings.CreateOrMoveEntry(guid, group, false, false);
        }

        string[] labels = new string[entry.labels.Count];
        entry.labels.CopyTo(labels);
        for (int i = 0; i < labels.Length; i++)
        {
            entry.SetLabel(labels[i], false, true, false);
        }
        entry.address = address;
        entry.SetLabel(group.Name, true, false, false);

        return entry;
    }

    /// <summary>
    /// 获取指定目录的资源
    /// </summary>
    /// <param name="filter">过滤器：
    /// 若以t:开头，表示用unity的方式过滤;
    /// 若以f:开头，表示用windows的SearchPattern方式过滤;
    /// 若以r:开头，表示用正则表达式的方式过滤。</param>
    public static string[] GetAssets(string folder, string filter)
    {
        if (string.IsNullOrEmpty(folder))
            throw new ArgumentException("folder");
        if (string.IsNullOrEmpty(filter))
            throw new ArgumentException("filter");

        folder = folder.TrimEnd('/').TrimEnd('\\');


        string[] guids = AssetDatabase.FindAssets(filter, new string[] { folder });
        string[] paths = new string[guids.Length];
        for (int i = 0; i < guids.Length; i++)
            paths[i] = AssetDatabase.GUIDToAssetPath(guids[i]);
        return paths;
    }

    public static void FindDepencies(UnityEngine.Object obj)
    {
        SerializedObject targetObjectSO = new SerializedObject(obj);
        SerializedProperty sp = targetObjectSO.GetIterator();
        while (sp.NextVisible(true))
        {
            if (sp.propertyType == SerializedPropertyType.ObjectReference && sp.objectReferenceValue != null)
            {
                Debug.Log(sp.objectReferenceValue);
            }
        }
    }
}