using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

using UnityEngine;
using UnityEditor;

using EditorTools.Patch;

public class SubpackageBuilder {

    public string output = null;
    public string platform = null;
    public string configFile = "../docs/配置文件/subpackage_config.xml";
    List<IParentNode> filesetList = new List<IParentNode> ();
    List<IParentNode> extendList = new List<IParentNode> ();
    List<IParentNode> loadFilesetList = new List<IParentNode> ();
    public string subVersion = null;

    public SubpackageBuilder (string output, string platform) {
        this.output = output;
        this.platform = platform;
        subVersion = System.DateTime.Now.ToString ("yyyyMMddHHmmss");
    }

    public void Split () {
        XmlDocument xmldoc = new XmlDocument ();
        try {
            xmldoc.Load (configFile);
            XmlElement root = xmldoc.DocumentElement;
            XmlElement apkFilesNode = (XmlElement)root.GetElementsByTagName ("apkfiles").Item (0);
            XmlNodeList list = apkFilesNode.ChildNodes;
            int count = list.Count;
            for (int i = 0; i < count; i++) {
                XmlNode node = list.Item (i);
                if (node is XmlElement && node.Name.Equals ("fileset")) {
                    filesetList.Add (new FilesetNode ((XmlElement)node));
                } else if (node is XmlElement && node.Name.Equals ("file")) {
                    filesetList.Add (new FileNode ((XmlElement)node));
                }
            }

            XmlElement extendFilesNode = (XmlElement)root.GetElementsByTagName("extendfiles").Item(0);
            list = extendFilesNode.ChildNodes;
            count = list.Count;
            for (int i = 0; i < count; i++) {
                XmlNode node = list.Item (i);
                if (node is XmlElement && node.Name.Equals ("fileset")) {
                    extendList.Add (new FilesetNode ((XmlElement)node));
                } else if (node is XmlElement && node.Name.Equals ("file")) {
                    extendList.Add (new FileNode ((XmlElement)node));
                }
            }

            string versionPath = "../release/" + platform + "/_version.json";
            VersionReader versionReader = new VersionReader (versionPath);
            // 替代资源类型小包内容
            List<VersionAsset> subPackageList = new List<VersionAsset> ();
            // 没节操类型小包内容 extendPackageList是subPackageList的子集
            List<VersionAsset> extendPackageList = new List<VersionAsset> ();
            // 需要下载的资源 unPackageList + subPackageList = All
            List<VersionAsset> unPackageList = new List<VersionAsset> ();
            // 需要下载的资源 unPackageListExtend + extendPackageList = All
            List<VersionAsset> unPackageListExtend = new List<VersionAsset> ();
            int limitSize = 1024 * 500; // 500K
            foreach (VersionAsset asset in versionReader.dict.Values) {
                if (Check (asset) && !asset.Path.EndsWith (".lua")) {
                    subPackageList.Add (asset);
                    if (Convert.ToInt32(asset.Size) > limitSize || (CheckExtend(asset) && !asset.Path.EndsWith(".lua"))) {
                        extendPackageList.Add (asset);
                    } else {
                        if (!asset.Path.EndsWith (".lua") && !asset.Path.EndsWith (".txt")) {
                            unPackageListExtend.Add (asset);
                    	}
                    }
                } else {
                    if (!asset.Path.EndsWith (".lua") && !asset.Path.EndsWith (".txt")) {
                        unPackageList.Add (asset);
                        unPackageListExtend.Add (asset);
                    }
                }
            }


            XmlElement loadNode = (XmlElement)root.GetElementsByTagName ("loadsort").Item (0);
            XmlNodeList loadList = loadNode.ChildNodes;
            count = loadList.Count;
            for (int i = 0; i < count; i++) {
                XmlNode node = loadList.Item (i);
                if (node is XmlElement && node.Name.Equals ("fileset")) {
                    loadFilesetList.Add (new FilesetNode ((XmlElement)node));
                } else if (node is XmlElement && node.Name.Equals ("file")) {
                    loadFilesetList.Add (new FileNode ((XmlElement)node));
                }
            }
            foreach (VersionAsset unPackageAsset in unPackageListExtend) {
                SetSort (unPackageAsset);
            }
            CopyFiles (subPackageList);
            CopyFilesExtend (extendPackageList);
            MakeJson (unPackageList, unPackageListExtend);
            CopyFilePatch (unPackageListExtend);
            Debug.Log ("分包资源处理完毕");
        } catch (Exception e) {
            Debug.LogError("出错了：" + e.Message);
            throw e;
        }
    }

    private bool Check (VersionAsset asset) {
        foreach (IParentNode node in filesetList) {
            if (node.Contains(asset.Path) && !node.Check (asset.Path)) {
                return false;
            }
        }
        return true;
    }

    private bool CheckExtend (VersionAsset asset) {
        foreach (IParentNode node in extendList) {
            if (node.Contains(asset.Path) && !node.Check (asset.Path)) {
                return false;
            }
        }
        return true;
    }

    private void SetSort (VersionAsset asset) {
        foreach (IParentNode node in loadFilesetList) {
            if (node.Contains(asset.Path) && node.Check (asset.Path)) {
                asset.sort = node.GetSort ();
                break;
            }
        }
    }

