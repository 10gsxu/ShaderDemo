Shader "Custom/RimLightShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _RimColor ("Rim Color", COLOR) = (1,1,1,1)
        _RimPower ("Rim Power", float) = 1
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float rimLight : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _RimColor;  
            float _RimPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                float3 normal = normalize(v.normal);
                o.rimLight = 1.0 - saturate(dot(normal, viewDir));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 rimColor = _RimColor.rgb * pow(i.rimLight, 1 / _RimPower);
                col.rgb += rimColor;
                return col;
            }
            ENDCG
        }
    }
}
