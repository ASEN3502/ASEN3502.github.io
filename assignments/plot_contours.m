function plot_contours(fig,f)

    % Contour plot of f(alpha,delta_e) for -5 <= alpha <= 20 deg and -20 <= delta_e <= 20 deg
    % fig = figure number, f = function handle f(alpha,delta_e) with angles in radians

    % Evaluate f on a uniform 1000x1000 grid (f must accept matrices, so use .* ./ .^)
    [alpha_grid,delta_grid] = meshgrid(linspace(-5*pi/180,20*pi/180,1000),linspace(-20*pi/180,20*pi/180,1000));
    f_grid = f(alpha_grid,delta_grid);

    % Plot with logarithmically spaced contour levels and color scale
    figure(fig);
    levels = logspace(-5,1,40);
    contour(alpha_grid.*180/pi,delta_grid.*180/pi,f_grid,levels,'DisplayName','Objective Function');
    colorbar;

    set(gca,'ColorScale','log');
    xlabel('\alpha [deg]');
    ylabel('\delta_e [deg]');

end
