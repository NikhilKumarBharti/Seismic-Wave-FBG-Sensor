function plotFBGResults(time, acceleration, strain, lambda_shift, lambda_B, wavelength, reflection_spectra, sample_indices)
    % Create figure with subplots
    figure('Position', [100, 100, 1200, 800]);

    % Plot 1: Seismic acceleration
    subplot(2, 2, 1);
    plot(time, acceleration, 'b');
    xlabel('Time (s)');
    ylabel('Ground acceleration (m/s^2)');
    title('Seismic Signal');
    grid on;

    % Plot 2: Calculated strain
    subplot(2, 2, 2);
    plot(time, strain * 1e6, 'r'); % Convert to microstrain for display
    xlabel('Time (s)');
    ylabel('Strain (με)');
    title('Calculated Strain');
    grid on;

    % Plot 3: Wavelength shift over time
    subplot(2, 2, 3);
    plot(time, lambda_shift, 'g');
    xlabel('Time (s)');
    ylabel('Wavelength shift (nm)');
    title('FBG Wavelength Shift');
    grid on;

    % Plot 4: FBG reflection spectra at different time points
    subplot(2, 2, 4);
    wavelength_nm = wavelength * 1e9; % Convert to nm for display
    colors = jet(length(sample_indices)); % Colormap for different time points
    hold on;
    for i = 1:length(sample_indices)
        plot(wavelength_nm, reflection_spectra(:,i), 'Color', colors(i,:));
    end
    hold off;
    xlabel('Wavelength (nm)');
    ylabel('Reflectivity');
    title('FBG Reflection Spectrum at Different Times');
    colormap(jet);
    c = colorbar;
    caxis([min(time(sample_indices)), max(time(sample_indices))]);
    c.Label.String = 'Time (s)';
    grid on;

    % Add legend for spectrum plot
    legend_str = cell(length(sample_indices), 1);
    for i = 1:length(sample_indices)
        legend_str{i} = ['t = ', num2str(time(sample_indices(i)), '%.2f'), ' s'];
    end
    legend(legend_str, 'Location', 'northeast');

    % Additional visualization: 3D waterfall plot of reflection spectra over time
    figure('Position', [100, 100, 800, 600]);

    % Sample more time points for waterfall plot
    num_samples_waterfall = 20;
    waterfall_indices = round(linspace(1, length(time), num_samples_waterfall));

    % Calculate spectra for waterfall plot
    waterfall_spectra = zeros(length(wavelength), num_samples_waterfall);
    for i = 1:num_samples_waterfall
        idx = waterfall_indices(i);
        waterfall_spectra(:,i) = calculateFBGSpectrum(wavelength, lambda_B(idx), 0.9, 0.2e-9);
    end

    % Create waterfall plot
    waterfall(wavelength_nm, time(waterfall_indices), waterfall_spectra');
    xlabel('Wavelength (nm)');
    ylabel('Time (s)');
    zlabel('Reflectivity');
    title('FBG Spectrum Evolution Over Time');
    set(gca, 'FontSize', 12);
    colormap(jet);

    % Create a separate figure for wavelength shift heatmap
    figure('Position', [100, 100, 800, 400]);

    % Create a time-wavelength mesh for the heatmap
    time_mesh = repmat(time', 1, length(wavelength));
    wavelength_mesh = repmat(wavelength_nm, length(time), 1);

    % Calculate reflection at each time and wavelength point
    reflection_heatmap = zeros(length(time), length(wavelength));
    for i = 1:length(time)
        reflection_heatmap(i,:) = calculateFBGSpectrum(wavelength, lambda_B(i), 0.9, 0.2e-9);
    end

    % Create the heatmap using pcolor
    pcolor(wavelength_mesh, time_mesh, reflection_heatmap);
    shading interp;
    colormap(jet);
    c = colorbar;
    c.Label.String = 'Reflectivity';
    xlabel('Wavelength (nm)');
    ylabel('Time (s)');
    title('FBG Reflection Spectrum Evolution');

    % Set color axis limits
    caxis([0 1]);

    % Add a line showing the Bragg wavelength shift over time
    hold on;
    plot(lambda_B*1e9, time, 'w--', 'LineWidth', 2);
    hold off;

    % Optimize figure appearance
    set(gca, 'FontSize', 12);
end