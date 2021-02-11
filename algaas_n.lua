-- Exports a function algaas_n(xin, Tin, lambdain) 
-- returning the refractive index of Al_xGa_(1-x)As

ee = 1.6021766208e-19
hbar = 1.0545718E-34
cvac = 299792458
kB = 1.380649E-23
kBinmeVperK = kB / ee * 1000

function nGehrsitz(A, C0, C1, E0, E1, E)
    return math.sqrt(A + C0 / (E0^2 - E^2) + C1 / (E1^2 - E^2))
end

AGaAs = 6.09
function AGaAsT(T)
    return 5.9613 + 7.178e-4 * T - 0.953e-6 * T^2
end

E1GaAsSQ = 4.5
function E1GaAsSQT(T)
    return 4.7171 - 3.237e-4 * T - 1.358e-6 * T^2
end

E0gammaGaAsSQ = 1.321079
function E0gammaGaAsTeV(T)
    return 1.5192 + 1.8 * 15.9e-3 * (1 - 1 / math.tanh(15.9 / (2 * kBinmeVperK * T))) + 1.1*33.6e-3 * (1 - 1 / math.tanh(33.6 / (2 * kBinmeVperK * T)))
end

function E0gammaGaAsT(T)
    return 1e-6 * ee / (hbar * 2 * math.pi * cvac) * E0gammaGaAsTeV(T)
end
function polyEval(x, a)
    return a[1] + x * a[2] + x^2 * a[3] + x^3 * a[4] + x^4 * a[5] + x^5 * a[6]
end
function Ain(T)
    return {AGaAsT(T), -16.159, 43.511, -71.317, 57.535, -17.451}
end
C1 = {21.5647, 113.74, -122.5, 108.401, -47.318, 0}
function E1SQ(T)
    return {E1GaAsSQT(T), 11.006, -3.08, 0, 0, 0}
end
C0inv = {50.535, -150.7, -62.209, 797.16, -1125, 503.79}
function E0in(T)
    return {E0gammaGaAsT(T), 1.1308, 0.1436, 0, 0, 0}
end


function algaas_n(xin, Tin, lambdain)
    angular_freq = 2 * math.pi * cvac / lambdain
    return nGehrsitz(polyEval(xin, Ain(Tin)), 
                     1 / polyEval(xin, C0inv), 
                     polyEval(xin, C1),
                     polyEval(xin, E0in(Tin)),
                     math.sqrt(polyEval(xin, E1SQ(Tin))),
                     1e-6 * angular_freq / (2 * math.pi * cvac))
end

