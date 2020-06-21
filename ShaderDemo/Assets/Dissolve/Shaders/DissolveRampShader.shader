Shader "Custom/Dissolve/RampShader"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        _Threshold ("Threshold", Range(0, 1)) = 0
        _EdgeLength ("Edge Length", Range(0, 1)) = 0
        _RampTex ("Ramp Tex", 2D) = "white" {}
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
                float2 uvRamp : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            float _Threshold;
            float _EdgeLength;
            sampler2D _RampTex;
            float4 _RampTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvNoise = TRANSFORM_TEX(v.uv, _NoiseTex);
                //o.uvRamp = TRANSFORM_TEX(v.uv, _RampTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed cutout = tex2D(_NoiseTex, i.uvNoise).r;
                clip(cutout - _Threshold);

                //边缘颜色
                fixed percent = saturate((cutout - _Threshold) / _EdgeLength);
                fixed4 edgeColor = tex2D(_RampTex, float2(percent, percent));

                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 result = lerp(edgeColor, col, percent);

                return fixed4(result.rgb, 1);
            }
            ENDCG
        }
    }
}
