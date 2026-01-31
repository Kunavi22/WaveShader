Shader "Custom/Chameleon"
{
    Properties
    {
        _ColorA ("Color A (Facing)", Color) = (0.2, 0.8, 1, 1)
        _ColorB ("Color B (Grazing)", Color) = (1, 0.2, 0.8, 1)

        _SpecColor ("Specular Color", Color) = (1,1,1,1)


        _Metallic ("Metallic", Range(0,1)) = 0.7
        _Roughness ("Roughness", Range(0.01,1)) = 0.25

        _Cube ("Reflection Cubemap", Cube) = "" {}
 
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" 

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            samplerCUBE _Cube;
            float4 _ColorA, _ColorB;
            float4 _SpecColor;
            
            float _Metallic;
            float _Roughness;
     

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex); 
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); 
                return o;
            }

           
            float DistributionGGX(float3 N, float3 H, float roughness)
            {
                float a = roughness * roughness;
                float a2 = a * a;
                float NdotH = max(dot(N, H), 0.0);
                float NdotH2 = NdotH * NdotH;
                float denom = (NdotH2 * (a2 - 1.0) + 1.0);
                return a2 / (3.14159265359 * denom * denom + 1e-5);
            }

            float GeometrySchlickGGX(float NdotV, float roughness)
            {
                float r = roughness + 1.0;
                float k = (r * r) / 8.0;
                return NdotV / (NdotV * (1.0 - k) + k + 1e-5);
            }

            float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
            {
                float NdotV = max(dot(N, V), 0.0);
                float NdotL = max(dot(N, L), 0.0);
                float ggx1 = GeometrySchlickGGX(NdotV, roughness);
                float ggx2 = GeometrySchlickGGX(NdotL, roughness);
                return ggx1 * ggx2;
            }

            float3 FresnelSchlick(float cosTheta, float3 F0)
            {
                return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

                // ---- Fresnel for color shift
                float fres = pow(1 - saturate(dot(N, V)), 3);

                float3 baseCol = lerp(_ColorA.rgb, _ColorB.rgb, fres);

                // ---- Cook-Torrance (GGX) specular
                float3 L = normalize(_MainLightPosition.xyz);
                float3 H = normalize(V + L);

                float NdotL = saturate(dot(N, L));
                float NdotV = saturate(dot(N, V));

                float rough = saturate(_Roughness);
                rough = max(rough, 0.04); // avoid singularities

                float3 F0 = lerp(float3(0.04, 0.04, 0.04), _SpecColor.rgb, _Metallic);

                float3 F = FresnelSchlick(max(dot(H, V), 0.0), F0);
                float D = DistributionGGX(N, H, rough);
                float G = GeometrySmith(N, V, L, rough);

                float3 specular = (D * G * F) / max(4.0 * NdotV * NdotL, 0.001);


                // ---- Reflection
                float3 R = reflect(-V, N);
                float3 env = texCUBE(_Cube, R).rgb;

                // ---- Combine (diffuse + direct specular + environment)
                float3 diffuse = baseCol * (1.0 - _Metallic);
                float3 col = diffuse * NdotL + specular * NdotL + env * _Metallic;

                return float4(col, 1);

                
            }
            ENDHLSL
        }
    }
}