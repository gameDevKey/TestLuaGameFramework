using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(UIRef))]
[DisallowMultipleComponent]
public class UIRefEditor : Editor
{
    private UIRef m_Target;
    private List<UIRefEditorStruct> uiRefStructs = new List<UIRefEditorStruct>();

    private void OnEnable()
    {
        m_Target = target as UIRef;

        foreach (var data in m_Target.Objects)
        {
            AddRef(data.Key, data.Value);
        }
    }

    public override void OnInspectorGUI()
    {
        foreach (var data in uiRefStructs)
        {
            if (!CheckValid(data))
            {
                return;
            }
            EditorGUILayout.BeginHorizontal();

            //修改Key
            if (data.TargetObj != null)
            {
                var newKey = EditorGUILayout.TextField(data.Key);
                if (!string.IsNullOrEmpty(newKey) && newKey != data.Key)
                {
                    ModifyKey(data, newKey);
                }
            }

            //修改组件类型
            if (data.TargetObj != null)
            {
                var newIndex = EditorGUILayout.Popup(data.TypeIndex, data.TypeStrList);
                if (newIndex != data.TypeIndex)
                {
                    data.TypeIndex = newIndex;
                    ModifyRef(data);
                }
            }

            //修改目标组件
            var newObj = EditorGUILayout.ObjectField(data.TargetObj, typeof(UnityEngine.Object), true);
            if (IsValidObject(data, newObj))
            {
                data.TargetObj = newObj;
                ModifyRef(data, newObj);
                RefreshTypeList(data);
            }

            if (GUILayout.Button("移除", GUILayout.Width(50)))
            {
                RemoveRef(data);
                EditorGUILayout.EndHorizontal();
                return;
            }
            EditorGUILayout.EndHorizontal();
        }

        if (GUILayout.Button("新增"))
        {
            AddRef();
        }
    }

    private void RefreshTypeList(UIRefEditorStruct data)
    {
        if (data.TargetObj == null) return;
        var sourceGo = GetSourceGameObject(data.TargetObj);
        if (sourceGo == null) return;
        data.TypeList = GetTypeList(sourceGo);
        data.TypeStrList = GetTypeStrList(data.TypeList);
        data.TypeIndex = 0;
        for (int i = 0; i < data.TypeList.Length; i++)
        {
            if (data.TargetObj == data.TypeList[i])
            {
                data.TypeIndex = i;
                break;
            }
        }
    }

    private bool CheckValid(UIRefEditorStruct data)
    {
        if (data == null)
        {
            Debug.LogError("UIRef数据丢失");
            return false;
        }
        if (!string.IsNullOrEmpty(data.Key))
        {
            if (data.RootObj == null)
            {
                Debug.LogError($"UIRef的GameObject丢失:{data.Key}");
                RemoveRef(data);
                return false;
            }
            if (data.TargetObj == null)
            {
                Debug.LogError($"UIRef的TargetObj丢失:{data.Key}");
                RemoveRef(data);
                return false;
            }
        }
        return true;
    }

    private GameObject GetSourceGameObject(UnityEngine.Object obj)
    {
        var gameObject = obj as GameObject;
        if (gameObject == null)
        {
            var cmp = obj as Component;
            gameObject = cmp?.gameObject;
        }
        return gameObject;
    }

    /// <summary>
    /// 保证新增组件为当前GameObject的子物体
    /// </summary>
    /// <param name="data"></param>
    /// <param name="newObj"></param>
    /// <returns></returns>
    private bool IsValidObject(UIRefEditorStruct data, UnityEngine.Object newObj)
    {
        if (newObj == null) return false;
        if (newObj == data.TargetObj) return false;
        var sourceGO = GetSourceGameObject(newObj);
        var trans = sourceGO?.transform;
        while (trans != null)
        {
            if (trans == data.RootObj.transform)
            {
                return true;
            }
            trans = trans.parent;
        }
        return false;
    }

    /// <summary>
    /// 要么是GameObject，要么是Component
    /// </summary>
    /// <param name="obj"></param>
    /// <returns></returns>
    private UnityEngine.Object[] GetTypeList(UnityEngine.GameObject obj)
    {
        var list = new List<UnityEngine.Object> { obj };
        list.AddRange(obj.GetComponents<Component>());
        var newlist = list.Where(val => val.GetType() != typeof(UIRef));
        return newlist.ToArray();
    }

    private string[] GetTypeStrList(UnityEngine.Object[] typeList)
    {
        List<string> result = new List<string>();
        foreach (var cmp in typeList)
        {
            var tpe = cmp.GetType();
            var names = tpe.ToString().Split(".");
            var name = names[names.Length - 1];
            result.Add(name);
        }
        return result.ToArray();
    }

    private void ModifyRef(UIRefEditorStruct data, UnityEngine.Object newObj = null)
    {
        if (newObj == null)
            newObj = data.TypeList[data.TypeIndex];
        data.TargetObj = newObj;
        data.Key = m_Target.ModifyObject(data.Key, newObj);
        Debug.Log($"修改:{data.Key}-->{newObj} index:{data.TypeIndex}");
    }

    private void ModifyKey(UIRefEditorStruct data, string newKey)
    {
        var lastKey = data.Key;
        data.Key = m_Target.ModifyKey(data.Key, newKey);
        Debug.Log($"修改Key:{lastKey}-->{data.Key}");
    }

    private void AddRef(string key = "", UnityEngine.Object obj = null)
    {
        var sc = new UIRefEditorStruct();
        sc.Key = key;
        sc.TargetObj = obj;
        sc.RootObj = m_Target.gameObject;
        RefreshTypeList(sc);
        uiRefStructs.Add(sc);
        Debug.Log($"添加:{sc.Key} obj:{sc.TargetObj} index:{sc.TypeIndex}");
    }

    private void RemoveRef(UIRefEditorStruct data)
    {
        uiRefStructs.Remove(data);
        m_Target.RemoveObject(data.Key);
        Debug.Log($"移除{data.Key}");
    }
}

public class UIRefEditorStruct
{
    public string Key;
    public int TypeIndex;
    public UnityEngine.Object TargetObj;
    public UnityEngine.GameObject RootObj;
    public string[] TypeStrList;
    public UnityEngine.Object[] TypeList;
}
