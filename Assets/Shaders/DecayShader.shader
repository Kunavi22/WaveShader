Shader "Custom/DecayShader" 
{
    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
 

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
            };


            v2f Vert(uint id : SV_VertexID)
            {
                v2f o;
                o.uv = float2((id << 1) & 2, id & 2);
                o.pos = float4(o.uv * 2 - 1, 0, 1);
                return o;
            }

            float _Damping;   
            float _Viscosity; 
            float _DeltaTime;
            sampler2D _Prev;

            float4 Frag(v2f i) : SV_Target
            {

                float2 uv = i.uv;

                uv.y = 1.0 - uv.y;

                float2 hv = tex2D(_Prev, uv).rg;

                float h = hv.r;
                float v = hv.g;

                float accel = -_Viscosity * _Viscosity * h - _Damping * v;

                v += accel * _DeltaTime;
                h += v * _DeltaTime;

                return float4(h, v, 0, 1);
            }
            ENDHLSL
        }
    }
}