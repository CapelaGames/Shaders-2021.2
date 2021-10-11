Shader "Unlit/Healthbar"
{
    Properties
    {
        // Shows no scale offset with section.
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        
        _Health("Health", range(0,1)) = 1
        
        _BorderSize("BorderSize", float) = 0.1
        
        // How to write a color.
        // _Color("Color", Color) = (1,1,1,1) 
        // Will need to declare as a float 4 later on. 
    }
    SubShader
    {
        // Old Way:
        // Tags { "RenderType"="Opaque" }
        
        // New Way:
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
 
        Pass
        {
            ZWrite Off
            
            // Old Way
            // src * X + dst * Y
            // New Way
            // src * SrcAlpha + dst * 1 - SrcAlpha
            
            // We are replacing the X and Y.
            Blend SrcAlpha OneMinusSrcAlpha // How we are blending.
            
            // src = this pixel we are rendering
            // dst = the background pixel
            
            // src = red
            // src * 0.420 (0.420 of the red is getting rendered)
            // dst * (1- 0.420) 0.580
            
            // pixel colour = src + dst
                        
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
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
 
            float _Health;
            float _BorderSize;
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
 
 
            // Shaders don't normally have this so we have to make it everytime.
            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }
 
            // First one to always add to all projects.
            fixed4 StartingFuntion(v2f i)
            {
                // Add this and print by default! 
                    // return (i.uv, 0 , 1);
            }
            
            // This is the overall function of the old healthbar.
            fixed4 OpaqueHealth(v2f i)
            {
                // Add this and print by default! 
                    // return (i.uv, 0 , 1);
                    // return (StartingFuntion(i));
                
                //bool healthbarMask = _Health < i.uv.x;
                    // return  healthbarMask;
 
                
                // Will gradient black to white.
                    // return fixed4(i.uv.xxx, 1);
 
 
                // The health normally doesn't go down until 0.8 and stays red at the last part.
                // Thus we are staying green for the first 0.2 (%20) of the healthbar and red at the last 0.2 (80%). 
                float tHealthColor = InverseLerp(0.2,0.8, _Health);
 
                // Basically will implement the colour change.
                float3 healthbarColor = lerp(float3(1,0,0),float3(0,1,0), tHealthColor);
                
                
                // The healthbar will be relative to the player's health.
                    // float3 healthbarColor = lerp(float3(1,0,0),float3(0,1,0), _Health);
                
                // Background colour = 
                float3 bgColor = float3(0.1,0.1,0.2);       // Blue Background
                    //float3 bgColor = float3(0,0,0);           // Black Background
 
                // This will chunk it into 8 parts.
                    //bool healthbarMask = floor(i.uv.x * 8)/8  < _Health;
                // Gradient Healthbar.
                bool healthbarMask = i.uv.x < _Health;
 
                // "clip" - Will not render this pixel. (This will make the health not show the background).
                // clip(healthbarMask - 0.00001);
                
                // Outs the colour.
                // If healthbarMask = 0 the colour will be bgColor
                // If healthbarMask =  the colour will be healthbarColor
                float3 outColour = lerp(bgColor, healthbarColor, healthbarMask);
 
                // Lerping is just going from one number to another number.
                // Lerping is 5 - 15
                // if t = 0
                // = 5
                // if t = 0.5
                // = 10
                // Slerp is a smoother transition.
 
                return  fixed4(outColour,1);
                return  fixed4(i.uv.xxx,1);
            }
            fixed4 BasicTransparentHealth(v2f i)
            {
                // Will print out the transpaent healthbar.
                return float4(1,0,0,i.uv.x);
            }
 
            float AddHealthBarCurve(float2 coords)
            {
                coords.x *= 8;
                float2 pointOnLine = float2(clamp(coords.x, 0.5, 7.5) , 0.5);
                float sdf = distance(coords, pointOnLine)*2 -1;

                //float pd = fwidth(sdf);
                //float mask =  1 - saturate( sdf / pd);
                 //sdf = the distance to the center line
                //clip = anything below 0 gets removed
                //sdf *= mask;

                //mask -= 0.0001f;
                
                clip(-sdf );

                return sdf;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                /*float choppy = 1- (distance(i.uv.x+0.005, (floor(i.uv.x*(9-0.09))/(8-0.09))) < 0.005);
                
                return fixed4(choppy.xxx,1);
                
                float chop = floor(i.uv.x / 8)* 8;
                return fixed4(chop.xxx,1);*/

                float sdf = AddHealthBarCurve(i.uv);
                float borderSdf = sdf + _BorderSize;
                

                float pd = fwidth(borderSdf); //screen space partial derivative
                                                //rate of change
                
                float borderMask = 1 - saturate( borderSdf / pd);//step(0, -borderSdf);
                

                
                float4 col = tex2D(_MainTex, i.uv);
                // This will not fade for the first 10%.
                float healthFade = InverseLerp(0.9, 1, _Health);
                bool healthbarMask = i.uv.x < _Health ;//floor( i.uv.x * 8)/8
                // clip(healthbarMask - 0.00001);       
                float tHealthColor = InverseLerp(0.2,0.8,_Health);
                float flash = cos(_Time.y * 4) * 0.4 + 1;
                // Old version of next line.
               //float3 healthbarColor = saturate( lerp(float3(1,0,0),float3(0,1,0),tHealthColor));
               float3 healthbarColor = tex2D(_MainTex,float2(_Health, i.uv.y)) * lerp(1, flash, _Health < 0.2);
                float3 bgColor = float3(0.1,0.1,0.2);
                float3 outColour = lerp(bgColor,healthbarColor, healthbarMask);
                
                //return fixed4(col.xyz * healthbarMask,1);
                return fixed4(outColour.xyz * borderMask, saturate( lerp(0,1, 1-healthFade)));
                return fixed4(i.uv.xxx,1);
            }
            ENDCG
        }
    }
}