using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System;
using UnityEditor.IMGUI.Controls;

namespace Tools
{
	internal class AssetProfilerTabBase 
	{
		protected AssetProfilerData data;
		
		bool guiInited = false;
		

		internal AssetProfilerTabBase(AssetProfilerData data,
			UIAssetHeadView headView)
		{
			this.data = data;
			this.headView = headView;
			this.FillData();
		}

		virtual protected string tabName()
		{
			return "默认标签";
		}

		internal bool drawTabButton(bool select, params GUILayoutOption[] options)
		{
			var colorHold = GUI.backgroundColor;
			GUI.backgroundColor = select ? Color.magenta : colorHold;
			var click = GUILayout.Button(this.tabName(), options);
			GUI.backgroundColor = colorHold;

			return click;
		}

		internal bool drawExportButton(Rect rect)
		{
			var colorHold = GUI.backgroundColor;
			GUI.backgroundColor = Color.green;
			var click = GUI.Button(rect, "导出数据");
			GUI.backgroundColor = colorHold;

			return click;
		}

		internal void drawContent(Rect rect)
		{
			if (!this.guiInited)
			{
				this.initGUI();
				this.guiInited = true;
			}

			this.onGUI(rect);
		}

		virtual protected void initGUI()
		{
		}

		virtual protected void FillData()
		{

		}

		virtual protected void onGUI(Rect rect)
		{
			EditorGUILayout.LabelField("默认内容");
		}

		virtual protected Rect drawFilter(Rect rect)
		{
			EditorGUILayout.LabelField("默认内容");
			return rect;
		}

		virtual protected bool platformTag()
		{
			return false;
		}

		virtual internal string hintStr()
		{
			return "";
		}

		virtual internal bool exportData(string root)
		{
			return true;
		}

		virtual internal void Refresh()
		{	
		}



		protected UIAssetHeadView headView;
		protected MultiColumnHeaderState state;
		internal MultiColumnHeader multiColumnHeader { get; set; }

		internal string searchString
		{
			get{
				return headView.searchString;
			}set
			{
				headView.searchString = value;
			}
		}
	}
}