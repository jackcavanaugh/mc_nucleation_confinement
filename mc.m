%% Simulation settings
experiments = 10^5; % total number of individual MC experiments
duration = 100; % total time of experiments in hours
attempts = duration; % time resolution of crystallization events
time = 0:duration/attempts:duration; % hours
ExpPlot = 5; % Number of individual survival curves to plot
N = 100; % Initial number of droplets
d = 100*10^-4; % diameter of individual droplet in cm
V = 4/3*pi*(d/2)^3; % droplet volume in cm^3
J = 1.23; % cm^-3 s^-1, Nucleation rate from 297-droplet experiment published in https://doi.org/10.1039/C8SC05634J

%% Monte Carlo Simulation
P0t = exp(-J*V*time*3600); % Probability that a droplet does not contain a crystal
cutoff = P0t(2); % Probability that a droplet has crystallized in one time step

% Initialize containers for experiment results
crystals = zeros(experiments, attempts + 1);

% Loop for each experiment
parfor experiment = 1:experiments
    droplets = N; % Experiment begins with N0 droplets
    
    % Monte Carlo steps for each experiment:
    for step = 2:(attempts + 1)
        crystals(experiment, step) = sum(rand(droplets, 1) > cutoff); %  Check for crystallization
        droplets = droplets - crystals(experiment, step); % Calculate remaining non-crystalline droplets
    end
end

N0 = N - cumsum(crystals,2); % Count non-crystalline droplets for all times
f_survival = N0/N; % Calculate survival curve for non-crystalline droplets for all times

bins = 0.5*[1 - 0.997 1 - 0.95 1 - 0.68 1 1 + 0.68 1 + 0.95 1 + 0.997];
envelopes = quantile(f_survival, bins, 1); % Bin experiments into 68/95/99.7% quantiles

%% Plot
f = figure;
plot(time, P0t,'r-', 'DisplayName', 'P0t'); 
hold on
plot(time, f_survival(1:ExpPlot,:)', 'r.');

%% # Plot shaded envelopes for quantiles based on 1-3 standard deviations from mean
% 3σ envelope
fill([time, fliplr(time)], ...
     [envelopes(1,:), fliplr(envelopes(7,:))], ...
     [0.8 0.8 0.8], 'EdgeColor', 'none', 'DisplayName', '3σ');

% 2σ envelope
fill([time, fliplr(time)], ...
     [envelopes(2,:), fliplr(envelopes(6,:))], ...
     [0.6 0.6 0.6], 'EdgeColor', 'none', 'DisplayName', '2σ');

%  1σ envelope
fill([time, fliplr(time)], ...
     [envelopes(3,:), fliplr(envelopes(5,:))], ...
     [0.4 0.4 0.4], 'EdgeColor', 'none', 'DisplayName', '1σ');

xlim([0 52]); ylim([0 1]);
box on
xlabel('time (hours)'); ylabel('N1/N0');
legend;
hold off;

