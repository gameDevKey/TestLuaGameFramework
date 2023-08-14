using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using UnityEditor;
using EditorTools.AssetBundle;

namespace EditorTools.Patch {
    public class MapAssetBuilder {

        private List<string> fileList = new List<string> ();
        private string output = null;
        private string srcRoot = "../data";

        public MapAssetBuilder (List<string> fileList) {
            this.fileList = fileList;
            this.output = AssetBuildStrategyManager.outputPath;
        }

        public void Build () {
            // foreach (string file in fileList) {
            //     AssetPatchMaker.Compress (srcRoot + "/" + file, this.output + file.Replace ("map/", ""));
            // }

            AssetBundleBuild[] _builds = new AssetBundleBuild[fileList.Count];
            for (int i = 0; i < fileList.Count; i++) {
                string file = fileList[i];
                AssetBundleBuild build = new AssetBundleBuild();
                build.assetBundleName = file.Replace("map/", "");
                build.assetNames = new string[] { "Assets/" + file.Replace(".map", ".bytes") };
                _builds[i] = build;
            }
            BuildPipeline.BuildAssetBundles(AssetBuildStrategyManager.outputPath, _builds, AssetBundleBuilder.GetBuildOptions(), AssetBundleBuilder.GetBuildTarget());
        }
    }
}
