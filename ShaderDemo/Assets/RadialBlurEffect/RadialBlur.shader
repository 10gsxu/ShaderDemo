Shader "Custom/RadialBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _BlurFactor;  //模糊强度
            float2 _BlurCenter; //模糊中心点

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //模糊方向: 中心像素 - 当前像素
                float2 dir = _BlurCenter.xy - i.uv;
                float4 col = 0;
                //迭代
                for (int j = 0; j < 5; ++j)
                {
                    //计算采样uv值：正常uv值+从中间向边缘逐渐增加的采样距离
                    float2 uv = i.uv + _BlurFactor * dir * j;
                    col += tex2D(_MainTex, uv);
                }
                //取平均值(乘法比除法性能好)
                col *= 0.2;
                return col;
            }
            ENDCG
        }
    }
}
