Shader "YQH/LowHpWarnning" 
{
    Properties
    {
        _Color ("颜色", Color) = (1,0,0,1)
        _Size ("尺寸", Range(0, 5)) = 2
        [Toggle]_Enable("开关",int) = 1
        [Toggle]_Flash("闪烁",int) = 1
        _Speed ("闪烁速度", Range(0, 10)) = 4
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
            #pragma multi_compile _ _FLASH_ON
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
                float4 screenPos : TEXCOORD1;
                float4 vertex : SV_POSITION;
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
                fixed4 finalColor = lerp(fixed4(0,0,0,0),_Color,sX);
                finalColor = lerp(finalColor,_Color,sY);
                
                #if _FLASH_ON
                    // 闪烁的Alpha值 区间[0,1]
                    finalColor.a *= sin(_Time.y * _Speed) * 0.5 + 0.5;
                #else
                    finalColor.a *= 1;
                #endif

                return finalColor;
            }
            ENDCG
        }
    }
    // FallBack "Diffuse"
}
