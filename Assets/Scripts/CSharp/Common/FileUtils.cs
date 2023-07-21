using System;
using System.IO;
using UnityEngine;

[XLua.LuaCallCSharp]
public class FileUtils
{
    public static FileInfo[] GetAllFile(string dir, string pattern)
    {
        if (!Directory.Exists(dir))
            return null;
        DirectoryInfo info = new DirectoryInfo(dir);
        return info.GetFiles(pattern);
    }

    public static string GetCurrentDir()
    {
        return Application.dataPath;
    }

    public static void CopyDir(string sourceDir, string targetDir, Func<FileInfo, bool> fileFilter = null, Func<FileInfo, string> nameGetter = null)
    {
        DirectoryInfo source = new DirectoryInfo(sourceDir);
        if (!source.Exists) return;

        DirectoryInfo target = new DirectoryInfo(targetDir);
        FileInfo[] files = source.GetFiles();

        for (int i = 0; i < files.Length; i++)
        {
            if (fileFilter == null || !fileFilter.Invoke(files[i]))
            {
                if(!target.Exists) target.Create();
                string newName = nameGetter != null ? nameGetter(files[i]) : files[i].Name;
                string newPath = FormatFilePath(target.FullName + @"\" + newName);
                File.Copy(files[i].FullName, newPath, true);
            }
        }

        DirectoryInfo[] dirs = source.GetDirectories();
        for (int j = 0; j < dirs.Length; j++)
        {
            CopyDir(dirs[j].FullName, FormatFilePath(target.FullName + @"\" + dirs[j].Name), fileFilter, nameGetter);
        }
    }

    public static string FormatFilePath(string filePath)
    {
        return filePath.Replace("\\", "/").Replace("//", "/");
    }
}
