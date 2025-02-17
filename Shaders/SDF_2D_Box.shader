Shader "Custom/SDF_2D_Box" {
    Properties {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _EdgeWidth ("Edge Width(%)", Range(0, 1)) = 0.1
        _Length_X ("Length_X", Range(0, 1)) = 0.5
        _Length_Y ("Length_Y", Range(0, 1)) = 0.5
    }
    
    SubShader {
        Tags { 
            "RenderType"="Transparent"  // 关键修改：改为透明类型
            "Queue"="Transparent"       // 设置透明渲染队列
            "RenderPipeline"="UniversalPipeline"
        }
        
        Pass {
            Blend SrcAlpha OneMinusSrcAlpha // 启用标准Alpha混合
            ZWrite Off                      // 关闭深度写入

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

            // SDF函数：矩形
            float sdf_rect(float2 p, float2 size) {
                float2 d = abs(p) - size;
                return length(max(d, 0)) + min(max(d.x, d.y), 0);
            }

            Varyings vert(Attributes IN) {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv * 2 - 1; // 将UV从[0,1]映射到[-1,1]
                return OUT;
            }

            half4 _MainColor;
            half4 _EdgeColor;
            float _EdgeWidth, _Length_X, _Length_Y;

            half4 frag(Varyings IN) : SV_Target {
                float scaledEdgeWidth = _EdgeWidth * min(_Length_X, _Length_Y);
                _Length_X = _Length_X - scaledEdgeWidth;
                _Length_Y = _Length_Y - scaledEdgeWidth;
                float sdf = sdf_rect(IN.uv, float2(_Length_X, _Length_Y));
                
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