using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;
using UnityEditor;
using System.Text.RegularExpressions;
using System.Reflection;
using System.IO;

using SLua;

public class LuaClassScanner {

    public Regex classRegex1 = new Regex(@"^\s*(\w+)\s*=\s*(\w+)\s+or\s+(BaseClass|{)", RegexOptions.IgnoreCase);
    public Regex classRegex2 = new Regex(@"^\s*(\w+)\s*=\s*{", RegexOptions.IgnoreCase);
    public Regex dataRegex = new Regex(@"^\s*Config.(\w+)\s*=\s*Config.(\w+)\s+or\s+{}", RegexOptions.IgnoreCase);

    public Dictionary<string, string> classToFiles = new Dictionary<string, string>();
    public Dictionary<string, string> dataToFiles = new Dictionary<string, string>();
    public Dictionary<string, int> moduleMappings = new Dictionary<string, int>();
    public Dictionary<string, string> classToModules = new Dictionary<string, string>();


    private string luaMapName = "mapping.lua";

    public LuaClassScanner()
    {
    }

    public static void ScanAndWriteFile(string path)
    {
        LuaClassScanner luaScanner = new LuaClassScanner();
        string[] names = Directory.GetFiles(path, "*.lua", SearchOption.AllDirectories);
        foreach (string name in names)
        {
            luaScanner.ScanFile(name.Replace("\\", "/"));
        }
        luaScanner.WriteFile();
    }

    public void WriteFile()
    {
        string fileName = "Assets/lua/" + luaMapName;
        StringBuilder sb = new StringBuilder();
        sb.AppendLine("ClassToFile = {}");
        foreach (var v in classToFiles)
        {
            sb.AppendLine("ClassToFile[\"" + v.Key + "\"] = \"" + v.Value + "\"");
        }

        sb.AppendLine();
        sb.AppendLine("DataToFile = {}");
        foreach (var v in dataToFiles)
        {
            sb.AppendLine("DataToFile[\"" + v.Key + "\"] = \"" + v.Value + "\"");
        }

        sb.AppendLine();
        sb.AppendLine("ClassToModule = {}");
        foreach (var v in classToModules)
        {
            sb.AppendLine("ClassToModule[\"" + v.Key + "\"] = \"" + v.Value + "\"");
        }

        sb.AppendLine();
        sb.AppendLine("ModuleMapping = ModuleMapping or {}");
        foreach (var v in moduleMappings)
        {
            sb.AppendLine("ModuleMapping[\"" + v.Key + "\"] = " + v.Value.ToString());
        }

        File.WriteAllText(fileName, sb.ToString());
        AssetDatabase.ImportAsset(fileName);
    }

    public void ScanFile(string file)
    {
        if (file != null && file.Equals("mapping"))
        {
            return;
        }
        if (file.StartsWith("Assets/lua/data"))
        {
            ScanFileByStream(file, file.Replace("Assets/lua/", "").Replace(".lua", ""));
        }
        else
        {
            ScanFileByFile(file, file.Replace("Assets/lua/", "").Replace(".lua", ""));
        }
    }

    public void ScanFileByFile(string file, string cpath) 
    {
        string fileName = IOUtils.GetFileName(file);
        if (fileName[0] >= 'A' && fileName[0] <= 'Z')
        {
            classToFiles.Add(fileName, cpath);

            if (cpath.StartsWith("module/"))
            {
                string[] pathInfo = cpath.Split("/"[0]);
                if (pathInfo.Length <= 2)
                {
                    return;
                }

                string modName = pathInfo[1];
                string modFacadeClass = "";
                string[] strArray = modName.Split('_');
                foreach (string c in strArray)
                {
                    modFacadeClass += c.Substring(0, 1).ToUpper() + c.Substring(1);
                }
                modFacadeClass += "Facade";

                if (!moduleMappings.ContainsKey(modFacadeClass))
                {
                    moduleMappings.Add(modFacadeClass, 0);
                }

                moduleMappings[modFacadeClass] += 1;
                classToModules[fileName] = modFacadeClass;
            }
        }
    }

    // 数据文件
    public void ScanFileByStream(string file, string cpath) 
    {
        string fileName = IOUtils.GetFileName(file);
        string configName = "";
        string[] strArray = fileName.Split('_');
        foreach (string c in strArray)
        {
            configName += c.Substring(0, 1).ToUpper() + c.Substring(1);
        }
        dataToFiles.Add(configName, cpath);
    }
}