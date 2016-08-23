# indicator of an affine set

"""
  IndAffine(A::Array{Float64,2}, b::Array{Float64,1})

Returns the function `g = ind{x : Ax = b}`.

  IndAffine(A::Array{Float64,1}, b::Float64)

Returns the function `g = ind{x : dot(a,x) = b}`.
"""

immutable IndAffine <: ProximableConvex
  A
  b
  L
  function IndAffine(A::Array{Float64,2}, b::Array{Float64,1})
    if size(A,1) > size(A,2)
      error("A must be full row rank")
    end
    AAt = A*A';
    L = chol(AAt, Val{:L})
    new(A, b, L)
  end
  IndAffine(a::Array{Float64,1}, b::Float64) =
    IndAffine(a', [b])
end

function call(f::IndAffine, x::Array{Float64,1})
  # the tolerance in the following line should be customizable
  if norm(f.A*x - f.b, Inf) > 1e-14 return Inf end
  return 0.0
end

function prox(f::IndAffine, gamma::Float64, x::Array{Float64,1})
  res = f.A*x - f.b
  y = x - f.A'*(f.L'\(f.L\res))
  return y, 0.0
end

fun_name(f::IndAffine) = "indicator of an affine subspace"
fun_type(f::IndAffine) = "R^n → R ∪ {+∞}"
fun_expr(f::IndAffine) = "x ↦ 0 if Ax = b, +∞ otherwise"
fun_params(f::IndAffine) =
  string( "A = ", typeof(f.A), " of size ", size(f.A), ", ",
          "b = ", typeof(f.b), " of size ", size(f.b))