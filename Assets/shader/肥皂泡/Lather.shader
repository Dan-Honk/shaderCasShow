Shader "Unlit/Lather"
{
    Properties
    {
        _Color("Main Color",Color) = (1,1,1,1)
        _MetalRef("MetalRef",Range(0,1)) = 0

        _MainTex("Main Tex",2D) = "white"{}
        _BumpMap("Bumpmap(RGB)",2D) = "bump" {}
        _BumpValue("BumpValue",Range(0,3)) = 1

        _LightModle("LightModleDiffuse(RGB)",2D) = "white"{}
        _LightModleValue("LightModleValue",Range(0,3)) = 1
        _LightModleSpec("LightModleSpec(RGB)",2D) = "black" {}
        _SpecValue("SpecValue",Range(0,4)) = 0

        _Bubble("Bubble",2D) = "white"{}
        _BubbleNoise("BubbleNoise",2D) = "white"{}
        _BubbleValue("Bubble Value",Range(0,2)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }

        Pass
        {
            Name "BASE"
            Tags{"LightMode" = "Always"}
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma fragmentoption ARB_fog_exp2
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 TtoV0 : TEXCOORD1;
                float3 TtoV1 : TEXCOORD2;
                float3 visual : TEXCOORD3;
                float4 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
