Shader "Prototype/MrtCombineMaterial"{
	Properties {
		_ColorTex("Color tex", 2D) = "white" {}
		_Pass1Tex("ARGB texture", 2D) = "white" {}
		_Pass2Tex("R texture", 2D) = "white" {}
	}

	SubShader {
		Tags{ "RenderType"="Opaque"}
		Pass {
			Tags { "LightMode"="ForwardBase"}
			ZTest On ZWrite On
				
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform sampler2D _ColorTex;
			uniform sampler2D_float _Pass1Tex;
			uniform sampler2D_float _Pass2Tex;

			struct v2f{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD2;
			};
 
			v2f vert(appdata_base v){
				v2f o;
 
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy;
				return o; 
			}
			
			float4 frag(v2f i): COLOR{				
				float4 baseColor = tex2D(_ColorTex, i.uv);
				float4 pass1 = tex2D(_Pass1Tex, i.uv);
				float4 pass2 = tex2D(_Pass2Tex, i.uv);
				fixed4 output = baseColor;

				//float4 accum = pass1;
				float4 accum = float4(pass1.xyz, pass2.y);
				float reveal = pass2.w;
	
				float4 fragColor = float4(accum.xyz / max(accum.w, 0.00001), reveal);
	
				output.xyz = lerp(fragColor.xyz, baseColor.xyz, fragColor.w);
				//output.xyz = pass2.xyz;
				//output = pass2.y;
				///output=pass2.w;
				return output;
			} 
		ENDCG
	}
}

Fallback off
}
