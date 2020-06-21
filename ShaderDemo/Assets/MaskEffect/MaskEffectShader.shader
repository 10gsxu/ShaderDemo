Shader "Custom/MaskEffectShader"
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
            
            // 创建圆
            // pos : 圆心
            // radius: 半径
            // uv: 当前像素坐标
            fixed3 createCircle(float2 pos, float radius, float2 uv)
            {
                //当前像素到中心点的距离
                float dis = distance(pos, uv);
                //smoothstep 平滑过渡, 这里也可以用 step 代替
                float col = smoothstep(radius + 0.008, radius, dis);
                return fixed3(col,col,col);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 scale = fixed2(_ScreenParams.x / _ScreenParams.y, 1);
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 mask = createCircle(float2(0.5, 0.5)*scale, 0.2, i.uv*scale);
                return col * fixed4(mask, 1.0);
            }
            ENDCG
        }
    }
}
