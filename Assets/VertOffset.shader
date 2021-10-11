Shader "Unlit/VertOffset"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _WaveAmp("Wave Amplitude", Range(0,0.2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define TAU 6.28318530718
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _WaveAmp;
            float GetWave(float2 uv)
            {
                float2 uvsCentered = uv * 2 -1;
                float radialDistance = length(uvsCentered);
                float wave = cos((radialDistance - _Time.y *  0.1)  * TAU * 5)* 0.5 + 0.5;
                wave *= 1 -radialDistance;//fade towards the edge
                
                return wave;
            }
            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.y = GetWave(v.uv) * _WaveAmp;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            float4 frag (v2f i) : SV_Target
            {
                return GetWave(i.uv);
            }
            ENDCG
        }
    }
}
