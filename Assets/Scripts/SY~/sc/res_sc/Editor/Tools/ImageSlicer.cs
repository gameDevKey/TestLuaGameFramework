//using System.Collections;
//using System.Collections.Generic;
//using System.IO;
//using UnityEditor;
//using UnityEngine;

///// <summary>
///// ���ܣ�ͼ���и��� �����Multiple��ʽ��ͼƬ��
///// ������ʽ��ѡ��ͼƬ��ѡ��༭���� Assets/ImageSlicer/Process to Sprites�˵�
///// </summary>
//public class ImageSlicer
//{
//    [MenuItem("Assets/ImageSlicer/Process to Sprites")]
//    static void ProcessToSprite()
//    {
//        Texture2D image = Selection.activeObject as Texture2D;  //��ȡѡȡ�Ķ���
//        string rootPath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(image)); //��ȡ·������
//        string path = rootPath + "/" + image.name + ".png";

//        TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter; //��ȡͼƬ���

//        AssetDatabase.CreateFolder(rootPath, image.name);

//        foreach (SpriteMetaData metaData in importer.spritesheet)   //����Сͼ��
//        {
//            Texture2D tex2d = new Texture2D((int)metaData.rect.width, (int)metaData.rect.height);

//            for (int y = (int)metaData.rect.y; y < metaData.rect.y + metaData.rect.height; y++) //Y������
//            {
//                for (int x = (int)metaData.rect.x; x < metaData.rect.x + metaData.rect.width; x++)
//                {
//                    tex2d.SetPixel(x - (int)metaData.rect.x, y - (int)metaData.rect.y, image.GetPixel(x, y));
//                }
//            }

//            //ת������EncodeToPNG���ݸ�ʽ
//            if (tex2d.format != TextureFormat.ARGB32 && tex2d.format != TextureFormat.RGB24)
//            {
//                Texture2D newTexture = new Texture2D(tex2d.width, tex2d.height);
//                newTexture.SetPixels(tex2d.GetPixels(0), 0);
//                tex2d = newTexture;
//            }
//            var pngData = tex2d.EncodeToPNG();

//            File.WriteAllBytes(rootPath + "/" + image.name + "/" + metaData.name + ".PNG", pngData);
//            //ˢ����Դ���ڽ���
//            AssetDatabase.Refresh();
//        }
//    }
//}