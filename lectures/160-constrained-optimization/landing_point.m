w = 20;
h = 15;

x0 = -18;
y0 = -4;

objective = @(x) (x(1) - x0)^2 + (x(2) - y0)^2;

function [g, h] = g_h_obs(x)
    xobs = -10;
    yobs = 0;
    robs = 5;
    g = robs^2 - (x(1) - xobs)^2 - (x(2) - yobs)^2;
    h = [];
end

xstar = fmincon(objective, [0; 0], [], [], [], [], [-w/2; -h/2], [w/2; h/2], @g_h_obs)
