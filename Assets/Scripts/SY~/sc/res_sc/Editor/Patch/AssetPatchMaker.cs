using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Linq;
using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using EditorTools.AssetBundle;
using EditorTools.UI;
using AssetFormatter;

namespace EditorTools.Patch {
    public class AssetPatchMaker {
        //不依赖其他资源的资源文件名后缀
        public static Regex UNSPLITABLE_FILE_PATH = new Regex(@"\.(png|tga|jpg|exr|psd|mp3|wav|ttf|json|anim|fbx|obj|shader|asset)", RegexOptions.IgnoreCase);
        //Shader和字体文件修改后，直接从字体和Shader的打包入口更新AssetBundle
        public static string POSTFIX_SHADER = ".shader";
        public static string POSTFIX_TTF = ".ttf";
        //代码文件不被认为是资源，代码文件不能放在Resource目录下
        public static string POSTFIX_CS = ".cs";
        public static string ROOT = "Assets/Things/";


        /// <summary>
        /// 比如UIPrefab依赖的图片变化了，Prefab没变化，打包会同时生成Prefab和图片的AssetBundle
        /// 但是作为只有图片AssetBundle作为差异化打包结果返回
        /// </summary>
        /// <returns></returns>
        [MenuItem ("Assets/MakePatch")]
        public static void MakePatch () {
            AssetPathHelper.buildTarget = EditorUserBuildSettings.activeBuildTarget;
            Make ();
        }

        [MenuItem ("Assets/MakePatchDataOnly")]
        public static void MakePatchDataOnly () {
            AssetPathHelper.buildTarget = EditorUserBuildSettings.activeBuildTarget;
            Make (true);
        }

        // 命令行
        public static void MakePatchCmd () {
            string platform = CommandLineReader.GetCustomArgument ("BuildTarget");
            AssetPathHelper.buildTarget = AssetPathHelper.GetBuildTarget (platform);
            Make ();
        }

        // 命令行
        public static void MakePatchDataOnlyCmd () {
            string platform = CommandLineReader.GetCustomArgument ("BuildTarget");
            AssetPathHelper.buildTarget = AssetPathHelper.GetBuildTarget (platform);
            Make (true);
        }

        public static void Make(bool isDataOnly = false) {
            if (!isDataOnly)
            {
                // 打包前设置压缩格式及资源格式
                TextureFormatter.FormatAll(false);
                UIChecker.Check();
            }

            AssetPathHelper.patchVersion = DateTime.Now.ToString ("yyyyMMddHHmmss");
            ResourcesMd5Computer resMd5 = new ResourcesMd5Computer();
            AssetDatabase.SaveAssets();
            resMd5.FindDiff();
            List<string> modifiedPathList = resMd5.assetResult;
            if (modifiedPathList.Count == 0 || isDataOnly)
            {
                Debug.Log("没有检测到任何被修改的文件，本次差异化打包生成的文件列表长度为0, 或者isDataOnly");
                // return;
            }
            else
            {
                Dictionary<string, List<string>> relierPathListDict = ConstructRelierPathListDict(GetAssetPathList(ROOT));
                Dictionary<string, List<string>> buildRelierPathListDict = GetRelierPathListDict(modifiedPathList, relierPathListDict);
                ReplaceUITextruePath(buildRelierPathListDict);
                Dictionary<string, List<string>> buildResult = AssetBundleExporter.BuildPatchAssets(buildRelierPathListDict);
            }
            List<string> luaList = new List<string>();
            List<string> dataList = new List<string>();
            List<string> mapList = new List<string>();
            foreach (string path in resMd5.newResMd5.Keys)
            {
                if (path.StartsWith("map/"))
                {
                    mapList.Add(path);
                }
                //else if (path.StartsWith("luadata/"))
                //{
                //    luaList.Add(path);
                //}
                //else if (path.StartsWith("lua/"))
                //{
                //    luaList.Add(path);
                //}
            }

            LuaScript patchScript;
            if (true)
            {
                LuaScript oldScript = new LuaScript();
                string path = AssetBuildStrategyManager.outputPath + "textures$business.folder";
                oldScript.LoadFrom(path);

                CopyLuaFile ("../lua", "Assets/lua");
                CopyLuaFile("../data", "Assets/lua/data");
                LuaClassScanner.ScanAndWriteFile("Assets/lua");
                
                LuaScript newScript = new LuaScript();
                newScript.LoadFromDir("Assets/lua");
                newScript.SaveFile(path, long.Parse(AssetPathHelper.patchVersion));

                patchScript = LuaScript.MakePatch(oldScript, newScript);

                //LuaAssetBuilder luaBuilder = new LuaAssetBuilder (luaList, "textures$business.folder");
                //luaBuilder.Build (long.Parse(AssetPathHelper.patchVersion));
            }



            if (resMd5.mapResult.Count > 0)
            {
                CopyMapFile(resMd5.mapResult);
                MapAssetBuilder mapBuilder = new MapAssetBuilder(resMd5.mapResult);
                mapBuilder.Build();
            }
            // foreach (string s in modifiedPathList) {
            //     Debug.Log("修改文件： " + s);
            // }

            // CopyToPatchFolder(buildResult);
            Debug.Log("修改_build_detail.json文件");
            resMd5.WriteMd5(resMd5.newResMd5, resMd5.md5Record, isDataOnly);

            BaseSettingHandle baseSetting = new BaseSettingHandle (AssetPathHelper.patchVersion);
            baseSetting.Write ();
            BuildPatchInfo(patchScript);
            Debug.Log("DONE!");
        }

