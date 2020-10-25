Shader "Unlit/Frensnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white"{}
        _FresnelScale("FresnelScale",Range(0,1)) = 1
        _FresnelInden("FresenlInden",Range(0,5)) = 5
        _CubeMap("CubeMap",Cube) = "_Shybox"{}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

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
                fixed3 worldRef1 :  TEXCOORD1;
                fixed3 worldNormal : TEXCOORD2;
                fixed3 worldViewDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FresnelScale;
            float _FresnelInden;
            samplerCUBE  _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                fixed3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
                o.worldRef1 = reflect(-o.worldViewDir,o.worldNormal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 reflection = texCUBE(_CubeMap,i.worldRef1).rgb;
               fixed4 col = tex2D(_MainTex,i.uv);

               float fresnel = _FresnelScale + (1 - _FresnelScale)* pow(1-dot(normalize(i.worldNormal),normalize(i.worldViewDir)) ,_FresnelInden);

               col.rgb = lerp(col.rgb,reflection,fresnel);
                return col;
            }
            ENDCG
        }
    }
}
