using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Tools
{
	internal class UIMeshData : UIAssetData
	{
		[SetSortId(2)]
		internal int subMesh;
		[SetSortId(3)]
		internal int vertices;
		[SetSortId(4)]
		internal int tris;
		[SetSortId(5)]
		internal int normal;
		[SetSortId(6)]
		internal int tangents;
		[SetSortId(7)]
		internal int color;
		[SetSortId(8)]
		internal int uv;
		[SetSortId(9)]
		internal int uv2;
		[SetSortId(10)]
		internal int uv3;
		[SetSortId(11)]
		internal int uv4;

		public UIMeshData(Object asset) : base(asset)
		{
		}

		internal override void SetData(BuildTarget target)
		{
			Mesh mesh = this.asset as Mesh;

			subMesh = mesh.subMeshCount;
			vertices = mesh.vertexCount;
			tris = mesh.triangles.Length / 3;
			normal = mesh.normals.Length;
			tangents = mesh.tangents.Length;
			color = mesh.colors.Length;

			uv = mesh.uv.Length;
			uv2 = mesh.uv2.Length;
			uv3 = mesh.uv3.Length;
			uv4 = mesh.uv4.Length;
		}
	}
}
