Shader "Unlit/Spiderman1"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DecoTex("DecoTex", 2D) = "white" {}
	}
		SubShader
	{
		Tags {
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Opaque"
			"Queue" = "Geometry+0"
		}
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
			    float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;				
				float fogCoord : TEXCOORD1;
				float3 normal : NORMAL;
				//float4 shadowCoord : TEXCOORD2;
				float4 screenUV : TEXCOORD2;

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_DecoTex);
			SAMPLER(sampler_DecoTex);
						
			
			
			half4 _MainTex_ST;
			
			CBUFFER_END

			v2f vert(appdata v)
			{
				v2f o;
				
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
											
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = TransformObjectToWorldNormal(v.normal);
				o.fogCoord = ComputeFogFactor(o.vertex.z);
				o.screenUV = ComputeScreenPos(o.vertex);
				
				//#ifdef _MAIN_LIGHT_SHADOWS
				//VertexPositionInputs vi = GetVertexPositionInputs(v.vertex.xyz);
				//o.shadowCoord = GetShadowCoord(vertexInput);				
				//#endif			
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{			    			    
				UNITY_SETUP_INSTANCE_ID(i);
				//UNITY_SETUP_STEREO_EVE_INDEX_POST_VERTEX(i);
				
				Light mainLight = GetMainLight();
				
				float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
				float a = col.a;
				
				//deco region
				/*float2 uv = (i.screenUV.xy /i.screenUV.w) * 20;
				uv.x *= (_ScreenParams.x / _ScreenParams.y); 								
				float4 decoColor = SAMPLE_TEXTURE2D(_DecoTex, sampler_DecoTex, uv);
				col = decoColor;
				col.a = a;
				*/
				
				float3 lightDir = mainLight.direction; //float3(1,0,0);
				float NdotL = saturate(dot(lightDir, i.normal));
				half3 ambient = SampleSH(i.normal);
				col.rgb *= NdotL;
				//col.rgb *= NdotL * _MainLightColor.rgb * mainLight.shadowAttenuation * mainLight.distanceAttenuation + ambient;
				//col.rgb = MixFog(col.rgb, i.fogCoord);
				
				return col;				
			}
			ENDHLSL
	}
	}
}
