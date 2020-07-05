Shader "Custom/CelShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _StairNum ("Stair Num", range(1, 9)) = 2
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
                float4 vertex : SV_POSITION;
                float ndl : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float _StairNum;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                half3 normalDir = UnityObjectToWorldNormal(v.normal);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.ndl = dot(normalDir, lightDir);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half halfLambert = i.ndl * 0.5 + 0.5;//i.ndl范围[-1，1]，转为[0, 1]
                half floorToon = floor(halfLambert * _StairNum) * (1/_StairNum);
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= floorToon;
                return col;
            }
            ENDCG
        }
    }
}
