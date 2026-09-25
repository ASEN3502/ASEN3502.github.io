% Starter code for the root-finder verification script (Task 1.4).
% Fill in every TODO. Running this script should print "All root finders
% verified." if every solver works, or stop with an error at the first
% solver that fails.

% Call the test once for each solver your team implemented, e.g.
% test_root_find(@bisection). The @ makes a handle to the function so it can
% be passed as an argument.
test_root_find(@bisection)
test_root_find(@newton_raphson)
% TODO: add a call for each of your other solvers

disp('All root finders verified.')

% A subfunction: defined at the bottom of the script and only callable from
% this script.
function test_root_find(solver)
    % Choose a test function whose root you know exactly.
    f = @(x) 0;             % TODO
    fprime = @(x) 0;        % TODO
    interval = [0 0];       % TODO
    atol = 1e-6;
    maxit = 100;

    % solver is a function handle, so it can be called like any function
    x = solver(f, fprime, interval, atol, maxit);

    % TODO: compute the error between x and the true root, and use assert
    % to raise an error if it is larger than atol. func2str(solver) gives
    % the solver's name for the error message.
    error_in_x = 0;
    assert(error_in_x <= atol, '%s failed', func2str(solver))
end
