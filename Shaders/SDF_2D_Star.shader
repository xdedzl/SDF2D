Shader "Custom/SDF_2D_Star" {
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

            // SDF函数：五角星
            float sdf_star(float2 p, float width) {
                const float pi = 3.14159;
                float angle = atan2(p.y, p.x);
                float radius = length(p);
                
                // 将角度映射到[0, 2pi/5]
                angle = fmod(angle + pi, 2.0 * pi / 5.0);
                if (angle < 0.0) angle += 2.0 * pi / 5.0;
                
                // 计算内外半径
                float r1 = width;
                float r2 = width * 0.382;  // 内圆半径（黄金分割）
                
                // 计算当前角度对应的半径
                float r = r2 + (r1 - r2) * abs(cos(angle * 2.5));
                
                return radius - r;
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
                float sdf = sdf_star(IN.uv, _Width);
                
                float inner = step(sdf, 0);
                float edge = step(0, sdf) * step(sdf, scaledEdgeWidth);
                
                half4 col = _MainColor * inner + _EdgeColor * edge;
                return col;
            }
            ENDHLSL
        }
    }
} 