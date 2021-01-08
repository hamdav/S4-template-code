a = 1081
r = 418
d = 90
L = 4000

print('r=' .. r .. ', a=' .. a .. ', d=' .. d .. ', L=' .. L)

for theta = 0.0, 90.0, 5.0 do
    for phi = 0.0, 10.0, 1.0 do
    
        S = S4.NewSimulation()
        S:SetLattice({a,0.000000},{0.000000,a})
        S:SetNumG(50)
        
        S:AddMaterial("vacuum", {1.000000,0.000000})
        S:AddMaterial("GAAS", {11.38482,0.000000})
        
        S:AddLayer('Layer_Above', 0.000000, 'vacuum')

        S:AddLayer('layer_1', d, 'GAAS')
        S:SetLayerPatternCircle('layer_1','vacuum', {0.000000,0.000000}, r)
    
        S:AddLayer('layer_2', L, 'vacuum')
    	S:AddLayer('Layer_Below', 0.000000, 'GAAS')
        
        S:SetExcitationPlanewave({phi,theta},{math.cos(math.rad(theta))/math.cos(math.rad(phi))
            , 0.000000},{-math.sin(math.rad(theta)),0.000000})
        
        real_eps_1 = 1.0
        imag_eps_1 = 0.0
        
        real_eps_2 = 11.38482
        imag_eps_2 = 0.0

        for i = 1400 , 1700, 1 do
        	freq = 1.0/i;
        	S:SetFrequency(freq)
        	S:SetMaterial('vacuum', {real_eps_1, imag_eps_1});
        	S:SetMaterial('GAAS', {real_eps_2, imag_eps_2});
        	incidence_flux, reflection_flux_vacuum = S:GetPoyntingFlux('Layer_Above', 0.000000)
        	reflection_flux_vacuum = (-1) * reflection_flux_vacuum / incidence_flux;
        	transmission_flux = S:GetPoyntingFlux('Layer_Below', 0.000000)
        	transmission_flux_GAAS = transmission_flux / incidence_flux;
        	incidence_flux_vacuum = incidence_flux / incidence_flux;
        	print(freq .. '\t' .. incidence_flux_vacuum .. '\t' .. reflection_flux_vacuum .. '\t' .. transmission_flux_GAAS);
        end
    end
end
