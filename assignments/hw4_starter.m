%% ASEN 3502 Homework 4
% Starter code. Fill in every TODO, then create your pdf with
%
%   publish('hw4_starter.m', 'pdf')
%
% (rename the file if you like, e.g. hw4_<lastname>.m, and publish that).
% The pdf appears in a new |html| folder next to this file. Open it and
% check it before submitting.
%
% How |publish| works:
%
% * A line starting with |%%| begins a new section with a heading; the
%   headings make the table of contents at the top of the pdf.
% * Comment lines right after a |%%| line are formatted as text. Blank
%   comment lines separate paragraphs. Text between |$...$| is typeset as
%   LaTeX math, e.g. $x_{i+1} = x_i + h$, and |$$...$$| on its own line
%   gives a displayed equation. Use this for derivations.
% * Code output (anything without a semicolon, |disp|, |fprintf|) and
%   every figure are inserted after the section's code.
% * Local functions must be at the very end of the file, after all the
%   script code. They are printed in the pdf too.
%
% Type |doc publish| for more. If you prefer a Live Script (.mlx), the same
% layout applies and you can export to pdf from the Live Editor.
%
% Derivations may be typed as LaTeX in the comments, written in a Live
% Script, or done by hand and appended to the pdf.

%% Question 1(a): Euler update
% TODO: write the explicit Euler update for $\{\dot x\} = \{f\}(t, \{x\})$
% as a displayed equation here.

%% Question 1(b): Implementation
% The |euler| function is a local function at the end of this file.

%% Question 1(c): Harmonic oscillator
% TODO: implement the dynamics in the local function |osc_dyn|, then
% solve with h = 0.1 on [0 10].
[t, x] = euler(@osc_dyn, [0 10], [1; 0], 0.1);

figure
% TODO: plot the numerical x_1(t) and the exact solution cos(t) together.
% Label the axes and add a legend.

%%
% TODO: describe how the numerical and exact solutions differ.

%% Question 2: Verification
% TODO: derive the exact solution and the first-order system here, then
% implement the system in the local function |test_dyn| and the test in
% |test_ode|. When they work, this line should run without an error:
test_ode(@euler, 0.001, 2e-3)
disp('Euler passed the test.')

%% Question 3: Error trend
N = [10 20 40 80 160 320 640];
h = 1./N;
E_max = zeros(size(h));
for k = 1:length(h)
    % TODO: solve the test problem with step h(k) and store the maximum
    % absolute error in the first state component in E_max(k).
end

figure
% TODO: loglog plot of E_max against h, then estimate the slope
% (polyfit on log(h) and log(E_max) is one way).

%%
% TODO: relate the slope to the order of Euler's method and estimate the
% step size needed for E_max = 1e-6.

%% Local functions
% These must stay at the end of the file.

function [t, x] = euler(dynamics, tspan, x0, h)
% EULER Explicit Euler integration of dx/dt = dynamics(t, x).
%   Same conventions as ode45: t is a column vector and x(i,:) is the
%   state at t(i).
    t = (tspan(1):h:tspan(2)).';
    x = zeros(length(t), length(x0));
    x(1,:) = x0;
    for i = 1:length(t)-1
        % TODO: Euler step. dynamics expects and returns column vectors,
        % so transpose x(i,:) going in and the derivative coming out.
    end
end

function xdot = osc_dyn(t, x)
% OSC_DYN Harmonic oscillator from Question 1(c).
    xdot = [0; 0]; % TODO
end

function xdot = test_dyn(t, x)
% TEST_DYN First-order form of the test problem in Question 2.
    xdot = [0; 0]; % TODO
end

function test_ode(integrator, h, E)
% TEST_ODE Raises an error unless integrator solves the test problem on
%   [0, 1] with maximum absolute error strictly less than E.
    % TODO: call integrator(@test_dyn, ...) and compare x(:,1) with the
    % exact solution at every time in t.
    max_error = Inf;
    assert(max_error < E, '%s failed: max error %g is not below %g', ...
        func2str(integrator), max_error, E)
end
