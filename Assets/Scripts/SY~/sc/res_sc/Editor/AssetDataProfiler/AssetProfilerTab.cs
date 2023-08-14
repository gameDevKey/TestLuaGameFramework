using System.IO;
using UnityEditor;
using UnityEditor.IMGUI.Controls;
using UnityEngine;

namespace Tools
{
    internal class AssetProfilerTab<T> : AssetProfilerTabBase
		where T : UIAssetData
	{
		SearchField searchField;
		string[] displayNames;
		int searchIndex;
		int selectTarget;

		internal AssetProfilerTab(AssetProfilerData data,
			UIAssetHeadView headView) : base(data, headView)
        {
			searchField = new SearchField();

			state = new MultiColumnHeaderState(GetWizardColumns());
			multiColumnHeader = new MultiColumnHeader(state);
			multiColumnHeader.sortingChanged += this.headView.OnSortingChanged;
		}

		private MultiColumnHeaderState.Column[] GetWizardColumns()
		{
			displayNames = UIAssetData.GetWizardNames(typeof(T));

			MultiColumnHeaderState.Column[] columns = new MultiColumnHeaderState.Column[displayNames.Length];
			
			for(int index = 0;index != displayNames.Length;index++)
			{
				string displayName = displayNames[index];
				var column = new MultiColumnHeaderState.Column();
				column.headerContent = new GUIContent(displayName);
				column.headerTextAlignment = TextAlignment.Left;
				column.minWidth = 50;
				column.width = 100;
				column.canSort = true;
				column.autoResize = true;

				columns[index] = column;
			}

			return columns;
		}

		protected override void onGUI(Rect rect)
		{
			if (this.headView != null)
			{
				float searchOffset = platformTag() ? 400 : 200;

				Rect wRect = new Rect();
				wRect.x = rect.x;
				wRect.y = rect.y;
				wRect.width = rect.width - searchOffset;
				wRect.height = EditorGUIUtility.singleLineHeight;
				headView.searchString = searchField.OnGUI(wRect, headView.searchString);

				wRect.x = wRect.xMax;
				wRect.width = 200;
				searchIndex = EditorGUI.Popup(wRect, searchIndex, displayNames);
				headView.searchColumnIndex = headView.searchColumnIndex != searchIndex ? searchIndex : headView.searchColumnIndex;

				if(platformTag())
				{
					wRect.x = wRect.xMax;
					wRect.width = 40;
					EditorGUI.LabelField(wRect, "平台:");

					wRect.x = wRect.xMax;
					wRect.width = 160;
					int preTarget = selectTarget;
					string[] displayNames = new string[] { "PC", "Android", "IOS" };
					selectTarget = EditorGUI.Popup(wRect, selectTarget, displayNames);
					if(preTarget != selectTarget)
					{
						data.ForeachAssets<T>(
							(x) =>
							{
								BuildTarget target = BuildTarget.StandaloneWindows;
								if (selectTarget == 0)
								{
									target = BuildTarget.StandaloneWindows;
								}
								else if(selectTarget == 1)
								{
									target = BuildTarget.Android;
								}
								else if(selectTarget == 2)
								{
									target = BuildTarget.iOS;
								}
								x.SetData(target);
							}
						,null);
					}					
				}

				rect.y += EditorGUIUtility.singleLineHeight + 4;
				rect.height -= EditorGUIUtility.singleLineHeight;
				this.headView.OnGUI(rect);
			}
		}     

		internal override string hintStr()
		{
			return "Ctrl+滚轮可以放大缩小视图";
		}

		internal override bool exportData(string root)
		{
			string path = Path.Combine(root, tabName());
			return data.ExportData<T>(path);
		}

		internal override void Refresh()
		{
			UIAssetData[] dataList = data.getDataList<T>() as UIAssetData[];
			this.headView.Refresh(dataList, multiColumnHeader);
		}
	}
}
