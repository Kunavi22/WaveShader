Shader "Custom/PaintShader" 
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

            float BrushKernel(float d, float ringStrengt)
            {
        
                // d in [0..1]
                float core = exp(-d * d * 8);          // center dent
                float ring = exp(-pow(d - 0.85, 2) * 10) * ringStrengt*1.5; // outer ridge
                return core - ring * 0.35 + 0.35;
            }


            v2f Vert(uint id : SV_VertexID)
            {
                v2f o;
                o.uv = float2((id << 1) & 2, id & 2);
                o.pos = float4(o.uv * 2 - 1, 0, 1);
                return o;
            }

            sampler2D _Prev;
            
            float2 _PaintUV;
            float _BrushRadius = 0.03;
            float _BrushStrength = 0.02;

            float2 _MouseDelta;

            float4 Frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // #if UNITY_UV_STARTS_AT_TOP
                // if (_Prev_TexelSize.y < 0)
                     uv.y = 1.0 - uv.y;
                // #endif
                
                float2 p = 1.0 -_PaintUV;

                float old = tex2D(_Prev, uv).r;

                float d = distance(uv, p) / _BrushRadius; 


                //Curves fix
                float2 dir = uv - p;
                float len = length(dir);
                dir = (len > 1e-5) ? dir / len : float2(0,0); //normalize with 0 check

                float flow = 1.0 - dot(_MouseDelta, dir);

                float brush = BrushKernel(d, flow);


                float edge = smoothstep(1.0, -0.2, d);
                float result = lerp(old, brush, edge);
                
  

                return float4(result, tex2D(_Prev, uv).g, 0, 1.0);
            }
            ENDHLSL
        }
    }
}