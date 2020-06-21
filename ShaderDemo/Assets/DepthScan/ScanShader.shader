Shader "Custom/ScanShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _LightColor("_LightColor", Color) = (1, 0, 0, 0.5)
        _LightWidth("_LightWidth", range(0.01, 0.5)) = 0.002
        _Speed("_Speed", range(0.001, 8)) = 0.3
    }
 
    SubShader
    {
        Tags{ "RenderType" = "Opaque" }
        
        ZTest Off
        cull Off
        ZWrite Off
        Pass
        {
            ZTest Off
            Cull Off
            ZWrite Off
            ColorMask RGBA
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
            sampler2D _CameraDepthTexture;
            fixed4 _LightColor;
            float _Speed;
            float _LightWidth;
 
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
 
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
 
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
                depth = Linear01Depth(depth);
                float pos = (_Time.y * _Speed * 1000 % 1000) * 0.001;
                if (depth > pos && depth < pos + _LightWidth)
                {
                    color.rgb = color.rgb * (1 - _LightColor.a) + _LightColor.rgb;
                }
                return color;
            }
            ENDCG
        }
        
    }
}
