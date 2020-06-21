Shader "Custom/ForceFieldShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", COLOR) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 10)) = 1
        _RimStrength ("Rim Strength", Range(0, 10)) = 1
        _IntersectPower ("Intersect Power", Range(0, 10)) = 1
    }
    SubShader
    {
        ZWrite Off
        Blend SrcAlpha One
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100
        //如果只使用一个Pass渲染，背面的相交效果会看不见
        Pass
        {
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "ForceField.cginc"
            ENDCG
        }
        
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "ForceField.cginc"
            ENDCG
        }
    }
}
