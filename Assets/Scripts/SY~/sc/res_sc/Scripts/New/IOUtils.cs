using System;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using System.Collections.Generic;
using System.Collections;
using System.IO;
using System.Text;
using MiniJSON;
using System.Runtime.InteropServices;

public class IOUtils
{
#if UNITY_WEBGL && !UNITY_EDITOR
    [DllImport("__Internal")]
    private static extern void SyncDB();
#endif

    public static string GetExt(string path)
    {
        string ext = System.IO.Path.GetExtension(path);
        return ext.Equals(string.Empty) ? ext : ext.Remove(0, 1);
    }

    public static string GetFileName(string file)
    {
        return Path.GetFileNameWithoutExtension(file);
    }

    public static string GetFileNameByExt(string file)
    {
        return Path.GetFileName(file);
    }

    public static string GetFolderName(string path)
    {
        if(path.EndsWith("/"))
        {
            path = path.Substring(0, path.Length - 1);
        }

        return Path.GetFileName(path);
    }

    public static string GetFolderNameByFile(string file)
    {
        string path = GetPathDirectory(file);
        return GetFolderName(path);
    }

    public static bool IsFile(string path)
    {
        return !string.IsNullOrEmpty(GetExt(path));
    }

    public static bool IsFolder(string path)
    {
        return string.IsNullOrEmpty(GetExt(path));
    }

    public static bool ExistFile(string file)
    {
        return System.IO.File.Exists(file);
    }

    public static bool ExistFolder(string folder)
    {
        return Directory.Exists(folder);
    }

    public static void ChangeFileName(string filePath, string name)
    {
        File.Move(filePath, GetPathDirectory(filePath) + name);
    }

    public static void createFile(string file, bool newFile)
    {
        if (ExistFile(file) && !newFile)
        {
            return;
        }

        DeleteFile(file);
        //File.Create(file);
    }

    public static void CreateFolder(string folder)
    {
        if (ExistFolder(folder)) return;
        Directory.CreateDirectory(folder);
    }

    public static void CreateFolderByFile(string file)
    {
        string folderPath = Path.GetDirectoryName(file);
        CreateFolder(folderPath);
    }

    public static void DeleteFile(string file)
    {
        if (File.Exists(file))
        {
            try
            {
                File.Delete(file);
            }
            catch
            {
                if (File.Exists(file))
                {
                    File.Delete(file);
                }
            }
        }
    }

    public static void DeleteFolder(string folder)
    {
        if (Directory.Exists(folder))
        {
            try
            {
                Directory.Delete(folder, true);
            }
            catch
            {
                if (Directory.Exists(folder))
                {
                    Directory.Delete(folder, true);
                }
            }
        }
    }

    public static void CleanFolder(string folder)
    {
        if (!ExistFolder(folder))
        {
            return;
        }

        string[] folders = GetFolders(folder, false);
        string[] files = GetFiles(folder, "", false);

        foreach (string folderPath in folders)
        {
            DeleteFolder(folderPath);
        }
        foreach (string file in files)
        {
            DeleteFile(file);
        }
    }

    public static string GetPathExcludeExt(string path,bool keepLast)
    {
        if(string.IsNullOrEmpty(path))
        {
            return string.Empty;
        }

        string directory = GetPathDirectory(path);
        string outPath = directory + GetFileName(path);

        if (!string.IsNullOrEmpty(outPath) && !outPath.EndsWith("/") && keepLast)
        {
            outPath += "/";
        }

        return outPath;
    }