        private static void CopyToPatchFolder(Dictionary<string, List<string>> buildResult) {
            string patchPath = AssetBuildStrategyManager.outputPath + "../" + AssetPathHelper.GetBuildTargetTxt() + "_patch/" + AssetPathHelper.GetPatchVersion() + "/";
            CreatePatchFolder(patchPath);
            StringBuilder log = new StringBuilder();
            HashSet<string> pathSet = new HashSet<string>();
            foreach (string k in buildResult.Keys) {
                Debug.Log("修改的资源：  " + k);
                log.Append(k);
                log.Append("\r\n");
                foreach (string s in buildResult[k]) {
                    log.Append(" ---- ");
                    log.Append(s);
                    log.Append("\r\n");
                    Debug.Log("    生成的AssetBundle Path: " + s);
                    if (pathSet.Contains(s) == false) {
                        pathSet.Add(s);
                        File.Copy(AssetBuildStrategyManager.outputPath + s, patchPath + s, true);
                    }
                }
            }
            File.Copy(AssetBuildStrategyManager.outputPath + "_resources.asset", patchPath + "_resources.asset", true);
            File.WriteAllText(patchPath + "_log.txt", log.ToString());
        }

        /// <summary>
        /// 将UIPrefab依赖的单张图片替换为合并图集后图集的路径，并且将其Value的RelierPathList合并
        /// </summary>
        /// <param name="relierPathListDict"></param>
        /// <returns></returns>
        private static void ReplaceUITextruePath(Dictionary<string, List<string>> relierPathListDict) {
            List<string> keyList = relierPathListDict.Keys.ToList<string>();
            foreach (string k in keyList) {
                if (k.Contains(UIPrefabProcessor.UI_TEXTURE_ROOT) == true) {
                    string atlasPath = AtlasGenerator.GetAtlasPath(k);
                    List<string> pathList = relierPathListDict[k];
                    for (int i = 0; i < pathList.Count; i++) {
                        if (pathList[i] == k) {
                            pathList[i] = atlasPath;
                        }
                    }
                    relierPathListDict.Remove(k);
                    if (relierPathListDict.ContainsKey(atlasPath) == false) {
                        relierPathListDict.Add(atlasPath, pathList);
                    } else {
                        relierPathListDict[atlasPath].AddRange(pathList);
                    }
                }
            }
        }

        /// <summary>
        /// 获取依赖了变化资源的资源列表
        /// Key为变化了的资源路径
        /// Value为依赖变化了的资源的资源的路径列表
        /// </summary>
        /// <param name="modifiedPathList"></param>
        /// <param name="relierPathListDict"></param>
        /// <returns></returns>
        private static Dictionary<string, List<string>> GetRelierPathListDict(List<string> modifiedPathList, Dictionary<string, List<string>> relierPathListDict) {
            Dictionary<string, List<string>> result = new Dictionary<string, List<string>>();
            foreach (string s in modifiedPathList) {
                if (relierPathListDict.ContainsKey(s) == true) {
                    result.Add(s, relierPathListDict[s]);
                }
            }
            return result;
        }

