﻿Shader "Unlit/Lather"
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
                float3 visual : TEXCORRD3;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            float4 _MainTex_ST;
            float4 _BumpMap_ST;

            v2f vert (appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex+_SinTime.y*v.normal*0.1);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap);

                TANGENT_SPACE_ROTATION;
                o.TtoV0 = normalize(mul(rotation,UNITY_MATRIX_IT_MV[0].xyz));
                o.TtoV1 = normalize(mul(rotation,UNITY_MATRIX_IT_MV[1].xyz));

                o.visual = normalize(mul(rotation,-ObjSpaceViewDir(v.vertex)));
                return o;
            }


            fixed4 _Color;
            fixed4 _ShadowColor;
            sampler2D _Bubble;
            sampler2D _BubbleNoise;
            sampler2D _LightModle;
            sampler2D _LightModleSpec;
            fixed _SpecValue;
            fixed _BumpValue;
            fixed _LightModleValue;
            fixed _BubbleValue;
            fixed _MetalRef;

            float3 lum(fixed3 c)
            {
                return c.r * 0.2 + c.g * 0.7 + c.b * 0.1;
            }

         
            float4 frag(v2f i):Color
            {
                fixed4 c = tex2D(_MainTex,i.uv.xy);
                float3 normal = UnpackNormal(tex2D(_BumpMap,i.uv.zw));
                normal.xy *= _BumpValue;
                normal = normalize(normal);

                float v_n_angle = saturate(acos(dot(-i.visual,normal))*2 / 3.14);
                //模拟肥皂泡厚度流动的变化，使用噪声图控制随机效果
                float BubbleR = tex2D(_BubbleNoise,i.uv.xy + float2(0,_Time.x)).r;
                float BubbleG = tex2D(_BubbleNoise,i.uv.xy + float2(BubbleR * 0.5, _Time.x) * 0.9 + 0.05 * _SinTime.x).g;
                float BubbleB = tex2D(_BubbleNoise,i.uv.xy + float2(BubbleG * 0.5,_Time.x) * 1.1 - 0.05 * _SinTime.y).b;
                float BubbleNoise = saturate(BubbleR * BubbleG * BubbleB * 4);

                fixed4 Bubble = tex2D(_Bubble,fixed2(BubbleNoise,v_n_angle));

                float3 correctiveNormal = normalize(reflect(i.visual,normal));
                normal = normalize(lerp(normal,correctiveNormal,_MetalRef));

                half2 vn;
                vn.x = dot(i.TtoV0,normal);
                vn.y = dot(i.TtoV1,normal);

                fixed4 LightModleLookup = saturate(tex2D(_LightModle, vn * 0.495 + 0.505) * _Color * _LightModleValue);
                
                fixed2x2 rotSpec = 
                {
                    -1,0,
                    0,-1
                };
                //使用旋转矩阵，将反射结果翻转
                half2 vnsp = mul(rotSpec,vn);
                fixed4 LightModleSpec = tex2D(_LightModleSpec,vn* 0.495 + 0.505);
                fixed4 LightModleSpec2 = tex2D(_LightModleSpec,vnsp * 0.495 + 0.505);
                //进行混合计算
                LightModleSpec.rgb = lum(saturate((LightModleSpec + LightModleSpec2)*0.5).rgb) * (LightModleSpec.rgb +LightModleSpec2.rgb)*0.5;

                LightModleSpec.a = 1;

                fixed4 diff = c * LightModleLookup;

                fixed4 finalColor = clamp(diff + LightModleSpec * _SpecValue,0,1) * lerp(fixed4(1,1,1,1),Bubble * 1.5,_BubbleValue);

                //菲涅尔
                float fresnel = saturate(pow(v_n_angle,1.6));
                //进行菲涅尔高光混合
                finalColor.a = saturate(fresnel * 0.2 + 0.8 * (fresnel + 0.1) * lum(LightModleSpec.rgb * _SpecValue + 0.1) + 0.05);

                return finalColor;
            }

            ENDCG
        }
    }
    //Fallback "VertexLit"
}
