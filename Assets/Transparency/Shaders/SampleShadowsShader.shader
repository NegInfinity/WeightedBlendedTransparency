Shader "Prototype/SimpleDiffuseShader"
{
    Properties 
    {
        _DiffuseTexture ("Diffuse Texture", 2D) = "white" {}
        _DiffuseTint ( "Diffuse Tint", Color) = (1, 1, 1, 1)
    }
 
    SubShader 
    {
        Tags { "RenderType"="Opaque" }

        pass
        {       
            Tags { "LightMode"="ForwardBase"}
 
            CGPROGRAM
 
            #pragma target 3.0
            //#pragma fragmentoption ARB_precision_hint_fastest
 
            #pragma vertex vertShadow
            #pragma fragment fragShadow
			//#pragma multi_compile_fwdbase
			#pragma multi_compile_fwdadd_fullshadows
 
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
 
            sampler2D _DiffuseTexture;
            float4 _DiffuseTint;
            float4 _LightColor0;
 
			struct v2f{
				float4 pos : SV_POSITION;
				float3 lightDir : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float2 uv : TEXCOORD2;
				LIGHTING_COORDS(3, 4)
			};
 
			v2f vertShadow(appdata_base v){
				v2f o;
 
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy;
				o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
				o.normal = normalize(v.normal).xyz;

				TRANSFER_VERTEX_TO_FRAGMENT(o);
 
				return o; 
			}
 
			float4 fragShadow(v2f i) : COLOR{                   
				float3 L = normalize(i.lightDir);
				float3 N = normalize(i.normal);  
 
				float attenuation = LIGHT_ATTENUATION(i) * 2;
				float4 ambient = UNITY_LIGHTMODEL_AMBIENT * 2;
 
				float NdotL = saturate(dot(N, L));
				float4 diffuseTerm = NdotL * _LightColor0 * _DiffuseTint * attenuation;
 
				float4 diffuse = tex2D(_DiffuseTexture, i.uv);
 
				float4 finalColor = (ambient + diffuseTerm) * diffuse;
 
				return finalColor;
			}
 
            ENDCG
        } 
         pass
        { 
            Tags { "LightMode"="ForwardAdd"}
            Blend One One
            ZWrite Off
 
            CGPROGRAM
 
            #pragma target 3.0
            //#pragma fragmentoption ARB_precision_hint_fastest
 
            #pragma vertex vertShadow
            #pragma fragment fragShadow
			#pragma multi_compile_fwdadd_fullshadows
 
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
 
            sampler2D _DiffuseTexture;
            float4 _DiffuseTint;
            float4 _LightColor0;
 
			struct v2f{
				float4 pos : SV_POSITION;
				float3 lightDir : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float2 uv : TEXCOORD2;
				LIGHTING_COORDS(3, 4)
			};
 
			v2f vertShadow(appdata_base v){
				v2f o;
 
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord.xy;
				o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
				o.normal = normalize(v.normal).xyz;

				TRANSFER_VERTEX_TO_FRAGMENT(o);
 
				return o; 
			}
 
			float4 fragShadow(v2f i) : COLOR{                   
				float3 L = normalize(i.lightDir);
				float3 N = normalize(i.normal);  
 
				float attenuation = LIGHT_ATTENUATION(i) * 2;
				//float4 ambient = UNITY_LIGHTMODEL_AMBIENT * 2;
 
				float NdotL = saturate(dot(N, L));
				float4 diffuseTerm = NdotL * _LightColor0 * _DiffuseTint * attenuation;
 
				float4 diffuse = tex2D(_DiffuseTexture, i.uv);
 
				float4 finalColor = diffuseTerm * diffuse;
 
				return finalColor;
			}
 
            ENDCG
        }        
   } 
    FallBack "Diffuse"
}