using UnityEngine;
using UnityEditor;


#if UNITY_EDITOR
public class BuildDataLoader : MonoSingleton<BuildDataLoader>
{
    private BuildDataObject data;
    public BuildDataObject LoadBuildData()
    {
#if UNITY_ANDROID
        string path = BuildConfig.BUILD_OBJ_DIR_PATH + BuildConfig.ANDROID_DATA_OBJ_NAME + ".asset";
#else
        string path = BuildConfig.BUILD_OBJ_DIR_PATH + BuildConfig.DEFAULT_DATA_OBJ_NAME + ".asset";
#endif
        return AssetDatabase.LoadAssetAtPath<BuildDataObject>(path);
    }

    protected override void Awake()
    {
        base.Awake();
        data = LoadBuildData();
    }

    public BuildDataObject GetData()
    {
        return data;
    }
}
#endif