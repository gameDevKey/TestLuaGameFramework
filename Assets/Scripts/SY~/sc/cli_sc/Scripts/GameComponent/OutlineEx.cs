using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;


public class OutlineEx : BaseMeshEffect
{
    public Color OutlineColor = Color.white;
    [Range(0, 6)]
    public float OutlineWidth = 1;
    float _OutlineWidth = 0;

    private static List<UIVertex> m_VetexList = new List<UIVertex>();

    private static Material marterial;

    protected override void Awake()
    {
#if UNITY_STANDALONE && !UNITY_EDITOR
        _OutlineWidth = Screen.height / 1280.0f * OutlineWidth;
#else
        _OutlineWidth = OutlineWidth;
#endif

        base.Awake();

        if(marterial == null)
        {
            var shader = Shader.Find("UI/OutlineEx");
            marterial = new Material(shader);
        }
        base.graphic.material = marterial;

#if UNITY_EDITOR
        if (base.graphic.canvas)
        {
            var v1 = base.graphic.canvas.additionalShaderChannels;
            var v2 = AdditionalCanvasShaderChannels.TexCoord1;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
            v2 = AdditionalCanvasShaderChannels.TexCoord2;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
            v2 = AdditionalCanvasShaderChannels.TexCoord3;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
            v2 = AdditionalCanvasShaderChannels.Tangent;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
            v2 = AdditionalCanvasShaderChannels.Normal;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
        }
        this._Refresh();
#endif
    }

    protected override void Start()
    {
        if (base.graphic.canvas)
        {
            var v1 = base.graphic.canvas.additionalShaderChannels;
            var v2 = AdditionalCanvasShaderChannels.TexCoord1;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
            v2 = AdditionalCanvasShaderChannels.TexCoord2;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
            v2 = AdditionalCanvasShaderChannels.TexCoord3;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
            v2 = AdditionalCanvasShaderChannels.Tangent;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
            v2 = AdditionalCanvasShaderChannels.Normal;
            if ((v1 & v2) != v2)
            {
                base.graphic.canvas.additionalShaderChannels |= v2;
            }
        }
        this._Refresh();
    }


#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.OnValidate();

        if (base.graphic.material != null)
        {
            this._Refresh();
        }
    }
