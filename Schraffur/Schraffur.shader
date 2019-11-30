Shader "Custom/Schraffur"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_LowSchraffur("Schraffur (RGB)", 2D) = "white" {}

		_ScharaffurInt("SchraffurIn", Range(0,3)) = 0.5
		_ScrollXSpeed("X scroll speed", Range(-10, 10)) = 0
		_ScrollYSpeed("Y scroll speed", Range(-10, 10)) = -0.4

		_LowSchraffurIn("LowSchraffurInt", Range(0, 100)) = 10
		_HighSchraffurInt("HighSchraffurInt", Range(0, 100)) = 10

		_LightSourceVector("LightSourceVec", Vector) = (0,0,0,0) // via Script ? 
		_Outline("Outline Width", Range(.002, 0.1)) = .005
	}
	SubShader
	{


		
		Tags { "Queue" = "Transparent" }
		ZWrite off
		Cull Front
		CGPROGRAM
		#pragma surface surf Standard  alpha:fade vertex:vert
		struct Input {
			float3 worldPos;
		};
		float _Color;
		float _Outline;

		
		void vert(inout appdata_full v) {

			v.vertex.xyz += v.normal *_Outline;
			float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));

		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{

			o.Albedo.rgb = _Color;
			o.Emission.rgb=_Color;
			o.Alpha = 1;
		}
		ENDCG

		ZWrite on
		Cull Back




		Tags{ "RenderType" = "Opaque" }

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard  

		
		
		sampler2D _MainTex;
		sampler2D _LowSchraffur;
		fixed _ScrollXSpeed;
		fixed _ScrollYSpeed;
		half _LowSchraffurIn;
		half _HighSchraffurInt;
		float4 _LightSourceVector;

		void vert(inout appdata_full v) {

			v.vertex.xyz += v.normal * 10;
			float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));

		}
		struct Input
		{
			float2 uv_MainTex;
			float2 uv_LowSchraffur;
			float3 viewDir;
		};
		half _ScharaffurInt;
		fixed4 _Color;
		uniform float _SchraffurMovement;
		uniform float _SchraffurIntensAlpha;
		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)


		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			fixed offsetX = _ScrollXSpeed * _SchraffurMovement;
			fixed offsetY = _ScrollYSpeed * _SchraffurMovement;
			fixed2 offsetUV = fixed2(offsetX, offsetY);

			fixed2 mainUV = IN.uv_MainTex + offsetUV;
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, mainUV) * _Color;
			fixed4 schrauffurLow = tex2D(_LowSchraffur,IN.uv_LowSchraffur+ offsetUV)*_Color;
			
			half dirN = dot(normalize(_LightSourceVector), o.Normal);
			
			//schraffurHighGrad
			o.Emission = schrauffurLow * _Color;
			half grey = (o.Emission.r + o.Emission.g + o.Emission.b)*0.3333;
			
			
			
			if ( dirN < _ScharaffurInt) {
				o.Emission *= c.rgb*dirN*_SchraffurIntensAlpha;
				half grey = (o.Emission.r+ o.Emission.g+ o.Emission.b)*0.3333;
				if (grey > 0.4) { // TODO: 0.4 in Variable 
					o.Emission.rgb *= 3;//LiftDark spots
				}
			}
			o.Emission *= _HighSchraffurInt;
			o.Albedo.rgb = 1;	
			o.Alpha = _SchraffurIntensAlpha;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