        /// <summary>
        /// 构建资源的逆向依赖关系表
        /// Key为资源路径，Value为依赖该资源的资源路径列表
        /// TODO:这里将对所有资源构建字典，随着资源增多消耗时间会增长，对《星辰》所有资源运行耗时78s，可以根据项目实际资源特点，深度优化
        /// </summary>
        /// <param name="assetPathList"></param>
        /// <returns></returns>
        private static Dictionary<string, List<string>> ConstructRelierPathListDict(List<string> assetPathList) {
            Dictionary<string, List<string>> result = new Dictionary<string, List<string>>();
            for (int i = 0; i < assetPathList.Count; i++) {
                string path = assetPathList[i];
                //不依赖其他资源的资源增加一条自己依赖自己的记录
                if (UNSPLITABLE_FILE_PATH.IsMatch(path) == true) {
                    AddDataToDict(result, path, path);
                } else {
                    string[] dependencies = AssetDatabase.GetDependencies(path);
                    foreach (string s in dependencies) {
                        if (s.Contains(POSTFIX_SHADER) == true
                            || s.Contains(POSTFIX_TTF) == true
                            || s.Contains(POSTFIX_CS) == true) {
                            continue;
                        }
                        AddDataToDict(result, s, path);
                    }
                }
            }
            return result;
        }

        private static void AddDataToDict(Dictionary<string, List<string>> dict, string key, string data){
            if (dict.ContainsKey(key) == false) {
                dict.Add(key, new List<string>() { data });
            } else {
                dict[key].Add(data);
            }
        }

        /// <summary>
        /// 获取所有资源路径列表，过滤掉Meta，cs，Lua，dll文件，可以在此处添加不需要处理的资源类型
        /// </summary>
        /// <param name="root"></param>
        /// <returns></returns>
        private static List<string> GetAssetPathList(string root) {
            List<string> result = Directory.GetFiles(root, "*.*", SearchOption.AllDirectories)
                                            .Where<string>(s => s.Contains(".meta") == false 
                                                                || s.Contains(".dll") == false 
                                                                || s.Contains(".cs") == false 
                                                                || s.Contains(".lua") == false)
                                            .ToList<string>();
            for (int i = 0; i < result.Count; i++) {
                result[i] = result[i].Replace("\\", "/");
            }
            return result;
        }

        private static void CreatePatchFolder(string path) {
            if (Directory.Exists(path) == false) {
                Directory.CreateDirectory(path);
            }
        }

        private static void BuildPatchInfo (LuaScript scriptPatch) {
            string folderRoot = AssetBuildStrategyManager.outputPath;
            string patchVersion = AssetPathHelper.GetPatchVersion ();
            List<VersionInfo> diffList = new List<VersionInfo> ();
            VersionHandle versionHandle = new VersionHandle (patchVersion);
            Dictionary<string, VersionInfo> newDict = versionHandle.ScanNewAsset();
            PatchListHandle patchHandle = new PatchListHandle ();
            patchHandle.Read ();
            string lastVersion = patchHandle.GetLastVersion ();
            if (lastVersion == null || lastVersion.Trim ().Length == 0) {
                foreach(VersionInfo info in newDict.Values) {
                    diffList.Add (info);
                }
            } else {
                Dictionary<string, VersionInfo> oldDict = versionHandle.ReadPatchVersion (lastVersion);
                foreach (VersionInfo info in newDict.Values) {
                    if (oldDict.ContainsKey (info.Path)) {
                        if (!oldDict[info.Path].Md5.Equals (info.Md5)) {
                            diffList.Add (info);
                        } else {
                            info.PatchVerion = oldDict[info.Path].PatchVerion;
                        }
                    } else {
                        diffList.Add (info);
                    }
                }
            }

            patchHandle.Write(patchVersion);
            versionHandle.WriteVersion (newDict);
            string patchPath = AssetBuildStrategyManager.outputPath + "../" + AssetPathHelper.GetBuildTargetTxt() + "_patch/" + AssetPathHelper.GetPatchVersion() + "/";
            CreatePatchFolder(patchPath);
            foreach(VersionInfo versionInfo in diffList) {
                File.Copy (folderRoot + versionInfo.Path, patchPath + versionInfo.Path, true);
            }

            if(scriptPatch != null)
            {
                string path = AssetBuildStrategyManager.outputPath + "../" + AssetPathHelper.GetBuildTargetTxt() + "_patch/" + AssetPathHelper.GetPatchVersion() + "/" + "textures$patch.folder";
                scriptPatch.SaveFile(path, long.Parse(patchVersion));


                LuaScript luascript = new LuaScript();
                luascript.LoadFrom(path);

            }
            File.WriteAllText(patchPath + "/_hotswap.lua", "function OnBeforeGameStart() end");
            //File.Copy(folderRoot + "_version_text.json", patchPath + "_version_text.json", true);
            File.Copy (folderRoot + "_version.json", patchPath + "_version.json", true);
            File.Copy (folderRoot + "_resources.asset", patchPath + "_resources.asset", true);
            File.Copy (folderRoot + "_base_setting.json", patchPath + "_base_setting.json", true);
            AssetDatabase.Refresh();
        }

