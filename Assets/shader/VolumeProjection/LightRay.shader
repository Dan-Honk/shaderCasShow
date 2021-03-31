Shader "Unlit/LightRay"
{
    Properties
    {
        _ProjectionEdge("ProjectionEdge",Range(0,10)) = 4
        _ProjectionLength("ProjectionLength",Range(0,100)) = 10
        _ProjectionFadeOut("Fadeout distance",float)= 5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        CGINCLUDE
        #pragma vertex vert
        #pragma fragemt lfrag
        #include "UnityCG.cginc"
        #include "Projection.cginc"
        uniform float4 _LightColor0;
        uniform float _ProjectionEdge;

        fixed4 lfrag(v2f i):SV_Target
        {
            fixed4 col = _LightColor0;
            float3 lDir = normalize(UnityWorldSpaceLightDir(i.wPos));
            float NdotL = dot(i.normal,lDir);
            col.a = min(1,pow(1 + NdotL,8));

            float3 vDir = normalize(UnityWorldSpaceLightDir(_WorldSpaceCameraPos.xyz));
            float3 NcrossL = cross(i.normal,lDir);
            float3 VcrossL = cross(vDir,lDir);
            float NLdotVL = dot(NcrossL,VcrossL);
            float VdotL = dot(vDir,lDit);
            col.a *= pow(max(abs(NLdotVL),pow(VdotL,4)),_ProjectionEdge);

            col.a *=pow(min(distance(_WorldSpaceCameraPos.xyz,i.wPos),_ProjectionFadeOut)/_ProjectionFadeout,3);
            return col;
        }
        ENDCG

        Pass
        {
            Tags{"LightMode" = "ForwardAdd"}
            ZWrite Off
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            ENDCG
        }
    }
}
