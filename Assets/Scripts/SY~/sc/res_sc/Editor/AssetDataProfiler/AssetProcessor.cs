using UnityEditor;

namespace Tools
{
	internal class AssetProcessor : AssetPostprocessor
	{
		internal delegate void ImportAssetCallback(string path);
		internal static ImportAssetCallback reimportCallBack;
		internal static ImportAssetCallback deleteCallBack;

		static void OnPostprocessAllAssets(
			string[] importedAssets, 
			string[] deletedAssets,
			string[] movedAssets, 
			string[] movedFromAssetPaths)
		{
			if (reimportCallBack != null)
			{
				foreach (var path in importedAssets)
				{
					reimportCallBack.Invoke(path);
				}
			}

			if (deleteCallBack != null)
			{
				foreach (var path in deletedAssets)
				{
					deleteCallBack.Invoke(path);
				}
			}

			if (deleteCallBack != null)
			{
				foreach (var path in movedFromAssetPaths)
				{

					deleteCallBack.Invoke(path);

				}
			}

			if (reimportCallBack != null)
			{
				foreach (var path in movedAssets)
				{
					reimportCallBack.Invoke(path);
				}
			}
		}
	}
}
