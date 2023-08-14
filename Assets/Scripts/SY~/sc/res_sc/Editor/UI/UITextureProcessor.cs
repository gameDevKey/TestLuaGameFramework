using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;

namespace EditorTools.UI
{
    public class UITextureProcessor : AssetPostprocessor
    {
        void OnPreprocessTexture()
        {
            //if (assetPath.EndsWith("Assets/Things/Textures/UI"))
            //{
            //    string atlasName = new DirectoryInfo(Path.GetDirectoryName(assetPath)).Name;
            //    TextureImporter importer = assetImporter as TextureImporter;
            //    importer.textureType = TextureImporterType.Sprite;
            //    importer.spritePackingTag = atlasName;
            //    importer.spriteImportMode = SpriteImportMode.Single;
            //    importer.mipmapEnabled = false;
            //    importer.isReadable = true;
            //    importer.anisoLevel = 0;

            //    AssetDatabase.ImportAsset(assetPath);
            //}
        }
    }

}
