@recipe function plot(avg_wave::AverageWave{T};
        hankel_indexes = -avg_wave.hankel_order:avg_wave.hankel_order,
        apply = real) where T<:AbstractFloat

    ho = avg_wave.hankel_order

    for n in hankel_indexes

        apply_field = apply.(avg_wave.amplitudes[:,n+ho+1,1])

        @series begin
            label --> "$apply Hankel = $n"
            seriestype --> :scatter
            (avg_wave.x, apply_field)
        end
    end
end

@recipe function plot(wave_effs::Vector{EffectiveWave{T}}) where T<:AbstractFloat
    k_effs = [w.k_eff for w in wave_effs]
    maxamp = maximum(norm(w.amplitudes) for w in wave_effs)

    rgbs = map(wave_effs) do w
        c = norm(w.amplitudes)/maxamp
        RGB(0.8,1-c,1-c)
    end

   scatter(real.(k_effs), imag.(k_effs), markercolors = rgbs )
    @series begin
        ylims --> (0,Inf)
        xlab --> "Re k_eff"
        ylab --> "Im k_eff"
        seriestype --> :scatter
        label --> "wavenumber k_eff"
        markercolors --> rgbs
        markerstrokealpha --> 0.4
        (real.(k_effs), imag.(k_effs))
    end
end

@recipe function plot(x::AbstractVector{T}, wave_effs::Vector{EffectiveWave{T}};
        hankel_indexes = -wave_effs[1].hankel_order:wave_effs[1].hankel_order,
        apply = real) where T<:AbstractFloat

    wave_eff = AverageWave(wave_effs, x)
    ho = wave_eff.hankel_order

    for n in hankel_indexes

        apply_field = apply.(wave_eff.amplitudes[:,n+ho+1,1])

        @series begin
            label --> "$apply H = $n"
            (x, apply_field)
        end
    end
end

@recipe function plot(match_wave::MatchWave{T})

    dx = match_wave.x_match[2] - match_wave.x_match[1]
    max_x = match_wave.x_match[end]
    x = [match_wave.x_match; (max_x:dx:(2*max_x)) + dx]
    @series (x, match_wave)
end

@recipe function plot(x::AbstractVector{T}, match_wave::MatchWave{T};
        hankel_indexes = -wave_effs[1].hankel_order:wave_effs[1].hankel_order, apply = real)

    ho = match_wave.average_wave.hankel_order
    wave_eff = AverageWave(match_wave.effective_waves, match_wave.x_match)
    max_amp = maximum(apply.(wave_eff.amplitudes[:,(hankel_indexes) .+ (ho+1),:]))
    min_amp = minimum(apply.(wave_eff.amplitudes[:,(hankel_indexes) .+ (ho+1),:]))

    max_amp = (max_amp > 0) ? 1.1*max_amp : 0.0
    min_amp = (min_amp < 0) ? 1.1*min_amp : 0.0

    @series begin
        label --> "match region"
        fillalpha --> 0.3
        fill --> (0,:orange)
        line --> 0
        (x1 -> x1, y->max_amp, match_w.x_match[1],  match_w.x_match[end])
    end
    @series begin
        label --> ""
        fillalpha --> 0.3
        fill --> (0,:orange)
        line --> 0
        (x1 -> x1, y->min_amp, match_w.x_match[1],  match_w.x_match[end])
    end
    # plot(x -> x,y->max_w,X[L],X[J],line=0,fill=(0,:orange), fillalpha=0.4, lab="match region")
    # plot!(x -> x,y->min_w,X[L],X[J],line=0,fill=(0,:orange), fillalpha=0.4, lab="")

    @series begin
        apply --> apply
        hankel_indexes --> hankel_indexes
        match_w.average_wave
    end

    @series begin
        apply --> apply
        hankel_indexes --> hankel_indexes
        (x, match_w.effective_waves)
    end

end