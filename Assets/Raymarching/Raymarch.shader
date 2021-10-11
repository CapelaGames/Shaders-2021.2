Shader "Unlit/Raymarch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #define MAX_STEPS 100
            #define  MAX_DIST 100
            #define  SURF_DIST 1e-3 //0.001

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 rayOrigin : TEXTCOORD1;
                float3 hitPos : TEXTCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.rayOrigin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1));//_WorldSpaceCameraPos //worldspace
                o.hitPos = v.vertex; //mul(unity_ObjectToWorld, v.vertex); //v.vertex //object space
                return o;
            }

            float GetDistance(float3 p)
            {
                float d;// = length(p) - .5; //.5 is radius of sphere
               // d = length(float2(length(p.xy) - .5, p.z)) - .1; //torus
                d = length(float2(length(p.xz) - .5, p.y)) - .1; //torus
                return d;
            }
            
            float Raymarch(float3 rayOrigin, float3 rayDirection)
            {
                float distanceFromOrigin = 0;
                float distanceFromSurface;
                for(int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = rayOrigin + distanceFromOrigin * rayDirection;
                    distanceFromSurface = GetDistance(p);
                    distanceFromOrigin += distanceFromSurface;
                    if(distanceFromSurface < SURF_DIST || distanceFromOrigin > MAX_DIST )
                    {
                        break;
                    }
                }
                return distanceFromOrigin;
            }

            float3 GetNormal(float3 p)
            {
                float2 eplison = float2(1e-2,0);
                float3 normal = GetDistance(p) - float3(
                    GetDistance(p - eplison.xyy), //vec3(.001,0,0)
                    GetDistance(p - eplison.yxy),//vec3(0,.001,0)
                    GetDistance(p - eplison.yyx)//vec3(0,0, .001)
                    );

                return normalize(normal);
            }
    
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - 0.5;
                float3 rayOrigin = i.rayOrigin;//float3(0,0,-3); //make up a camera position
                float3 rayDirection = normalize(i.hitPos - rayOrigin); //normalize(float3(uv.x,uv.y,1));

                float distance = Raymarch(rayOrigin,rayDirection);
                
                //fixed4 col = float4(uv.rg,0,1);
                //fixed4 col = 0; col.rgb = rayDirection;
                //fixed4 col = 0;
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 col = 0;

                float mask = dot(uv,uv); //squared distance from the center;
                
                if(distance < MAX_DIST)
                {
                    float3 p = rayOrigin + rayDirection * distance;
                    float3 normal = GetNormal(p);
                    col.rgb = normal;
                }
                else
                {
                    //discard;
                }

                col = lerp(col, tex, smoothstep(.1,.2,mask));
                 
                return col;
            }
            ENDCG
        }
    }
}
