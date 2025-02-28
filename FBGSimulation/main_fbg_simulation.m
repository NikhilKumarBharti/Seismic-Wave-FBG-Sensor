% Main script for FBG response to speaker vibration
clearvars; close all; clc;

% Generate seismic signal using existing function
f = linspace(0, 45, 2048); % frequency vector
zeta = 0.5; % bandwidth of the earthquake excitation
sigma = 0.5; % standard deviation of the excitation
fn = 20; % dominant frequency of the earthquake excitation (Hz)
T90 = 1; % value of the envelope function at 90 percent of the duration
eps = 0.9; % normalized duration time when ground motion achieves peak
tn = 50; % duration of ground motion (seconds)

% Function call to generate ground acceleration
[acceleration, time] = seismSim(sigma, fn, zeta, f, T90, eps, tn);

% FBG parameters
lambda_B0 = 1550e-9; % Base Bragg wavelength at rest (m)
p_e = 0.22; % Effective photo-elastic coefficient (typical value for silica fiber)
n_eff = 1.468; % Effective refractive index of the fiber core
strain_sensitivity = 1.2; % Increased FBG strain sensitivity (pm/μɛ)
strain_scale_factor = 1e-4; % Adjusted to reflect realistic strain values

% Calculate strain from acceleration
strain = acceleration * strain_scale_factor;

% Introduce a range of strain to simulate vibrations
strain_amplitude = 1000e-6; % Increased amplitude of strain vibrations
strain = strain + strain_amplitude * sin(2 * pi * fn * time);

% Calculate wavelength shift using FBG model
[lambda_shift, lambda_B] = calculateFBGResponse(strain, lambda_B0, p_e, n_eff, strain_sensitivity);

% Generate optical spectrum at specific time points
num_samples = 5; % Number of sample points to generate spectra
sample_indices = round(linspace(1, length(time), num_samples));
wavelength_range = linspace(lambda_B0 - 1e-9, lambda_B0 + 1e-9, 1000); % 2 nm range around Bragg wavelength

% Parameters for reflection spectrum
reflectivity = 0.9; % Peak reflectivity
bandwidth = 0.2e-9; % Spectral width (m)

% Pre-allocate reflection spectra matrix
reflection_spectra = zeros(length(wavelength_range), num_samples);

% Generate reflection spectra at selected time points
for i = 1:num_samples
    idx = sample_indices(i);
    % Get the shifted center wavelength at this time point
    center_wavelength = lambda_B(idx);
    % Calculate reflection spectrum
    reflection_spectra(:, i) = calculateFBGSpectrum(wavelength_range, center_wavelength, reflectivity, bandwidth);

    % Debug output
    fprintf('Time index: %d, Center Wavelength: %.4f nm\n', idx, center_wavelength * 1e9);
end

% Plot results
plotFBGResults(time, acceleration, strain, lambda_shift, lambda_B, wavelength_range, reflection_spectra, sample_indices);

% Save results to file
save('fbg_speaker_vibration_response.mat', 'time', 'acceleration', 'strain', 'lambda_shift', 'lambda_B');

fprintf('Simulation complete. Results saved to fbg_speaker_vibration_response.mat\n');