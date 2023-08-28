using UnityEngine;
using UnityEngine.Rendering;

class HUDRender
{
    BetterList<HUDMesh> m_MeshList = new BetterList<HUDMesh>(); // 所有的
    BetterList<HUDMesh> m_ValidList = new BetterList<HUDMesh>(); // 当前有效的
    HUDMesh m_MeshFont;
    HUDMesh m_curFontMesh;
    public bool m_bMeshDirty;

    public HUDMesh QueryMesh(int nAtlasID, int nSpriteID)
    {
        // 先从当前有效的Mesh的找
        for (int i = m_ValidList.size - 1; i >= 0; --i)
        {
            if (m_ValidList[i].AtlasID == nAtlasID)
                return m_ValidList[i];
        }
        // 从所有的里面找
        for (int i = m_MeshList.size - 1; i >= 0; --i)
        {
            if (m_MeshList[i].AtlasID == nAtlasID)
            {
                m_ValidList.Add(m_MeshList[i]);
                m_MeshList[i].SetAtlasID(nAtlasID, nSpriteID);
                m_bMeshDirty = true;
                return m_MeshList[i];
            }
        }
        HUDMesh pHudMesh = new HUDMesh();
        pHudMesh.SetAtlasID(nAtlasID, nSpriteID);
        m_MeshList.Add(pHudMesh);
        m_ValidList.Add(pHudMesh);
        m_bMeshDirty = true;
        return pHudMesh;
    }


    public void Release()
    {
        for (int i = 0; i < m_MeshList.size; ++i)
        {
            m_MeshList[i].Release();
            m_MeshList[i] = null;
        }
        m_MeshFont = null;
        m_curFontMesh = null;
        m_MeshList.Clear();
        m_ValidList.Clear();
    }

    // 功能：快速清队模型的顶点
    public void FastClearVertex()
    {
        m_curFontMesh = null;
        for (int i = m_ValidList.size - 1; i >= 0; --i)
        {
            HUDMesh mesh = m_ValidList[i];
            mesh.FastClearVertex();
        }
        m_ValidList.Clear();
    }

    // 功能：更新模型顶点(每帧更新)
    public void FillMesh()
    {
        for (int i = m_ValidList.size - 1; i >= 0; --i)
        {
            HUDMesh mesh = m_ValidList[i];
            if (mesh.IsDirty())
            {
                int nOldSpriteNumb = mesh.OldSpriteNumb;
                mesh.UpdateLogic();
                int nCurSpriteNumb = mesh.SpriteNumb;
                if (nOldSpriteNumb != 0 && nCurSpriteNumb == 0)
                    m_bMeshDirty = true;
                else if (nOldSpriteNumb == 0 && nCurSpriteNumb != 0)
                    m_bMeshDirty = true;
                if (nCurSpriteNumb == 0)
                {
                    m_ValidList.RemoveAt(i);
                    if (m_MeshFont == mesh)
                    {
                        m_curFontMesh = null;
                    }
                    else
                    {
                        mesh.CleanAllVertex();
                    }
                }
            }
        }
    }
    public void OnCacelRender()
    {
        m_bMeshDirty = false;
    }
    public void RenderTo(CommandBuffer cmdBuffer)
    {
        m_bMeshDirty = false;
        if (m_ValidList.size == 0)
            return;
        Matrix4x4 matWorld = Matrix4x4.identity;
        for (int i = 0, nSize = m_ValidList.size; i < nSize; ++i)
        {
            HUDMesh mesh = m_ValidList[i];
            if (mesh.SpriteNumb > 0 && mesh.AtlasID != 0)
            {
                cmdBuffer.DrawMesh(mesh.m_Mesh, matWorld, mesh.m_mat);
            }
        }
        for (int i = 0, nSize = m_ValidList.size; i < nSize; ++i)
        {
            HUDMesh mesh = m_ValidList[i];
            if (mesh.SpriteNumb > 0 && mesh.AtlasID == 0)
            {
                cmdBuffer.DrawMesh(mesh.m_Mesh, matWorld, mesh.m_mat);
            }
        }
    }
}
