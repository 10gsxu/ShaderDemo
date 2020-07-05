Shader "Custom/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _HColor ("Highlight Color", Color) = (0.8, 0.8, 0.8, 1.0)
        _SColor ("Shadow Color", Color) = (0.2, 0.2, 0.2, 1.0)
        
        // ramp
        _ToonSteps ("Steps of Toon", range(1, 9)) = 2
        _RampThreshold ("Ramp Threshold", Range(0.1, 1)) = 0.5
        _RampSmooth ("Ramp Smooth", Range(0, 1)) = 0.1
        
        // specular
        _SpecularColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
        _SpecularSmooth ("Specular Smooth", Range(0, 1)) = 0.1
        _SpecularGloss ("Specular Gloss", Range(0, 1)) = 0.3
        
        // rim light
        _RimColor ("Rim Color", Color) = (0.8, 0.8, 0.8, 0.6)
        _RimThreshold ("Rim Threshold", Range(0, 1)) = 0.5
        _RimSmooth ("Rim Smooth", Range(0, 1)) = 0.1
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
                float4 vertex : SV_POSITION;
                float ndl : TEXCOORD1;
                float ndh : TEXCOORD2;
                float ndv : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            fixed4 _HColor;
            fixed4 _SColor;
            
            float _RampThreshold;
            float _RampSmooth;
            float _ToonSteps;
            
            fixed4 _SpecularColor;
            float _SpecularSmooth;
            fixed _SpecularGloss;
            
            fixed4 _RimColor;
            fixed _RimThreshold;
            float _RimSmooth;
            
            float linearstep(float min, float max, float t)
            {
                return saturate((t - min) / (max - min));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                half3 normalDir = UnityObjectToWorldNormal(v.normal);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 viewDir = normalize(WorldSpaceViewDir(v.vertex));
                half3 halfDir = normalize(lightDir + viewDir);
                o.ndl = max(0, dot(normalDir, lightDir));
                o.ndh = max(0, dot(normalDir, halfDir));
                o.ndv = max(0, dot(normalDir, viewDir));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // multi steps
                float diff = smoothstep(_RampThreshold - i.ndl, _RampThreshold + i.ndl, i.ndl);
                float interval = 1 / _ToonSteps;
                float level = round(diff * _ToonSteps) / _ToonSteps;
                float ramp;
                if (_RampSmooth == 1)
                {
                    ramp = interval * linearstep(level - _RampSmooth * interval * 0.5, level + _RampSmooth * interval * 0.5, diff) + level - interval;
                }
                else
                {
                    ramp = interval * smoothstep(level - _RampSmooth * interval * 0.5, level + _RampSmooth * interval * 0.5, diff) + level - interval;
                }
                ramp = max(0, ramp);
                _SColor = lerp(_HColor, _SColor, _SColor.a);
                fixed3 rampColor = lerp(_SColor.rgb, _HColor.rgb, ramp);
                
                // specular
                float specular = pow(i.ndh, _SpecularGloss * 128.0);
                specular = smoothstep(0.5 - _SpecularSmooth * 0.5, 0.5 + _SpecularSmooth * 0.5, specular);
                fixed3 lightColor = _LightColor0.rgb;
                fixed3 specularColor = _SpecularColor.rgb * lightColor * specular;
                
                // rim
                float rim = (1.0 - i.ndv) * i.ndl;
                rim = smoothstep(_RimThreshold - _RimSmooth * 0.5, _RimThreshold + _RimSmooth * 0.5, rim);
                fixed3 rimColor = _RimColor.rgb * lightColor * _RimColor.a * rim;
            
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= rampColor + specularColor + rimColor;
                return col;
            }
            ENDCG
        }
    }
}
