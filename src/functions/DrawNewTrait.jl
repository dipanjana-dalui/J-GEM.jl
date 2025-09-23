# ========================================== #
#		  FUNCTION DRAW NEW TRAITS           #
# ========================================== #

function DrawNewTraits(x_dist::Matrix{Float64}, parent_traits::Vector{Float64}, 
						h2::Array{Float64}, no_param::Int64, no_columns::Int64, col::Int64, j::Int64)


	pop_size = size(x_dist[x_dist[:, 1] .== col, 2:no_param+1])
	# QUANTITATIVE TRAITS
	pop_mean = mapslices(mean ∘ skipmissing, x_dist[x_dist[:, 1] .== col, 2:no_param+1], dims=1)

	if pop_size[1] == 1 # when only 1 individual left
		pop_var = Matrix{Float64}(fill(0, pop_size[1], pop_size[2]))
	else
		pop_var = mapslices(var ∘ skipmissing, x_dist[x_dist[:, 1] .== col, 2:no_param+1], dims=1)
	end
	pop_var = round.(pop_var, digits=6)
	pop_stdev = round.(sqrt.(pop_var), digits=6)

	# describe the trait distribution for offspring 
	exp_offspring_traits = h2[col,j] .* reshape(parent_traits[1:no_param], size(pop_mean)[1], size(pop_mean)[2]) .+ (1-h2[col,j]) .* pop_mean		
	sigma_offspring_traits = sqrt(1-(h2[col,j])^2)*pop_stdev
	
	# trait MU and SIGMA for lognormal
	MU = log.(exp_offspring_traits.^2 ./ sqrt.(sigma_offspring_traits.^2 .+ exp_offspring_traits.^2)) 	
	SIGMA = sqrt.(log.(sigma_offspring_traits.^2 ./ exp_offspring_traits.^2 .+ 1))
	
	offspring_traits = fill(NaN, 1, length(exp_offspring_traits))

	for i = 1:length(exp_offspring_traits)
		if !isnan(MU[i]) && !isnan(SIGMA[i])
			if !iszero(SIGMA[i])
				offspring_traits[1,i] = rand(LogNormal(MU[i], SIGMA[i])) # pull traits when sigma != 0
			else
				offspring_traits[1,i] = exp_offspring_traits[i]
			end 
		end
	end
	
	offspring_genotypes = collect(transpose(parent_traits[no_param+1:no_columns-1]))

	return (offspring_traits=offspring_traits, offspring_genotype=offspring_genotypes)
end

