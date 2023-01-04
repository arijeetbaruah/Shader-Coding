Shader "Custom/MyFirstShader"
{
    Properties
    {
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (1, 1, 1, 1)
        _ColorStart("Color Start", Range(0,1)) = 0
        _ColorEnd("Color End", Range(0,1)) = 1
    }
    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Cull off
            ZWrite off
            Blend One One       // Additive
            //Blend DstColor Zero //Multiple

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

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

            Interpolators vert(MeshData v)
            {
                Interpolators o;
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
                float xOffset = cos(i.uv.x * TAU * 8) * 0.01 ;
                float t = cos((i.uv.y  + xOffset - _Time.y * 0.5) * TAU * 5) * 0.5 + 0.5;
                t *= 1 - i.uv.y;
                float faceRemoveal = abs(i.normals.y) < 0.999;
                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);

                return t * gradient * faceRemoveal;
            }
            ENDCG
        }
    }
        //FallBack "Diffuse"
}
