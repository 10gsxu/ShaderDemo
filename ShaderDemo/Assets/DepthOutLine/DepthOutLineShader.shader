Shader "Custom/DepthOutLineShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Edge ("Edge", Range(0, 0.2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 dxy : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _CameraDepthTexture;
            float2 _MainTex_TexelSize;
            float _Edge;
            
            half edge(half2 uv, float2 xy){
                half offset = 0;
                half center = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv)));
                //获取九宫格的深度差
                for (int i = -1;i < 2;i++){
                    for (int j = -1;j < 2;j++){
                        offset += center - Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv + half2(i * xy.x, j * xy.y))));
                    }
                }
                return abs(offset) * 10000;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.dxy = _MainTex_TexelSize;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float rate = saturate(edge(i.uv, i.dxy));
                rate = rate > _Edge ? 0 : 1;
                return col * rate;
            }
            ENDCG
        }
    }
}
