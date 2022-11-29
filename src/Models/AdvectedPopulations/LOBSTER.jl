"""
The Lodyc Ocean Biogeochemical Simulation Tools for Ecosystem and Resources (LOBSTER) model

Tracers
========
* Nitrates: NO₃ (mmol N/m³)
* Ammonia: NH₄ (mmol N/m³)
* Phytoplankton: P (mmol N/m³)
* Zooplankton: Z (mmol N/m³)
* Small (slow sinking) detritus: D (mmol N/m³)
* Large (fast sinking) detritus: DD (mmol N/m³)
* Small (slow sinking) detritus carbon content: Dᶜ (mmol C/m³)
* Large (fast sinking) detritus carbon content: DDᶜ (mmol C/m³)
* Disolved organic matter: DOM (mmol N/m³)

Optional tracers
===========
* Disolved inorganic carbon: DIC (mmol C/m³)
* Alkalinity: ALK (mmol ⁻/m³)

* Oxygen: OXY (mmol O₂/m³)

Required forcing
===========
* Photosynthetically available radiation: PAR (W/m²)

For optional tracers:
* Temperature: T (ᵒC)
* Salinity: S (‰)
"""
module LOBSTER
using Oceananigans
using Oceananigans.Units: second, minute, minutes, hour, hours, day, days, year, years

#####
##### Grazing
#####

@inline p(P, D, params) = params.p̃*P/(params.p̃*P+(1-params.p̃)*D + eps(0.0)) # Preference for phytoplankton

@inline G_d(P, Z, D, params) = params.g_z*(1-p(P, D, params))*D*Z/(params.K_z+P*p(P, D, params)+(1-p(P, D, params))*D) # Grazing of detritus

@inline G_p(P, Z, D, params) = params.g_z*p(P, D, params)*P*Z/(params.K_z+P*p(P, D, params)+(1-p(P, D, params))*D) # Grazing of phytoplankton

#####
##### Autotrophic growth limitations
#####

@inline Lₚₐᵣ(PAR, params) = 1 - exp(-PAR/params.Kₚₐᵣ) # reference (4) #Light limitation

@inline L_NO₃(NO₃, NH₄, params) = NO₃*exp(-params.ψ*NH₄)/(NO₃+params.Kₙₒ₃) #Nitrate limitation

@inline L_NH₄(NH₄, params) = max(0.0, NH₄/(NH₄+params.Kₙₕ₄)) #Ammonium limitation

#####
##### Nutrient forcing
#####

@inline NO₃_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    -params.μ_p*Lₚₐᵣ(PAR, params)*L_NO₃(NO₃, NH₄, params)*P  #phytoplankton consumption
    + params.μ_n*NH₄ #nitrification
)

@inline NH₄_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    params.α_p*params.γ*params.μ_p*Lₚₐᵣ(PAR, params)*(L_NO₃(NO₃, NH₄, params)+L_NH₄(NH₄, params))*P 
    - params.μ_p*Lₚₐᵣ(PAR, params)*L_NH₄(NH₄, params)*P 
    - params.μ_n*NH₄ 
    + params.α_z*params.μ_z*Z 
    + params.α_d*params.μ_d*D 
    + params.α_dd*params.μ_dd*DD 
    + params.μ_dom*DOM 
)

@inline DOM_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    (1-params.α_p)*params.γ*params.μ_p*Lₚₐᵣ(PAR, params)*(L_NO₃(NO₃, NH₄, params)+L_NH₄(NH₄, params))*P 
    - params.μ_dom*DOM 
    +(1-params.α_z)*params.μ_z*Z
    +(1-params.α_d)*params.μ_d*D 
    +(1-params.α_dd)*params.μ_dd*DD 
)

#####
##### Plankton forcing
#####

@inline P_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    (1-params.γ)*params.μ_p*Lₚₐᵣ(PAR, params)*(L_NO₃(NO₃, NH₄, params)+L_NH₄(NH₄, params))*P 
    - G_p(P, Z, D, params) 
    - params.m_p*P^2
)
@inline Z_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    params.a_z*(G_d(P, Z, D, params) + G_p(P, Z, D, params)) 
    - params.m_z*Z^2 
    - params.μ_z*Z
)

#####
##### Detritus forcing
#####

@inline D_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    (1-params.f_d)*(1-params.a_z)*(G_d(P, Z, D, params)+G_p(P, Z, D, params)) 
    + (1-params.f_d)*params.m_p*P^2 
    - G_d(P, Z, D, params) 
    + params.f_z*params.m_z*Z^2 
    - params.μ_d*D 
)

@inline DD_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    params.f_d*(1-params.a_z)*(G_d(P, Z, D, params)+G_p(P, Z, D, params)) 
    + params.f_d*params.m_p*P^2 
    + (1-params.f_z)*params.m_z*Z^2 
    - params.μ_dd*DD 
)

#####
###### Detritus carbon content forcing
#####

@inline Dᶜ_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    ((1-params.f_d)*(1-params.a_z)*(G_d(P, Z, D, params)+G_p(P, Z, D, params)) 
    + (1-params.f_d)*params.m_p*P^2 
    - G_d(P, Z, D, params) 
    + params.f_z*params.m_z*Z^2)*params.Rd_phy
    - params.μ_d*Dᶜ
)

@inline DDᶜ_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) = (
    (params.f_d*(1-params.a_z)*(G_d(P, Z, D, params)+G_p(P, Z, D, params)) 
    + params.f_d*params.m_p*P^2 
    + (1-params.f_z)*params.m_z*Z^2)*params.Rd_phy
    - params.μ_dd*DDᶜ
)

#####
##### Carbonate chemistry (optional)
#####

