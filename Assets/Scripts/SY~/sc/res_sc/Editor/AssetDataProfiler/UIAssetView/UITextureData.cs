using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Tools
{
	internal class UITextureData : UIAssetData
	{
		internal enum Compression
		{
			None = 0,
			NormalQuality,
			HighQuality,
			LowQuality,
		}

		[SetSortId(3)]
		internal int width;

		[SetSortId(4)]
		internal int height;

		[SetSortId(5)]
		internal bool isReadable;

		[SetSortId(6)]
		internal bool generateMipMap;

		[SetSortId(7)]
		internal bool generateBoardMipMap;

		[SetSortId(8)]
		internal TextureWrapMode wrapMode;

		[SetSortId(9)]
		internal FilterMode filterMode;

		[SetSortId(10)]
		internal int maxTextureSize;

		[SetSortId(11)]
		internal TextureFormat textureformat;

		[SetSortId(12)]
		internal Compression textureCompression;

		[SetSortId(13)]
		internal bool crunchedCompression;

		[SetSortId(14)]
		internal int compressionQuality;

		public UITextureData(Object asset) : base(asset)
		{

		}


		internal override void SetData(BuildTarget target)
		{
			this.platform = target == BuildTarget.NoTarget ? this.platform : target;

			Texture texture = this.asset as Texture;
			width = texture.width;
			height = texture.height;

			TextureImporter import =
				importer as TextureImporter;
			
			isReadable = import.isReadable;
			generateMipMap = import.mipmapEnabled;
			generateBoardMipMap = import.borderMipmap;
			wrapMode = import.wrapMode;
			filterMode = import.filterMode;


			ColorSpace colorSpace;
			TextureImporterFormat textureFormat;
			import.ReadTextureImportInstructions(target, out textureformat, out colorSpace, out compressionQuality);

			textureCompression = (Compression)System.Enum.ToObject(
				typeof(Compression), (int)import.textureCompression);
			maxTextureSize = import.maxTextureSize;
			crunchedCompression = import.crunchedCompression;
		}
	}
}