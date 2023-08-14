using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Tools
{
	internal enum PlatForm
	{
		Standalone,
		Android,
		IOS,
	}

	internal static class AssetPathTool
	{
		internal static string RelativePath(string assetPath)
		{
			return assetPath.Substring(assetPath.IndexOf("Asset"));
		}
	}
}
