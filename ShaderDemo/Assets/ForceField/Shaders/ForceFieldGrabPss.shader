Shader "Custom/ForceFieldGrabPss"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RimColor ("Rim Color", COLOR) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0, 10)) = 1
        _IntersectPower ("Intersect Power", Range(0, 10)) = 1
        
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        _DistortStrength("Distort Strength", Range(0,1)) = 0.2
        _DistortTimeFactor("Distort TimeFactor", Range(0,1)) = 0.2
    }
    SubShader
    {
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100
        
        //获取屏幕图像
        GrabPass
        {
            "_GrabTempTex"
        }

        //如果只使用一个Pass渲染，背面的相交效果会看不见
        Pass
        {
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "ForceFieldGrabPassLib.cginc"
            ENDCG
        }
        
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "ForceFieldGrabPassLib.cginc"
            ENDCG
        }
    }
}
