using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace Tools
{
	internal class AssetProfilerData
	{
		class TypeObjs<T> where T : UIAssetData
		{
			List<T> datas = new List<T>();
			//一个资源路径可能包含多个资源			
			Dictionary<string, List<T>> lookup = new Dictionary<string, List<T>>();
			List<UnityEngine.Object> record = new List<UnityEngine.Object>();

			internal TypeObjs()
			{
			}

			internal void FillData(UIAssetData[] objs)
			{
				foreach (var o in objs)
				{
					if (o is T)
					{
						var obj = (T)o;

						List<T> table = new List<T>();
						if (!lookup.TryGetValue(obj.assetPath, out table))
						{
							table = new List<T>();
							lookup.Add(obj.assetPath, table);
						}
						datas.Add(obj);
						table.Add(obj);

						record.Add(obj.asset);
					}
				}
			}


			internal void foreachData(System.Action<T> action)
			{
				foreach (var com in this.datas)
				{
					action(com);
				}
			}

			internal void foreachData(System.Action<T> action, IComparer<T> comparer)
			{
				if (comparer == null)
				{
					foreachData(action);
					return;
				}
				List<T> list = datas.ToList();
				list.Sort(comparer);
				foreach (var com in list)
				{
					action(com);
				}
			}

			internal T[] getData()
			{
				return datas.ToArray();
			}

			internal void CreateAsset(T data)
			{
				string path = UnityEditor.AssetDatabase.GetAssetPath(data.asset);
				//已存在的对象
				if(record.Contains(data.asset))
				{
					List<T> table;
					if(lookup.TryGetValue(path,out table))
					{
						foreach(var edata in table)
						{
							edata.SetData(UnityEditor.BuildTarget.NoTarget);
						}
					}
				}
				else
				{		
					List<T> table;
					if(!lookup.TryGetValue(path,out table))
					{
						table = new List<T>();
						lookup.Add(path, table);
					}
					datas.Add(data);
					table.Add(data);
					record.Add(data.asset);
				}
			}

			internal void DeleteAsset(string path)
			{
				List<T> table;
				if (lookup.TryGetValue(path,out table))
				{
					foreach(var data in table)
					{
						datas.Remove(data);
						record.Remove(data.asset);
					}
				}
				lookup.Remove(path);
			}
		}

		Dictionary<System.Type, object> data = new Dictionary<System.Type, object>();

		TypeObjs<T> getData<T>() where T : UIAssetData
		{
			object obj;
			if (data.TryGetValue(typeof(T), out obj))
			{
				return obj as TypeObjs<T>;
			}
			return null;
		}

		internal T[] getDataList<T>() where T : UIAssetData
		{
			object obj;
			if (data.TryGetValue(typeof(T), out obj))
			{
				var typeObj = obj as TypeObjs<T>;
				return typeObj.getData();
			}
			return null;
		}


		internal bool ExportData<T>(string fileName) where T : UIAssetData
		{
			var typeObjs = getData<T>();
			fileName = Path.ChangeExtension(fileName, ".csv");
			StringBuilder builder = new StringBuilder();
			bool rootFirst = true;
			typeObjs.foreachData((assetData) =>
			{
				if (rootFirst)
				{
					builder.AppendLine(assetData.GetFieldNames());
					rootFirst = false;
				}
				builder.AppendLine(assetData.GetFieldValue());
			});
			File.WriteAllText(fileName, builder.ToString());
			
			return true;
		}

		internal void FillData<T>(UIAssetData[] objs) where T : UIAssetData
		{
			System.Type type = typeof(T);
			object typeObjes;
			if (!data.TryGetValue(type,out typeObjes))
			{
				typeObjes = new TypeObjs<T>();

				data.Add(type, typeObjes);
			}

			TypeObjs<T> collection = typeObjes as TypeObjs<T>;
			collection.FillData(objs);
		}

		internal void ForeachAssets<T>(Action<T> action, IComparer<T> comparer) where T : UIAssetData
		{
			var typeObjs = getData<T>();
			if (typeObjs != null)
			{
				typeObjs.foreachData(action, comparer);
			}
		}

		internal void CreateData<T>(UnityEngine.Object obj, Type dataType) where T : UIAssetData
		{
			var typeObjs = getData<T>();
			if (typeObjs != null)
			{
				object data = Activator.CreateInstance(dataType, (object)obj);
				if(data is T)
				{ 
					typeObjs.CreateAsset((T)data);
				}
			}
		}

		internal void DeleteData<T>(string path) where T : UIAssetData
		{
			var typeObjs = getData<T>();
			if (typeObjs != null)
			{
				typeObjs.DeleteAsset(path);
			}
		}

		internal void clear()
		{
			this.data.Clear();
		}
	}	
}