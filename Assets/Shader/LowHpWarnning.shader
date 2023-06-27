Shader "YQH/LowHpWarnning" 
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,0,0,1)
        _Speed ("Speed", Range(0, 10)) = 4
        _Size ("Size", Range(0, 5)) = 2
        [Toggle]_Enable("开关",int) = 1
    }

    SubShader 
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _ENABLE_ON
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            fixed4 _Color;
            float _Size;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos (o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target {
                #if !_ENABLE_ON
                    return 0;
                #endif

                // 计算屏幕坐标
                float2 screenPos = i.screenPos.xy / i.screenPos.w * _ScreenParams.xy;

                float centerX = _ScreenParams.x/2;
                float centerY = _ScreenParams.y/2;

                float disX = abs(screenPos.x - centerX);
                float disY = abs(screenPos.y - centerY);

                // Size越大，插值越大，白色越多
                float sX = smoothstep(0, _Size, disX / centerX);
                float sY = smoothstep(0, _Size, disY / centerY);

                // 计算纵向和横向的颜色占比
                float4 finalColor = lerp(float4(0,0,0,0),_Color,sX);
                finalColor = lerp(finalColor,_Color,sY);

                // 闪烁的Alpha值 区间[0,1]
                float alpha = sin(_Time.y * _Speed) * 0.5 + 0.5;

                finalColor.a *= alpha;

                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
