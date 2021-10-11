Shader "Unlit/test2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rock("Rock",2D) = "white" {}
        _Pattern("Pattern",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _Rock;
            sampler2D _Pattern;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(UNITY_MATRIX_M ,v.vertex);
                //o.uv.x += _Time.y * 0.1;
                o.uv = v.uv;
                
                return o;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float4 moss = tex2D(_MainTex, i.worldPos.xz);
                //float4 moss = tex2D(_MainTex, i.uv);
                float4 rock = tex2D(_Rock,  i.worldPos.xz);
                float pattern = tex2D( _Pattern, i.uv).x;
                fixed4 col = lerp(rock, moss, pattern);
                return col;
            }
            ENDCG
        }
    }
}
