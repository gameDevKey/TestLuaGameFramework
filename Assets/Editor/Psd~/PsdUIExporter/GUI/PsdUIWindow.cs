using Ntreev.Library.Psd;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.IMGUI.Controls;
using UnityEngine;

namespace PsdUIExporter {

    public class PsdUIWindow : EditorWindow {

        const string Prefs_pdfPath = "Prefs_pdfPath_psd";
        const string Prefs_subatlas = "Prefs_subatlas_psd";
        private string psdPath;
        private int toolbarid = 0;
        private int rightbarid = 0;
        private static int id;

        [NonSerialized]
        bool m_Initialized = false;

        SearchField m_SearchField;

        [SerializeField]
        public TreeViewState m_TreeViewState = null;
        public TreeViewState m_TableViewState = null;
        NodeTreeView treeView;
        MultiColumnTreeView tableView;

        public OperableVO operVO = null;

        public NodeTreeViewItem rootTree = null;
        public NodeTreeViewItem rootList = null;

        private bool autoLoad = true;

        private Dictionary<int, NodeTreeViewItem> itemDict = new Dictionary<int,NodeTreeViewItem>();

        // 当打开界面的时候调用
        private void OnEnable() {
            if (autoLoad) {
                psdPath = EditorPrefs.GetString(Prefs_pdfPath);
            }
        }

