using System;
using System.Collections.Generic;
using System.Xml;
using System.Text.RegularExpressions;
using LitJson;

namespace EditorTools.AssetBundle {
    public class AssetBuildStrategy {
        public string name;
        public Regex entryPattern; //入口文件路径匹配模式
        public List<StrategyNode> nodeList;

        public AssetBuildStrategy(XmlNode xmlNode) {
            name = xmlNode.Attributes["name"].Value;
            entryPattern = new Regex(xmlNode.SelectSingleNode("path").InnerText, RegexOptions.IgnoreCase);
            nodeList = GetStrategyNodeList(xmlNode.SelectSingleNode("strategy").InnerText, name);
        }

        private List<StrategyNode> GetStrategyNodeList(string json, string strategyName) {
            List<StrategyNode> result = new List<StrategyNode>();
            JsonData jsonData = null;
            try {
                jsonData = JsonMapper.ToObject(json);
            } catch (Exception e) {
                Logger.GetLogger(AssetBundleExporter.LOGGER_NAME).Log(json);
                Logger.GetLogger(AssetBundleExporter.LOGGER_NAME).Exception(e);
            }
            JsonData strategyData = jsonData["strategy"];
            for (int i = 0; i < strategyData.Count; i++) {
                StrategyNode node = new StrategyNode();
                JsonData nodeData = strategyData[i];
                node.strategy = strategyName;
                node.processor = nodeData.Keys.Contains("processor") == true ? (string)nodeData["processor"] : string.Empty;
                node.mode = ((string)nodeData["mode"]).ToLower();
                node.pattern = new Regex((string)nodeData["pattern"], RegexOptions.IgnoreCase);
                result.Add(node);
                Verify(node);
            }
            return result;
        }

        private void Verify(StrategyNode node) {
            //folder节点中pattern必须包含path子模式
            if (node.mode == PackageMode.FOLDER) {
                string[] groupNames = node.pattern.GetGroupNames();
                int index = Array.IndexOf<string>(groupNames, AssetPathHelper.REGEX_TOKEN_PATH);
                if (index == -1) {
                    string msg = "打包策略中，Folder模式节点中Pattern错误，没有文件夹路径定义, 策略： " + node.strategy + ",  Pattern: " + node.pattern;
                    AssetBundleExporter.ThrowException(msg);
                }
            }
        }
    }

    public class StrategyNode {
        public string strategy;  //节点所属策略名称
        public string processor; //节点资源分离处理器
        public string mode;      //节点资源打包模式
        public Regex pattern;    //节点资源分包分离正则表达式
    }

    public class PackageMode {
        /// <summary>
        /// 单一文件
        /// </summary>
        public const string SINGLE = "single";
        /// <summary>
        /// 选择文件集合
        /// </summary>
        public const string SELECTION = "selection";
        /// <summary>
        /// 文件夹
        /// </summary>
        public const string FOLDER = "folder";
    }

}
