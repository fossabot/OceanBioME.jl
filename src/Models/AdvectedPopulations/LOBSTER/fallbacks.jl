# These have to be manually defined because PAR comes after the tracers, otherwise we could write `whatever(::Val(...), x, y, z, t, NO₃, ..., args...)` etc.

# core fallback
@inline (bgc::LOBSTER)(tracer::Val{:NO₃}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args...) = @inbounds bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args[end])
@inline (bgc::LOBSTER)(tracer::Val{:NH₄}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args...) = @inbounds bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args[end])
@inline (bgc::LOBSTER)(tracer::Val{:P}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args...) = @inbounds bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args[end])
@inline (bgc::LOBSTER)(tracer::Val{:Z}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args...) = @inbounds bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args[end])
@inline (bgc::LOBSTER)(tracer::Val{:sPOM}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args...) = @inbounds bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args[end])
@inline (bgc::LOBSTER)(tracer::Val{:bPOM}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args...) = @inbounds bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args[end])
@inline (bgc::LOBSTER)(tracer::Val{:DOM}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, args...) = @inbounds bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, D, bPOM, DOM, args[end])

# Carbonates and oxygen
# We can't tell the difference between carbonates and oxygen, and variable redfields without specifying more 
# We're lucky that the optional groups have 2, 1, 3 extra variables each so this is the only non-unique conbination
@inline (bgc::LOBSTER{<:Any, <:Any, <:Any, <:Val{(true, true, false)}, <:Any, <:Any})(tracer::Val{:DIC}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, DIC, ALK, OXY, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM * bgc.disolved_organic_redfield, bPOM * bgc.disolved_organic_redfield, DOM * bgc.disolved_organic_redfield, DIC, ALK, PAR)
@inline (bgc::LOBSTER{<:Any, <:Any, <:Any, <:Val{(true, true, false)}, <:Any, <:Any})(tracer::Val{:ALK}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, DIC, ALK, OXY, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM * bgc.disolved_organic_redfield, bPOM * bgc.disolved_organic_redfield, DOM * bgc.disolved_organic_redfield, DIC, ALK, PAR)
@inline (bgc::LOBSTER{<:Any, <:Any, <:Any, <:Val{(true, true, false)}, <:Any, <:Any})(tracer::Val{:OXY}, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, DIC, ALK, OXY, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOM, bPOM, DOM, OXY, PAR)

# Carbonates and variable redfield
@inline (bgc::LOBSTER)(tracer::Val{:DIC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, sPOC, bPOC, DOC, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOC, bPOC, DOC, DIC, ALK, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:ALK}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, sPOC, bPOC, DOC, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOC, bPOC, DOC, DIC, ALK, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:sPOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, sPOC, bPOC, DOC, PAR) = bgc(Val(:sPON), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, DIC, ALK, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:bPOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, sPOC, bPOC, DOC, PAR) = bgc(Val(:bPON), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, DIC, ALK, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:DOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, sPOC, bPOC, DOC, PAR) = bgc(Val(:DON), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, DIC, ALK, PAR)

# Oxygen and variable redfield
@inline (bgc::LOBSTER)(tracer::Val{:OXY}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, OXY, sPOC, bPOC, DOC, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, OXY, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:sPOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, OXY, sPOC, bPOC, DOC, PAR) = bgc(Val(:D), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:bPOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, OXY, sPOC, bPOC, DOC, PAR) = bgc(Val(:DD), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:DOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, OXY, sPOC, bPOC, DOC, PAR) = bgc(Val(:DOM), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, PAR)

# Carbonates, oxygen, and variable redfield
@inline (bgc::LOBSTER)(tracer::Val{:DIC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, OXY, sPOC, bPOC, DOC, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOC, bPOC, DOC, DIC, ALK, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:ALK}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, OXY, sPOC, bPOC, DOC, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPOC, bPOC, DOC, DIC, ALK, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:OXY}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, OXY, sPOC, bPOC, DOC, PAR) = bgc(tracer, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, OXY, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:sPOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, OXY, sPOC, bPOC, DOC, PAR) = bgc(Val(:D), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:bPOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, OXY, sPOC, bPOC, DOC, PAR) = bgc(Val(:DD), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, PAR)
@inline (bgc::LOBSTER)(tracer::Val{:DOC}, x, y, z, t, NO₃, NH₄, P, Z, sPON, bPON, DON, DIC, ALK, OXY, sPOC, bPOC, DOC, PAR) = bgc(Val(:DOM), x, y, z, t, NO₃, NH₄, P * bgc.phytoplankton_redfield, Z * bgc.phytoplankton_redfield, sPOC, bPOC, DOC, PAR)