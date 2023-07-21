using UnityEditor;

public class BuildEditor
{
    [MenuItem("构建/打包工具")]
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