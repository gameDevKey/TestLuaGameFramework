using UnityEditor;

public class BuildEditor
{
    [MenuItem("Tools/打包")]
    public static void OpenBuildWindow()
    {
#if UNITY_ANDROID
        EditorWindow.GetWindow(typeof(AndroidBuildTool));
#elif UNITY_IOS

#else
        EditorWindow.GetWindow(typeof(DefaultBuildTool));
#endif
    }
}