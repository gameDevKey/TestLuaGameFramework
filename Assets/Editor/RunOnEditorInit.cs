using UnityEditor;

[InitializeOnLoad]
public class RunOnEditorInit
{
    static RunOnEditorInit()
    {
        AddressableGroupSetter.InitGroups();
    }
}