    private void CopyFiles (List<VersionAsset> list) {
        string rootPath = "../release/" + platform + "_subpackage/";
        string originPath = "../release/" + platform + "/";
        DirectoryInfo root = new DirectoryInfo (rootPath);
        if (root.Exists) {
            root.Delete (true);
        }
        (new DirectoryInfo (rootPath)).Create ();
        // Directory.CreateDirectory (Path.GetDirectoryName (targetRoot + "version.json"));
        foreach (VersionAsset asset in list) {
            Directory.CreateDirectory (Path.GetDirectoryName (rootPath + asset.Path));
            File.Copy (originPath + asset.Path, rootPath + asset.Path, true);
        }
        File.Copy (originPath + "_base_setting.json", rootPath + "_base_setting.json");
        File.Copy (originPath + "_version.json", rootPath + "_version.json");
    }

    private void CopyFilesExtend (List<VersionAsset> list) {
        string rootPath = "../release/" + platform + "_subpackage_extend/";
        string originPath = "../release/" + platform + "/";
        DirectoryInfo root = new DirectoryInfo (rootPath);
        if (root.Exists) {
            root.Delete (true);
        }
        (new DirectoryInfo (rootPath)).Create ();
        // Directory.CreateDirectory (Path.GetDirectoryName (targetRoot + "version.json"));
        foreach (VersionAsset asset in list) {
            Directory.CreateDirectory (Path.GetDirectoryName (rootPath + asset.Path));
            File.Copy (originPath + asset.Path, rootPath + asset.Path, true);
        }
        File.Copy (originPath + "_base_setting.json", rootPath + "_base_setting.json");
        File.Copy (originPath + "_version.json", rootPath + "_version.json");
    }

    private void CopyFilePatch (List<VersionAsset> list) {
        string rootPath = "../release/" + platform + "_subpatch/" + this.subVersion + "/";
        string platPath = "../release/" + platform + "_subpackage/";
        string platPathExtend = "../release/" + platform + "_subpackage_extend/";
        string originPath = "../release/" + platform + "/";
        DirectoryInfo root = new DirectoryInfo (rootPath);
        if (root.Exists) {
            throw new Exception ("分包版本目录异常");
        }
        (new DirectoryInfo (rootPath)).Create ();
        foreach (VersionAsset asset in list) {
            Directory.CreateDirectory (Path.GetDirectoryName (rootPath + asset.Path));
            File.Copy (originPath + asset.Path, rootPath + asset.Path, true);
        }
        File.Copy (originPath + "_base_setting.json", rootPath + "_base_setting.json");
        File.Copy (originPath + "_version.json", rootPath + "_version.json");
        File.Copy (platPathExtend + "_subpackage.json", rootPath + "_subpackage.json");
    }

    private void MakeJson (List<VersionAsset> list, List<VersionAsset> listExtend) {
        // 少的
        StringBuilder filesb = new StringBuilder ();
        // 多的
        StringBuilder fileextend = new StringBuilder ();
        bool first = true;
        filesb.Append ("{\n");
        filesb.Append ("    \"version\":\"" + this.subVersion + "\"\n");
        filesb.Append ("    ,\"list\":[\n");

        fileextend.Append ("{\n");
        fileextend.Append ("    \"version\":\"" + this.subVersion + "\"\n");
        fileextend.Append ("    ,\"list\":[\n");
        foreach (VersionAsset info in list) {
            if (first) {
                filesb.Append ("        " + info.ToVersionSortString ());
                first = false;
            } else {
                filesb.Append (",\n        " + info.ToVersionSortString ());
            }
        }
        first = true;
        foreach (VersionAsset info in listExtend) {
            if (first) {
                fileextend.Append ("        " + info.ToVersionSortString ());
                first = false;
            } else {
                fileextend.Append (",\n        " + info.ToVersionSortString ());
            }
        }
        filesb.Append ("\n    ]\n");
        filesb.Append ("}");

        fileextend.Append ("\n    ]\n");
        fileextend.Append ("}");
        string output_root = "../release/" + platform + "_subpackage";
        string output_root_extend = "../release/" + platform + "_subpackage_extend";
        if (true) {
            string tmp = Application.temporaryCachePath + "/buildassets/";
            Directory.CreateDirectory (Path.GetDirectoryName (tmp + "_subpackage.json"));
            File.WriteAllText (tmp + "_subpackage.json", filesb.ToString ());
            AssetPatchMaker.Compress(tmp + "_subpackage.json", output_root + "/_subpackage.json");

            tmp = Application.temporaryCachePath + "/buildassets/";
            Directory.CreateDirectory (Path.GetDirectoryName (tmp + "_subpackage_extend.json"));
            File.WriteAllText (tmp + "_subpackage_extend.json", fileextend.ToString ());
            AssetPatchMaker.Compress(tmp + "_subpackage_extend.json", output_root_extend + "/_subpackage.json");
        } else {
            File.WriteAllText (output_root + "/_subpackage.json", filesb.ToString ());
        }
        Debug.Log ("创建subpackage.json文件完成");
    }
}
