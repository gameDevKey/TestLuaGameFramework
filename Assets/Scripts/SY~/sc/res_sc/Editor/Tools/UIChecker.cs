using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class UIChecker
{
    private static string ui_path = Application.dataPath + "/Things/ui/texture";
    private static string icon_path = Application.dataPath + "/IconOrigin";

    private static List<string> fileNames = new List<string>();

    [MenuItem("Tools/UICheck", false, 130)]
    public static void Check()
    {
        fileNames.Clear();
        SearchDir(ui_path);
        foreach (var file in fileNames)
        {
            string name = file.Replace(Application.dataPath, "Assets").Replace("\\", "/");
            TextureImporter importer = AssetImporter.GetAtPath(name) as TextureImporter;
            string[] args = name.Split('/');
            if (args != null && args.Length >= 5)
            {
                if (importer != null && (importer.spritePackingTag != args[4] || importer.mipmapEnabled || importer.spritePixelsPerUnit != 100))
                {
                    importer.mipmapEnabled = false;
                    importer.isReadable = true;
                    importer.spritePackingTag = args[4];
                    importer.textureType = TextureImporterType.Sprite;
                    importer.spriteImportMode = SpriteImportMode.Single;
                    importer.anisoLevel = 0;
                    importer.spritePixelsPerUnit = 100;
                    AssetDatabase.ImportAsset(name);
                }
            }
        }

        fileNames.Clear();
        SearchDir(icon_path);
        foreach (var file in fileNames)
        {
            string file_name = Path.GetFileNameWithoutExtension(file);
            string name = file.Replace(Application.dataPath, "Assets").Replace("\\", "/");
            TextureImporter importer = AssetImporter.GetAtPath(name) as TextureImporter;
            if (importer != null && (importer.textureType != TextureImporterType.Sprite || importer.spritePixelsPerUnit != 100))
            {
                importer.mipmapEnabled = false;
                importer.isReadable = true;
                importer.textureType = TextureImporterType.Sprite;
                importer.anisoLevel = 0;
                AssetDatabase.ImportAsset(name);
            }
        }

        Debug.Log("UI贴图格式化完成!");
    }

    private static void SearchDir(string path)
    {
        string[] dirs = Directory.GetDirectories(path);
        string[] files = Directory.GetFiles(path);

        foreach (var fs in files)
        {
            if (fs.EndsWith(".png") || fs.EndsWith(".tga") || fs.EndsWith(".psd"))
            {
                fileNames.Add(fs);
            }
        }

        foreach (var dir in dirs)
        {
            SearchDir(dir);
        }
    }
}
