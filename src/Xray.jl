immutable XRayValue
    energy::Float64
    uncertainty::Float64
end
abstract XRayFeature
immutable XRayLine <: XRayFeature
    experiment::XRayValue
    theory::XRayValue
end
immutable XRayEdge <: XRayFeature
    experiment::XRayValue
    theory::XRayValue
    vapor::XRayValue
end

#convert(::FloatingPoint, x::XRayValue) = x.energy
#convert(::FloatingPoint, x::XRayFeature) = convert(::FloatingPoint, x.experiment)

xrays = Dict{String, XRayFeature}()
x_float(x::Union(String, FloatingPoint)) = float(x=="" ? -0 : x)
let
    samenames = Dict{String, String}()
    let names = readdlm("/Users/oneilg/.julia/Xray/data/names.txt",',')
        for name in names
            if name[end] == ')'
                n1, n2 = split(name)
                n2 = join(split(n2))
                n1 = join(split(n1))
                samenames[n1] = n2[2:end-1]
            end
        end
    end

    let raw_data = readdlm("/Users/oneilg/.julia/Xray/data/nist_energies.txt", '\t')
        for i = 7:size(raw_data,1)
            (element, A, transition, theory, theory_unc, direct,
            direct_unc, combined, combined_unc, vapor, vapor_unc, blend, ref) = raw_data[i,:]
            x_experiment = XRayValue(x_float(direct), x_float(direct_unc))
            x_theory = XRayValue(x_float(theory), x_float(theory_unc))
            x_vapor = XRayValue(x_float(vapor), x_float(vapor_unc))
            transition = join(split(transition))
            if transition[end-2:end] == "ge"
                x_feature = XRayEdge(x_experiment, x_theory, x_vapor)
            else
                x_feature = XRayLine(x_experiment, x_theory)
            end

            xrays[element*transition] = x_feature
            if haskey(samenames, transition)
                xrays[element*samenames[transition]] = xrays[element*transition]
            end
        end
    end


end
