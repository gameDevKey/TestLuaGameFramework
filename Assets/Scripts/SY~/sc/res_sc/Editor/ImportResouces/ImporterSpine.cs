using UnityEngine;
using UnityEditor;
using System.Text.RegularExpressions;
using System.IO;

/// <summary>
/// 2D动画资源导入
/// </summary>
class ImporterSpine : EditorWindow
{
    private static Regex pattern = new Regex(@"Assets/Art/spine/");
    private static string output = "Assets/Things/spine/";

    public static Regex assetPath = new Regex(@"(\d+)", RegexOptions.IgnoreCase);

    [MenuItem("Assets/生成场景元素Spine")]
    public static void CreateSpinePrefab()
    {
        
        Object[] selections = Selection.GetFiltered(typeof(Object), SelectionMode.TopLevel);
        if (selections.Length > 0)
        {
            foreach (Object selection in selections)
            {
                string path = AssetDatabase.GetAssetPath(selection);
                Debug.Log(path);
                if (!path.StartsWith("Assets/Art/spine/"))
                {
                    Debug.LogError("请选在Assets/Art/spine/里面的文件夹");
                    return;
                }

                if (!Directory.Exists(path))
                {
                    Debug.LogError("请选在Assets/Art/spine/里面的文件夹,不要选择文件");
                    return;
                }

                if (pattern.IsMatch(path))
                {
                    string[] files = Directory.GetFiles(path, "*_SkeletonData.asset", SearchOption.TopDirectoryOnly);
                    if (files.Length <= 0)
                    {
                        Debug.LogError("找不到SkeletonData.asset文件，请检查资源");
                        return;
                    }
                    string asset_path = files[0];
                    string asset_name = assetPath.Match(path).Groups[1].Value;
                    Object obj = AssetDatabase.LoadAssetAtPath(asset_path, typeof(Object));
                    GameObject new_obj = new GameObject(asset_name);
                    new_obj.layer = LayerMask.NameToLayer("UI");
                    Spine.Unity.SkeletonAnimation sk_com = new_obj.AddComponent<Spine.Unity.SkeletonAnimation>();
                    sk_com.skeletonDataAsset = obj as Spine.Unity.SkeletonDataAsset;
                    // string defaultName = sk_com.skeletonDataAsset.GetSkeletonData().Animations.Items[0].Name;
                    sk_com.AnimationName = "stand1";
                    sk_com.loop = true;
                    MeshRenderer meshRender = new_obj.GetComponent<MeshRenderer>();
                    if (meshRender)
                    {
                        meshRender.lightProbeUsage = UnityEngine.Rendering.LightProbeUsage.Off;
                        meshRender.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.Off;
                        meshRender.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                        meshRender.receiveShadows = false;
                    }
                    string prefab_path = output + asset_name + ".prefab";

                    if (File.Exists(prefab_path))
                    {
                        File.Delete(prefab_path);
                    }
                    Debug.Log("lujing:" + prefab_path);
                    PrefabUtility.SaveAsPrefabAsset(new_obj, prefab_path);
                }
            }
        }
        else
        {
            Debug.LogError("请选择需要重新生成Prefab的Spine/Model文件夹");
        }

        Debug.Log("生产Spine成功");
    }

    [MenuItem("Assets/生成UI界面Spine")]
    public static void CreateSpineUIPrefab() {
        Object[] selections = Selection.GetFiltered(typeof(Object), SelectionMode.TopLevel);
        if (selections.Length > 0) {
            foreach (Object selection in selections) {
                string path = AssetDatabase.GetAssetPath(selection);
                if (path == "Assets/Things/Spine/Model") {
                    Debug.LogError("请选在Spine/Model/里面的文件夹");
                    return;
                }

                if (!Directory.Exists(path)) {
                    Debug.LogError("请选在Spine/Model/里面的文件夹,不要选择文件");
                    return;
                }

                if (pattern.IsMatch(path)) {
                    string[] files = Directory.GetFiles(path, "*_SkeletonData.asset", SearchOption.TopDirectoryOnly);
                    if (files.Length <= 0) {
                        Debug.LogError("找不到SkeletonData.asset文件，请检查资源");
                        return;
                    }
                    string asset_path = files[0];
                    FileInfo fi = new FileInfo(asset_path);
                    string asset_name = fi.Name.Replace("_SkeletonData.asset", "");
                    // string asset_name = assetPath.Match(path).Groups[1].Value;
                    Object obj = AssetDatabase.LoadAssetAtPath(asset_path, typeof(Object));
                    GameObject new_obj = new GameObject(asset_name);
                    new_obj.layer = LayerMask.NameToLayer("UI");
                    // string defaultName = (obj as Spine.Unity.SkeletonDataAsset).GetSkeletonData().Animations.Items[0].Name;

                    Spine.Unity.SkeletonGraphic sk_gra = new_obj.AddComponent<Spine.Unity.SkeletonGraphic>();
                    sk_gra.skeletonDataAsset = obj as Spine.Unity.SkeletonDataAsset;
                    sk_gra.skeletonDataAsset.scale = 1;
                    sk_gra.startingAnimation = "stand1";
                    sk_gra.startingLoop = true;
                    sk_gra.raycastTarget = false;
                    sk_gra.material = AssetDatabase.LoadAssetAtPath<Material>(path + "/" + asset_name + "_Material.mat");
                    sk_gra.material.shader = Shader.Find("Xcqy/SpineSkeletonGraphic");
                    sk_gra.MeshGenerator.settings.pmaVertexColors = false;
                    new_obj.GetComponent<RectTransform>().pivot = new Vector2(0.5f, 0f);
                    new_obj.GetComponent<RectTransform>().sizeDelta = Vector2.one * 512;
                    AssetDatabase.Refresh();

                    string prefab_path = output + asset_name + ".prefab";

                    if (File.Exists(prefab_path)) {
                        File.Delete(prefab_path);
                    }

                    PrefabUtility.SaveAsPrefabAsset(new_obj, prefab_path);
                }
            }
        } else {
            Debug.LogError("请选择需要重新生成Prefab的Spine/Model文件夹");
        }

        Debug.Log("生产Spine成功");
    }
}
