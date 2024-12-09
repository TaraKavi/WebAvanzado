uniform float uTime;
uniform float uPositionFrequency;
uniform float uStrength;
uniform float uWarpFrequency;
uniform float uWarpStrength;

varying vec3 vPosition;
varying float vUpDot;
varying vec3 gNormal;



#include ../includes/simplexNoise2d.glsl
#include ../includes/random2D.glsl


float getElevation(vec2 position)
{
    //warp
    vec2 warpedPosition = position;
    warpedPosition += uTime*0.2;
    warpedPosition += simplexNoise2d(warpedPosition * uPositionFrequency * uWarpFrequency) * uWarpStrength;

    float elevation = 0.0;
    elevation += simplexNoise2d(warpedPosition * uPositionFrequency      ) / 2.0;
    elevation += simplexNoise2d(warpedPosition * uPositionFrequency * 2.0) / 4.0;
    elevation += simplexNoise2d(warpedPosition * uPositionFrequency * 4.0) / 8.0;

    float elevationSign = sign(elevation);    
    elevation = pow(abs(elevation), 2.0) * elevationSign;
    elevation *= uStrength;

    return elevation;
}

void main()
{    

    // Neighbours positions
    float shift = 0.01;
    vec3 positionA = position.xyz + vec3(shift, 0.0, 0.0);
    vec3 positionB = position.xyz + vec3(0.0, 0.0, - shift);

    // Elevation
    float elevation = getElevation(csm_Position.xz);
    csm_Position.y += elevation;
    positionA.y    += getElevation(positionA.xz);
    positionB.y    += getElevation(positionB.xz);

    // // Add random distortion directly to vertex position
    // vec2 randomOffset = random2D(csm_Position.xz);
    // csm_Position.xz += randomOffset * 0.02; // Adjust strength of distortion

    //compute normal
    vec3 toA = normalize(positionA - csm_Position);
    vec3 toB = normalize(positionB - csm_Position);
    csm_Normal = cross(toA, toB);

    // normal 4 glitch
    vec4 modelNormal = modelMatrix * vec4(csm_Normal,0.0);
    gNormal =  modelNormal.xyz;

    //glitch
    float glitchTime = uTime - csm_Position.y;
    float glitchStrength = sin(glitchTime) + sin(glitchTime*3.45) + sin(glitchTime*8.76);
    glitchStrength /= 3.0;
    glitchStrength = smoothstep(0.3, 1.0, glitchStrength);
    glitchStrength *= 0.25;
    csm_Position.x += (random2D(csm_Position.xz + uTime) - 0.5) * glitchStrength;
    csm_Position.z += (random2D(csm_Position.zx + uTime) - 0.5) * glitchStrength;;



    // Varyings
    vPosition = csm_Position;
    vPosition.xz += uTime * 0.2;
    
    vUpDot = dot(csm_Normal, vec3(0.0, 1.0, 0.0));

}