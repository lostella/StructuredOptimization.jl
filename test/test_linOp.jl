#test linear operators

stuff = [
	 Dict("Operator" => (eye,),
              "params" => ((),),
	      "args"   => ( randn(400), randn(400) )
	     ),
	 Dict("Operator" => (diagop,),
              "params" => ((randn(2,2)+im*randn(2,2),),),
	      "args"   => ( randn(2,2)+im*randn(2,2), randn(2,2)+im*randn(2,2) )
	      ),
	 Dict("Operator" => (diagop,),
              "params" => ((2,),),
	      "args"   => ( randn(2,2), randn(2,2) )
	      ),
	 Dict("Operator" => (diagop,),
              "params" => ((2+im*3,),),
	      "args"   => ( randn(2,2), (2+im*3)*randn(2,2) )
	      ),
	 Dict("Operator" => (*,),
              "params" => ((randn(4,4)),),
	      "args"   => ( randn(4), randn(4) )
	      ),
	 Dict("Operator" => (*,),
              "params" => ((randn(4,4)+im*randn(4,4)),),
	      "args"   => ( randn(4)+im*randn(4), randn(4)+im*randn(4) )
	      ),
	 Dict("Operator" => (*,),
              "params" => ((randn(4,6)+im*randn(4,6)),),
	      "args"   => ( randn(6)+im*randn(6), randn(4)+im*randn(4) )
	      ),
	
	 Dict("Operator" => (fft,),
              "params" => ((), ),
	      "args"   => ( randn(64)+im*randn(64), randn(64)+im*randn(64) )
	      ),
	
	 Dict("Operator" => (fft,),
              "params" => ((),),
	      "args"   => ( randn(64,64), fft(randn(64,64)) )
	      ),
	
	 Dict("Operator" => (ifft,),
              "params" => ((), ),
	      "args"   => ( randn(64,64), fft(randn(64,64)) )
	      ),
	
	 Dict("Operator" => (ifft,),
              "params" => ((), ),
	      "args"   => ( randn(64)+im*randn(64), randn(64)+im*randn(64) )
	      ),
	 Dict("Operator" => (dct,),
	      "params" => ((), ),
	      "args"   => ( randn(64,64), randn(64,64) )
	      ),
	 Dict("Operator" => (idct,),
              "params" => ((), ),
	      "args"   => ( randn(64)+im*randn(64), randn(64)+im*randn(64) )
	      ),
	
	 Dict("Operator" => (reshape,),
              "params" => ((10,10), ),
	      "args"   => ( randn(100), randn(10,10) )
	      ),
	 Dict("Operator" => (*, dct),
              "params" => ((randn(32,64)) ,() ),
	      "args"   => ( randn(64), randn(32) )
	      ),
	 Dict("Operator" => (ifft, reshape, dct),
              "params" => ((),(10,10),() ),
	      "args"   => ( randn(100), dct(reshape(ifft(randn(100)),10,10)) )
	      ),
	 Dict("Operator" => (dct, getindex, reshape, dct),
              "params" => ((),([1:100]),(10,10),() ),
	      "args"   => ( randn(120), randn(10,10) )
	      ),
	 Dict("Operator" => (ifft, getindex),
              "params" => ((),([1:20]) ),
	      "args"   => ( randn(200)+im*randn(200), randn(20)+im*randn(20) )
	      ),
	 Dict("Operator" => (fft, getindex),
              "params" => ((),([1:5]) ),
	      "args"   => ( randn(12)+im*randn(12), randn(5)+im*randn(5) )
	      ),
	 Dict("Operator" => (dct, getindex),
              "params" => ((),([1:2,:,2:5]) ),
	      "args"   => ( randn(5,5,5)+im*randn(5,5,5), randn(2,5,4)+im*randn(2,5,4) )
	      ),
	 ]


for i in eachindex(stuff)

	x,y = deepcopy(stuff[i]["args"])
	X,Y = OptVar(x), OptVar(y)

	params = stuff[i]["params"][1]
	Op     = stuff[i]["Operator"][1]
	if Op == * 
		A = Op(params,X)
	else
		A = Op(X, params...)
	end
	for j = 2:length(stuff[i]["params"])
		params = stuff[i]["params"][j]
		Op     = stuff[i]["Operator"][j]
		if Op == * 
			A = Op(params,A)
		else
			A = Op(A, params...)
		end
	end
	test1,test2 = RegLS.test_FwAdj(A, x, y)
	@test test1 < 1e-8
	@test test2 < 1e-8
	test3 = RegLS.test_Op(A, x, y)
	@test test3 < 1e-8

end

### test sum of linear operators

x1 = ones(3)
X1 = OptVar(x1)
y = fft(randn(3))
x = x1

A = -fft(X1)

@test norm((A*x)+fft(x)./sqrt(3)) < 1e-8

test1,test2 = RegLS.test_FwAdj(A, x, y)
@test test1 < 1e-8
@test test2 < 1e-8
test3 = RegLS.test_Op(A, x, y)
@test test3 < 1e-8

x1 = randn(3)
X1 = OptVar(x1)
y = randn(3)
x = x1

A = 3*X1-dct(X1)

@test norm((A*x)-(3*x-dct(x))) < 1e-8

test1,test2 = RegLS.test_FwAdj(A, x, y)
@test test1 < 1e-8
@test test2 < 1e-8
test3 = RegLS.test_Op(A, x, y)
@test test3 < 1e-8

x1,x2 = randn(3,3), randn(3,3)
X1,X2 = OptVar(x1), OptVar(x2)
y = randn(3,3)
x = [x1,x2]

A = 3.4*X1-2.0*dct(X2)
@test norm((A*x)-(3.4*x1-2*dct(x2))) < 1e-8

test1,test2 = RegLS.test_FwAdj(A, x, y)
@test test1 < 1e-8
@test test2 < 1e-8
test3 = RegLS.test_Op(A, x, y)
@test test3 < 1e-8


x1,x2,x3 = randn(3),randn(3),randn(3)
X1,X2,X3 = OptVar(x1), OptVar(x2), OptVar(x3)
y = randn(3)
x = [x1,x2,x3]

A = dct(X1)-X1+5.3*dct(X2)+eye(X1)+X3
@test norm((A*x)-(dct(x1)-x1+5.3*dct(x2)+x1+x3)) < 1e-8

test1,test2 = RegLS.test_FwAdj(A, x, y)
@test test1 < 1e-8
@test test2 < 1e-8
test3 = RegLS.test_Op(A, x, y)
@test test3 < 1e-8

#test Affine

x1 = randn(3)
X1 = OptVar(x1)
y = fft(randn(3))
x = x1
b = fft(randn(3))

A = fft(X1)-b

show(A)

res = A*x
fx = norm(res)^2
res0 = fft(x1)./sqrt(3)-b
fx0 = norm(res0)^2

@test norm(fx-fx0)<1e-8

gradx0 = ifft(res0)*sqrt(3)
gradx  = A'*res0

@test norm(gradx-gradx0)<1e-8

x1,x2 = randn(3,3), randn(3,3)
X1,X2 = OptVar(x1), OptVar(x2)
y = randn(3,3)
b = randn(3,3)
x = [x1,x2]

A = 3.4*X1-2.0*dct(X2)+b

show(A)

resx = A*x
fx = vecnorm(resx)^2
resx0 = 3.4*x1-2.0*dct(x2)+b
fx0 = vecnorm(resx0)^2

@test norm(fx-fx0)<1e-8

gradx  = A'*resx
gradx0 = [3.4*resx0, -2.0*idct(resx0)]

@test norm(gradx-gradx0)<1e-8















