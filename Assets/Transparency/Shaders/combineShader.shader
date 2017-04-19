Shader "PostProcess/TransparencyCombine"{
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_UiTex("UI tex", 2D) = "white" {}
		_ColorTex("Color tex", 2D) = "white" {}
		_Pass1Tex("Pass1 texture", 2D) = "white" {}
		_Pass2Tex("Pass2 texture", 2D) = "white" {}
	}

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
				
CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform sampler2D _UiTex;
uniform sampler2D _ColorTex;
uniform sampler2D_float _Pass1Tex;
uniform sampler2D_float _Pass2Tex;

float4 frag (v2f_img i) : SV_Target
{
	float4 original = tex2D(_MainTex, i.uv);
	float2 passCoords = float2(i.uv.x, 1.0-i.uv.y);
	float4 baseColor = tex2D(_ColorTex, passCoords);
	float4 pass1 = tex2D(_Pass1Tex, passCoords);
	float4 pass2 = tex2D(_Pass2Tex, passCoords);
	fixed4 output = baseColor;

	float4 accum = pass1;
	accum.w = pass2.y;
	float reveal = pass2.w;
	
	float4 fragColor = float4(accum.xyz / max(accum.w, 0.00001), reveal);
	
	output.xyz = lerp(fragColor.xyz, baseColor.xyz, fragColor.w);
	//fixed4 output = (original+pass1+baseColor+pass2)*0.25;
	//fixed4 output = (original+pass1)*0.5;
	//fixed4 output = (original+pass1+pass2)/3.0;
	//fixed4 output = 1.0 - original;
	//fixed4 output = (original + pass1) * 0.5;
	return output;
}
ENDCG

	}
}

Fallback off
}