#endif


    private void _Refresh()
    {
#if UNITY_STANDALONE && !UNITY_EDITOR
        _OutlineWidth = Screen.height / 1280.0f * OutlineWidth;
#else
        _OutlineWidth = OutlineWidth;
#endif
        base.graphic.SetVerticesDirty();
    }


    public override void ModifyMesh(VertexHelper vh)
    {
        vh.GetUIVertexStream(m_VetexList);

        this._ProcessVertices();

        vh.Clear();
        vh.AddUIVertexTriangleStream(m_VetexList);
    }

    public void ChangeOutlineColor(Color color)
    {
        this.OutlineColor = color;
        this._Refresh();
    }

    public void ChangeOutlineColor(Color color, float width)
    {
        this.OutlineColor = color;
        this.OutlineWidth = width;
        this._Refresh();
    }

    private void _ProcessVertices()
    {
        for (int i = 0, count = m_VetexList.Count - 3; i <= count; i += 3)
        {
            var v1 = m_VetexList[i];
            var v2 = m_VetexList[i + 1];
            var v3 = m_VetexList[i + 2];

            var minX = _Min(v1.position.x, v2.position.x, v3.position.x);
            var minY = _Min(v1.position.y, v2.position.y, v3.position.y);
            var maxX = _Max(v1.position.x, v2.position.x, v3.position.x);
            var maxY = _Max(v1.position.y, v2.position.y, v3.position.y);
            var posCenter = new Vector2(minX + maxX, minY + maxY) * 0.5f;

            Vector2 triX, triY, uvX, uvY;
            Vector2 pos1 = v1.position;
            Vector2 pos2 = v2.position;
            Vector2 pos3 = v3.position;
            if (Mathf.Abs(Vector2.Dot((pos2 - pos1).normalized, Vector2.right))
                > Mathf.Abs(Vector2.Dot((pos3 - pos2).normalized, Vector2.right)))
            {
                triX = pos2 - pos1;
                triY = pos3 - pos2;
                uvX = v2.uv0 - v1.uv0;
                uvY = v3.uv0 - v2.uv0;
            }
            else
            {
                triX = pos3 - pos2;
                triY = pos2 - pos1;
                uvX = v3.uv0 - v2.uv0;
                uvY = v2.uv0 - v1.uv0;
            }

            var uvMin = _Min(v1.uv0, v2.uv0, v3.uv0);
            var uvMax = _Max(v1.uv0, v2.uv0, v3.uv0);

            var col_rg = new Vector2(OutlineColor.r, OutlineColor.g);
            var col_ba = new Vector4(0, 0, OutlineColor.b, OutlineColor.a);
            var normal = new Vector3(0, 0, _OutlineWidth);

            v1 = _SetNewPosAndUV(v1, this._OutlineWidth, posCenter, triX, triY, uvX, uvY, uvMin, uvMax);
            v1.uv3 = col_rg;
            v1.tangent = col_ba;
            v1.normal = normal;
            v2 = _SetNewPosAndUV(v2, this._OutlineWidth, posCenter, triX, triY, uvX, uvY, uvMin, uvMax);
            v2.uv3 = col_rg;
            v2.tangent = col_ba;
            v2.normal = normal;
            v3 = _SetNewPosAndUV(v3, this._OutlineWidth, posCenter, triX, triY, uvX, uvY, uvMin, uvMax);
            v3.uv3 = col_rg;
            v3.tangent = col_ba;
            v3.normal = normal;

            m_VetexList[i] = v1;
            m_VetexList[i + 1] = v2;
            m_VetexList[i + 2] = v3;
        }
    }


    private static UIVertex _SetNewPosAndUV(UIVertex pVertex, float pOutLineWidth,
        Vector2 pPosCenter,
        Vector2 pTriangleX, Vector2 pTriangleY,
        Vector2 pUVX, Vector2 pUVY,
        Vector2 pUVOriginMin, Vector2 pUVOriginMax)
    {

        var pos = pVertex.position;
        var posXOffset = pos.x > pPosCenter.x ? pOutLineWidth : -pOutLineWidth;
        var posYOffset = pos.y > pPosCenter.y ? pOutLineWidth : -pOutLineWidth;
        pos.x += posXOffset;
        pos.y += posYOffset;
        pVertex.position = pos;

        var uv = pVertex.uv0;
        Vector2 vecx = pUVX / pTriangleX.magnitude * posXOffset * (Vector2.Dot(pTriangleX, Vector2.right) > 0 ? 1 : -1);
        Vector2 vecy = pUVY / pTriangleY.magnitude * posYOffset * (Vector2.Dot(pTriangleY, Vector2.up) > 0 ? 1 : -1);
        uv += new Vector4(vecx.x, vecx.y, 0, 0);
        uv += new Vector4(vecy.x, vecy.y, 0, 0);
        pVertex.uv0 = uv;

        pVertex.uv1 = pUVOriginMin;     //uv1 uv2 ����  tangent  normal ��������� ��������
        pVertex.uv2 = pUVOriginMax;

        return pVertex;
    }


    private static float _Min(float pA, float pB, float pC)
    {
        return Mathf.Min(Mathf.Min(pA, pB), pC);
    }


    private static float _Max(float pA, float pB, float pC)
    {
        return Mathf.Max(Mathf.Max(pA, pB), pC);
    }


    private static Vector2 _Min(Vector2 pA, Vector2 pB, Vector2 pC)
    {
        return new Vector2(_Min(pA.x, pB.x, pC.x), _Min(pA.y, pB.y, pC.y));
    }


    private static Vector2 _Max(Vector2 pA, Vector2 pB, Vector2 pC)
    {
        return new Vector2(_Max(pA.x, pB.x, pC.x), _Max(pA.y, pB.y, pC.y));
    }
}
