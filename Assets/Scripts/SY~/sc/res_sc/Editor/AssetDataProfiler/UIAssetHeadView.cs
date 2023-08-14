using UnityEditor.IMGUI.Controls;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using System.Linq;
using UnityEditor;
using System;

namespace Tools
{
	internal sealed class UIAssetHeadView : TreeView
	{
		static readonly int DefaultId = 0;
		//默认使用搜索第一列
		internal int searchColumnIndex = 0;

		int viewSize = 12;
		int maxViewSize = 15;

		internal class ColumnComparer : IComparer<UIAssetData>
		{
			string name;
			bool order;

			internal ColumnComparer(string name, bool order)
			{
				this.name = name;
				this.order = order;
			}

			private object getCompareValue(UIAssetData data)
			{
				var field = data.GetType().GetField(
					name, BindingFlags.Instance | BindingFlags.NonPublic);

				object value = field.GetValue(data);
				return field.GetValue(data);
			}

			public int Compare(UIAssetData x, UIAssetData y)
			{
				var value1 = getCompareValue(x);
				var value2 = getCompareValue(y);

				if (value1 is string)
				{
					string z = System.Convert.ToString(value1);
					string w = System.Convert.ToString(value2);

					if (order)
					{
						return string.Compare(w, z);
					}
					else
					{
						return string.Compare(z, w);
					}
				}
				else
				{
					float z = System.Convert.ToSingle(value1);
					float w = System.Convert.ToSingle(value2);
					if (z > w)
						return order ? -1 : 1;
					if (z < w)
						return order ? 1 : -1;
				}
				return 0;
			}
		}

		List<UIAssetData> m_SourceData = new List<UIAssetData>();

		public UIAssetHeadView(TreeViewState state) : base(state)
		{
			showBorder = true;
			showAlternatingRowBackgrounds = true;
		}

		internal void Refresh(UIAssetData[] dataList,
			MultiColumnHeader header)
		{
			m_SourceData.Clear();

			this.multiColumnHeader = header;
			m_SourceData.AddRange(dataList);

			this.Reload();
		}

		internal void OnSortingChanged(MultiColumnHeader multiColumnHeader)
		{
			SortIfNeeded(rootItem, GetRows());
		}


		protected override void RowGUI(RowGUIArgs args)
		{
			GUIStyle labelStyle = new GUIStyle(EditorStyles.label);
			labelStyle.alignment = TextAnchor.MiddleLeft;
			labelStyle.fontSize = viewSize;

			for (int i = 0; i < args.GetNumVisibleColumns(); ++i)
			{
				UIAssetData item = args.item as UIAssetData;
				Rect rect = args.GetCellRect(i);
				var content = multiColumnHeader.GetColumn(i).headerContent;

				object value = UIAssetData.GetData(item, content.text);
				if(value.GetType().IsEnum)
				{
					string objValue = value.ToString();
					if(objValue == "-1")
					{
						value = (object)Enum.GetName(value.GetType(),0);
					}
				}
				string label = value.ToString();
				EditorGUI.LabelField(rect, label, labelStyle);
			}
		}

		protected override IList<TreeViewItem> BuildRows(TreeViewItem root)
		{
			var rows = base.BuildRows(root);
			SortIfNeeded(root, rows);
			return rows;
		}

		void SortIfNeeded(TreeViewItem root, IList<TreeViewItem> rows)
		{
			if (rows.Count <= 1 || multiColumnHeader.sortedColumnIndex == -1)
				return;

			SortByColumn();

			rows.Clear();
			for (int i = 0; i < root.children.Count; i++)
				rows.Add(root.children[i]);

			Repaint();
		}

		void SortByColumn()
		{
			var sortedColumns = multiColumnHeader.state.sortedColumns;

			List<UIAssetData> assetList = new List<UIAssetData>();
			foreach (var item in rootItem.children)
			{
				assetList.Add(item as UIAssetData);
			}

			var sortedColumnIndex = multiColumnHeader.state.sortedColumnIndex;
			var ascending = multiColumnHeader.IsSortedAscending(sortedColumnIndex);
			var content = multiColumnHeader.GetColumn(sortedColumnIndex).headerContent;

			assetList.Sort(new ColumnComparer(content.text, ascending));
			rootItem.children = assetList.Cast<TreeViewItem>().ToList();
		}

		protected override TreeViewItem BuildRoot()
		{
			TreeViewItem root = new TreeViewItem(0, -1, "root");

			int id = 0;
			foreach (var item in m_SourceData)
			{
				item.id = ++id;
				item.depth = DefaultId;
				root.AddChild(item);
			}

			return root;
		}

		protected override void SelectionChanged(IList<int> selectedIds)
		{
			var assetItem = FindItem(selectedIds[0], rootItem) as UIAssetData;
			if (assetItem != null)
			{
				UnityEngine.Object o = assetItem.asset;
				EditorGUIUtility.PingObject(o);
				Selection.activeObject = o;
			}
		}

		protected override bool CanBeParent(TreeViewItem item)
		{
			return false;
		}
		//自定义的搜索的功能，由于我们没给displayName 添加值所以自定义搜索功能 
		protected override bool DoesItemMatchSearch(TreeViewItem item, string search)
		{
			UIAssetData data = item as UIAssetData;
			var columnHead = multiColumnHeader.GetColumn(searchColumnIndex);
			if(columnHead != null)
			{
				string fieldName = columnHead.headerContent.text;
				string displayName = UIAssetData.GetData(data, fieldName).ToString();
				return displayName.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;
			}
			return false;
		}

		public override void OnGUI(Rect rect)
		{
			var eve = Event.current;
			if (eve.control && eve.isScrollWheel)
			{
				viewSize = eve.delta.y < 0 ? Math.Min(maxViewSize, ++viewSize) : Math.Max(12, --viewSize);
			}
			rowHeight = rowHeight != viewSize ? viewSize + 2 : rowHeight;
			base.OnGUI(rect);
		}
	}
}
