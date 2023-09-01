// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "YQH/MyDiffuse-Pixel-Half"
{
    Properties{
        _Diffuse("Diffuse",Color) = (1,1,1,1)
    }

    SubShader{
        Pass{
            Tags{ "LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };

            struct v2f{
                float4 pos:SV_POSITION;
                fixed3 worldNormal:TEXCOORD0;
            };

            v2f vert(a2v v) {
                // 漫反射光照 = (光源颜色 * 漫反射颜色) * max(0, 物体表面法线 点乘 光源方向)
                v2f o;
                
                o.pos = UnityObjectToClipPos(v.vertex);

                //世界空间坐标系下的物体表面法线向量
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                //环境光
                fixed ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //世界空间坐标系下的光源方向(只考虑场景中存在一个平行光)
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(i.worldNormal,worldLight)*0.5+0.5);

                fixed3 color = ambient + diffuse;

                return fixed4(color,1);
            }

            ENDCG
        }
    }
}
