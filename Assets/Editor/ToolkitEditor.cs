using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using System.Text;

public class ToolkitEditor
{
    [MenuItem("Toolkit/复制路径 &c")]
    static void CopyPathToClipboard()
    {
        string targetPath = "";
        var obj = Selection.activeObject;
        if(EditorUtility.IsPersistent(obj))
        {
            // 磁盘资源
            var guids = Selection.assetGUIDs;
            targetPath = AssetDatabase.GUIDToAssetPath(guids[0]);
        }
        else
        {
            // 场景资源
            var go = obj as GameObject;
            if( go == null )
            {
                Debug.LogError("未知资源:"+obj);
                return;
            }
            StringBuilder paths = new StringBuilder();
            Transform parent = go.transform;
            while(parent!=null)
            {
                paths.Insert(0,parent.name);
                if(parent.GetComponent<Canvas>()!=null)
                    break;
                paths.Insert(0,"/");
                parent = parent.parent;
            }
            targetPath = paths.ToString();
        }
        UnityEngine.GUIUtility.systemCopyBuffer = targetPath;
        Debug.Log("已复制路径:"+targetPath);
    }
}
