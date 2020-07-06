Shader "Custom/MatcapShader"
{
    Properties
    {
        _MatcapTex ("Matcap Tex", 2D) = "white" {}
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
                float2 matcapuv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MatcapTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //UNITY_MATRIX_IT_MV 用于 将法线从模型空间转化到视觉空间
                //乘以逆转置矩阵将normal变换到视空间
                float3 viewnormal = mul(UNITY_MATRIX_IT_MV, v.normal);
                //需要normalize一下，否则保证normal处在（-1,1）区间，否则有scale的object效果不对
                viewnormal = normalize(viewnormal);
                o.matcapuv = viewnormal.xy * 0.5 + 0.5;

                //如果缩放模型，这种方式会出现问题，一定要保证ViewNormal处在（-1,1）区间
                //o.matcapuv.x = mul(UNITY_MATRIX_IT_MV[0], v.normal) * 0.5 + 0.5; 
                //o.matcapuv.y = mul(UNITY_MATRIX_IT_MV[1], v.normal) * 0.5 + 0.5; 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MatcapTex, i.matcapuv);
                return col;
            }
            ENDCG
        }
    }
}
