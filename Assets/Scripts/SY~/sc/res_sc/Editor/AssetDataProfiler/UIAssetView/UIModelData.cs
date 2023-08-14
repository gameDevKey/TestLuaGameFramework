using UnityEditor;
using UnityEngine;

namespace Tools
{
	internal class UIModelData : UIAssetData
	{
		[SetSortId(2)]
		internal ModelImporterMeshCompression meshCompression;

		[SetSortId(3)]
		internal bool isReadable;

		[SetSortId(4)]
		internal bool optimizeMesh;

		[SetSortId(5)]
		internal ModelImporterAnimationType animationType;

		[SetSortId(6)]
		internal bool addCollider;

		[SetSortId(7)]
		internal ModelImporterIndexFormat indexFormat;

		[SetSortId(8)]
		internal bool weldVertices;

		[SetSortId(9)]
		internal bool importVisibility;

		[SetSortId(10)]
		internal bool importCameras;

		[SetSortId(11)]
		internal bool importLights;

		[SetSortId(12)]
		internal bool preserveHierarchy;

		[SetSortId(13)]
		internal bool swapUVChannels;

		[SetSortId(14)]
		internal bool generateSecondaryUV;


		public UIModelData(Object asset) : base(asset)
		{

		}
		internal override void SetData(BuildTarget target)
		{
			ModelImporter modelImpoer = importer as ModelImporter;

			meshCompression = modelImpoer.meshCompression;
			isReadable = modelImpoer.isReadable;
			optimizeMesh = modelImpoer.optimizeMesh;
			animationType = modelImpoer.animationType;
			addCollider = modelImpoer.addCollider;

			indexFormat = modelImpoer.indexFormat;
			weldVertices = modelImpoer.weldVertices;

			importVisibility = modelImpoer.importVisibility;
			importCameras = modelImpoer.importCameras;
			importLights = modelImpoer.importLights;
			preserveHierarchy = modelImpoer.preserveHierarchy;
			swapUVChannels = modelImpoer.swapUVChannels;
			generateSecondaryUV = modelImpoer.generateSecondaryUV;
		}
	}
}
