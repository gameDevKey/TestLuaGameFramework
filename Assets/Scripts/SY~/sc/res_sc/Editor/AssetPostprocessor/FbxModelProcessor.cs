// using System;
// using UnityEngine;
// using UnityEditor;
// using System.Collections;
// using System.Collections.Generic;

// namespace EditorTools.Asset {
//     /// <summary>
//     /// 模型FBX文件导入后处理
//     /// 1.importMaterials = false
//     /// 2.AnimationType = Legacy
//     /// 3.将FBX文件中的AnimationClip提取出来，生成独立的AnimationClip文件
//     /// </summary>
//     public class FbxModelProcessor : AssetPostprocessor {

//         private void OnPreprocessModel() {
//             ModelImporter importer = assetImporter as ModelImporter;
//             if (importer != null) {
//                 // importer.globalScale = 0.01f;
//                 importer.importMaterials = false;
//                 importer.importNormals = ModelImporterNormals.None;
//                 importer.importTangents = ModelImporterTangents.None;
//                 importer.animationType = ModelImporterAnimationType.Legacy;
//             }
//         }

//         private void OnPreprocessAnimation() {
//             ModelImporter importer = assetImporter as ModelImporter;
//             if (importer != null) {
//             }
//             
//         }

//         private void OnPostprocessModel(GameObject go) {
//             ModelImporter importer = assetImporter as ModelImporter;
//             if (importer != null) {
//                 AnimationClip[] clips = AnimationUtility.GetAnimationClips(go);
//                 if (clips.Length > 1) {
//                     //暂时默认一个fbx只包含一个AnimationClip资源
//                     EditorUtility.DisplayDialog("错误", "一个模型文件中只能包含一个AnimationClip对象", "马上处理~~~");
//                     throw new Exception("一个模型文件中只能包含一个AnimationClip对象");
//                 }
//                 for (int i = 0; i < clips.Length; i++) {
//                     AnimationClip clip = clips[i];
//                     AnimationClip copy = new AnimationClip();
//                     EditorUtility.CopySerialized(clip, copy);
//                     string copyPath = assetPath.Replace(".FBX", ".anim");
//                     copyPath = copyPath.Replace(".fbx", ".anim");
//                     AssetDatabase.CreateAsset(copy, copyPath);
//                 }
//             }
//         }

//     }
// }

