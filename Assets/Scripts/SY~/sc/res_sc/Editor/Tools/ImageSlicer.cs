//using System.Collections;
//using System.Collections.Generic;
//using System.IO;
//using UnityEditor;
//using UnityEngine;

///// <summary>
///// 功能：图集切割器 （针对Multiple格式的图片）
///// 操作方式：选中图片，选择编辑器的 Assets/ImageSlicer/Process to Sprites菜单
///// </summary>
//public class ImageSlicer
//{
//    [MenuItem("Assets/ImageSlicer/Process to Sprites")]
//    static void ProcessToSprite()
//    {
//        Texture2D image = Selection.activeObject as Texture2D;  //获取选取的对象
//        string rootPath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(image)); //获取路径名称
//        string path = rootPath + "/" + image.name + ".png";

//        TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter; //获取图片入口

//        AssetDatabase.CreateFolder(rootPath, image.name);

//        foreach (SpriteMetaData metaData in importer.spritesheet)   //遍历小图集
//        {
//            Texture2D tex2d = new Texture2D((int)metaData.rect.width, (int)metaData.rect.height);

//            for (int y = (int)metaData.rect.y; y < metaData.rect.y + metaData.rect.height; y++) //Y轴像素
//            {
//                for (int x = (int)metaData.rect.x; x < metaData.rect.x + metaData.rect.width; x++)
//                {
//                    tex2d.SetPixel(x - (int)metaData.rect.x, y - (int)metaData.rect.y, image.GetPixel(x, y));
//                }
//            }

//            //转换纹理到EncodeToPNG兼容格式
//            if (tex2d.format != TextureFormat.ARGB32 && tex2d.format != TextureFormat.RGB24)
//            {
//                Texture2D newTexture = new Texture2D(tex2d.width, tex2d.height);
//                newTexture.SetPixels(tex2d.GetPixels(0), 0);
//                tex2d = newTexture;
//            }
//            var pngData = tex2d.EncodeToPNG();

//            File.WriteAllBytes(rootPath + "/" + image.name + "/" + metaData.name + ".PNG", pngData);
//            //刷新资源窗口界面
//            AssetDatabase.Refresh();
//        }
//    }
//}