function [lambda_shift, lambda_B] = calculateFBGResponse(strain, lambda_B0, p_e, n_eff, strain_sensitivity)
    % Calculate the wavelength shift using the strain-optic effect
    lambda_shift_m = strain * strain_sensitivity * 1e-12; % Convert pm/μɛ to m/strain

    % Calculate the new Bragg wavelength
    lambda_B = lambda_B0 + lambda_shift_m;

    % Convert shift to nm for plotting
    lambda_shift = lambda_shift_m * 1e9;
end