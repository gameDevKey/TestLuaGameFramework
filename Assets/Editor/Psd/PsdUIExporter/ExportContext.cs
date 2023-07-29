using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEditor;
using LitJson;
using System.Text.RegularExpressions;

namespace PsdUIExporter {
    public class ExportContext {

        private static ExportContext instance = null;

        private Dictionary<string, Font> fontDict = new Dictionary<string, Font>();
        private ExpConfigVO configVo = null;
        private Dictionary<string, AutoCheckResInfo> autoCheckDict = new Dictionary<string, AutoCheckResInfo>();
        private List<PreDefinedInfo> predefinedList = new List<PreDefinedInfo>();
        private ParamParser paramParser = null;

        public static ExportContext GetInstance() {
            if (instance == null) {
                instance = new ExportContext();
            }
            return instance;
        }

        public static void OnDestroy() {
            instance = null;
        }

        private ExportContext() {
            configVo = new ExpConfigVO();
            paramParser = new ParamParser();
            InitFontDict();
        }

        public void Init() {
            return;
            List<string> autoList = configVo.autoCheckList;
            string fileName = null;
            foreach (string subpath in autoList) {
                DirectoryInfo dir = new DirectoryInfo(subpath);
                if (dir.Exists) {
                    FileInfo [] files = dir.GetFiles();
                    if (files != null) {
                        foreach (FileInfo file in files) {
                            fileName = file.Name;
                            if (file.FullName.Trim().ToLower().EndsWith("png")) {
                                string key = fileName.Substring(0, fileName.Length - 4);
                                if (autoCheckDict.ContainsKey(key)) {
                                    Debug.Log("自动检测资源重名[" + key + "]" + autoCheckDict[key].path + " ===> " + subpath + "/" + fileName);
                                }
                                if (!autoCheckDict.ContainsKey(key)) {
                                    autoCheckDict.Add(key, new AutoCheckResInfo(key, dir.Name, subpath + "/" + fileName));
                                }
                            }
                        }
                    }
                } else {
                    string errinfo = "autocheck不存在的目录：" + subpath;
                    throw new Exception(errinfo);
                }
            }
            predefinedList = configVo.predefinedList;
        }

        private void InitFontDict() {
            //@FIXME 根据项目组修改这个地方
            Font fz = AssetDatabase.LoadAssetAtPath<Font>(configVo.fontSpecialPath);
            Font wqy = AssetDatabase.LoadAssetAtPath<Font>(configVo.fontNormalPath);
            fontDict.Add(configVo.fontSpecialKey, fz);
            fontDict.Add(configVo.fontNormalKey, wqy);
        }

        public Font GetFont(string type) {
            if (configVo.fontSpecialKey.Equals(type)) {
                return fontDict[configVo.fontSpecialKey];
            } else {
                return fontDict[configVo.fontNormalKey];
            }
        }

        public ExpConfigVO GetConfigVo() {
            return configVo;
        }

        public AutoCheckResInfo GetAutoCheckFile(string name) {
            if (autoCheckDict.ContainsKey(name)) {
                return autoCheckDict[name];
            } else {
                return null;
            }
        }

        public string CheckPreDefined(string name) {
            foreach (PreDefinedInfo preInfo in predefinedList) {
                if (preInfo.regex.IsMatch(name)) {
                    return preInfo.module;
                }
            }
            return null;
        }

        // public ParamParser GetParamParser() {
        //     return paramParser;
        // }
        public void ParamProcess(INode node) {
            paramParser.Parser(node);
        }

        public void ParamAfterInitProcess(INode node) {
            paramParser.AfterInitParser(node);
        }
    }

    public class ExpConfigVO {
        public string basePath = "Assets/Things/Textures/UI/Base";
        public string fontNormalPath = null;
        public string fontSpecialPath = null;
        public string fontNormalKey = null;
        public string fontSpecialKey = null;

        public List<string> autoCheckList = new List<string>();
        public List<PreDefinedInfo> predefinedList = new List<PreDefinedInfo>();

        public ExpConfigVO() {
            string config = AssetDatabase.LoadAssetAtPath<TextAsset>("Assets/Editor/UI/PsdUIExporter/psd_config.json").text;
            JsonData jsonData = JsonMapper.ToObject(config);
            basePath = jsonData["base_path"].ToString();

            fontNormalPath = jsonData["font_normal_path"].ToString();
            fontNormalKey = jsonData["font_normal_key"].ToString();
            fontSpecialPath = jsonData["font_special_path"].ToString();
            fontSpecialKey = jsonData["font_special_key"].ToString();

            JsonData autoData = jsonData["auto_check"];
            if (autoData.IsArray) {
                int length = autoData.Count;
                for (int i = 0; i < length; i++) {
                    JsonData data = autoData[i];
                    if (data.IsString) {
                        autoCheckList.Add(data.ToString());
                    }
                }
            }
            JsonData preData = jsonData["pre_defined"];
            if (preData.IsArray) {
                int length = preData.Count;
                for (int i = 0; i < length; i++) {
                    JsonData data = preData[i];
                    string regex = data["regex"].ToString();
                    string module = data["module"].ToString();
                    predefinedList.Add(new PreDefinedInfo(regex, module));
                }
            }

        }
    }

    public class AutoCheckResInfo {

        public string name = null;
        public string dirName = null;
        public string path = null;

        public AutoCheckResInfo(string name, string dirName, string path) {
            this.name = name;
            this.dirName = dirName;
            this.path = path;
        }
    }

    public class PreDefinedInfo {
        public Regex regex = null;
        public string module = null;

        public PreDefinedInfo(string regex, string module) {
            this.regex = new Regex(regex);
            this.module = module;
        }
    }
}
