#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"
#include "OITransparency.cginc"
 
sampler2D _MainTex;
float4 _Color;
float4 _SpecularColor;
float _Smoothness;
 
struct AppData{
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 texcoord : TEXCOORD0;
};

struct v2f{
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD2;

	float3 lightDir: TEXCOORD0;
	float3 normal: TEXCOORD1;
	LIGHTING_COORDS(3, 4)
};
 
v2f vert(appdata_base v){
	v2f o;
 
	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	o.uv = v.texcoord.xy;

	o.lightDir = ObjSpaceLightDir(v.vertex);
	o.normal = normalize(v.normal).xyz;

	TRANSFER_VERTEX_TO_FRAGMENT(o);

	return o; 
}

TrFrag frag(v2f i){
	float4 finalColor = tex2D(_MainTex, i.uv)*_Color;// * i.color;

	float3 l = normalize(i.lightDir);
	float3 n = normalize(i.normal);

	float attenuation = LIGHT_ATTENUATION(i) * 2.0;

	float nDotL = saturate(dot(n, l));
	float4 diffuseTerm = nDotL * _LightColor0 * attenuation;
	#ifdef TRANSPARENCY_USE_AMBIENT
		float4 ambient = UNITY_LIGHTMODEL_AMBIENT * 2.0;
		finalColor = (ambient + diffuseTerm) * finalColor;
	#else
		finalColor = diffuseTerm * finalColor;
	#endif

	TrFrag result;
	#ifdef TRANSPARENCY_USE_ADDITIVE
		result = encodeTransparencyAdditive(finalColor, i.pos.z/i.pos.w, 0.0);
	#else
		result = encodeTransparency(finalColor, i.pos.z/i.pos.w);
	#endif
	return result;
}
