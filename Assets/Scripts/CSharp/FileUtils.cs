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
}