        private void OnGUI() {

            InitIfNeeded();

            GUILayout.BeginVertical();
            DrawFileSelect();
            // if (psd != null) {
            // }
            // GUILayout.Space(2);

                GUILayout.BeginHorizontal();
                    int midwidth = 215;
                    var lwidth = position.width * 0.3f;
                	var rwidth = position.width - lwidth - midwidth;

                	// 左边区域
            		GUILayout.BeginVertical(GUILayout.Width(lwidth), GUILayout.ExpandHeight(true));
                	    TopToolBar();
                	    if (toolbarid == 0) {
                	        BuildTreeArea(lwidth);
                	    } else {
                	        BuildTableArea(lwidth);
                	    }
                	GUILayout.EndVertical();

            		GUILayout.BeginVertical(GUILayout.Width(midwidth), GUILayout.ExpandHeight(true));
                	    BuildMidArea(midwidth);
            		GUILayout.EndVertical();

                	// 右边区域
            		GUILayout.BeginVertical(GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
                	    BuildRightArea(rwidth - 10f);
            		GUILayout.EndVertical();

                GUILayout.EndHorizontal();

            GUILayout.EndVertical();
        }

        private void InitIfNeeded() {
            if (!m_Initialized) {
                ExportContext.GetInstance().Init();

                if (m_TreeViewState == null) {
                    m_TreeViewState = new TreeViewState();
                }

                if (operVO == null) {
                    operVO = new OperableVO();
                    string sub = EditorPrefs.GetString(Prefs_subatlas);
                    if (sub != null) {
                        operVO.subAtlasName = sub;
                    } else {
                        operVO.subAtlasName = "TmpPng";
                    }
                }

                if (m_TableViewState == null) {
                    m_TableViewState = new TreeViewState();
                }
                treeView = new NodeTreeView(m_TreeViewState, rootTree, operVO);
                treeView.Reload();

                tableView = new MultiColumnTreeView(m_TableViewState, rootList, operVO);
                tableView.Reload();


                m_SearchField = new SearchField();
                m_SearchField.downOrUpArrowKeyPressed += tableView.SetFocusAndEnsureSelectedItem;

                m_Initialized = true;
            }

        }

        private void BuildTableArea(float width) {
            Rect rect = new Rect(0, 2 * EditorGUIUtility.singleLineHeight + 6, width, EditorGUIUtility.singleLineHeight);
            tableView.searchString = m_SearchField.OnGUI(rect, tableView.searchString);
            rect = new Rect(0, 3 * EditorGUIUtility.singleLineHeight + 8, width, position.height - 3 * EditorGUIUtility.singleLineHeight - 8);
            tableView.OnGUI(rect);
        }

        private void BuildTreeArea(float width) {
            if (treeView == null) {
            }
            var treeViewRect = new Rect(0, 2 * EditorGUIUtility.singleLineHeight + 4, width, position.height - 3 * EditorGUIUtility.singleLineHeight - 4);
            treeView.OnGUI(treeViewRect);
            var toolRect = new Rect(0, position.height - EditorGUIUtility.singleLineHeight, width, EditorGUIUtility.singleLineHeight);
            BottomToolBar(toolRect);
        }

        private void BuildMidArea(float width) {
            GUIStyle style = new GUIStyle();
            // style.alignment = TextAnchor.MiddleCenter;
            style.fontStyle = FontStyle.Bold;
            style.normal.textColor = new Color(1, 1, 1);
            int labelWidth = 38;
            GUILayout.Label(" 全局属性",  style);
            GUILayout.Box("", new []{GUILayout.Height(1), GUILayout.ExpandWidth(true)});
            EditorGUILayout.LabelField("图片子目录:");
            EditorGUI.BeginChangeCheck();
            operVO.subAtlasName = EditorGUILayout.TextField(operVO.subAtlasName);
            if (EditorGUI.EndChangeCheck()) {
                EditorPrefs.SetString(Prefs_subatlas, operVO.subAtlasName);
            }

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("单独生成预设:", GUILayout.Width(100));
            if (GUILayout.Button("确定")) {
                operVO.warnError = null;
                if (rootTree == null || rootTree.node == null)
                    return;
                rootTree.node.CreatePrefab();
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("关联重复图片:", GUILayout.Width(100));
            if (GUILayout.Button("确定")) {
                operVO.warnError = null;
                if (rootTree == null || rootTree.node == null)
                    return;
                RelationImage();
                treeView.Reload();
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("检查图片重复:", GUILayout.Width(100));
            if (GUILayout.Button("确定")) {
                operVO.warnError = null;
                if (rootTree == null || rootTree.node == null)
                    return;
                rootTree.node.CheckRepeated();
                treeView.Reload();
            }
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("生成图片:", GUILayout.Width(100));
            // if (GUILayout.Button("全部")) {
            //     if (rootTree == null || rootTree.node == null) {
            //         EditorUtility.DisplayDialog("提示", "还没有生成预设", "确定");
            //         return;
            //     }
            //     operVO.gimageType = GImageType.All;
            //     rootTree.node.CreateImage();
            // }
            if (GUILayout.Button("非重复")) {
                operVO.warnError = null;
                if (rootTree == null || rootTree.node == null) {
                    EditorUtility.DisplayDialog("提示", "还没有生成预设", "确定");
                    return;
                }
                operVO.gimageType = GImageType.NotRepeated;
                rootTree.node.CreateImage();
            }
            GUILayout.EndHorizontal();
            GUILayout.Space(5);

            GUILayout.Label(" 结点属性",  style);
            GUILayout.Box("", new []{GUILayout.Height(1), GUILayout.ExpandWidth(true)});
            GUILayout.Space(1);
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("名字:", GUILayout.Width(labelWidth));
            EditorGUI.BeginChangeCheck();
            operVO.nodeName = EditorGUILayout.TextField(operVO.nodeName);
            if (EditorGUI.EndChangeCheck() && operVO.item != null) {
                operVO.item.node.SetName(operVO.nodeName);
            }
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("类型:", GUILayout.Width(labelWidth));
            EditorGUILayout.IntPopup(operVO.noteType, new[] { "图片", "组", "文字"}, new[] {1, 2, 3});
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("资源:", GUILayout.Width(labelWidth));
            EditorGUILayout.IntPopup(operVO.resType, new[] { "共享", "私有"}, new[] { 1, 2});
            GUILayout.EndHorizontal();

            EditorGUILayout.LabelField("图片目录:");
            EditorGUI.BeginChangeCheck();
            operVO.nodeSubAtlasName = EditorGUILayout.TextField(operVO.nodeSubAtlasName);
            if (EditorGUI.EndChangeCheck() && operVO.item != null && operVO.item.node is ImageNode) {
                ((ImageNode)operVO.item.node).nodeSubAtlasName = operVO.nodeSubAtlasName;
            }

            // GUILayout.BeginHorizontal();
            // EditorGUILayout.LabelField("忽略:", GUILayout.Width(labelWidth));
            // EditorGUI.BeginChangeCheck();
            // operVO.ignore = EditorGUILayout.IntPopup(operVO.ignore, new[] { "否", "是" }, new[] { 0, 1 });
            // if (EditorGUI.EndChangeCheck() && operVO.item != null) {
            //     if (operVO.ignore == PBool.True) {
            //         operVO.item.node.SetIgnore(true);
            //     } else {
            //         operVO.item.node.SetIgnore(false);
            //     }
            // }
            EditorGUI.BeginChangeCheck();
            operVO.ignore = EditorGUILayout.Toggle("忽略", operVO.ignore);
            if (EditorGUI.EndChangeCheck() && operVO.item != null) {
                if (operVO.ignore) {
                    operVO.item.node.SetIgnore(true);
                } else {
                    operVO.item.node.SetIgnore(false);
                }
            }
            // GUILayout.EndHorizontal();
            EditorGUI.BeginChangeCheck();
            operVO.transformOnly = EditorGUILayout.Toggle("TransformOnly", operVO.transformOnly);
            if (EditorGUI.EndChangeCheck() && operVO.item != null) {
                if (operVO.transformOnly) {
                    operVO.item.node.SetTransformOnly(true);
                } else {
                    operVO.item.node.SetTransformOnly(false);
                }
            }

            EditorGUI.BeginChangeCheck();
            operVO.noImage = EditorGUILayout.Toggle("NoImage", operVO.noImage);
            if (EditorGUI.EndChangeCheck() && operVO.item != null) {
                if (operVO.noImage) {
                    operVO.item.node.SetNoImage(true);
                } else {
                    operVO.item.node.SetNoImage(false);
                }
            }

            EditorGUI.BeginChangeCheck();
            operVO.isMirror= EditorGUILayout.Toggle("图片镜像", operVO.isMirror);
            if (EditorGUI.EndChangeCheck() && operVO.item != null) {
                if (operVO.item.node is ImageNode) {
                    if (operVO.isMirror) {
                        ((ImageNode)operVO.item.node).isMirror = true;
                    } else {
                        ((ImageNode)operVO.item.node).isMirror = false;
                    }
                    ((ImageNode)operVO.item.node).DoMirror();
                }
            }
            GUILayout.Space(5);

            GUILayout.Label(" 九宫格", style);
            GUILayout.Box(GUIContent.none, new []{GUILayout.Height(1), GUILayout.ExpandWidth(true)});
            float def = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 50;
            GUILayout.BeginHorizontal();
            operVO.pslice.left = EditorGUILayout.IntField("left:", operVO.pslice.left);
            operVO.pslice.top = EditorGUILayout.IntField("top:", operVO.pslice.top);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            operVO.pslice.right = EditorGUILayout.IntField("right:", operVO.pslice.right);
            operVO.pslice.bottom = EditorGUILayout.IntField("bottom:", operVO.pslice.bottom);
            GUILayout.EndHorizontal();
            EditorGUIUtility.labelWidth = def;

            using (new EditorGUILayout.HorizontalScope()) {
                if (GUILayout.Button("切割")) {
                    operVO.warnError = null;
                    if (operVO != null && operVO.item != null) {
                        TextureSlicer.Slice(operVO.item.node, operVO.pslice);
                    }
                }

                // if (GUILayout.Button("确定")) {
                //     if (operVO != null && operVO.item != null && operVO.item.node is ImageNode) {
                //         ImageNode node = (ImageNode)operVO.item.node;
                //         if (node.GetSclieTexture() != null) {
                //             node.SetTexture(node.GetSclieTexture());
                //         }
                //     }
                // }

                if (GUILayout.Button("原还")) {
                    operVO.warnError = null;
                    if (operVO != null && operVO.item != null && operVO.item.node is ImageNode) {
                        ImageNode node = (ImageNode)operVO.item.node;
                        node.ResetTexture();
                    }
                }

                if (GUILayout.Button("清空")) {
                    operVO.warnError = null;
                    operVO.pslice = new PSlice();
                }
            }
            GUILayout.Space(5);

            GUILayout.Label(" 其它",  style);
            GUILayout.Box(GUIContent.none, new []{GUILayout.Height(1), GUILayout.ExpandWidth(true)});
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("单独生成图片:", GUILayout.Width(100));
            if (GUILayout.Button("确定")) {
                operVO.warnError = null;
                operVO.warnError = null;
                if (operVO.item != null && operVO.item.node.GetGameObject() != null) {
                    INode node = operVO.item.node;
                    if (node is ImageNode && ((ImageNode)node).GetSclieTexture() != null) {
                        ((ImageNode)node).SetTexture(((ImageNode)node).GetSclieTexture());
                    }
                    operVO.gimageType = GImageType.Single;
                    operVO.item.node.CreateImage();
                } else {
                    EditorUtility.DisplayDialog("提示", "还没有生成预设", "确定");
                }
            }
            GUILayout.EndHorizontal();
        }

        private void BuildRightArea(float width) {
            rightbarid = GUILayout.Toolbar(rightbarid, new[] { "新资源", "旧资源" });
            if (rightbarid== 0) {
                if (operVO != null && operVO.item != null && operVO.item.node is ImageNode) {
                    Texture2D texture = ((ImageNode)operVO.item.node).GetFinalTexture();
                    if (texture != null) {
                        GUILayout.Label("" + texture.width + "X" + texture.height);
                        GUILayout.Box(GUIContent.none, new []{GUILayout.Height(1), GUILayout.ExpandWidth(true)});
                        ShowTexture(texture);
                    }
                }
            } else {
                if (operVO != null && operVO.item != null && operVO.item.node is ImageNode) {
                    if (operVO.item.node.IsRepeated()) {
                        string p = ((ImageNode)operVO.item.node).GetResPath();
                        Texture2D texture = AssetDatabase.LoadAssetAtPath<Texture2D>(p);
                        if (texture != null)
                            GUILayout.Label("" + texture.width + "X" + texture.height);
                            GUILayout.Box(GUIContent.none, new []{GUILayout.Height(1), GUILayout.ExpandWidth(true)});
                            ShowTexture(texture);
                    }
                }
            }

            var rect = new Rect(position.width - width - 2, position.height - EditorGUIUtility.singleLineHeight, width - 2, EditorGUIUtility.singleLineHeight);
            GUILayout.BeginArea(rect);
            {
                GUILayout.BeginHorizontal();
                {
                    if (operVO.warnError != null) {
                        GUIStyle style = new GUIStyle();
                        style.fontStyle = FontStyle.Bold;
                        style.normal.textColor = new Color(1, 0, 0);
                        GUILayout.Label(operVO.warnError, style, GUILayout.ExpandWidth(true));
                        if (GUILayout.Button("Clean", EditorStyles.miniButton, GUILayout.Width(60))) {
                            operVO.warnError = null;
                        }
                    }
                }
                GUILayout.EndHorizontal();
            }
            GUILayout.EndArea();
        }

        private void ShowTexture(Texture2D texture) {
            if (texture == null)
                return;
            int width = texture.width;
            int height = texture.height;
            float ratio = 1.0f;
            float previewSize = 512.0f;
            if (width > previewSize || height > previewSize) {
                if (width > height) {
                    ratio = previewSize / (float)width;
                } else {
                    ratio = previewSize / (float)height;
                }
            }
            GUILayout.Box(texture, GUILayout.Width(width * ratio + 10), GUILayout.Height(height * ratio + 10));
        }

        private void DrawFileSelect() {
            using (var hor = new EditorGUILayout.HorizontalScope()) {
                EditorGUILayout.LabelField("PSD文件路径：", GUILayout.Width(30));
                EditorGUI.BeginChangeCheck();
                psdPath = EditorGUILayout.TextField(psdPath);

                if (GUILayout.Button("选择", EditorStyles.miniButtonRight, GUILayout.Width(60))) {
                    string dir = Application.dataPath;
                    if (!string.IsNullOrEmpty(psdPath)) {
                        dir = System.IO.Path.GetDirectoryName(psdPath);
                    }

                    psdPath = EditorUtility.OpenFilePanel("选择一个pdf文件", dir, "psd");

                    if (psdPath.Contains(Application.dataPath)) {
                        psdPath = psdPath.Replace("\\", "/").Replace(Application.dataPath, "Assets");
                    }
                }
                bool change = EditorGUI.EndChangeCheck();
                if (change) {
                    EditorPrefs.SetString(Prefs_pdfPath, psdPath);
                }
                if (GUILayout.Button("解析", EditorStyles.miniButtonRight, GUILayout.Width(60))) {
                    operVO.warnError = null;
                    if (!string.IsNullOrEmpty(psdPath)) {
                        OpenPsdDocument();
                        treeView.ExpandAll();
                    } else {
                        EditorUtility.DisplayDialog("提示", "请选择psd文件", "确定");
                    }
                }
                // if (!string.IsNullOrEmpty(psdPath) && psd == null) {
                //     OpenPsdDocument();
                // }
            }
        }

        private void OpenPsdDocument() {
            if (System.IO.File.Exists(psdPath)) {
                using (PsdDocument document = PsdDocument.Create(psdPath)) {
            	    INode root= new RootNode("RootName");
                    rootTree = new NodeTreeViewItem(++id, -1, root);
                    rootList = new NodeTreeViewItem(++id, -1, root);
                    try {
                        foreach (PsdLayer layer in document.Childs) {
                            ParseLayer(layer, rootTree, 0);
                        }
                    } catch (Exception e) {
                        EditorUtility.DisplayDialog("提示", "解析图层出错了【" + operVO.parseErrorLayer + "】:" + e.Message, "确定");
                        throw e;
                    }
        		}
                if (rootTree != null) {
                    treeView.SetRoot(rootTree);
                    treeView.Reload();
                }
                if (rootList != null) {
                    tableView.SetRoot(rootList);
                    tableView.Reload();
                }
            } else {
                EditorUtility.DisplayDialog("提示", "文件不存在", "确定");
            }
        }

        void ParseLayer(PsdLayer layer, NodeTreeViewItem parentNode, int depth) 
        {
            INode node = null;
            NodeTreeViewItem nodeItem = null;
            if (ExportUtility.IsNoexportLayer(layer)) {
                return;
            }
            switch (layer.LayerType) {
                case LayerType.Text:
                    node = new TextNode(operVO, layer, parentNode.node);
                    parentNode.node.AddChild(node);
                    nodeItem = new NodeTreeViewItem(++id, depth, node);
                    rootList.AddChild(new NodeTreeViewItem(++id, 0, node));
                    parentNode.AddChild(nodeItem);
                    break;
                case LayerType.Group:
                    node = new GroupNode(operVO, layer, parentNode.node);
                    parentNode.node.AddChild(node);
                    nodeItem = new NodeTreeViewItem(++id, depth, node);
                    rootList.AddChild(new NodeTreeViewItem(++id, 0, node));
                    parentNode.AddChild(nodeItem);
                    break;
                case LayerType.Complex:
                case LayerType.Color:
                case LayerType.Normal:
                    node = new ImageNode(operVO, layer, parentNode.node);
                    parentNode.node.AddChild(node);
                    nodeItem = new NodeTreeViewItem(++id, depth, node);
                    rootList.AddChild(new NodeTreeViewItem(++id, 0, node));
                    parentNode.AddChild(nodeItem);
                    break;
                default:
                    throw new Exception("psd图层类型异常，无法识别:" + layer.LayerType);
            }
            if (node != null && layer.Childs.Length > 0) {
        	    foreach (PsdLayer child in layer.Childs) {
            	    ParseLayer(child, nodeItem, depth + 1);
        		}
            }
        }

        private void TopToolBar() {
            EditorGUI.BeginChangeCheck();
            toolbarid = GUILayout.Toolbar(toolbarid, new[] { "资源树", "资源列表" });
            if (EditorGUI.EndChangeCheck()) {
                // Debug.LogError(toolbarid);
            }
        }

        private void BottomToolBar(Rect rect) {
            GUILayout.BeginArea(rect);
            using (new EditorGUILayout.HorizontalScope()) {
                var style = "miniButton";
                if (GUILayout.Button("展开", style)) {
                    treeView.ExpandAll();
                }

                if (GUILayout.Button("折叠", style)) {
                    treeView.CollapseAll();
                }
            }
            GUILayout.EndArea();
        }

        public NodeTreeViewItem GetNodeById(int id) {
            if (rootTree == null) {
                return null;
            }
            if (itemDict.ContainsKey(id)) {
                return itemDict[id];
            } else {
                return null;
            }
        }
        private void ScanRoot(NodeTreeViewItem node) {
            if (node == null || node.node == null) {
                return;
            }
            if (!itemDict.ContainsKey(node.id)) {
                itemDict.Add(node.id, node);
            }
            if (node.children == null) {
                return;
            }
            foreach (NodeTreeViewItem item in node.children) {
                ScanRoot(item);
            }
        }

        private void RelationImage() {
            if (rootList == null)
                return;
            foreach (NodeTreeViewItem item in rootList.children) {
                if (item.node != null && item.node is ImageNode) {
                    ((ImageNode)item.node).RelationImage();
                }
            }
            GameObject tmp = new GameObject();
            tmp.transform.SetParent(GameObject.Find("Canvas").transform);
            GameObject.DestroyImmediate(tmp);
        }

        private void OnDestroy() {
            ExportContext.OnDestroy();
        }
    }
}
