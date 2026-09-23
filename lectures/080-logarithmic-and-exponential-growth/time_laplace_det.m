% Time laplace_det against MATLAB's built-in det (LU factorization) as n grows.
% Each row of n adds a factor of about n to the Laplace time, so it goes from
% instantaneous to hopeless within a few steps. Stop it with Ctrl-C when bored.

ns = 2:11;                 % n = 11 takes about a minute; 12 would take ~15 min
t_laplace = nan(size(ns));
t_lu      = nan(size(ns));

fprintf('%4s  %12s  %12s  %10s\n', 'n', 'laplace (s)', 'det (s)', 'n!')
for k = 1:numel(ns)
    n = ns(k);
    A = rand(n);

    tic; d1 = laplace_det(A); t_laplace(k) = toc;
    tic; d2 = det(A);         t_lu(k)      = toc;

    fprintf('%4d  %12.4g  %12.4g  %10.3g\n', n, t_laplace(k), t_lu(k), factorial(n))
    assert(abs(d1 - d2) < 1e-8 * max(1, abs(d2)), 'determinants disagree')
end

% Extrapolate: each step multiplies the Laplace time by roughly n.
t = t_laplace(end);
fprintf('\nProjected laplace_det times (extrapolating by a factor of n per step):\n')
for n = ns(end)+1:25
    t = t * n;
    fprintf('  n = %2d:  %s\n', n, human_time(t))
end

semilogy(ns, t_laplace, 'o-', ns, t_lu, 's-', 'LineWidth', 1.5)
xlabel('n'), ylabel('time (s)'), grid on
legend('Laplace expansion, O(n!)', 'det (LU), O(n^3)', 'Location', 'northwest')

function s = human_time(t)
    units = {'s', 60; 'min', 60; 'hr', 24; 'days', 365.25; 'years', Inf};
    for i = 1:size(units, 1)
        if t < units{i, 2}
            s = sprintf('%.3g %s', t, units{i, 1});
            return
        end
        t = t / units{i, 2};
    end
end
