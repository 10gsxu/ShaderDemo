Shader "Custom/PlanarReflection"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Strength ("Strength", Range(0, 1)) = 1
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
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 uvReflect : TEXCOORD1;
                float halfLambert : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            fixed4 _MainColor;

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float _Strength;
            sampler2D _ReflectTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvReflect = ComputeScreenPos(o.vertex);

                float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                o.halfLambert = dot(worldNormal, worldLightDir)*0.5 + 0.5;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float3 diffuse = color * _MainColor.rgb;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * color;
                fixed3 result = ambient + _LightColor0.rgb * diffuse * i.halfLambert;
                fixed4 reflectCol = tex2Dproj(_ReflectTex, i.uvReflect)*_Strength;
                return fixed4(result, _MainColor.w)+reflectCol;
            }
            ENDCG
        }
    }
}
