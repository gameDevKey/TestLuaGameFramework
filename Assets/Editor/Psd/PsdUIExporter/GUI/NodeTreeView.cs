using Ntreev.Library.Psd;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.IMGUI.Controls;
using UnityEngine;

namespace PsdUIExporter {
    public class NodeTreeView : TreeView {

        private static int id;
        const float kRowHeights = 20f;
        const float kToggleWidth = 18f;
        private NodeTreeViewItem root = null;
        private OperableVO operVo = null;

        private Dictionary<int, NodeTreeViewItem> itemDict = new Dictionary<int,NodeTreeViewItem>();
        private Dictionary<string, Texture> previewIcons = new Dictionary<string, Texture>();

        public NodeTreeView(TreeViewState state, NodeTreeViewItem root, OperableVO operVo) : base(state) {
            this.root = root;
            this.operVo = operVo;
            var m_MultiColumnHeaderState = CreateDefaultMultiColumnHeaderState();
            this.multiColumnHeader = new MultiColumnHeader(m_MultiColumnHeaderState);
            this.multiColumnHeader.canSort = false;

            this.rowHeight = kRowHeights;
            this.columnIndexForTreeFoldouts = 1;
            this.showAlternatingRowBackgrounds = true;
            this.showBorder = true;
            this.customFoldoutYOffset = (kRowHeights - EditorGUIUtility.singleLineHeight) * 0.5f; // center foldout in the row since we also center content. See RowGUI
            this.extraSpaceBeforeIconAndLabel = kToggleWidth;
            InitPreviewIcons();
        }

        void InitPreviewIcons() {
            previewIcons.Add(LayerType.Group.ToString(), EditorGUIUtility.FindTexture("Folder Icon"));
            previewIcons.Add(LayerType.Normal.ToString(), EditorGUIUtility.IconContent("GameObject Icon").image);
            previewIcons.Add(LayerType.Color.ToString(), EditorGUIUtility.FindTexture("GameObject Icon"));
            previewIcons.Add(LayerType.Text.ToString(), EditorGUIUtility.IconContent("Text Icon").image);
            previewIcons.Add(LayerType.Complex.ToString(), EditorGUIUtility.IconContent("GameObject Icon").image);
            previewIcons.Add(LayerType.Overflow.ToString(), EditorGUIUtility.IconContent("GameObject Icon").image);
            previewIcons.Add("CANVAS", EditorGUIUtility.IconContent("GameObject Icon").image);
        }

        public void SetRoot(NodeTreeViewItem root) {
            this.root = root;
            ScanRoot(root);
        }

        protected override TreeViewItem BuildRoot() {
            if (root == null) {
                TreeViewItem n = new NodeTreeViewItem(0, -1, null);
                n.children = new List<TreeViewItem>();
                return n;
            } else {
                return root;
            }
        }

        protected override bool CanMultiSelect(TreeViewItem item) {
            return true;
        }

        protected override void SelectionChanged(IList<int> selectedIds) {
            base.SelectionChanged(selectedIds);
            foreach (int i in selectedIds) {
                NodeTreeViewItem item = GetNodeById(i);
                operVo.SetNodeItem(item);

                if (item.node.GetGameObject() != null) {
                    Selection.activeGameObject = item.node.GetGameObject();
                }
            }
        }

        private NodeTreeViewItem GetNodeById(int id) {
            if (root == null) {
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


        protected override void RowGUI(RowGUIArgs args) {
            var item = (NodeTreeViewItem)args.item;
            var node = item.node;

            if (Event.current.type == EventType.MouseDown && args.rowRect.Contains(Event.current.mousePosition))
                SelectionClick(args.item, false);

            for (int i = 0; i < args.GetNumVisibleColumns(); ++i) {
                var rect = args.GetCellRect(i);
                CenterRectUsingSingleLineHeight(ref rect);
                //Debug.Log(rect);
                var clums = args.GetColumn(i);
                if (clums == 0) {
                    GUI.Label(rect, (args.row + 1).ToString());
                } else if (clums == 1) {
                    Rect toggleRect = rect;
                    float space = GetContentIndent(item);
                    toggleRect.x += space;
                    toggleRect.width = 18f;

                    var texture = EditorGUIUtility.IconContent("GameObject Icon").image;
                    if (previewIcons.ContainsKey(node.GetLayerType().ToString())) {
                        texture = previewIcons[node.GetLayerType().ToString()];
                    }

                    GUI.DrawTexture(toggleRect, texture);

                    // args.rowRect = rect;
                    Rect tRect = rect;
                    tRect.x += (space + 18f);
                    GUI.Label(tRect, item.node.GetName());
                    // base.RowGUI(args);
                } else if (clums == 2) {
                    // string t = "图片";
                    // if (node.GetLayerType() == Ntreev.Library.Psd.LayerType.Text) {
                    //     t = "文字";
                    // } else if (node.GetLayerType() == Ntreev.Library.Psd.LayerType.Group) {
                    //     t = "组";
                    // } else {
                    //     t = "图片";
                    // }
                    // GUI.Label(rect, t);
                    string nv = node.GetNameVerify();
                    if (nv != null) {
                        GUI.Label(rect, nv);
                    }
                } else if (clums == 3) {
                    if (node.IsLocal()) {
                        GUI.Label(rect, "本地");
                    } else if (node.IsRepeated()) {
                        GUI.Label(rect, "生成");
                    }
                } else if (clums == 4) {
                    GUI.Label(rect, node.GetParamStr());
                }
            }
        }

        static MultiColumnHeaderState CreateDefaultMultiColumnHeaderState() {
            var columns = new[]
            {
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent(EditorGUIUtility.FindTexture("FilterByLabel"), "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "),
                    contextMenuText = "Asset",
                    headerTextAlignment = TextAlignment.Center,
                    sortedAscending = true,
                    sortingArrowAlignment = TextAlignment.Right,
                    width = 30,
                    minWidth = 30,
                    maxWidth = 60,
                    autoResize = false,
                    allowToggleVisibility = false
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent("Name"),
                    headerTextAlignment = TextAlignment.Left,
                    sortedAscending = true,
                    sortingArrowAlignment = TextAlignment.Center,
                    width = 200,
                    minWidth = 100,
                    autoResize = false,
                    allowToggleVisibility = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent(""), // verify
                    headerTextAlignment = TextAlignment.Left,
                    sortedAscending = true,
                    sortingArrowAlignment = TextAlignment.Center,
                    width = 50,
                    minWidth = 30,
                    maxWidth = 60,
                    autoResize = false,
                    allowToggleVisibility = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent(""), //local
                    headerTextAlignment = TextAlignment.Left,
                    sortedAscending = true,
                    sortingArrowAlignment = TextAlignment.Center,
                    width = 50,
                    minWidth = 30,
                    maxWidth = 60,
                    autoResize = false,
                    allowToggleVisibility = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent("Param"),
                    headerTextAlignment = TextAlignment.Left,
                    sortedAscending = true,
                    sortingArrowAlignment = TextAlignment.Center,
                    width = 100,
                    minWidth = 30,
                    maxWidth = 60,
                    autoResize = false,
                    allowToggleVisibility = true
                }
            };

            var state = new MultiColumnHeaderState(columns);
            return state;
        }
    }
}
