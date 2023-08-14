using System;
using System.Reflection;
using System.Text;
using System.IO;
using System.Collections.Generic;
using UnityEditor.IMGUI.Controls;
using UnityEditor;

namespace Tools
{
	//数据层
	internal class UIAssetData : TreeViewItem
	{
		private class AssetCompare : IComparer<FieldInfo>
		{
			public int Compare(FieldInfo x, FieldInfo y)
			{
				int a = 0;
				int b = 0;

				var propertyA = x.GetCustomAttributes(typeof(SetSortIdAttribute), false);
				if (propertyA.Length > 0)
				{
					var property = (SetSortIdAttribute)propertyA[0];
					a = property.SortId;
				}

				var propertyB = y.GetCustomAttributes(typeof(SetSortIdAttribute), false);
				if (propertyB.Length > 0)
				{
					var property = (SetSortIdAttribute)propertyB[0];
					b = property.SortId;
				}
				if (a < b)
					return -1;
				else if (b > a)
					return 1;

				return 0;
			}
		}
		static char Separator = ',';

		[SetSortId(0)]
		protected string name;

		[SetSortId(1)]
		internal string assetPath;

		internal BuildTarget platform { get; set; }

		internal UnityEngine.Object asset { get; private set; }

		protected AssetImporter importer { get; private set; }

		internal UIAssetData(UnityEngine.Object asset)
		{
			this.asset = asset;
			this.assetPath = AssetDatabase.GetAssetPath(asset);
			this.name = this.asset.name;

			this.importer = AssetImporter.GetAtPath(this.assetPath);
			this.platform = BuildTarget.StandaloneWindows;
			this.SetData(platform);
		}

		internal string GetFieldNames()
		{
			StringBuilder builder = new StringBuilder();

			var fields = this.GetType().GetFields(
				BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.DeclaredOnly);

			builder.Append("name");
			builder.Append(Separator);
			builder.Append("assetPath");
			builder.Append(Separator);

			foreach (var field in fields)
			{
				string value = field.Name;
				builder.Append(value);
				builder.Append(Separator);
			}
			return builder.ToString();
		}

		internal string GetFieldValue()
		{
			StringBuilder builder = new StringBuilder();

			var fields = this.GetType().GetFields(
				BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.DeclaredOnly);

			builder.Append(name);
			builder.Append(Separator);
			builder.Append(assetPath);
			builder.Append(Separator);

			foreach (var field in fields)
			{
				string value = field.GetValue(this).ToString();
				builder.Append(value);
				builder.Append(Separator);
			}
			return builder.ToString();
		}

		internal static object GetData(UIAssetData data, string fieldName)
		{	
			var fields = data.GetType().GetField(fieldName,
				BindingFlags.Instance | BindingFlags.NonPublic);

			return fields.GetValue(data);
		}

		internal static string[] GetWizardNames(Type dataType)
		{
			var fields = dataType.GetFields(
				BindingFlags.Instance | BindingFlags.NonPublic);
			Array.Sort(fields, new AssetCompare());

			string[] fieldNames = new string[fields.Length];
			for (int index = 0;index != fields.Length;index++)
			{
				var field = fields[index];
				fieldNames[index] = field.Name;
			}

			return fieldNames;
		}

		internal virtual void SetData(BuildTarget platform)
		{

		}
	}
}

