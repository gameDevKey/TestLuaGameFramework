using System.Collections;
using System.Collections.Generic;
using UnityEditor.U2D;
using UnityEngine;
using UnityEngine.Rendering;

class HUDVertex
{
    HUDVertex m_pNext;
    int m_nID;
    static HUDVertex s_InvalidList;
    static int s_nInvalidCount = 0;
    static int s_nVertexID = 0;

    public static HUDVertex QueryVertex()
    {
        HUDVertex p = s_InvalidList;
        if (p != null)
        {
            s_InvalidList = p.m_pNext;
            --s_nInvalidCount;
            p.m_pNext = null;
        }
        if (p == null)
        {
            p = new HUDVertex();
            p.m_nID = ++s_nVertexID;
        }
        return p;
    }
    public static void ReleaseVertex(HUDVertex p)
    {
        if (p != null)
        {
            p.m_pNext = s_InvalidList;
            s_InvalidList = p;
            ++s_nInvalidCount;
        }
    }
    public int ID
    {
        get { return m_nID; }
    }

    public Vector2 vecRU; // 右上角
    public Vector2 vecRD; // 右下角
    public Vector2 vecLD; // 左下角
    public Vector2 vecLU; // 左上角

    public Vector2 uvRD;  // 右上角
    public Vector2 uvRU;
    public Vector2 uvLU;
    public Vector2 uvLD;

    public Color32 clrRD;
    public Color32 clrRU;
    public Color32 clrLU;
    public Color32 clrLD;

    public Vector3 WorldPos;
    public Vector2 ScreenPos; // 屏幕坐标
    public Vector2 Offset; // 本地偏移
    public Vector2 Move;   // 当前移动量(变动值)
    public float Scale;

    public int SpriteID; // 图片ID
    public int AtlasID;  // 图集ID
    public char ch;       // 字
    public short width;    // 图片或文字的宽度
    public short height;   // 图片或文字的高度
    public HUDMesh hudMesh;
    public int m_hudVertexIndex; // 只能在HUDMesh中修改，切记

    public static int GetCharWidth(CharacterInfo chInfo)
    {
        int nWidth = chInfo.glyphWidth;
        if (chInfo.maxX > nWidth)
        {
            if (chInfo.minX < 0)
                return chInfo.maxX - chInfo.minX;
            else
                return chInfo.maxX + chInfo.minX;
        }
        return nWidth;
    }

    public void InitChar(CharacterInfo chInfo)
    {
        //width = (short)chInfo.glyphWidth;
        width = (short)GetCharWidth(chInfo);
        height = (short)chInfo.glyphHeight;
        Scale = 1.0f;
        //AtlasID = 0;

        float fL = chInfo.minX;
        float fT = chInfo.minY;
        float fR = chInfo.maxX;
        float fB = chInfo.maxY;

        vecRU.Set(fR, fT);  // 右上角
        vecRD.Set(fR, fB);  // 右下角
        vecLD.Set(fL, fB);  // 左下角
        vecLU.Set(fL, fT);  // 左上角

        uvRU = chInfo.uvBottomRight;
        uvRD = chInfo.uvTopRight;
        uvLD = chInfo.uvTopLeft;
        uvLU = chInfo.uvBottomLeft;
    }

    public void RebuildCharUV(CharacterInfo chInfo)
    {
        uvRU = chInfo.uvBottomRight;
        uvRD = chInfo.uvTopRight;
        uvLD = chInfo.uvTopLeft;
        uvLU = chInfo.uvBottomLeft;
    }

    static public Rect ConvertToTexCoords(Rect rect, int width, int height)
    {
        Rect final = rect;

        if (width != 0f && height != 0f)
        {
            final.xMin = rect.xMin / width;
            final.xMax = rect.xMax / width;
            final.yMin = 1f - rect.yMax / height;
            final.yMax = 1f - rect.yMin / height;
        }
        return final;
    }

