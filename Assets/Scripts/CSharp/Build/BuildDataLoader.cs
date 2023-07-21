using UnityEngine;
using UnityEditor;


public class BuildDataLoader : MonoSingleton<BuildDataLoader>
{
    private BuildDataObject data;
    public BuildDataObject LoadBuildData()
    {
        string path = "";
#if UNITY_EDITOR
        path = BuildConfig.BUILD_OBJ_DIR_PATH + BuildConfig.DEFAULT_DATA_OBJ_NAME + ".asset";
#elif UNITY_ANDROID
        path = BuildConfig.BUILD_OBJ_DIR_PATH+BuildConfig.ANDROID_DATA_OBJ_NAME+".asset";
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