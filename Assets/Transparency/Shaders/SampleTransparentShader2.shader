Shader "Prototype/SimpleTransparentShader2"{
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_TintColor ( "Tint", Color) = (1, 1, 1, 1)
	}
 
	SubShader{
		Tags{ "RenderType"="Transparent" "Queue"="Transparent"}

        	pass{       
			Tags { "LightMode"="ForwardBase"}
            
			ZWrite Off
			Cull Off
			Blend One One, Zero OneMinusSrcAlpha
 
			CGPROGRAM
 
			#pragma target 3.0
			#pragma vertex vertShadow
			#pragma fragment fragShadow
			#pragma multi_compile_fwdadd_fullshadows
 
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			//#include "OITransparency.cginc"
 
			sampler2D _MainTex;
			float4 _TintColor;
			float4 _LightColor0;
 
			struct appdata_t{
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				fixed4 color : COLOR;
				float2 uv : TEXCOORD2;
			};
 
			v2f vertShadow(appdata_t v){
				v2f o;
 
				o.color = v.color;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy;
				return o; 
			}
			
			struct FragOut{
				float4 c1: COLOR1;
				float4 c2: COLOR2;
			};

			float computeWeight(float4 color, float z){
				float weight =  
					max(min(1.0, max(max(color.r, color.g), color.b) * color.a), color.a) *
					clamp(0.03 / (0.00001 + pow(z / 200, 4.0)), 0.01, 3000);
				return weight;
			}

			FragOut fragShadow(v2f i){
				float z = i.pos.z/i.pos.w;
				float4 finalColor = tex2D(_MainTex, i.uv)*_TintColor * i.color;
				
				//One, One
				//return weightedColor = finalColor.xyzw*weight;
				//Zero, OneMinusSrcAlpha
				//return finalColor.w
				//dst2 = src * 0 + dst2 * (1.0 - alpha) = dst2 - dst2*alpha
				//dst1 = float4(finalColor.xyz, 1.0)*weight*alpha + dst1*1
				//dst1 = dst1 - (-float4(finalColor.xyz, 1.0)*weight)*alpha
				
				//dst = dst * (1.0 - a)

				//dst2 = 0 + dst2 * (1.0 - alpha)
				//dst2 = 1.0 * color + dst2 * (1.0 - alpha)
				//dst1 = dst1 + float4(finalColor.xyz, 1.0)*weight*alpha
				//dst1 = float4(finalColor.xyz, 1.0)*weight*alpha + dst1
				
				//v2 = v2 * (1.0 - alpha)
				//v1 = v1 + float4(finalColor.xyz, 1.0)*weight*alpha
				
				//dst2 = src2*0.0 + dst2* (1.0 - alpha) = src2*0.0 + dst2 - alpha*dst2
				//dst1 = float4(finalColor.xyz, 1.0)*weight*alpha + dst1*1.0
				float weight = computeWeight(finalColor, z);
				float4 weightColor = float4(finalColor.xyz, 1.0)*weight;
				float4 weightPremulColor = weightColor*finalColor.w;
				float alpha = finalColor.w;
				
				FragOut res;
				res.c1 = float4(weightPremulColor.xyz, 1.0);
				//res.c1 = float4(weightColor.xyz, 0.0);
				//res.c1 = 0.0;
				//res.c1.x = -1.0;
				
				res.c2 = 0.0;
				res.c2.yz = weightPremulColor.w;
				res.c2.w = alpha;
				//res.c2.y = weightColor.w;//weightedColor.w/f;
				//res.c2.y = tr.col.w/f; res.c1.w = f;				
				return res;
			}
 
		ENDCG
		} 
	}
	FallBack Off
}