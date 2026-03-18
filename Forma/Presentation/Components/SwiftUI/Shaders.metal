#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

float hash(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float smoothHash(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i), hash(i + float2(1,0)), f.x),
        mix(hash(i + float2(0,1)), hash(i + float2(1,1)), f.x),
        f.y
    );
}

// 4 octaves instead of 6 — removes fine granular texture
float fbm(float2 p) {
    float v = 0.0, a = 0.52;
    for (int i = 0; i < 4; i++) {
        v += a * smoothHash(p);
        p = p * 2.1 + float2(1.7, 9.2);
        a *= 0.48;
    }
    return v;
}

float3 palette(float t, float intensity) {
    float3 dark   = float3(0.04, 0.05, 0.11);
    float3 mid    = float3(0.06, 0.12, 0.32);
    float3 bright = float3(0.12, 0.22, 0.62);
    float3 peak   = float3(0.18, 0.35, 0.80);
    t = clamp(t * intensity, 0.0, 1.0);
    if (t < 0.33) return mix(dark,   mid,    t / 0.33);
    if (t < 0.66) return mix(mid,    bright, (t - 0.33) / 0.33);
                  return mix(bright, peak,   (t - 0.66) / 0.34);
}

[[ stitchable ]]
half4 fluidNoise(float2 pos, half4 color, float t, float intensity) {
    float2 uv = pos / float2(390.0, 844.0);
    uv.y = 1.0 - uv.y;

    // Zoom in — hides fine noise detail at edges, keeps center smooth
    uv = (uv - 0.5) * 0.72 + 0.5;

    float2 p1 = uv + float2(sin(t*0.38)*0.20, cos(t*0.29+1.1)*0.16);
    float2 p2 = uv + float2(cos(t*0.47+2.3)*0.16, sin(t*0.33+0.7)*0.18);
    float2 p3 = uv + float2(sin(t*0.52+4.1)*0.13, cos(t*0.41+2.8)*0.14);

    // Scale down UV frequency — larger, softer blobs
    float n1 = fbm(p1 * 1.4 + float2(t*0.28,  t*0.19));
    float n2 = fbm(p2 * 1.1 + float2(-t*0.22, t*0.16));
    float n3 = fbm(p3 * 1.6 + float2(t*0.18, -t*0.24));

    float noise = n1*0.52 + n2*0.31 + n3*0.17;

    float breathe = 0.5 + 0.5 * sin(t * 0.4);
    noise = noise * 0.88 + breathe * 0.06;

    // Softer power curve — smoother gradients, no harsh edges
    noise = pow(noise, 1.05);

    float2 centered = (uv - 0.5) * 1.5;
    float vignette = pow(clamp(1.0 - dot(centered, centered), 0.0, 1.0), 0.5);

    float3 col = palette(noise, intensity) * vignette;

    // No grain — clean output
    col = clamp(col, 0.0, 1.0);

    return half4(half3(col), 1.0);
}