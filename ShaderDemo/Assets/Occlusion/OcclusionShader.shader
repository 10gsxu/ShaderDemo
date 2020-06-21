Shader "Custom/OcclusionShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _RimColor ("Rim Color", COLOR) = (1,1,1,1)
        _RimLength ("Rim Length", Range(0, 10)) = 1
    }
    SubShader
    {
        Pass
        {
            ZTest Greater
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldViewDir : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };
            float4 _RimColor;
            float _RimLength;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldViewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }   
            fixed4 frag (v2f i) : SV_Target
            {
                float alpha = pow(1 - saturate(dot(i.worldNormal, i.worldViewDir)), _RimLength);
                _RimColor.a = alpha;
                return _RimColor;
            }
            ENDCG
        }
        //正常阶段
        Pass
        {
            ZTest Less
            ZWrite On
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
    }
}
