Shader "Custom/SDF_2D_Heart" {
    Properties {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _EdgeWidth ("Edge Width(%)", Range(0, 1)) = 0.1
        _Width ("Width", Range(0, 1)) = 0.5
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

            // SDF函数：心形
            float sdf_heart(float2 p, float width) {
                p.x = abs(p.x);
                
                // 调整大小和位置
                p = p / width;
                p.y -= 0.25;
                
                // 主要形状
                float b = p.x * p.x + p.y * p.y - 1.0;
                float q = b * b * b - p.x * p.x * p.y * p.y * p.y;
                
                // 转换为近似的距离场
                float d = sign(q) * length(p - float2(0.0, -0.25));
                return d * width;
            }

            Varyings vert(Attributes IN) {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv * 2 - 1;
                return OUT;
            }

            half4 _MainColor;
            half4 _EdgeColor;
            float _EdgeWidth, _Width;

            half4 frag(Varyings IN) : SV_Target {
                float scaledEdgeWidth = _EdgeWidth * _Width;
                _Width = _Width - scaledEdgeWidth;
                float sdf = sdf_heart(IN.uv, _Width);
                
                float inner = step(sdf, 0);
                float edge = step(0, sdf) * step(sdf, scaledEdgeWidth);
                
                half4 col = _MainColor * inner + _EdgeColor * edge;
                return col;
            }
            ENDHLSL
        }
    }
} 