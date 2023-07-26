using UnityEngine;
using UnityEditor;


#if UNITY_EDITOR
public class BuildDataLoader : MonoSingleton<BuildDataLoader>
{
    private BuildDataObject data;
    public BuildDataObject LoadBuildData()
    {
        string path = BuildConfig.BUILD_OBJ_DIR_PATH + BuildConfig.DEFAULT_DATA_OBJ_NAME + ".asset";
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