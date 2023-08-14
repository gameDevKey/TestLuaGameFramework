using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace Tools
{
	internal class UIParticleSystemData : UIAssetData
	{
		[SetSortId(3)]
		internal int materials;

		[SetSortId(4)]
		internal int particles;

		public UIParticleSystemData(Object asset) : base(asset)
		{
		}

		internal override void SetData(BuildTarget target)
		{
			GameObject prefab = asset as GameObject;  
			var renderes = prefab.GetComponentsInChildren<Renderer>();
			HashSet<Material> objHash = new HashSet<Material>();

			foreach (var render in renderes)
			{
				foreach (var mat in render.sharedMaterials)
				{
					objHash.Add(mat);
				}
			}

			var particleSystem = prefab.GetComponentsInChildren<ParticleSystem>();
			foreach (var particle in particleSystem)
			{
				particles += particle.main.maxParticles;
			}

			materials = objHash.Count;
		}
	}
}