    //获取所在的文件夹
    public static string GetPathDirectory(string path,bool keepLast = true)
    {
        if(string.IsNullOrEmpty(path))
        {
            return path;
        }

        string directory = Path.GetDirectoryName(path).Replace(@"\", "/");

        string lastStr = string.Empty;
        if(!directory.Equals(string.Empty) && keepLast)
        {
            lastStr = "/";
        }

        return directory + lastStr;
    }

    public static void DeleteEmptyFolder(string path, bool isDeleteRoot = false)
    {
        if (!ExistFolder(path)) {
            return;
        }

        string[] folderPaths = Directory.GetDirectories(path);
        foreach (var v in folderPaths) DeleteEmptyFolder(v, true);

        string name = GetFileName(path);
        string[] childFolder = Directory.GetDirectories(path);
        string[] files = Directory.GetFiles(path);

        if (childFolder.Length <= 0 && files.Length <= 0 && isDeleteRoot)
        {
            Directory.Delete(path);
        }
    }

    public static void RemoveFolder(string folder)
    {
        if (ExistFolder(folder))
        {
            try
            {
                Directory.Delete(folder,true);
            }
            catch
            {
                if (ExistFolder(folder))
                {
                    Directory.Delete(folder, true);
                }
            }
        }
    }

    public static string[] GetFolders(string path, bool isRecursive = true)
    {
        if(!ExistFolder(path))
        {
            return new string[] {};
        }

        path = path.Replace(@"\", "/");
        string[] folderPaths = Directory.GetDirectories(path, "*.*", isRecursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);
        List<string> folders = new List<string>();

        for (int j = 0; j < folderPaths.Length; j++)
        {
            folders.Add(folderPaths[j].Replace(@"\", "/") + "/" );
        }

        return folders.ToArray();
    }

    public static string[] GetFiles(string path, string types = "", bool isRecursive = true, bool isExclude = false, string contains = "")
    {
        if (!ExistFolder(path))
        {
            return new string[] { };
        }

        if (types == null)
        {
            types = string.Empty;
        }

        if (string.IsNullOrEmpty(types) && isExclude)
        {
            return new string[] { };
        }

        if (types.Length > 0 && (types[0] == ","[0] || types[types.Length - 1] == ","[0] || types.IndexOf(",,") != -1))
        {
            return new string[] { };
        }

        bool isAll = false;
        HashSet<string> typeFiles = new HashSet<string>();
        if (!string.IsNullOrEmpty(types))
        {
            foreach (var ext in types.Split(","[0]))
            {
                typeFiles.Add(ext.Equals("*") ? "" : ext);
            }
        }
        else
        {
            isAll = true;
        }

        string searchPattern = (typeFiles.Count == 1 && !isExclude) ? "*." + types : "*.*";

        path = path.Replace(@"\", "/");
        List<string> files = new List<string>();

        string[] findFiles = Directory.GetFiles(path, searchPattern, isRecursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);
        for (int j = 0; j < findFiles.Length; j++)
        {
            string ext = GetExt(findFiles[j]);
            string fileName = GetFileName(findFiles[j]);
            if (!string.IsNullOrEmpty(contains) && !fileName.Contains(contains))
            {
                continue;
            }

            if(ext.Equals("DS_Store"))
            {
                continue;
            }

            if (!isExclude && (isAll || typeFiles.Contains(ext)))
            {
                files.Add(findFiles[j].Replace(@"\", "/"));
            }
            else if (isExclude && !typeFiles.Contains(ext))
            {
                files.Add(findFiles[j].Replace(@"\", "/"));
            }
        }
        return files.ToArray();
    }

    public static string[] GetFilesByHashSet(string path, HashSet<string> typeFiles,string types, bool isRecursive = true, bool isExclude = false)
    {
        bool isAll = typeFiles.Count <= 0;

        string searchPattern = (typeFiles.Count == 1 && !isExclude) ? "*." + types : "*.*";

        path = path.Replace(@"\", "/");
        List<string> files = new List<string>();

        string[] findFiles = Directory.GetFiles(path, searchPattern, isRecursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);
        for (int j = 0; j < findFiles.Length; j++)
        {
            string ext = GetExt(findFiles[j]);

            if (!isExclude && (isAll || typeFiles.Contains(ext)))
            {
                files.Add(findFiles[j].Replace(@"\", "/"));
            }
            else if (isExclude && !typeFiles.Contains(ext))
            {
                files.Add(findFiles[j].Replace(@"\", "/"));
            }
        }
        return files.ToArray();
    }

    public static string SubPath(string srcString, string subString)
    {
        int index = srcString.IndexOf(subString);
        if (index == -1) return srcString;
        return srcString.Substring(index + subString.Length);
    }

    public static string GetMd5(string file)
    {
        if(!IOUtils.ExistFile(file))
        {
            return string.Empty;
        }
        byte[] data = File.ReadAllBytes(file);
        return GetMd5ByByte(data);
    }

    public static string GetMd5ByByte(byte[] data)
    {
        System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
        byte[] retVal = md5.ComputeHash(data);
        StringBuilder sb = new StringBuilder();
        for (int j = 0; j < retVal.Length; j++)
        {
            sb.Append(retVal[j].ToString("x2"));
        }
        return sb.ToString();
    }

    public static string getManifestAsset(string file)
    {
        if (!ExistFile(file))
        {
            return string.Empty;
        }

        string content = File.ReadAllText(file);

        int beginIndex = content.IndexOf("Assets:");
        int endIndex = content.IndexOf("Dependencies:");

        content = content.Substring(beginIndex + 10, endIndex - beginIndex - 11);


        return content;
    }

    public static void CopyDirectory(string sourcePath, string destinationPath)
    {
        string path = Application.dataPath + "/Plugins/Android";
        if (!Directory.Exists(path)) Directory.CreateDirectory(path);

        DirectoryInfo info = new DirectoryInfo(sourcePath);
        Directory.CreateDirectory(destinationPath);
        foreach (FileSystemInfo fsi in info.GetFileSystemInfos())
        {
            if (fsi.Name.Equals(".svn"))
                continue;

            string destName = Path.Combine(destinationPath, fsi.Name);
            if (fsi is System.IO.FileInfo)
                File.Copy(fsi.FullName, destName);
            else
            {
                Directory.CreateDirectory(destName);
                CopyDirectory(fsi.FullName, destName);
            }
        }
    }

    public static void CopyFile(string srcFile,string destFile, bool overwrite = true)
    {
        if(ExistFile(srcFile))
        {
            CreateFolderByFile(destFile);
            File.Copy(srcFile, destFile, overwrite);
        }
    }

    public static void saveAssetFile(string savePath, byte[] results, string md5)
    {
        string saveFolder = Path.GetDirectoryName(savePath);
        if (!Directory.Exists(saveFolder)) Directory.CreateDirectory(saveFolder);

        FileStream fileStream = new FileStream(savePath, FileMode.Create, FileAccess.Write);
        fileStream.Seek(0, SeekOrigin.Begin);
        fileStream.Write(results, 0, results.Length);
        fileStream.Flush();
        fileStream.Close();

        string saveVersionPath = savePath + ".version";
        FileStream versionFileStream = new FileStream(saveVersionPath, FileMode.Create, FileAccess.Write);
        StreamWriter sw = new StreamWriter(versionFileStream);
        sw.WriteLine(md5);
        sw.Flush();
        sw.Close();
        versionFileStream.Close();
    }

    public static string ReadAllText(string file)
    {
        if (!ExistFile(file)) return string.Empty;
        return File.ReadAllText(file);
    }

    public static byte[] ReadAllBytes(string file)
    {
        if (!ExistFile(file)) return new byte[] { };
        return File.ReadAllBytes(file);
    }

    public static string[] ReadAllLines(string file)
    {
        if (!ExistFile(file)) return new string[]{ };
        return File.ReadAllLines(file);
    }

    public static void WriteAllText(string path,string contents)
    {
        File.WriteAllText(path,contents, new System.Text.UTF8Encoding(false));
    }

    public static void SafeWriteAllText(string file, string contents)
    {
        string cacheFile = GetCacheFile(file);
        WriteAllText(cacheFile, contents);
        DeleteFile(file);
        ChangeFileName(cacheFile, IOUtils.GetFileNameByExt(file));
    }


    public static void WriteAllBytes(string path,byte[] bytes)
    {
        File.WriteAllBytes(path, bytes);
    }

    public static void BeginSyncDB()
    {
#if !UNITY_EDITOR && UNITY_WEBGL
        SyncDB();
#endif
    }

    //keepLast为false，会把末尾'/'抹去
    public static string GetAbsPath(string path)
    {
        if (path.Equals(string.Empty))
        {
            return path;
        }

        string absPath = Path.GetFullPath(path).Replace(@"\", "/");

        string ext = GetExt(path);

        if(ext.Equals(string.Empty)  && !absPath.EndsWith("/"))
        {
            absPath += "/";
        }

        return absPath;
    }

    public static string GetPath(string path)
    {
        if (GetExt(path).Equals(string.Empty) && !path.EndsWith("/"))
        {
            return path + "/";
        }
        else
        {
            return path;
        }
    }

    public static string GetAbsPathByRoot(string rootPath,string path)
    {
        if (path.StartsWith("./") || path.StartsWith("../"))
        {
            return GetAbsPath(rootPath + "/" + path);
        }
        else
        {
            return GetAbsPath(path);
        }
    }

    public static void CheckCacheFile(string file)
    {
        string cacheFile = GetCacheFile(file);

        if (!ExistFile(file) && ExistFile(cacheFile))
        {
            ChangeFileName(cacheFile, GetFileNameByExt(file));
        }
        else
        {
            DeleteFile(cacheFile);
        }
    }

    public static string GetCacheFile(string file)
    {
        string fileName = GetFileName(file);
        string fileExt = GetExt(file);
        string fileDirectory = GetPathDirectory(file);

        string cacheFileName = string.Format("{0}_cache.{1}", fileName, fileExt);
        string cacheFile = fileDirectory + cacheFileName;

        return cacheFile;
    }

    public static void SaveFileByCache(string srcFile,string destFile)
    {
        string cacheFile = GetCacheFile(destFile);
        CopyFile(srcFile, cacheFile);
        DeleteFile(destFile);
        ChangeFileName(cacheFile, GetFileNameByExt(destFile));
    }

    public static Dictionary<string, object> ReadJsonFileToDict(string file, bool needExist)
    {
        if (!ExistFile(file))
        {
            if (needExist)
            {
                throw new Exception(string.Format("json文件不存[{0}]", file));
            }
            else
            {
                return new Dictionary<string, object>();
            }
        }

        try
        {
            string configStr = IOUtils.ReadAllText(file);
            return Json.Deserialize(configStr) as Dictionary<string, object>;
        }
        catch (Exception e)
        {
            throw new Exception(string.Format("json文件加载失败[{0}][error:{1}]", file, e.Message));
        }
    }

    public static void GetLocalPath(string fullPath,string rootPath)
    {

    }

    public static void SyncFolder(string srcFolder,string destFolder,string passFolders,string fileTypes,bool syncMeta, Func<string, string> onSrcFile = null)
    {
        srcFolder = GetAbsPath(srcFolder);
        destFolder = GetAbsPath(destFolder);

        List<string> localPassFolders = new List<string>();
        if(!passFolders.Equals(string.Empty))
        {
            localPassFolders.AddRange(passFolders.Split(","[0]));
        }

        string[] srcFolders = GetFolders(srcFolder);

        //
        string[] destFolders = GetFolders(destFolder);
        HashSet<string> destPassFolders = new HashSet<string>();
        foreach (var localFolder in localPassFolders)
        {
            string absPath = destFolder + localFolder;
            destPassFolders.Add(localFolder);
            string[] folders = GetFolders(absPath);
            foreach (string folder in folders)
            {
                string childLocalFolder = SubPath(folder, destFolder);
                destPassFolders.Add(childLocalFolder);
            }
        }
        HashSet<string> hashDestFolders = new HashSet<string>();
        foreach (string folder in destFolders)
        {
            string localFolder = SubPath(folder, destFolder);
            if(!destPassFolders.Contains(localFolder))
            {
                hashDestFolders.Add(localFolder);
            }
        }

        //
        string[] srcFiles = GetFiles(srcFolder, fileTypes);

        HashSet<string> srcPassFiles = new HashSet<string>();
        foreach (var localPath in localPassFolders)
        {
            string absPath = srcFolder + localPath;
            string[] files = GetFiles(absPath);
            foreach (string file in files)
            {
                string childLocalFile = SubPath(file, srcFolder);
                if(onSrcFile != null)
                {
                    childLocalFile = onSrcFile(childLocalFile);
                }
                srcPassFiles.Add(childLocalFile);
            }
        }

        string[] destFiles = GetFiles(destFolder, fileTypes);

        HashSet<string> destPassFiles = new HashSet<string>();
        foreach (var localPath in localPassFolders)
        {
            string absPath = destFolder + localPath;
            string[] files = GetFiles(absPath);
            foreach (string file in files)
            {
                string childLocalFile = SubPath(file, destFolder);
                destPassFiles.Add(childLocalFile);
            }
        }

        HashSet<string> hashDestFiles = new HashSet<string>();
        foreach (string file in destFiles)
        {
            string localFile = SubPath(file, destFolder);
            if (!IOUtils.GetExt(file).Equals("meta") && !destPassFiles.Contains(localFile))
            {
                hashDestFiles.Add(localFile);
            }
        }

        HashSet<string> srcMetaFiles = new HashSet<string>();
        HashSet<string> ignoreMetaFiles = new HashSet<string>();
        //
        foreach (string file in srcFiles)
        {
            string localFile = SubPath(file, srcFolder);
            if (onSrcFile != null)
            {
                localFile = onSrcFile(localFile);
            }

            if (IOUtils.GetExt(file).Equals("meta"))
            {
                if(syncMeta && !ignoreMetaFiles.Contains(localFile))
                {
                    srcMetaFiles.Add(localFile);
                }
                continue;
            }

            if (srcPassFiles.Contains(localFile))
            {
                continue;
            }

            string destFile = destFolder + localFile;

            string folder = GetPathDirectory(file);
            string localFolder = SubPath(folder, srcFolder);

            hashDestFolders.Remove(localFolder);
            hashDestFiles.Remove(localFile);

            string srcMd5 = GetMd5(file);
            string destMd5 = GetMd5(destFile);

            if(srcMd5.Equals(destMd5))
            {
                continue;
            }

            IOUtils.CreateFolderByFile(destFile);
            IOUtils.CopyFile(file,destFile);

            if(syncMeta)
            {
                string srcMateFile = file + ".meta";
                string srcLocalMetaFile = localFile + ".meta";
                string destMateFile = destFile + ".meta";
                srcMetaFiles.Remove(srcLocalMetaFile);
                ignoreMetaFiles.Add(srcLocalMetaFile);
                IOUtils.CopyFile(srcMateFile, destMateFile);
            }
        }

        if(syncMeta)
        {
            foreach(string file in srcMetaFiles)
            {
                string srcMateFile =srcFolder + file;
                string destMateFile = destFolder + file;
                if (!IOUtils.ExistFile(destMateFile))
                {
                    IOUtils.CopyFile(srcMateFile, destMateFile);
                }
            }
        }

        foreach(string folder in srcFolders)
        {
            string localFolder = SubPath(folder, srcFolder);
            hashDestFolders.Remove(localFolder);
        }

        //
        foreach (string file in hashDestFiles)
        {
            IOUtils.DeleteFile(destFolder + file);
            IOUtils.DeleteFile(destFolder + file + ".meta");
        }

        foreach (string folder in hashDestFolders)
        {
            IOUtils.RemoveFolder(destFolder + folder);
            IOUtils.DeleteFile(destFolder + folder.Substring(0,folder.Length - 1) + ".meta");
        }
    }

    public static bool CopyAssetFile(string srcFile, string targetFile)
    {
        if (ExistFile(targetFile) && IsSameFile(srcFile, targetFile))
        {
            return false;
        }

        CreateFolderByFile(targetFile);

        CopyFile(srcFile,targetFile);
        return true;
    }

    public static bool IsSameFile(string srcFile, string targetFile)
    {
        string srcFileMd5 = GetMd5(srcFile);
        if(string.IsNullOrEmpty(srcFileMd5))
        {
            return false;
        }

        string targetFileMd5 = GetMd5(targetFile);
        return srcFileMd5.Equals(targetFileMd5);
    }
} 
