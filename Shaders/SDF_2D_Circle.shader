Shader "Custom/SDF_2D_Circle" {
    Properties {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _EdgeWidth ("Edge Width(%)", Range(0, 1)) = 0.1
        _Radius ("Radius", Range(0, 1)) = 0.5
    }
    
    SubShader {
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "RenderPipeline"="UniversalPipeline"
        }
        
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            // SDF函数：圆形
            float sdf_circle(float2 p, float radius) {
                return length(p) - radius;
            }

            Varyings vert(Attributes IN) {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv * 2 - 1; // 将UV从[0,1]映射到[-1,1]
                return OUT;
            }

            half4 _MainColor;
            half4 _EdgeColor;
            float _EdgeWidth, _Radius;

            half4 frag(Varyings IN) : SV_Target {
                float scaledEdgeWidth = _EdgeWidth * _Radius;
                float adjustedRadius = _Radius - scaledEdgeWidth;
                float sdf = sdf_circle(IN.uv, adjustedRadius);
                
                // 修改为只向外扩展
                float inner = step(sdf, 0);              // 内部区域：sdf <= 0
                float edge = step(0, sdf) * step(sdf, scaledEdgeWidth);  // 边缘区域：0 < sdf <= scaledEdgeWidth
                
                // 混合颜色
                half4 col = _MainColor * inner + _EdgeColor * edge;
                return col;
            }
            ENDHLSL
        }
    }
} 