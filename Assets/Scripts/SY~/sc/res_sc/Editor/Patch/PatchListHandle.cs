using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using EditorTools.UI;
using EditorTools.AssetBundle;

using LitJson;

namespace EditorTools.Patch {

    public class PatchListHandle {

        private string root = null;
        private string buildTarget = null;
        private string fileName = "patch_list.json";
        private string lastVersion = null;

        PatchData patchData = new PatchData();

        //public List<PatchInfo> list = new List<PatchInfo> ();

        public string GetLastVersion () {
            return lastVersion;
        }

        public PatchListHandle () {
            this.root = AssetBuildStrategyManager.outputPath;
            this.buildTarget = AssetPathHelper.GetBuildTargetTxt ();
        }

        public void Read ()
        {
            string file = root + "../" + buildTarget + "_patch/" + fileName;
            if (File.Exists(file))
            {
                string text = File.ReadAllText(file);
                patchData = JsonMapper.ToObject<PatchData>(text);
            }
            if(patchData.patchList.Count > 0)
            {
                lastVersion = patchData.patchList[patchData.patchList.Count - 1].version;
            }

            //string file = root + "../" + buildTarget + "_patch/" + fileName;
            //if (File.Exists (file)) {
            //    string detail = File.ReadAllText (file);
            //    JsonData jsonData = JsonMapper.ToObject (detail);
            //    int count = jsonData.Count;
            //    for (int i = 0; i < count; i++) {
            //        lastVersion = jsonData[i]["version"].ToString ();
            //        patchList.patchInfoList.Add (new PatchInfo (lastVersion));
            //    }
            //}
        }

        public void Write (string newVersion)
        {
            string file = root + "../" + buildTarget + "_patch/" + fileName;
            string dir = Path.GetDirectoryName (file);
            if (!Directory.Exists (dir)) {
                Directory.CreateDirectory (dir);
            }

            //string file = root + "../" + buildTarget + "_patch/" + fileName;

            PatchInfo patchInfo = new PatchInfo();
            patchInfo.version = newVersion;
            patchData.patchList.Add(patchInfo);
            string text = JsonMapper.ToJson(patchData);
            File.WriteAllText(file, text);

            //StringBuilder filesb = new StringBuilder ();
            //filesb.Append ("[\n");
            //bool theFirst = true;
            //foreach (PatchInfo version in list) {
            //    if (theFirst) {
            //        filesb.Append ("{\"version\":\"" + version.version + "\"}\n");
            //        theFirst = false;
            //    } else {
            //        filesb.Append (",{\"version\":\"" + version.version + "\"}\n");
            //    }
            //}
            //if (theFirst) {
            //    filesb.Append ("{\"version\":\"" + newVersion + "\"}\n");
            //    theFirst = false;
            //} else {
            //    filesb.Append (",{\"version\":\"" + newVersion + "\"}\n");
            //}
            //filesb.Append ("]");
            //File.WriteAllText (file, filesb.ToString ());
        }
    }


    public class PatchData
    {
        public List<PatchInfo> patchList = new List<PatchInfo>();

        public static PatchData FromJson(string json)
        {
            return JsonMapper.ToObject<PatchData>(json);
        }
    }

        public class PatchInfo
    {
        public string version = null;

        public PatchInfo ()
        {
        }
    }
}
