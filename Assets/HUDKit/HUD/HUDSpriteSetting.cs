using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct HUDSpriteAttibute
{
    public int m_nHeadID; // ��ͷ��ͼƬID
    public int m_nAddID;  // + ��
    public int m_nSubID;  // - ��
    public int[] m_NumberID; // ����ID
    public void InitNumber(string szHeadName, string szPrefix)
    {
        var instance = HUDManager.Instance;
        m_nHeadID = instance.SpriteNameToID(szHeadName);
        m_nAddID = instance.SpriteNameToID(szPrefix + '+');
        m_nSubID = instance.SpriteNameToID(szPrefix + '-');
        m_NumberID = new int[10];
        for (int i = 0; i < m_NumberID.Length; ++i)
        {
            m_NumberID[i] = instance.SpriteNameToID(szPrefix + i.ToString());
        }
    }
}

public class HUDSpriteSetting
{
    public HUDSpriteAttibute[] SpriteAttibutes;
}

