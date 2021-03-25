struct a2v
{
    float4 vertex : POSITION;
    float3 normal:NORMAL;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float3 wPos : TEXCOORD1;
    float3 normal : TEXCOORD2;
};

uniform fixed4 _ProjectionColor;
uniform float _ProjectionLength;
uniform float _ProjectionFadeOut;

v2f vert(a2v v)
{
    v2f o;
    o.wPos = mul(unity_ObjectToWorld,v.vertex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    float3 lightDir = normalize(UnityWorldSpaceLightDir(o.wPos));
    v.vertex.xyz += v.normal * 0.01;//取边缘
    v.vertex = mul(UNITY_MATRIX_M,v.vertex);
    float NdotL = min(0,dot(o.normal,lightDir));
    v.vertex.xyz += lightDir * NdotL * _ProjectionLength;
    o.pos = v.vertex = mul(UNITY_MATRIX_VP,v.vertex);
    return o;
}

