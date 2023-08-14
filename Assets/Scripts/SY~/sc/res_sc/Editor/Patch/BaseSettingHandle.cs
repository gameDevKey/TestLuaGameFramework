using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEngine;

using EditorTools.AssetBundle;
using EditorTools.UI;

using LitJson;

namespace EditorTools.Patch {
    public class BaseSettingHandle {
        public string curResVersion;
        private string root = null;
        private string buildTarget = null;

        public BaseSettingHandle (string version) {
            this.curResVersion = version;
            this.root = AssetBuildStrategyManager.outputPath;
            this.buildTarget = AssetPathHelper.GetBuildTargetTxt ();
        }

        public void Write () {
            string template = "../client/Assets/Resources/base_setting.txt";
            string setting = File.ReadAllText (template);
            JsonData jsonData = JsonMapper.ToObject (setting);
            string check_apk_path = @jsonData["check_apk_path"].ToString ();
            string debug = @jsonData["debug"].ToString ();
            string apk_version = @jsonData["apk_version"].ToString ();
            string res_version = @jsonData["res_version"].ToString ();
            string check_apk = @jsonData["check_apk"].ToString ();
            string cdn_path = @jsonData["cdn_path"].ToString ();
            string download_apk_path = @jsonData["download_apk_path"].ToString ();
            string theonw_cdn_path  = @jsonData["theone_cdn_path"].ToString ();
            StringBuilder filesb = new StringBuilder ();
            filesb.Append ("{\n");
            filesb.Append ("\"check_apk_path\": \"" + check_apk_path + "\",\n");
            filesb.Append ("\"debug\": \"" + debug + "\",\n");
            filesb.Append ("\"apk_version\": \"" + apk_version + "\",\n");
            filesb.Append ("\"res_version\": \"" + this.curResVersion + "\",\n");
            filesb.Append ("\"check_apk\": \"" + check_apk + "\",\n");
            filesb.Append ("\"download_apk_path\": \"" + download_apk_path + "\",\n");
            filesb.Append ("\"cdn_path\": \"" + cdn_path + "\",\n");
            filesb.Append ("\"theone_cdn_path\": \"" + theonw_cdn_path + "\"\n");
            filesb.Append ("}");
            File.WriteAllText (root + "/_base_setting.json", filesb.ToString ());
            Debug.Log ("创建base_setting.json文件完成");
        }
    }
}
