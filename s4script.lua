require 'algaas_n'

-- =================================
--      Create relevant constants
-- =================================

-- a: Latice constant
a = 1081
-- r: radius of holes
r = 411
-- d: thickness of membrane
d = 110
-- L: gap beneath membrane
L = 750

-- =================================
--      Set up simulation object
-- =================================

-- Create a simulation object and set the latice constant and number of fourier coeffs.
-- Note that the time complexity is O(n^3) in number of fourier coeffs, so optimize if you can. 
S = S4.NewSimulation()
S:SetLattice({a, 0.0},{0.0, a})
S:SetNumG(50)

--      Create the materials
-- Note that the dielectric constant for GaAs/AlGaAs changes with freq
-- so it will be set later
S:AddMaterial("vacuum", {1.0,0.0})
S:AddMaterial("GAAS", {1.0, 0.0})
S:AddMaterial("AL92GAAS", {1.0, 0.0}) 
S:AddMaterial("AL67GAAS", {1.0, 0.0}) 

--      Set the stack
S:AddLayer('Layer_Above', 0.0, 'vacuum')

-- First membrane
S:AddLayer('membrane_0', d, 'GAAS')
S:SetLayerPatternCircle('membrane_0','vacuum', {0.000000,0.000000}, r)

-- Gap
S:AddLayer('gap_0', L, 'vacuum')

-- dbr: values from simulations before
d_gaas = 108.5
d_algaas = 127.1

S:AddLayer('gaas_0', d_gaas, 'GAAS')
S:AddLayer('al92gaas_0', d_algaas, 'AL92GAAS')
for i = 1, 2, 1 do
    S:AddLayerCopy('gaas_' .. i, d_gaas, 'gaas_0')
    S:AddLayerCopy('al92gaas_' .. i, d_algaas, 'al92gaas_0')
end

S:AddLayerCopy('quarter_wave_layer', 114.8, 'gaas_0')
S:AddLayer('etch_stop_layer', 397, 'AL67GAAS')

-- bottom
S:AddLayer('Layer_Below', 0.000000, 'GAAS')
        
-- =================================
--      Run the simulation
-- =================================

-- For many thetas and phis, simulate a plane wave. 
-- These will later be reconstructed to a gaussian beam
for theta = 0.0, 45.0, 9 do
    for phi = 0.0, 10.0, 5.0 do
    
        -- Set the excitation to a plain wave. 
        -- The polarization is rotated so that all plainwaves are polarized in the same direction
        S:SetExcitationPlanewave({phi,theta},{math.cos(math.rad(theta))/math.cos(math.rad(phi))
            , 0.000000},{-math.sin(math.rad(theta)),0.000000})

        for wavelength = wavelength_start, wavelength_end, 1 do

            -- Set the system frequency
        	S:SetFrequency(1/wavelength)

            -- Dielectric constant of GaAs changes with frequency, so it needs to be set at each step. 
        	S:SetMaterial('GAAS', {algaas_n(0, 293, wavelength)^2, 0})

            -- Calculate the results. 
        	incidence_flux, reflection_flux_vacuum = S:GetPoyntingFlux('Layer_Above', 0.000000)
        	reflection_flux_vacuum = (-1) * reflection_flux_vacuum / incidence_flux;
        	transmission_flux = S:GetPoyntingFlux('Layer_Below', 0.000000)
        	transmission_flux_GAAS = transmission_flux / incidence_flux;
        	incidence_flux_vacuum = incidence_flux / incidence_flux;

            -- print the results
        	print(wavelength, theta, phi, a, r, d, L, incidence_flux_vacuum, reflection_flux_vacuum, transmission_flux_GAAS);
        end
    end
end
