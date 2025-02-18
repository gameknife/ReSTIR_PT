/***************************************************************************
 # Copyright (c) 2015-21, NVIDIA CORPORATION. All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without
 # modification, are permitted provided that the following conditions
 # are met:
 #  * Redistributions of source code must retain the above copyright
 #    notice, this list of conditions and the following disclaimer.
 #  * Redistributions in binary form must reproduce the above copyright
 #    notice, this list of conditions and the following disclaimer in the
 #    documentation and/or other materials provided with the distribution.
 #  * Neither the name of NVIDIA CORPORATION nor the names of its
 #    contributors may be used to endorse or promote products derived
 #    from this software without specific prior written permission.
 #
 # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS "AS IS" AND ANY
 # EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 # IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 # PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 # CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 # EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 # PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 # PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 # OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 # OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **************************************************************************/
#pragma once
#include "Utils/HostDeviceShared.slangh"
#include "Scene/Material/MaterialDefines.slangh"

BEGIN_NAMESPACE_FALCOR

#ifdef HOST_CODE
#define SamplerState std::shared_ptr<Sampler>
#define Texture2D std::shared_ptr<Texture>
#endif

static const uint kMaterialTypeBits = 8;    ///< Maximum number of bits to store MaterialType.

/** Material type.
*/
// TODO: Specify the backing type when Slang issue has been resolved
enum class MaterialType // : uint32_t
{
    Standard,
    Cloth,
    Hair,

    Count // Must be last
};

/** This is a host/device structure that describes material resources.
*/
struct MaterialResources
{
    // See BasicMaterial.h for channel layout
    Texture2D baseColor;
    Texture2D specular;
    Texture2D emissive;
    Texture2D normalMap;
    Texture2D transmission;
    Texture2D displacementMap;

    SamplerState samplerState;
    SamplerState displacementSamplerStateMin;
    SamplerState displacementSamplerStateMax;
};

/** This is a host/device structure that describes a material.
*/
struct MaterialData
{
    float4   baseColor              = float4(1.f);      ///< Material base color (RGB) and opacity (A).
    float4   specular               = float4(0.f);      ///< Material specular channel encoding occlusion (R), roughness (G), metallic (B) in the default MetalRough mode. In SpecGloss mode specular color (RGB) and glossiness (A).
    float3   emissive               = float3(0.f);      ///< Emissive color (RGB).
    float    emissiveFactor         = 1.f;              ///< Multiplication factor for the emissive color to control light intensity.

    float    alphaThreshold         = 0.5f;             ///< Alpha threshold, only used in case the alpha mode is mask.
    float    IoR                    = 1.5f;             ///< Index of refraction.
    float    diffuseTransmission    = 0.f;              ///< Diffuse transmission.
    float    specularTransmission   = 0.f;              ///< Specular transmission.

    float3   transmission           = float3(1.f);      ///< Transmission color.
    float    _pad0                  = 0.f;

    float3   volumeAbsorption       = float3(0.f);      ///< Volume absorption coefficient.
    float    volumeAnisotropy       = 0.f;              ///< Volume phase function anisotropy (g).

    float3   volumeScattering       = float3(0.f);      ///< Volume scattering coefficient.
    float    _pad1                  = 0.f;

    uint32_t flags                  = 0;                ///< See flags in MaterialDefines.slangh
    uint32_t type                   = (uint32_t)MaterialType::Standard; ///< Material type.
    float    displacementScale      = 0.f;              ///< Displacement scale value.
    float    displacementOffset     = 0.f;              ///< Displacement offset value.

    /** Get the material type. This decides how the fields should be interpreted.
        \return Material type.
    */
    MaterialType getType() { return (MaterialType)type; }

    /** Get the nested priority used for nested dielectrics.
        \return Nested priority, with 0 reserved for the highest possible priority.
    */
    uint getNestedPriority() { return EXTRACT_NESTED_PRIORITY(flags); }
};

#ifdef HOST_CODE
#undef SamplerState
#undef Texture2D
#endif

END_NAMESPACE_FALCOR
