// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/DissolveEffectX"
{
    Properties
    {
        _MainTex ("Texture(RGB)", 2D) = "white" {}
        _DissolveVector("DissolveVector",Vector) = (0,0,0,0)
    }

    CGINCLUDE
    #include "Lighting.cginc"
    uniform sampler2D _MainTex;
    uniform float4 _MainTex_ST;
    uniform float4 _DissolveVector;
    
    struct v2f
    {
        float4 pos : SV_POSITION;
        float3 worldNormal : NORMAL;
        float2 uv : TEXCOORD0;
        float3 worldLight : TEXCOORD1;
        float4 objPos : TEXCOORD2;
    };

    v2f vert(appdata_base v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
        o.objPos  = v.vertex;
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.worldLight = UnityObjectToWorldDir(_WorldSpaceLightPos0.xyz);
        return o;
    }

    fixed4 frag(v2f i) :SV_Target
    {
        half3 normal = normalize(i.worldNormal);
        half3 light = normalize(i.worldLight);
        fixed diff = max(0,dot(normal,light));
        fixed4 albedo = tex2D(_MainTex,i.uv);
        clip(normalize(i.objPos.xyz) - _DissolveVector.xyz);
        fixed3 c = diff * albedo;
        return fixed4(c,1);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Tags{"RenderType" = "Opaque"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack "Diffuse"
}
