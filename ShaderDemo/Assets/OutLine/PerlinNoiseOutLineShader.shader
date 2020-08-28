Shader "Custom/PerlinNoiseOutLineShader"
{
    //法线外扩实现描边
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Outline("Outline",float) = 0.1
        _OutlineColor("OutlineColor",Color) = (0,0,0,1)

        _NoiseTillOffset ("NoiseTillOffset", Vector) = (1,1,0,0)
        _NoiseAmp("NoiseAmp", float) = 1
    }
    SubShader
    {
        //Queue设置为Transparent-1，放在天空盒之后，透明物体之前渲染
        Tags { "RenderType"="Opaque" "Queue" = "Transparent-1" }
        LOD 100
        
        //正常阶段
        Pass
        {
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv :TEXCOORD0;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv:TEXCOORD0;
            };
            sampler2D _MainTex;     
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }   
            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex,i.uv);
            }
            ENDCG
        }
        
        //描边放在第二个Pass渲染，可以通过深度测试抛弃被遮挡的部分，优化渲染效率
        //描边阶段，法线外扩，渲染背面
        Pass
        {
            //只需要边缘外扩
            Cull Front
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv :TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
            };
            float _Outline;
            float4 _OutlineColor;  

            half4 _NoiseTillOffset;
            half _NoiseAmp;        

            float2 hash22(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
            }

            float2 hash21(float2 p)
            {
                float h = dot(p, float2(127.1, 311.7));
                return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
            }

            //perlin noise
            float perlin_noise(float2 p) {
                float2 pi = floor(p);
                float2 pf = p - pi;
                float2 w = pf * pf * (3.0 - 2.0 * pf);
                return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)), dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
                        lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)), dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //把法线转换到视图空间
                float3 vnormal = mul((float3x3)UNITY_MATRIX_IT_MV,v.normal);
                //把法线转换到投影空间
                float2 pnormal_xy = mul((float2x2)UNITY_MATRIX_P,vnormal.xy);
                //朝法线方向外扩
                //o.vertex.xy = o.vertex.xy + pnormal_xy * o.vertex.w * _Outline;//* o.vertex.w描边不会随着Z轴的变化而变化

                float2 noise_uv = v.uv;
                noise_uv = noise_uv * _NoiseTillOffset.xy + _NoiseTillOffset.zw;
                float nosieWidth = perlin_noise(noise_uv);
                nosieWidth = nosieWidth * 2 - 1;    // ndc Space (-1, 1)

                half outlineWidth = _Outline + _Outline * nosieWidth * _NoiseAmp;
                o.vertex.xy = o.vertex.xy + pnormal_xy * o.vertex.w * outlineWidth;//* o.vertex.w描边不会随着Z轴的变化而变化

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}