    public void InitSprite(int nWidth = 0, int nHeight = 0)
    {
        ch = '\0';
        AtlasID = -1;
        var sp = HUDManager.Instance.GetSpriteByID(SpriteID);
        if (sp == null)
            return;

        var atlas = GameAssetLoader.Instance.GetAtlasBySprite(sp);
        AtlasID = atlas.name.GetHashCode();
        width = nWidth <= 0 ? (short)(sp.rect.width + 0.5f) : (short)nWidth;
        height = nHeight <= 0 ? (short)(sp.rect.height + 0.5f) : (short)nHeight;
        Scale = 1.0f;

        float fL = 0.0f;
        float fT = 0.0f;
        float fR = width;
        float fB = height;

        vecRU.Set(fR, fT);  // 右上角
        vecRD.Set(fR, fB);  // 右下角
        vecLD.Set(fL, fB);  // 左下角
        vecLU.Set(fL, fT);  // 左上角

        float uvR = sp.rect.xMax;
        float uvL = sp.rect.xMin;
        float uvB = sp.rect.yMin;
        float uvT = sp.rect.yMax;

        uvRU.Set(uvR, uvB);
        uvRD.Set(uvR, uvT);
        uvLD.Set(uvL, uvT);
        uvLU.Set(uvL, uvB);

        clrLD = clrLU = clrRD = clrRU = Color.white;
    }
    public void SlicedFill(int nWidth, int nHeight, float fOffsetX, float fOffsetY, float uvL, float uvT, float uvR, float uvB)
    {
        ch = '\0';
        Scale = 1.0f;

        float fL = fOffsetX;
        float fB = fOffsetY;
        float fR = fOffsetX + nWidth;
        float fT = fOffsetY + nHeight;

        vecRU.Set(fR, fB);  // 右上角
        vecRD.Set(fR, fT);  // 右下角
        vecLD.Set(fL, fT);  // 左下角
        vecLU.Set(fL, fB);  // 左上角

        uvRU.Set(uvR, uvT);
        uvRD.Set(uvR, uvB);
        uvLD.Set(uvL, uvB);
        uvLU.Set(uvL, uvT);

        clrLD = clrLU = clrRD = clrRU = Color.white;
        if (hudMesh != null)
            hudMesh.VertexDirty();
    }
}


class HUDMesh
{
    public Mesh m_Mesh;
    public Material m_mat;
    public BetterList<Vector3> mVerts = new BetterList<Vector3>();
    public BetterList<Vector2> mOffset = new BetterList<Vector2>();
    public BetterList<Vector2> mUvs = new BetterList<Vector2>();
    public BetterList<Color32> mCols = new BetterList<Color32>();
    public BetterList<int> mIndices = new BetterList<int>();
    public float m_Scale = 1.0f;
    int m_nOldSpriteNumb = 0;

    BetterList<HUDVertex> m_SpriteVertex = new BetterList<HUDVertex>();
    bool m_bQueryTexture = false;
    int mAtlasID = 0;
    Texture mainTex;
    Texture alphaTex;
    bool mDirty = false;
    bool mHaveNullVertex = false;

    public static float s_fCameraScale = 0.8f; // [0.1, 0.8]
    public static float s_fCameraScaleX = 0.8f;
    public static float s_fCameraScaleY = 0.8f;
    public static float s_fNumberScale = 1.0f;


    public static Camera GetHUDMainCamera()
    {
        return HUDManager.Instance.MainCamera;
    }

    public void SetAtlasID(int nAtlasID)
    {
        if (mAtlasID != nAtlasID && mAtlasID != 0)
        {
            ReleaseTexture();
        }
        mAtlasID = nAtlasID;
        if (m_mat == null)
        {
            m_mat = new Material(Shader.Find("Unlit/HUDSprite"));
            if (m_mat != null && Application.platform != RuntimePlatform.WindowsEditor)
            {
                m_mat.EnableKeyword("MAIN_ALPHA_ON");
            }
        }
        if (mAtlasID != 0)
            QueryTexture();
    }
    public int AtlasID
    {
        get { return mAtlasID; }
    }


    private void QueryTexture()
    {
        if (!m_bQueryTexture)
        {
            m_bQueryTexture = true;
            OnLoadHUDAtlas();
        }
    }
    private void ReleaseTexture()
    {
        if (m_bQueryTexture)
        {
            m_bQueryTexture = false;
            //TODO 卸载图集
            //CAtlasMng.instance.ReleaseAtlasByID(mAtlasID);
        }
    }
    float GetReserveY()
    {
        if (Application.platform == RuntimePlatform.IPhonePlayer)
            return -1.0f; // IOS使用meta, 反过来
        // 主角坐下来时，也需要反过来，先不处理
        return 1.0f;
    }

    void OnLoadHUDAtlas()
    {
        var sprite = HUDManager.Instance.GetSpriteByID(mSpriteID);
        if (sprite != null)
        {
            m_mat.SetTexture("_MainTex", sprite.texture);
            m_mat.SetTexture("_MainAlpha", sprite.associatedAlphaSplitTexture);
            m_mat.SetFloat("_ReverseY", GetReserveY());
            Debug.Log($"LoadHUDSprite:{mSpriteID},{sprite},{sprite.texture}");
        }
    }

    public void Release()
    {
        CleanAllVertex();
        if (m_Mesh != null)
        {
            GameObject.DestroyObject(m_Mesh);
            m_Mesh = null;
        }
        if (m_mat != null)
        {
            GameObject.DestroyObject(m_mat);
            m_mat = null;
        }
    }

    public void CleanAllVertex()
    {
        mDirty = true;
        mHaveNullVertex = false;
        m_SpriteVertex.Clear();
        ReleaseTexture();
    }

