Shader "Transparency/Transparent Lit Phong "{
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Color ( "Color", Color) = (1, 1, 1, 1)
	}
 
	SubShader{
		Tags{ "RenderType"="Opaque" "Queue"="AlphaTest+50"} //This a hack. A horrible horrible hack. 

        	pass{       
			Tags { "LightMode"="ForwardBase"}
            
			ZWrite Off
			Cull Off
			Blend One One, Zero OneMinusSrcAlpha
 
			CGPROGRAM
 
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows
 
			#define TRANSPARENCY_USE_AMBIENT
			#include "LitTransparencyBase.cginc" 

		ENDCG
		}
        	pass{       
			Tags { "LightMode"="ForwardAdd"}
            
			ZWrite Off
			Cull Off
			Blend One One, Zero OneMinusSrcAlpha
 
			CGPROGRAM
 
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows		

			#define TRANSPARENCY_USE_ADDITIVE
			#include "LitTransparencyBase.cginc" 
		ENDCG
		} 
	}
	FallBack Off
}