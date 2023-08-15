using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Text;
using System.Linq;
using System.Text.RegularExpressions;

public class EditorUtil
{
    private static Regex validCharRegex = new Regex(@"[\p{L}\p{N}_]+", RegexOptions.IgnoreCase);

    public static List<T> FindAssets<T>(string filter, string findPath) where T : UnityEngine.Object
    {
        List<T> assets = new List<T>();
        string[] allPath = AssetDatabase.FindAssets(filter, new string[] { findPath });
        for (int i = 0; i < allPath.Length; i++)
        {
            string path = AssetDatabase.GUIDToAssetPath(allPath[i]);
            var obj = AssetDatabase.LoadAssetAtPath<T>(path);
            assets.Add(obj);
        }
        return assets;
    }

    public static string GetValidName(string name)
    {
        StringBuilder sb = new StringBuilder();
        foreach (char c in name)
        {
            if (validCharRegex.IsMatch(c.ToString()))
            {
                sb.Append(c);
            }
            else
            {
                sb.Append("_");
            }
        }
        return sb.ToString();
    }
}
