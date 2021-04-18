Shader "Unlit/GaussBlur"
{
    Properties
    {
        _MainTex("Texture",2D) = "white"{}
        _BlurTex("BlurTex",2D) = "white"{}
    }
    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;
    float4 _offsets;

    struct v2f_blur
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float4 uv01 : TEXCOORD1;
        float4 uv23 : TEXCOORD2;
        float4 uv45 : TEXCOORD3;
    };

    v2f_blur vert_blur(appdata_img v)
    {
        v2f_blur o;
        _offsets *= _MainTex_TexelSize.xyxy;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = v.texcoord.xyxy;

        o.uv01 = v.texcoord.xyxy + _offsets.xyxy * float4(1,1,-1,-1);
        o.uv23 = v.texcoord.xyxy + _offsets.xyxy * float4(1,1,-1,-1)*2.0;
        o.uv45 = v.texcoord.xyxy + _offsets.xyxy * float4(1,1,-1,-1)*3.0;

        return o;
    }

    fixed4 frag_blur(v2f_blur i) :SV_Target
    {
        fixed4 color = fixed4(0,0,0,0);
        color += 0.40 * tex2D(_MainTex, i.uv);
        color += 0.15 * tex2D(_MainTex, i.uv01.xy);
        color += 0.15 * tex2D(_MainTex, i.uv01.zw);
        color += 0.10 * tex2D(_MainTex, i.uv23.xy);
        color += 0.10 * tex2D(_MainTex, i.uv23.zw);
        color += 0.05 * tex2D(_MainTex, i.uv45.xy);
        color += 0.05 * tex2D(_MainTex, i.uv45.zw);
        return color;
    }
    ENDCG
    SubShader
    {
        Pass
        {
            ZTest Off
            Cull Off
            ZWrite Off
            Fog{Mode Off}
            CGPROGRAM
            #pragma vertex vert_blur
            #pragma fragment frag_blur
            ENDCG
        }
    }
}