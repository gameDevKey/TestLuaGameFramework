// using System;
// using UnityEngine;
// using UnityEditor;
// using System.Collections;
// using System.Collections.Generic;
// using System.Text.RegularExpressions;
// using System.IO;
// 
// namespace EditorTools.Asset {
//     /// <summary>
//     /// NPC模型FBX文件导入后处理
//     /// 1.importMaterials = false
//     /// 2.AnimationType = Legacy
//     /// 3.将FBX文件中的AnimationClip提取出来，生成独立的AnimationClip文件
//     /// </summary>
//     public class NpcFbxModelProcessor : AssetPostprocessor {
// 
//         public static Regex npcFbxReg = new Regex (@"Assets/Things/Unit/Npc/AnimationFbx/(\d+)/(\w+)\.FBX", RegexOptions.IgnoreCase);
//         public static Regex npcModelReg = new Regex (@"Assets/Things/Unit/Npc/Model/(\w+)\.FBX", RegexOptions.IgnoreCase);
// 
//         private void OnPreprocessModel() {
//             if (IsMatch (npcFbxReg, assetPath) || IsMatch(npcModelReg, assetPath)) {
//                 ModelImporter importer = assetImporter as ModelImporter;
//                 if (importer != null) {
//                     // importer.globalScale = 0.01f;
//                     importer.importMaterials = false;
//                     importer.importNormals = ModelImporterNormals.None;
//                     importer.importTangents = ModelImporterTangents.None;
//                     importer.animationType = ModelImporterAnimationType.Legacy;
//                 }
//             }
//         }
// 
//         private void OnPreprocessAnimation() {
//             ModelImporter importer = assetImporter as ModelImporter;
//             if (importer != null) {
//             }
//             
//         }
// 
//         private void OnPostprocessModel(GameObject go) {
//             if (IsMatch (npcFbxReg, assetPath)) {
//                 string animationId = npcFbxReg.Match (assetPath).Groups[1].Value;
//                 string name = npcFbxReg.Match (assetPath).Groups[2].Value;
//                 string dir = "Assets/Things/Unit/Npc/Animation/" + animationId;
//                 string copyPath = dir + "/" + name + ".anim";
//                 if (!Directory.Exists (dir)) {
//                     Directory.CreateDirectory (dir);
//                 }
//                 ModelImporter importer = assetImporter as ModelImporter;
//                 string path = importer.assetPath;
//                 if (importer != null) {
//                     AnimationClip[] clips = AnimationUtility.GetAnimationClips (go);
//                     if (clips.Length > 1) {
//                         //暂时默认一个fbx只包含一个AnimationClip资源
//                         EditorUtility.DisplayDialog ("错误", "一个模型文件中只能包含一个AnimationClip对象", "马上处理~~~");
//                         throw new Exception ("一个模型文件中只能包含一个AnimationClip对象");
//                     }
//                     for (int i = 0; i < clips.Length; i++) {
//                         AnimationClip clip = clips[i];
//                         AnimationClip copy = new AnimationClip ();
//                         EditorUtility.CopySerialized (clip, copy);
//                         AssetDatabase.CreateAsset (copy, copyPath);
//                         if (name.Contains ("move") || name.Contains ("stand")) {
//                             AnimationClip newClip = AssetDatabase.LoadAssetAtPath (copyPath, typeof (AnimationClip)) as AnimationClip;
//                             newClip.wrapMode = WrapMode.Loop;
//                         }
//                     }
//                 }
//             }
//         }
// 
//         static bool IsMatch (Regex regex, string path) {
//             if (path != null && regex.IsMatch (path)) {
//                 return true;
//             } else {
//                 return false;
//             }
//         }
//     }
// }
