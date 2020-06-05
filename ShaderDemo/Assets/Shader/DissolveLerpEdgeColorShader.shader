Shader "Custom/Dissolve/EdgeLerpColorShader"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        _Threshold ("Threshold", Range(0, 1)) = 0
        _EdgeLength ("Edge Length", Range(0, 1)) = 0
        _EdgeStartColor ("Edge Start Color", COLOR) = (1,1,1,1)
        _EdgeEndColor ("Edge End Color", COLOR) = (1,1,1,1)
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
                float2 uvNoise : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            float _Threshold;

            float _EdgeLength;
            fixed4 _EdgeStartColor;
            fixed4 _EdgeEndColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvNoise = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed cutout = tex2D(_NoiseTex, i.uvNoise).r;
                clip(cutout - _Threshold);

                //边缘颜色
                if(cutout - _Threshold < _EdgeLength)
                {
                    fixed percent = (cutout - _Threshold) / _EdgeLength;
                    return lerp(_EdgeStartColor, _EdgeEndColor, percent);
                }

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
