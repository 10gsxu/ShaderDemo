Shader "Custom/PlanarShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowPlane ("ShadowPlane", Vector) = (0, 1, 0, 0.1)
        _ShadowProjDir ("ShadowProjDir", Vector) = (0, 0, 0, 0)
        _ShadowColor("ShadowColor", Color) = (0, 0, 0, 0.5)
        _WorldPos ("WorldPos", Vector) = (0, 0, 0, 0)
        _ShadowInvLen ("ShadowInvLen", float) = 0
        _ShadowFadeParams ("ShadowFadeParams", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back
            ColorMask RGB
            
            Stencil
            {
                Ref 0           
                Comp Equal          
                WriteMask 255       
                ReadMask 255
                //Pass IncrSat
                Pass Invert
                Fail Keep
                ZFail Keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _ShadowPlane;
            float4 _ShadowProjDir;
            float4 _ShadowColor;
            float4 _WorldPos;
            float _ShadowInvLen;
            float4 _ShadowFadeParams;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 shadowPos : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float3 lightdir = normalize(_ShadowProjDir);
                float3 worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float distance = (_ShadowPlane.w - dot(_ShadowPlane.xyz, worldpos)) / dot(_ShadowPlane.xyz, lightdir.xyz);
                //如果y坐标低于平面，则不投影
                if(worldpos.y < _ShadowPlane.w)
                    distance = 0;
                worldpos = worldpos + distance * lightdir.xyz;
    
                o.vertex = mul(UNITY_MATRIX_VP, float4(worldpos, 1.0));
                
                o.worldPos = _WorldPos;
                o.shadowPos = worldpos;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 direction = i.worldPos - i.shadowPos;
                float4 color = _ShadowColor;
                color.a = (pow((1.0 - clamp(((sqrt(dot(direction, direction)) * _ShadowInvLen) - _ShadowFadeParams.x), 0.0, 1.0)), _ShadowFadeParams.y) * _ShadowFadeParams.z);
                return color;
            }
            ENDCG
        }

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