@inline DIC_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, DIC, ALK, params) = (
    -params.μ_p*Lₚₐᵣ(PAR, params)*(L_NO₃(NO₃, NH₄, params) + L_NH₄(NH₄, params))*params.Rd_phy*(1+params.ρ_caco3)*P
    +params.α_p*params.γ*params.μ_p*Lₚₐᵣ(PAR, params)*(L_NO₃(NO₃, NH₄, params)+L_NH₄(NH₄, params))*params.Rd_phy*P
    +params.α_z*params.μ_z*params.Rd_phy*Z
    #+params.α_d*params.μ_d*D*(Dᶜ/(D+eps(0.0)))
    #+params.α_dd*params.μ_dd*DD*(DDᶜ/(DD+eps(0.0)))
    +params.μ_dom*DOM*params.Rd_dom
)

@inline ALK_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, DIC, ALK, params) = (
    params.μ_p*Lₚₐᵣ(PAR, params)*L_NO₃(NO₃, NH₄, params)*P
    -2*params.ρ_caco3*params.μ_p*Lₚₐᵣ(PAR, params)*(L_NO₃(NO₃, NH₄, params)+L_NH₄(NH₄, params))*params.Rd_phy*P
)

#####
##### Oxygen chemistry (optional)
#####

# XXX there is a typo in https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2010JC006446 so I am not sure the first term of this is correct, but this makes sense
@inline OXY_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, OXY, params) = (
    params.μ_p*Lₚₐᵣ(PAR, params)*L_NO₃(NO₃, NH₄, params)*params.Rd_oxy*P
    - (params.Rd_oxy-params.Rd_nit)*NH₄_forcing(x, y, z, t, NO₃, NH₄, P, Z, D, DD, Dᶜ, DDᶜ, DOM, PAR, params) 
    - params.Rd_oxy*params.μ_n*NH₄ 
)

#####
##### Model definition for OceanBioME to setup
#####
D_sinking = -3.47e-5
DD_sinking = -200/day

tracers=(:NO₃, :NH₄, :P, :Z, :D, :DD, :Dᶜ, :DDᶜ, :DOM)
optional_tracers=(carbonates=(:DIC, :ALK), oxygen=(:OXY,))

forcing_functions=(NO₃=NO₃_forcing, NH₄=NH₄_forcing, P=P_forcing, Z=Z_forcing, D=D_forcing, DD=DD_forcing, Dᶜ = Dᶜ_forcing, DDᶜ = DDᶜ_forcing, DOM=DOM_forcing, DIC=DIC_forcing, ALK=ALK_forcing, OXY=OXY_forcing)

sinking = (D = D_sinking, DD = DD_sinking, Dᶜ = D_sinking, DDᶜ = DD_sinking)
required_fields = (:PAR, )
requried_parameters = NamedTuple()

const defaults = (
    p̃ = 0.5,  # Preference for phytoplankton
    g_z = 9.26e-6,   # Zooplankton maximal grazing rate  s⁻¹
    K_z = 1.0,    # Grazing half-saturation value    mmolm⁻³
    #Q_sol = 600,  # incoming solar radiation   Wm⁻², need to check the number
    Kₚₐᵣ = 33.0,  # Light limitation half-saturation value  Wm⁻²
    ψ = 3.0,  # Inhibition of nitrate uptake by ammonium
    Kₙₒ₃ = 0.7,  # Nitrate limitation half-saturation value   mmolm⁻³
    Kₙₕ₄ = 0.001,  # Ammonium limitation half-saturation value   mmolm⁻³
    v_dd_min = 50.0/day, #DD min sinking speed  50/day
    v_dd_max = 200.0/day, #DD max sinking speed
    #detritus sinking parameters
    w_d = -3.47e-5,  #  Detritus sedimentation speed   ms⁻¹
    w_dd = -200.0/day,  #  Detritus sedimentation speed  -v_dd_min       50m/day=0.0005878  ms⁻¹
    λ = 1.0, 
    μ_p = 1.21e-5, #  s⁻¹   Phytoplankton maximal growth rate   1/day

    a_z = 0.7,  # Assimilated food fraction by zooplankton
    m_z = 2.31e-6,  # Zooplankton mortality rate  s⁻¹mmol⁻¹m³
    μ_z = 5.8e-7, # Zooplankton excretion rate  s⁻¹
    #g_z = 9.26e-6, # Zooplankton maximal grazing rate  s⁻¹
    #p̃ = 0.5, # Preference for phytoplankton
    #K_z = 1.0, # Grazing half-saturation value    mmolm⁻³
    m_p = 5.8e-7, # Phytoplankton mortality rate   s⁻¹

    μ_d = 5.78e-7, #  Detritus remineralization rate  s⁻¹
    μ_dd = 5.78e-7, 
    γ = 0.05,  #  Phytoplankton exudation rate  

    μ_n = 5.8e-7, # Nitrification rate   s⁻¹
    #f_n = 0.75, #  Ammonium/DOM redistribution ratio
    α_p = 0.75,  #NH4 fraction of P exsudation
    α_z = 0.5,  #NH4 fraction of Z excretion
    α_d = 0.0, #NH4 fraction of D degradation
    α_dd = 0.0, #NH4 fraction of  DD degradation

    Rd_phy = 6.56, # C:N ratio for P molC mol N -1
    Rd_dom = 6.56,
    Rd_chl = 1.31,
    ρ_caco3 = 0.1, # rain ratio of organic carbon to CaCO3 
    Rd_oxy = 10.75, #O:N for PP
    Rd_nit = 2.0, #O:N for Nitrification

    f_z = 0.5, #  Fraction of slow sinking mortality   0.5  
    f_d = 0.5, # Faecal pellets and P mortality fraction to DD   0.5

    μ_dom = 3.86e-7, # DOM breakdown rate    s⁻¹
)
end # module