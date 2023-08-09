using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
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
        base.OnInspectorGUI();


        foreach (var data in uiRefStructs)
        {
            if (!CheckValid(data))
            {
                return;
            }
            EditorGUILayout.BeginHorizontal();
            if (data.GameObject == null)
            {
                data.GameObject = (GameObject)EditorGUILayout.ObjectField(data.GameObject, typeof(GameObject), true);
            }
            else
            {
                var newKey = EditorGUILayout.TextField(data.Key);
                if (!string.IsNullOrEmpty(newKey) && newKey != data.Key)
                {
                    ModifyKey(data, newKey);
                    EditorGUILayout.EndHorizontal();
                    continue;
                }
                data.TypeList ??= GetTypeList(data.GameObject);
                data.TypeStrList ??= GetTypeStrList(data.TypeList);
                var newIndex = EditorGUILayout.Popup(data.TypeIndex, data.TypeStrList);
                if (newIndex != data.TypeIndex)
                {
                    data.TypeIndex = newIndex;
                    ModifyRef(data);
                    EditorGUILayout.EndHorizontal();
                    continue;
                }
                var newObj = EditorGUILayout.ObjectField(data.TargetObj, data.TargetObj?.GetType(), true);
                if (newObj != data.TargetObj && IsValidObject(data, newObj))
                {
                    data.TargetObj = newObj;
                    ModifyRef(data, newObj);
                    EditorGUILayout.EndHorizontal();
                    continue;
                }
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

    private bool CheckValid(UIRefEditorStruct data)
    {
        if (data == null)
        {
            Debug.LogError("UIRef数据丢失");
            return false;
        }
        if (!string.IsNullOrEmpty(data.Key))
        {
            if (data.GameObject == null)
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

    /// <summary>
    /// 保证新增组件为当前GameObject的子物体
    /// </summary>
    /// <param name="data"></param>
    /// <param name="newObj"></param>
    /// <returns></returns>
    private bool IsValidObject(UIRefEditorStruct data, UnityEngine.Object newObj)
    {
        var gameObject = newObj as GameObject;
        if (gameObject == null)
        {
            var cmp = newObj as Component;
            gameObject = cmp.gameObject;
        }
        while (gameObject != null)
        {
            if (gameObject == data.GameObject)
            {
                return true;
            }
            gameObject = gameObject.transform.parent.gameObject;
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
        sc.TypeIndex = -1;
        if (obj != null)
        {
            sc.GameObject = obj as GameObject;
            if (sc.GameObject == null)
            {
                var cmp = obj as Component;
                sc.GameObject = cmp.gameObject;
            }
            sc.TypeList = GetTypeList(sc.GameObject);
            sc.TypeStrList = GetTypeStrList(sc.TypeList);
            for (int i = 0; i < sc.TypeList.Length; i++)
            {
                if (sc.TargetObj == sc.TypeList[i])
                {
                    sc.TypeIndex = i;
                    break;
                }
            }
        }
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
    public UnityEngine.GameObject GameObject;
    public string[] TypeStrList;
    public UnityEngine.Object[] TypeList;
}
