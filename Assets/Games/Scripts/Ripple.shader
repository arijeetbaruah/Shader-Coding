Shader "Custom/Ripple"
{
    Properties
    {
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (1, 1, 1, 1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0,1)) = 1
        _WaveAmp("Wave Amplitude", Range(0, 10)) = 1
    }
        SubShader
    {
        Tags {
            "RenderType" = "Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            float _WaveAmp;

            #include "UnityCG.cginc"
            #define TAU 6.28318530718

            struct MeshData // per-vertex mesh data 
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                /*float4 color : COLOR;*/
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normals : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            float GetWave(float2 uv)
            {
                float2 uvCentered = uv * 2 - 1;
                float radialDistance = length(uvCentered);

                float wave = cos((radialDistance - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                wave *= 1 - radialDistance;
                return wave;
            }

            Interpolators vert(MeshData v)
            {
                Interpolators o;

                //float wave1 = cos((v.uv0.y - _Time.y * 0.1) * TAU * 5);
                //float wave2 = cos((v.uv0.x - _Time.y * 0.1) * TAU * 5);
                //v.vertex.y = wave1 * wave2 * _WaveAmp;

                v.vertex.y = GetWave(v.uv0) * _WaveAmp;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normals = UnityObjectToWorldNormal(v.normals);
                o.uv = v.uv0;
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            float4 frag(Interpolators i) : SV_Target
            {
                float2 uvCentered = i.uv * 2 - 1;
                float radialDistance = length(uvCentered);
                radialDistance *= 1 - radialDistance;

                float4 gradient = lerp(_ColorA, _ColorB, radialDistance);
                return GetWave(i.uv) * gradient;
            }
            ENDCG
        }
    }
        //FallBack "Diffuse"
}
