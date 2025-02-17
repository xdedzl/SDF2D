Shader "Custom/SDF_2D_Triangle" {
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

            // SDF函数：等边三角形
            float sdf_triangle(float2 p, float width) {
                const float k = sqrt(3.0);
                // 将原点移到三角形的重心位置（重心在高的1/3处）
                p.y = p.y + width/k/3.0;  // 修改为1/3的高度
                p.x = abs(p.x) - width;
                p.y = p.y + width/k;
                if(p.x + k*p.y > 0.0) {
                    p = float2(p.x-k*p.y, -k*p.x-p.y)/2.0;
                }
                p.x -= clamp(p.x, -2.0*width, 0.0);
                return -length(p)*sign(p.y);
            }

            Varyings vert(Attributes IN) {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv * 2 - 1; // 将UV从[0,1]映射到[-1,1]
                return OUT;
            }

            half4 _MainColor;
            half4 _EdgeColor;
            float _EdgeWidth, _Width;

            half4 frag(Varyings IN) : SV_Target {
                float scaledEdgeWidth = _EdgeWidth * _Width;
                _Width = _Width - scaledEdgeWidth;
                float sdf = sdf_triangle(IN.uv, _Width);
                
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