        public static void Compress (string inFile, string outFile) {
            Compress (File.ReadAllBytes (inFile), outFile);
        }

        public static void Compress (byte[] bytes, string outFile) {
            File.WriteAllBytes (outFile, Compress (bytes));
        }

        public static byte[] Compress (byte[] bytes) {
            var coder = new SevenZip.Compression.LZMA.Encoder ();
            var input = new MemoryStream (bytes);
            var stream = new MemoryStream ();

            coder.WriteCoderProperties (stream);
            stream.Write (System.BitConverter.GetBytes (input.Length), 0, 8);
            coder.Code (input, stream, input.Length, -1, null);
            byte[] output = stream.ToArray ();
            input.Close ();
            stream.Close ();
            return output;
        }

        /// <summary>
        /// 解压缩文件
        /// <param name="inFile">输入文件</param>
        /// <param name="outFile">输出文件</param>
        /// </summary>
        public static void Decompress (string inFile, string outFile) {
            Decompress (File.ReadAllBytes (inFile), outFile);
        }

        /// <summary>
        /// 解压缩字节数组
        /// <param name="bytes">压缩内容</param>
        /// <param name="outFile">输出文件</param>
        /// </summary>
        public static void Decompress (byte[] bytes, string outFile) {
            File.WriteAllBytes (outFile, Decompress (bytes));
        }

        /// <summary>
        /// 解压缩字节数组
        /// <param name="bytes">压缩内容</param>
        /// </summary>
        public static byte[] Decompress (byte[] bytes) {
            var coder = new SevenZip.Compression.LZMA.Decoder ();
            var input = new MemoryStream (bytes);
            var stream = new MemoryStream ();

            var properties = new byte[5];
            input.Read (properties, 0, 5);
            var fileLengthBytes = new byte[8];
            input.Read (fileLengthBytes, 0, 8);
            long fileLength = BitConverter.ToInt64 (fileLengthBytes, 0);
            coder.SetDecoderProperties (properties);
            coder.Code (input, stream, input.Length, fileLength, null);
            var output = stream.ToArray ();

            input.Close ();
            stream.Close ();

            return output;
        }

        private static void CopyLuaFile (string source, string target) {
            DirectoryInfo dir = new DirectoryInfo (source);
            FileInfo[] files = dir.GetFiles ();
            DirectoryInfo[] subDirs = dir.GetDirectories ();

            if (Directory.Exists(target))
            {
                Directory.Delete(target, true);
                Directory.CreateDirectory(target);
            }

            foreach (FileInfo fileInfo in files) {
                string fileName = fileInfo.Name;
                string extName = fileInfo.Extension;
                if (extName.Equals (".lua")) {
                    string newName = fileName; //.Replace (".lua", ".txt");
                    string dstName = target + "/" + newName;
                    string dstDir = Path.GetDirectoryName(dstName);
                    if (!Directory.Exists(dstDir))
                    {
                        Directory.CreateDirectory(dstDir);
                    }
                    //Debug.Log(source + "/" + fileName + "<>" + target + "/" + newName);
                    File.Copy (source + "/" + fileName, dstName, true);
                }
                else if(extName.Equals(".pb"))
                {
                    string newName = fileName; //.Replace (".lua", ".txt");
                    string dstName = target + "/" + newName.Replace(".pb",".lua");
                    string dstDir = Path.GetDirectoryName(dstName);
                    if (!Directory.Exists(dstDir))
                    {
                        Directory.CreateDirectory(dstDir);
                    }
                    //Debug.Log(source + "/" + fileName + "<>" + target + "/" + newName);
                    File.Copy (source + "/" + fileName, dstName, true);
                }
            }

            foreach (DirectoryInfo dirInfo in subDirs) {
                string folder = dirInfo.Name;
                CopyLuaFile (source + "/" + folder, target + "/" + folder);
            }
        }

        private static void CopyMapFile(List<string> list) {
            if (!Directory.Exists("Assets/map")) {
                Directory.CreateDirectory("Assets/map");
            }
            string srcRoot = "../data";
            foreach (string mapPath in list) {
                string tp = "Assets/" + mapPath.Replace(".map", ".bytes");
                File.Copy(srcRoot + "/" + mapPath, tp, true);
                AssetDatabase.ImportAsset(tp);
            }
        }

        public static string GetFileLastWriteTime(string path) {
            FileInfo fileInfo = new FileInfo(path);
            return fileInfo.LastWriteTime.ToString("yyyyMMddHHmmss");
        }
    }
}

