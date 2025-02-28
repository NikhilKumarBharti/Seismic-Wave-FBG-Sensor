function [y, t] = seismSim(sigma, fn, zeta, f, T90, eps, tn)
    % Number of frequency points
    nf = length(f);

    % Frequency step
    df = f(2) - f(1);

    % Calculate time step and time vector
    dt = 1 / (2 * f(end));
    t = 0:dt:tn;
    nt = length(t);

    % Generate white noise in frequency domain
    Z = complex(randn(1, nf), randn(1, nf));

    % Calculate the Kanai-Tajimi power spectral density function
    H = zeros(1, nf);
    for k = 2:nf  % Skip DC component
        H(k) = 1 / ((1 - (f(k)/fn)^2)^2 + (2*zeta*f(k)/fn)^2);
    end

    % Apply the Kanai-Tajimi filter to the white noise
    X = Z .* sqrt(H * sigma^2 * df);

    % Prepare for inverse FFT
    X_full = [X, conj(fliplr(X(2:end-1)))];  % Make it conjugate symmetric

    % Perform inverse FFT to get time domain signal
    x_raw = real(ifft(X_full));

    % Ensure x_raw is long enough
    if length(x_raw) < nt
        x_raw = [x_raw, zeros(1, nt - length(x_raw))];
    end

    x_raw = x_raw(1:nt);  % Truncate to desired length

    % Generate modulation function (envelope)
    a = -log(T90) / ((1-eps)*tn)^2;
    e = zeros(1, nt);
    for i = 1:nt
        if t(i) <= eps*tn
            e(i) = (t(i)/(eps*tn))^2;
        else
            e(i) = exp(-a * (t(i) - eps*tn)^2);
        end
    end

    % Apply envelope to generate the final acceleration time history
    y = x_raw .* e;

    % Normalize to specified standard deviation
    y = y * sigma / std(y);
end