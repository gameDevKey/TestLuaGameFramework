using Ntreev.Library.Psd;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.IMGUI.Controls;
using UnityEngine;

namespace PsdUIExporter {
    public class MultiColumnTreeView : TreeView {

        private static int id;
        private NodeTreeViewItem root = null;
        private OperableVO operVo = null;
        private readonly List<TreeViewItem> rows = new List<TreeViewItem>();
        private Dictionary<string, Texture> previewIcons = new Dictionary<string, Texture>();

        const float kRowHeights = 20f;
        const float kToggleWidth = 18f;

        private Dictionary<int, NodeTreeViewItem> itemDict = new Dictionary<int,NodeTreeViewItem>();

        // Sort options per column
        SortOption[] m_SortOptions = 
		{
			SortOption.Name, 
			SortOption.Name, 
			SortOption.Value1, 
			SortOption.Value2,
			SortOption.Value3
		};

        public MultiColumnTreeView(TreeViewState state, NodeTreeViewItem root, OperableVO operVo) : base(state) {
            this.root = root;
            this.operVo = operVo;
            // if (root != null) {
            //     foreach (NodeTreeViewItem item in root.children) {
            //         rows.Add(item);
            //     }
            // }
            var m_MultiColumnHeaderState = CreateDefaultMultiColumnHeaderState();
            this.multiColumnHeader = new MultiColumnHeader(m_MultiColumnHeaderState);
            this.multiColumnHeader.canSort = true;
            this.multiColumnHeader.sortingChanged += OnSortingChanged;

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

        protected override TreeViewItem BuildRoot() {
            if (root == null) {
                TreeViewItem n = new NodeTreeViewItem(0, -1, null);
                n.children = new List<TreeViewItem>();
                return n;
            } else {
                return root;
            }
        }

        protected override IList<TreeViewItem> BuildRows(TreeViewItem root) {
            if (root == null) {
                return new List<TreeViewItem>();
            } else {
                List<TreeViewItem> list = root.children;
                if (list == null) {
                    return new List<TreeViewItem>();
                } else {
                    if (!string.IsNullOrEmpty(searchString)) {
                        rows.Clear();
                        foreach (TreeViewItem item in list) {
                            if (item.displayName.IndexOf(searchString, StringComparison.OrdinalIgnoreCase) >= 0) {
                                rows.Add(item);
                            }
                        }
                        return rows;
                    }
                    return list;
                }
            }
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

        void OnSortingChanged(MultiColumnHeader multiColumnHeader) {
            SortIfNeeded(rootItem, GetRows());
        }

        void SortIfNeeded(TreeViewItem root, IList<TreeViewItem> rows) {
            if (rows.Count <= 1)
                return;

            if (multiColumnHeader.sortedColumnIndex == -1) {
                return; // No column to sort for (just use the order the data are in)
            }

            SortByMultipleColumns();
            Reload();
        }

        void SortByMultipleColumns() {
            var sortedColumns = multiColumnHeader.state.sortedColumns;
            if (sortedColumns.Length == 0)
                return;
            var items = rootItem.children.Cast<NodeTreeViewItem>();
            var sorted = InitialOrder(items, sortedColumns);
            rootItem.children = sorted.Cast<TreeViewItem>().ToList();
        }

        IOrderedEnumerable<NodeTreeViewItem> InitialOrder(IEnumerable<NodeTreeViewItem> myTypes, int[] history) {
            SortOption sortOption = m_SortOptions[history[0]];
            bool ascending = multiColumnHeader.IsSortedAscending(history[0]);
            switch (sortOption) {
                case SortOption.Name:
                    return myTypes.Order(l => l.node.GetName(), ascending);
                case SortOption.Value1:
                    return myTypes.Order(l => {
                            return l.node.GetNameVerify();
                    }, ascending);
                case SortOption.Value2:
                    return myTypes.Order(l => {
                        if (l.node.IsLocal()) {
                            return "本地";
                        } else if (l.node.IsRepeated()) {
                            return "生成";
                        } else {
                            return "-";
                        }
                    }, ascending);
                case SortOption.Value3:
                    return myTypes.Order(l => l.node.IsPublic(), ascending);
                default:
                    // Assert.IsTrue(false, "Unhandled enum");
                    break;
            }
            // default
            return myTypes.Order(l => l.node.GetName(), ascending);
        }

        public void SetRoot(NodeTreeViewItem root) {
            this.root = root;
            ScanRoot(root);
        }

        protected override bool CanMultiSelect(TreeViewItem item) {
            return true;
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
                string t = null;
                switch (clums) {
                    case 0:
                        GUI.Label(rect, (args.row + 1).ToString());
                        break;
                    case 1:
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
                    	// base.RowGUI(args);
                        Rect tRect = rect;
                    	tRect.x += (space + 18f);
                    	GUI.Label(tRect, item.node.GetName());
                        break;
                    case 2:
                        t = node.GetNameVerify();
                        GUI.Label(rect, t);
                        break;
                    case 3:
                        t = "";
                        if (node.IsLocal()) {
                            t = "本地";
                    	} else if (node.IsRepeated()) {
                            t = "生成";
                    	}
                        GUI.Label(rect, t);
                        break;
                    case 4:
                        t = "公";
                        if (item.node.IsPublic()) {
                            t = "公";
                        } else {
                            t = "私";
                        }
                        GUI.Label(rect, t);
                        break;
                    default:
                        GUI.Label(rect, item.node.GetName());
                        break;
                }
            }
        }

        static MultiColumnHeaderState CreateDefaultMultiColumnHeaderState() {
            var columns = new[]
            {
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent(EditorGUIUtility.FindTexture("FilterByLabel")),
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
                    minWidth = 60,
                    autoResize = false,
                    allowToggleVisibility = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent("verify"),
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
                    headerContent = new GUIContent("Create"),
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
                    headerContent = new GUIContent("Type"),
                    headerTextAlignment = TextAlignment.Left,
                    sortedAscending = true,
                    sortingArrowAlignment = TextAlignment.Center,
                    width = 25,
                    minWidth = 30,
                    maxWidth = 60,
                    autoResize = false,
                    allowToggleVisibility = true
                }
            };

            var state = new MultiColumnHeaderState(columns);
            return state;
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
    }


    static class MyExtensionMethods {
        public static IOrderedEnumerable<T> Order<T, TKey>(this IEnumerable<T> source, Func<T, TKey> selector, bool ascending) {
            if (ascending) {
                return source.OrderBy(selector);
            } else {
                return source.OrderByDescending(selector);
            }
        }

        public static IOrderedEnumerable<T> ThenBy<T, TKey>(this IOrderedEnumerable<T> source, Func<T, TKey> selector, bool ascending) {
            if (ascending) {
                return source.ThenBy(selector);
            } else {
                return source.ThenByDescending(selector);
            }
        }
    }

    public enum SortOption {
        Name,
        Value1,
        Value2,
        Value3,
    }
}
