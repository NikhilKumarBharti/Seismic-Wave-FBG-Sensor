% Existing code for ground acceleration generation
clearvars; close all; clc;

f = linspace(0,45,2048); % frequency vector
zeta = 0.5; % bandwidth of the earthquake excitation.
sigma = 0.5; % standard deviation of the excitation.
fn = 20; % dominant frequency of the earthquake excitation (Hz).
T90 = 1; % value of the envelop function at 90 percent of the duration.
eps = 0.9; % normalized duration time when ground motion achieves peak.
tn = 50; % duration of ground motion (seconds).
--
% Function call to generate ground acceleration
[y, t] = seismSim(sigma, fn, zeta, f, T90, eps, tn); 
% y: acceleration record
% t: time

figure
plot(t, y, 'b');
xlabel('time (s)')
ylabel('ground acceleration (m/s^2)')
axis tight
set(gcf, 'color', 'w')

% Step 1: Normalize and scale the signal to 0-5V for Arduino
y_normalized = (y - min(y)) / (max(y) - min(y));  % Normalize the signal
y_scaled = y_normalized * 5;  % Scale the signal to 0-5V

% Step 2: Establish connection with Arduino
a = arduino('COM3', 'Uno');  % Change 'COM3' to your Arduino port and 'Uno' to your board model

% Step 3: Send the scaled signal to Arduino via PWM (e.g., pin D5)
pwmPin = 'D5';  % Use a PWM-capable pin
for i = 1:length(y_scaled)
    writePWMVoltage(a, pwmPin, y_scaled(i));  % Send the scaled signal
    pause(0.01);  % Delay to simulate real-time transmission
end

% Step 4: Clear the Arduino object after sending signals
clear a;