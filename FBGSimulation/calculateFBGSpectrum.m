% Function definitions
function reflection = calculateFBGSpectrum(wavelength, center_wavelength, reflectivity, bandwidth)
    % Calculate normalized wavelength parameter
    normalized_wavelength = (wavelength - center_wavelength) / bandwidth;

    % Calculate reflection using Gaussian approximation
    reflection = reflectivity * exp(-4 * log(2) * normalized_wavelength.^2);
end