    // 功能：快速清队模型的顶点
    public void FastClearVertex()
    {
        mDirty = true;
        mHaveNullVertex = false;
        m_SpriteVertex.Clear();
    }

    public void PushHUDVertex(HUDVertex v)
    {
        mDirty = true;
        v.m_hudVertexIndex = m_SpriteVertex.size;
        m_SpriteVertex.Add(v);
        if (!m_bQueryTexture)
            QueryTexture();
    }
    public void EraseHUDVertex(HUDVertex v)
    {
        int nIndex = v.m_hudVertexIndex;
        if (nIndex >= 0 && nIndex < m_SpriteVertex.size)
        {
            if (m_SpriteVertex[nIndex] != null && v.ID == m_SpriteVertex[nIndex].ID)
            {
                mDirty = true;
                mHaveNullVertex = true;
                m_SpriteVertex[nIndex] = null;
                return;
            }
        }

        for (int i = m_SpriteVertex.size - 1; i >= 0; --i)
        {
            if (m_SpriteVertex[i] != null && m_SpriteVertex[i].ID == v.ID)
            {
                mDirty = true;
                mHaveNullVertex = true;
                m_SpriteVertex[i] = null;
                break;
            }
        }
    }
    public void VertexDirty()
    {
        mDirty = true;
    }
    public bool IsDirty()
    {
        return mDirty;
    }
    public int SpriteNumb
    {
        get { return m_SpriteVertex.size; }
    }
    public int OldSpriteNumb
    {
        get { return m_nOldSpriteNumb; }
    }

    public void UpdateLogic()
    {
        if (!mDirty)
            return;
        mDirty = false;

        if (mHaveNullVertex)
        {
            mHaveNullVertex = false;
            m_SpriteVertex.ClearNullItem();
        }
        UpdateMesh();
        OnLoadHUDAtlas();
        m_nOldSpriteNumb = m_SpriteVertex.size;
    }

    void FillVertex()
    {
        PrepareWrite(m_SpriteVertex.size * 4);
        Vector2 vOffset = Vector2.zero;
        float fScaleX = 1.0f, fScaleY = 1.0f;
        float fCameraScaleX = s_fCameraScaleX;
        float fCameraScaleY = s_fCameraScaleY;
        //if(m_bScaleByDist)
        //{
        //    fCameraScaleX = s_fScaleXByDist;
        //    fCameraScaleY = s_fScaleYByDist;
        //}

        for (int i = 0, nSize = m_SpriteVertex.size; i < nSize; ++i)
        {
            HUDVertex v = m_SpriteVertex[i];
            v.m_hudVertexIndex = i;
            mVerts.Add(v.WorldPos);
            mVerts.Add(v.WorldPos);
            mVerts.Add(v.WorldPos);
            mVerts.Add(v.WorldPos);

            //fScaleX = fCameraScaleX * v.Scale;
            //fScaleY = fCameraScaleY * v.Scale; 
            fScaleX = fCameraScaleX * v.Scale;
            fScaleY = fCameraScaleY * v.Scale;

            vOffset = v.vecRU;
            vOffset += v.Offset;
            vOffset.x *= fScaleX;
            vOffset.y *= fScaleY;
            //vOffset += v.ScreenPos + v.Move;
            vOffset += v.Move;
            mOffset.Add(vOffset);

            vOffset = v.vecRD;
            vOffset += v.Offset;
            vOffset.x *= fScaleX;
            vOffset.y *= fScaleY;
            //vOffset += v.ScreenPos + v.Move;
            vOffset += v.Move;
            mOffset.Add(vOffset);

            vOffset = v.vecLD;
            vOffset += v.Offset;
            vOffset.x *= fScaleX;
            vOffset.y *= fScaleY;
            //vOffset += v.ScreenPos + v.Move;
            vOffset += v.Move;
            mOffset.Add(vOffset);

            vOffset = v.vecLU;
            vOffset += v.Offset;
            vOffset.x *= fScaleX;
            vOffset.y *= fScaleY;
            //vOffset += v.ScreenPos + v.Move;
            vOffset += v.Move;
            mOffset.Add(vOffset);

            mUvs.Add(v.uvRU);
            mUvs.Add(v.uvRD);
            mUvs.Add(v.uvLD);
            mUvs.Add(v.uvLU);
            mCols.Add(v.clrRD);
            mCols.Add(v.clrRU);
            mCols.Add(v.clrLU);
            mCols.Add(v.clrLD);
        }
    }

