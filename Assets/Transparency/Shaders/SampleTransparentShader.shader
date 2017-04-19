Shader "Prototype/SimpleTransparentShader"{
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
			//AlphaTest Greater .01
			//Blend SrcAlpha OneMinusSrcAlpha
			Blend One One
 
			CGPROGRAM
 
			#pragma target 3.0
			//#pragma fragmentoption ARB_precision_hint_fastest
 
			#pragma vertex vertShadow
			#pragma fragment fragShadow
			//#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdadd_fullshadows
 
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "OITransparency.cginc"
 
			sampler2D _MainTex;
			float4 _TintColor;
			float4 _LightColor0;
 
			struct appdata_t {
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
			
			float4 fragShadow(v2f i): COLOR1{
				float z = i.pos.z/i.pos.w;
				float4 finalColor = tex2D(_MainTex, i.uv)*_TintColor * i.color;
				
				float weight = computeWeight(finalColor, z);
				float4 weightColor = float4(finalColor.xyz, 1.0)*weight;
				float4 weightPremulColor = weightColor*finalColor.w;
				float alpha = finalColor.w;

				//TrFrag tr;
				//tr = encodeTransparency(finalColor, z);
				//return tr.col;
				return weightPremulColor;
			}
 
		ENDCG
		} 
        	pass{       
			Tags { "LightMode"="ForwardBase"}
            
			ZWrite Off
			Cull Off
			AlphaTest Greater .01
			//Blend SrcAlpha OneMinusSrcAlpha
			//Blend Zero OneMinusSrcAlpha
			//Blend Zero OneMinusSrcAlpha
			Blend One OneMinusSrcAlpha
 
			CGPROGRAM
 
			#pragma target 3.0
			//#pragma fragmentoption ARB_precision_hint_fastest
 
			#pragma vertex vertShadow
			#pragma fragment fragShadow
			//#pragma multi_compile_fwadbase
			#pragma multi_compile_fwdadd_fullshadows
 
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "OITransparency.cginc"
 
			sampler2D _MainTex;
			float4 _TintColor;
			float4 _LightColor0;
 
			struct appdata_t {
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
			
			float4 fragShadow(v2f i): COLOR2{
				float z = i.pos.z/i.pos.w;
				float4 finalColor = tex2D(_MainTex, i.uv)*_TintColor * i.color;

				float weight = computeWeight(finalColor, z);
				float4 weightColor = float4(finalColor.xyz, 1.0)*weight;
				float4 weightPremulColor = weightColor*finalColor.w;
				float alpha = finalColor.w;
								
				//TrFrag tr;
				//tr = encodeTransparency(finalColor, z);				
				//return alpha;
				float4 res = 0.0;
				res.y = -weightColor.w;
				res.w = alpha;
				return res;//tr.col1;//float4(tr.col1.xyz, tr.col1.w);
			}
 
		ENDCG
		} 
	}
	FallBack Off
}