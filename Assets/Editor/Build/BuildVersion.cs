using System;
using System.Collections.Generic;
using System.Text;

// 版本号组成: <主版本号>.<子版本号1>.<子版本号2>_[Develop/Release]
public class BuildVersion
{
    private uint m_MainVersion = 1;
    private uint m_SubVersion1;
    private uint m_SubVersion2;
    private string m_BuildMode;
    private string m_Version;
    private uint m_MaxSub = 9;
    private string m_DefaultVersion = "1.0.0_Develop";

    public BuildVersion(string version, BuildConfig.EBuildMode mode, uint maxSub = 9)
    {
        if(string.IsNullOrEmpty(version) || !version.Contains(".") || !version.Contains("_"))
        {
            version = m_DefaultVersion;
        }
        m_MaxSub = maxSub;
        var arr = version.Split(".");
        var arr1 = arr[2].Split("_");
        uint.TryParse(arr[0], out m_MainVersion);
        uint.TryParse(arr[1], out m_SubVersion1);
        uint.TryParse(arr1[0], out m_SubVersion2);
        m_BuildMode = mode.ToString();
        UpdateSub(0);
    }

    public void UpdateSub(uint value = 1)
    {
        if (m_SubVersion2 < m_MaxSub)
        {
            m_SubVersion2 += value;
        }
        if (m_SubVersion2 > m_MaxSub)
        {
            m_SubVersion2 = 0;
            m_SubVersion1 += value;
        }
        if (m_SubVersion1 > m_MaxSub)
        {
            m_SubVersion1 = 0;
            m_MainVersion += value;
        }
        OnVersionUpdate();
    }

    public void UpdateMain(uint value = 1)
    {
        m_MainVersion += value;
        OnVersionUpdate();
    }

    public string Get()
    {
        return m_Version;
    }

    private void OnVersionUpdate()
    {
        m_Version = $"{m_MainVersion}.{m_SubVersion1}.{m_SubVersion2}_{m_BuildMode}";
    }
}