using System;
using System.IO;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Linq;
using System.Text;

using UnityEngine;

using EditorTools.AssetBundle;
using EditorTools.UI;

using LitJson;

namespace EditorTools.Patch {
    public class VersionHandle {
        private string folderRoot;
        private string patchRoot;
        private string curVersion;

        public VersionHandle (string patchVersion) {
            this.folderRoot = AssetBuildStrategyManager.outputPath;
            this.patchRoot = AssetBuildStrategyManager.outputPath + "../" + AssetPathHelper.GetBuildTargetTxt () + "_patch";
            this.curVersion = patchVersion;
        }

        public Dictionary<string, VersionInfo> ScanNewAsset () {
            Dictionary<string, VersionInfo> dict = new Dictionary<string, VersionInfo> ();
            DirectoryInfo dir = new DirectoryInfo (this.folderRoot);
            FileInfo[] files = dir.GetFiles ();
            string name = null;
            MD5 md5 = MD5.Create();
            foreach (FileInfo fileInfo in files) {
                name = fileInfo.Name;
                if (name.EndsWith (".meta") 
                    || name.EndsWith (".manifest")
                    || name.EndsWith (".json")
                    ) {
                    continue;
                }
                byte[] fileData = md5.ComputeHash(File.ReadAllBytes(fileInfo.FullName));
                string fileToken = Convert.ToBase64String(fileData);
                dict.Add (fileInfo.Name, new VersionInfo (fileInfo.Name, fileToken, "" + (int)fileInfo.Length, curVersion));
            }
            return dict;
        }

        public Dictionary<string, VersionInfo> ReadPatchVersion (string lastVersion) {
            string filePath = this.patchRoot + "/" + lastVersion + "/_version.json";
            byte[] bytes = AssetPatchMaker.Decompress (File.ReadAllBytes (filePath));
            string detail = System.Text.Encoding.Default.GetString (bytes);
            JsonData jsonData = JsonMapper.ToObject (detail);
            int count = jsonData.Count;
            string path = "";
            string size = "";
            string patchVersion = "";
            string md5 = "";
            Dictionary<string, VersionInfo> dict = new Dictionary<string, VersionInfo> ();
            for (int i = 0; i < count; i++) {
                JsonData data = jsonData[i];
                path = data["path"].ToString ();
                size = data["size"].ToString ();
                patchVersion = data["patchVersion"].ToString ();
                md5 = data["md5"].ToString ();
                if (!path.EndsWith (".lua")) {
                    dict.Add (path, new VersionInfo (path, md5, size, patchVersion));
                }
            }
            return dict;
        }

        public void WriteVersion (Dictionary<string, VersionInfo> dict) {
            StringBuilder filesb = new StringBuilder ();
            bool first = true;
        	filesb.Append ("[\n");
        	foreach (VersionInfo info in dict.Values) {
        	    if (first) {
        	        filesb.Append (info.ToVersionString ());
        	        first = false;
        	    } else {
        	        filesb.Append (",\n " + info.ToVersionString ());
        	    }
        	}
            //foreach (string file in dataList) {
            //    string path = file.Replace ("luadata", "data");
        	   // if (first) {
        	   //     filesb.Append (new VersionInfo(path, "luadatamd5==", "1", this.curVersion).ToVersionString ());
        	   //     first = false;
        	   // } else {
        	   //     filesb.Append (",\n " + new VersionInfo(path, "luadatamd5==", "1", this.curVersion).ToVersionString ());
        	   // }
            //}
            //foreach (string file in luaList) {
            //    string path = file.Substring (4);
        	   // if (first) {
        	   //     filesb.Append (new VersionInfo(path, "luamd5==", "1", this.curVersion).ToVersionString ());
        	   //     first = false;
        	   // } else {
        	   //     filesb.Append (",\n " + new VersionInfo(path, "luamd5==", "1", this.curVersion).ToVersionString ());
        	   // }
            //}
        	filesb.Append ("\n]");
            string tmp = Application.temporaryCachePath + "/buildassets/";
            Directory.CreateDirectory (Path.GetDirectoryName (tmp + "_version.json"));
            File.WriteAllText(folderRoot + "/_version_text.json", filesb.ToString());
            File.WriteAllText (tmp + "_version.json", filesb.ToString ());
            AssetPatchMaker.Compress(tmp + "_version.json", folderRoot + "/_version.json");
        }
    }

    public class VersionInfo {

        private string path = null;
        private string md5 = null;
        private string size = null;
        private string patchVerion = null;

        public string Path { get { return path; } }
        public string Md5 { get { return md5; } }
        public string Size { get { return size; } }
        public string PatchVerion { get { return patchVerion; } set { patchVerion = value; } }

        public VersionInfo (string path, string md5, string size, string patchVerion) {
            this.path = path;
            this.md5 = md5;
            this.size = size;
            this.patchVerion = patchVerion;
        }

        public string ToVersionString () {
            StringBuilder filesb = new StringBuilder ();
            filesb.Append ("{");
            filesb.Append ("\"path\":\"" + path + "\", ");
            filesb.Append ("\"size\":\"" + size + "\", ");
            filesb.Append ("\"patchVersion\":\"" + patchVerion + "\", ");
            filesb.Append ("\"md5\":\"" + md5 + "\"");
            filesb.Append ("}");
            return filesb.ToString ();
        }
    }
}