    void PrepareWrite(int nVertexNumb)
    {
        mVerts.CleanPreWrite(nVertexNumb);
        mOffset.CleanPreWrite(nVertexNumb);
        mUvs.CleanPreWrite(nVertexNumb);
        mCols.CleanPreWrite(nVertexNumb);
    }
    // 功能：填充顶点数据
    void UpdateMesh()
    {
        int nOldVertexCount = mVerts.size;
        FillVertex();

        int nLast = mVerts.size - 1;
        int nExSize = mVerts.buffer.Length;
        int nVertexCount = mVerts.size;
        if (nLast >= 0)
        {
            Vector3[] vers = mVerts.buffer;
            Vector2[] uv1s = mUvs.buffer;
            Vector2[] offs = mOffset.buffer;
            Color32[] cols = mCols.buffer;
            for (int i = mVerts.size, iMax = mVerts.buffer.Length; i < iMax; ++i)
            {
                vers[i] = vers[nLast];
                uv1s[i] = uv1s[nLast];
                offs[i] = offs[nLast];
                cols[i] = cols[nLast];
            }
        }
        mVerts.size = nExSize;
        mUvs.size = nExSize;
        mCols.size = nExSize;
        mOffset.size = nExSize;

        // 更新索引数据
        bool rebuildIndices = nOldVertexCount != nExSize;
        if (rebuildIndices)
            AdjustIndexs(nVertexCount);

        if (m_Mesh == null)
        {
            m_Mesh = new Mesh();
            m_Mesh.hideFlags = HideFlags.DontSave;
            m_Mesh.name = "hud_mesh";
            m_Mesh.MarkDynamic();
        }
        else if (rebuildIndices || m_Mesh.vertexCount != mVerts.size)
        {
            m_Mesh.Clear();
        }

        if (m_Mesh != null)
        {
            m_Mesh.vertices = mVerts.buffer;
            m_Mesh.uv = mUvs.buffer;
            m_Mesh.uv2 = mOffset.buffer;
            m_Mesh.colors32 = mCols.buffer;
            m_Mesh.triangles = mIndices.buffer;
        }
    }

    void AdjustIndexs(int nVertexCount)
    {
        int nOldSize = mIndices.size;
        int nNewSize = mVerts.size / 4 * 6;
        mIndices.CleanPreWrite(nVertexCount / 4 * 6);
        // 填充多余的
        int nMaxCount = mIndices.buffer.Length;
        int[] Indices = mIndices.buffer;

        int index = 0;
        int i = 0;
        for (; i < nVertexCount; i += 4)
        {
            Indices[index++] = i;
            Indices[index++] = i + 1;
            Indices[index++] = i + 2;

            Indices[index++] = i + 2;
            Indices[index++] = i + 3;
            Indices[index++] = i;
        }
        int nLast = nVertexCount - 1;
        for (; index < nMaxCount;)
        {
            Indices[index++] = nLast;
            Indices[index++] = nLast;
            Indices[index++] = nLast;
            Indices[index++] = nLast;
            Indices[index++] = nLast;
            Indices[index++] = nLast;
        }
        mIndices.size = index;
    }

    //public void PushChar(Vector3 vWorld, float fScreenX, float fScreenY, float fLocalX, float fLocalY, char ch, Color clrLeftUp, Color clrLeftDown, Color clrRightUp, Color clrRightDown)
    //{
    //    mFont.GetCharacterInfo(ch, ref m_tempCharInfo);

    //    float fL = fLocalX;
    //    float fB = fLocalY;
    //    float fR = fLocalX + m_tempCharInfo.glyphWidth;
    //    float fT = fLocalY + m_tempCharInfo.glyphHeight;

    //    fL = fScreenX + fL * m_Scale;
    //    fT = fScreenY + fT * m_Scale;
    //    fR = fScreenX + fR * m_Scale;
    //    fB = fScreenY + fB * m_Scale;

    //    Vector3[] vertex = { Vector3.zero, Vector3.zero, Vector3.zero, Vector3.zero };
    //    vertex[0].Set(fR, fB, 0f);  // 右上角
    //    vertex[1].Set(fR, fT, 0f);  // 右下角
    //    vertex[2].Set(fL, fT, 0f);  // 左下角
    //    vertex[3].Set(fL, fB, 0f);  // 左上角

    //    mVerts.Add(vWorld);
    //    mVerts.Add(vWorld);
    //    mVerts.Add(vWorld);
    //    mVerts.Add(vWorld);

    //    mOffset.Add(vertex[0]);
    //    mOffset.Add(vertex[1]);
    //    mOffset.Add(vertex[2]);
    //    mOffset.Add(vertex[3]);

    //    mUvs.Add(m_tempCharInfo.uvBottomRight);
    //    mUvs.Add(m_tempCharInfo.uvTopRight);
    //    mUvs.Add(m_tempCharInfo.uvTopLeft);
    //    mUvs.Add(m_tempCharInfo.uvBottomLeft);

    //    mCols.Add(clrRightDown);
    //    mCols.Add(clrRightUp);
    //    mCols.Add(clrLeftUp);
    //    mCols.Add(clrLeftDown);
    //}
}
