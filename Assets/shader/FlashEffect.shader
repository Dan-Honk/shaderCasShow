// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/FlashEffect"
{
    Properties
    {
        _MainTex ("MainTex(RGB)", 2D) = "white" {}
        _FlashTex("FlashTex",2D) = "black" {}
        _FlashColor("FlashColor",Color) = (1,1,1,1)
        _FlashSpeedX("FlashSpeedX",Range(-5,5)) = 0
        _FlashSpeedY("FlashSpeedY",Range(-5,5)) = 0.5
        _FlashFactor("FlashFactor",Range(0,5)) = 1
        _RotateAngle("RotateAngle",Range(-5.0,5.0)) = 0.0
    }
    CGINCLUDE
	#include "Lighting.cginc"
    uniform sampler2D _MainTex;
    uniform float4 _MainTex_ST;
    uniform sampler2D _FlashTex;
    uniform fixed4 _FlashColor;
    uniform fixed _FlashSpeedX;
    uniform fixed _FlashSpeedY;
    uniform fixed _FlashFactor;
    uniform float _RotateAngle;

    struct v2f
    {
        float4 pos : SV_POSITION;
        float3 worldNormal : NORMAL;
        float2 uv :TEXCOORD0;
        float3 worldLight : TEXCOORD1;
    };

    v2f vert(appdata_base v)
    {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.worldNormal = UnityObjectToWorldNormal(v.normal);
        o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
        o.worldLight = UnityObjectToWorldDir(_WorldSpaceLightPos0.xyz);
        return o;
    }

    fixed4 frag(v2f i) : SV_Target
    {
        half3 normal = normalize(i.worldNormal);
        half3 light = normalize(i.worldLight);
        fixed diff = max(0,dot(normal,light)); //漫反射
        i.uv = 1 - i.uv;
        //fixed4 albebo = tex2D(_MainTex,i.uv);
        half flashuv = i.uv + half2(_FlashSpeedX,_FlashSpeedY) * _Time.y;

        float2 pivot = float2(0.5,0.5);

        // float cosAngle = cos(_RotateAngle);
        // float sinAnle = sin(_RotateAngle);

        // float2x2 rot = float2x2(cosAngle,-sinAnle,sinAnle,cosAngle);

        i.uv -= pivot;

        //i.uv = mul(rot,i.uv);
        i.uv += pivot;

        fixed4 albebo = tex2D(_MainTex,i.uv);
        fixed4 flash = tex2D(_FlashTex,flashuv) * _FlashColor * _FlashFactor;
        fixed3 col = diff *albebo+ flash.rgb;
        //fixed3 col = albebo.rgb;
        return fixed4(col,1);
    }
    ENDCG


    SubShader
    {   
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack "Diffuse"
}
