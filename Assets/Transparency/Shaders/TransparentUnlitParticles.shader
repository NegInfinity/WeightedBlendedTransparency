Shader "Transparency/Transparent Unlit Particles"{
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_TintColor ( "Tint", Color) = (1, 1, 1, 1)
	}
 
	SubShader{
		Tags{ "RenderType"="Transparent" "Queue"="Transparent"}

        	pass{       
			Tags { "LightMode"="Always"}
            
			ZWrite Off
			Cull Off
			Blend One One, Zero OneMinusSrcAlpha
 
			CGPROGRAM
 
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_fwdadd_fullshadows
 
			#include "UnityCG.cginc"
			#include "OITransparency.cginc"
 
			sampler2D _MainTex;
			float4 _TintColor;
 
			struct AppData{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
				float2 uv : TEXCOORD2;
			};
 
			v2f vert(AppData v){
				v2f o;
 
				o.color = v.color;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy;
				return o; 
			}

			TrFrag frag(v2f i){
				float4 finalColor = tex2D(_MainTex, i.uv)*_TintColor * i.color;

				TrFrag result;
				result = encodeTransparency(finalColor, i.pos.z/i.pos.w);
				return result;
			}
 
		ENDCG
		} 
	}
	FallBack Off
}