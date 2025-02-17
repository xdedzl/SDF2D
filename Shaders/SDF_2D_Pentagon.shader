Shader "Custom/SDF_2D_Pentagon" {
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

            // SDF函数：正五边形
            float sdf_pentagon(float2 p, float width) {
                const float pi = 3.14159;
                const int n = 5; // 边数
                
                // 计算到边的最小距离
                float angle = atan2(p.y, p.x);
                float sector = floor((angle + pi) * n / (2.0 * pi));
                float angleFromSector = sector * 2.0 * pi / n - pi + pi / n;
                float2 dir = float2(cos(angleFromSector), sin(angleFromSector));
                
                return length(p - width * dir) - width;
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
                float sdf = sdf_pentagon(IN.uv, _Width);
                
                float inner = step(sdf, 0);
                float edge = step(0, sdf) * step(sdf, scaledEdgeWidth);
                
                half4 col = _MainColor * inner + _EdgeColor * edge;
                return col;
            }
            ENDHLSL
        }
    }
} 