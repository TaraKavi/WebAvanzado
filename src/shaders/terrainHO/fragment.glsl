uniform vec3 uColor;
uniform float uTime;

varying vec3 vPosition;
varying float vUpDot;
varying vec3 gNormal;


#include ../includes/simplexNoise2d.glsl
#include ../includes/random2D.glsl

void main()
{

    //normal
    vec3 normal1 = normalize(gNormal);

    // stripes
    float stripes = mod((vPosition.y - uTime * 0.02) * 20.0 , 1.0);
    stripes = pow(stripes,3.0);

    //fresnel
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    float fresnel = dot(viewDirection, normal1)+1.0;
    fresnel = pow(fresnel,2.0);

    //falloff  IMP
    float falloff = smoothstep(3.0, 0.0, fresnel);

    //holographic
    float holographic = stripes * fresnel;
    holographic += fresnel * 2.25;
    holographic *= falloff;

    // Final color
    csm_DiffuseColor = vec4(uColor , holographic);
    
}