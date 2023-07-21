using UnityEditor;
using UnityEngine;
using System.IO;

public abstract class BuildToolBase : EditorWindow
{
    private const int labelWidth = 200;

    public abstract void Build();

    protected BuildDataObject DataObject;
    protected string DataObjectPath;

    protected void Init(string objName)
    {
        DirectoryInfo target = new DirectoryInfo(BuildConfig.BUILD_OBJ_DIR_PATH);
        if(!target.Exists) target.Create();
        DataObjectPath = BuildConfig.BUILD_OBJ_DIR_PATH+objName+".asset";
        DataObject = GetDataObject();
    }

    public BuildDataObject GetDataObject()
    {
        return AssetDatabase.LoadAssetAtPath<BuildDataObject>(DataObjectPath);
    }

    public BuildDataObject CreateDataObject()
    {
        BuildDataObject instance = CreateInstance<BuildDataObject>();
        AssetDatabase.CreateAsset(instance, DataObjectPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        return instance;
    }

    public void DrawDataObjectArea()
    {
        if (DataObject == null)
        {
            DrawButton("创建", () =>
            {
                DataObject = CreateDataObject();
            },
            "请创建数据集");
        }
        else
        {
            EditorGUILayout.BeginHorizontal();
            DrawLabel("数据集");
            EditorGUILayout.ObjectField(DataObject, typeof(BuildDataObject), false);
            EditorGUILayout.EndHorizontal();
        }
    }

    public void DrawButton(string btn, System.Action callback, string title = null)
    {
        EditorGUILayout.BeginHorizontal();
        if (!string.IsNullOrEmpty(title))
            DrawLabel(title);
        if (GUILayout.Button(btn))
        {
            callback();
        }
        EditorGUILayout.EndHorizontal();
    }

    public void DrawLabel(string label)
    {
        GUILayout.Label(label, EditorStyles.boldLabel, GUILayout.Width(labelWidth));
    }
}