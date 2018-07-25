function integrate_B_full(n::Int, X, Y0; Y1 =1000000, θin = 0.0, num_coefs = 10000)
    K(Y) = cos(Y*sin(θin) + n*atan2(Y,X))*hankelh1(n,sqrt(X^2+Y^2))
    # approximate function with Chebyshev polynomial (to high precision) then integrate from Y0 to Y1
    return 2.0*(-1.0)^n*sum(Fun(K,Y0..Y1, num_coefs))
end

# Y0 = sqrt(k^a12^2 - X^2)
function integrate_B(n::Int, X, Y0; θin = 0.0, num_coefs = 10000)
    Y1 = max(2000.0*X, 4000.0) # note Y1 is non-dimensional!
    # assymptotically approximate the integral from Y1 to Inf (tested in integrate_hankels.nb)
    Binf = (1.0+1.0im)*exp(im*Y1*(1.0 - sin(θin)))*
        (1.0 + (-1.0)^n*exp(2.0im*Y1*sin(θin))*(1.0 - sin(θin)) + sin(θin))/(sqrt(pi*Y1)*cos(θin)^2)

    return Binf + integrate_B_full(n, X, Y0; Y1=Y1, θin=θin, num_coefs = num_coefs)
end

# for only whole-correction, this doesn't involve an integral
function integrate_S(n::Int,X; θin = 0.0)
    S = 2.0*(im^Float64(n))*exp(-im*n*θin)*exp(im*X*cos(θin))/cos(θin)
    if X<0 S = conj(S) end
    S
end

"note that this uses the non-dimensional x = k*depth"
function average_wave_system(ω::T, medium::Medium{T}, specie::Specie{T}, wave_eff::EffectiveWave{T} = zero(EffectiveWave{T});
        θin::Float64 = 0.0,
        x::AbstractVector{T} = [zero(T)], mesh_points::Int = 201,
        hankel_order::Int = wave_eff.hankel_order) where T<:AbstractFloat

    if hankel_order < 0 # which is the default for zero(EffectiveWave{T})
        hankel_order = maximum_hankel_order(ω, medium, [specie]; tol=1e-3)
    end

    k = real(ω/medium.c)
    ak = real(k*specie.r);
    M = hankel_order;

    # estimate a large enough mesh
    if x == [0.]
        k_eff = wavenumber_low_volfrac(ω, medium, [specie])
        max_x = 10.0*k/abs(imag(k_eff)) # at this A ≈ exp(-10) ≈ 4.5e-5
        J = mesh_points
        h = ak/Int(ceil((J-1)*ak/max_x));
        x = (0:J)*h
    else
        J = length(collect(x))
        h = x[2] - x[1]
    end

    Z = OffsetArray{Complex{Float64}}(-M:M);
    for m = 0:M
        Z[m] = Zn(ω,specie,medium,m)
        Z[-m] = Z[m]
    end

    σ =  trap_scheme(x) # integration scheme: trapezoidal
    PQ_quad = intergrand_kernel(x; ak = ak, θin = θin, M = M);

    MM_quad = [
        specie.num_density*Z[n]*σ[j]*PQ_quad[l,m+M+1,j,n+M+1] + k^2*( (m==n && j==l) ? 1.0+0.0im : 0.0+0.0im)
    for  l=1:J, m=-M:M, j=1:J, n=-M:M];

    b_mat = [ -k^2*exp(im*x[l]*cos(θin))*exp(im*m*(pi/2.0 - θin)) for l = 1:J, m = -M:M]

    return (x, (MM_quad,b_mat))
end

function intergrand_kernel(x::AbstractVector{T}; ak::T = 1.0, θin::T = 0.0,
        M::Int = 2, num_coefs::Int = 10000) where T<:AbstractFloat

    dx = x[2] - x[1]
    J = length(collect(x)) -1

    if !(typeof(x) <: OffsetArray)
        if J*dx != x[end] warn("Unexpected x = $x.") end
        x = OffsetArray((0:J)*dx, 0:J)
    end
    if !(Int(floor(ak/dx)) ≈ ak/dx)
        warn("There are no mesh points exactly on-top of the intergrands kinks. This could lead to poor accuracy.")
    end
    p = min(Int(floor(ak/dx)),J)
    X = OffsetArray((-J:J)*dx, -J:J)

    B = OffsetArray{Complex{Float64}}(-p:p, -2M:2M);
    for j = -p:p, m = -2M:2M
        if ak^2 -X[j]^2 < -dx^2 error("evaluating B in the wrong domain") end
        B[j,m] = integrate_B(m, X[j], sqrt(abs(ak^2 -X[j]^2)); θin = θin, num_coefs=num_coefs)
    end
    S = OffsetArray{Complex{Float64}}(-J:J, -2M:2M);
    for j = -J:J, m = -2M:2M
        S[j,m] = integrate_S(m, X[j]; θin = θin)
    end
    function intergrand(l,j,m,n)
        P = S[j-l,n-m]
        Q = (abs(j-l)<= p) ? (B[j-l,n-m] - S[j-l,n-m]) : 0.0+0.0im
        P + Q
    end

    intergrand_quad = [intergrand(l,j,m,n) for  l=0:J, m=-M:M, j=0:J, n=-M:M]

    return intergrand_quad
end