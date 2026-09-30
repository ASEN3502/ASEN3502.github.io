function [t, x] = euler(f, tspan, x0, h)
% EULER  Integrate dx/dt = f(t, x) with Euler's method.
%   [t, x] = EULER(f, tspan, x0, h) has the same inputs and outputs as
%   ODE45, plus the fixed step size h.  tspan = [t0, tf].
%
%   Example:  [t, x] = euler(@(t, x) -x + sin(t), [0, 6], 1, 0.1);
t = (tspan(1):h:tspan(2))';
x = zeros(size(t));
x(1) = x0;
for i = 1:length(t) - 1
    x(i+1) = x(i) + h * f(t(i), x(i));
end
end
