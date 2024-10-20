function [fig, subplot_handles] = compare_signals(signal_sets, varargin)
%% COMPARE_SIGNALS Compare two or more sets of signals
%
% Generates a single figure with subplots comparing sets of signals.
% This is just a wrapper for the plot_signals function to make comparisons of full
% sets of signals more handy to implement.
%
%
% INPUT 
% ------ POSITIONAL PARAMETERS ------
% signal_sets:   A cell-array containing an arbitrary number of 2-D matrices
%                of identical sizes. The longer dimension is interpreted as the
%                x axis. A number of subplots identical to the shorter dimension
%                is created, and in each subplots the corresponding signals of 
%                each cell element are plotted together.
%                This is the _only_ required parameter!
% time:          x vector to plot against, must have same length as the signals.
%                If omitted or [], the index is used instead.
%                Alternatively: a cell array with as many entries as there
%                are signals in 'signal_sets', where each entry specifies the
%                x axis of the corresponding signal. Optional.
% signal_labels: Either (1) a single character vector, in which case this
%                vector with appended '_i' is used as the y label for each
%                signal, where i is the signal's index, or (2) a cell array
%                with the same number of entries as there are signals, where each
%                entry contains the ylabel for that signal, or (3) '', in which
%                case the signal index i is used. Optional.
% xlab:          x Axis label. Optional.
% plot_title:    Overall plot title to put over the whole figure. Optional.
%
% ------ OPTIONAL PARAMETERS, PASS AS NAME/VALUE ------
% mat_labels:    Labels to use for the different signal sets that have been provided.
%                Must be a cell array of the same length as signal_sets. If not 
%                provided or empty, signals are simply named numerically, starting with 1.
% num_plot_cols: Number of subplot columns. Default is 1.
% plot_by_rows:  Boolean that specifies whether to fill subplots by rows
%                (true, default) or by columns (false).
% markers:       Either a single vector of the same length as the individual
%                signals, or a cell array with one entry for each signal.
%                Each entry can either be a vector of the same length as
%                the signals, or {}. For each non-zero entry in a vector, a
%                marker is shown in the plot. If only one vector is
%                provided, the markers are plotted in all signals;
%                otherwise they are only plotted for a single signal.
% vlines:        Same as markers, but vertical lines are plotted instead of
%                markers. Also the format is different: here, the vectors
%                should contain the x values at which to plot the lines.
%                Caution: this causes the plot to become very slow if many 
%                vlines are shown!
% vline_labels:  Labels for vlines. If vlines is a single vector, this must
%                be a cell array with one string per entry in vlines. If
%                vlines is a cell array, this must be a cell array with one
%                entry per signal as well.
% fig_title:     Figure title. If not provided, plot_title is used.
% logy:          Should individual signals be shown with a logarithmic y axis? If yes, provide an
%                array with the indices of the corresponding signals, i.e. [2,3, 7]. Default is []
%                (none).
% link_axes:     Axes across which to link subplots: 'x', 'y', 'xy', ''. 'x' is default. Linking the
%                y axis is not possible when logy is non-empty.
% linespec:      Standard plot linespec. Default is '-'.
%
% OUTPUTS        fig: The generated figure.
%    subplot_handles: Vector containing handles for the generated subplots.
%
% EXAMPLES
%   t = 1:1000;
%   mat1 = [1:1000; sin(2*pi*t/100)];
%   mat2 = [1000:-1:1; cos(2*pi*t/100)];
%   mat3 = [ones(1, 1000); zeros(1, 1000)];
%   % This is what I originally developed this for: easy and direct comparison of signals in a matrix
%   compare_signals({mat1, mat2, mat3});  
%
%   % Here's a more complex example of what's also possible with this function.
%   vlines = 100:100:900;
%   compare_signals({mat1, mat2, mat3}, t, {'Signal A', 'Signal B'}, 'Time (s)', 'Demo Title', ...
%                'vlines', vlines, 'mat_labels', {'mat1', 'mat2', 'mat3'});
%
% Eike Petersen, 2021
% Danmarks Tekniske Universitet / Technical University of Denmark, DTU Compute
%


%% Input handling
p = inputParser;

% Positional arguments
addRequired(p, 'signals', @ismatrix);
addOptional(p, 'time', [], @(time) isempty(time) || isvector(time));
addOptional(p, 'signal_labels', [], @(par) isempty(par) || iscell(par) || ischar(par));
addOptional(p, 'xlab', [], @(par) isempty(par) || ischar(par));
addOptional(p, 'plot_title', [], @(par) isempty(par) || ischar(par));
% Name-value arguments
addParameter(p, 'mat_labels', {}, @iscell);
addParameter(p, 'num_plot_cols', 1, @isnumeric);
addParameter(p, 'plot_by_rows', true, @islogical);
check_vec_or_cell_of_vecs = @(par) isempty(par) || isvector(par) || (iscell(par) && isvector(par{1}));
addParameter(p, 'markers', {}, check_vec_or_cell_of_vecs);
addParameter(p, 'vlines', {}, check_vec_or_cell_of_vecs);
addParameter(p, 'vline_labels', {}, @iscell);
addParameter(p, 'fig_title', '', @ischar);
addParameter(p, 'logy', [], @(logy) isempty(logy) || isvector(logy));
addParameter(p, 'link_axes', 'x', @ischar);
addParameter(p, 'linespec', '-', @ischar);

parse(p, signal_sets, varargin{:})
struct2vars(p.Results);

signals = signal_sets{1};
[m, n] = size(signals);
if m > n
    signals = signals';
    signals_in_rows = false;
else
    signals_in_rows = true;
end
nsig = size(signals, 1);

ref_sigs = cell(nsig, 1);
ref_sig_labels = cell(nsig, 1);
for ii = 1:nsig
    if signals_in_rows
        ref_sigs{ii} = cell2mat(cellfun(@(signals_loc) signals_loc(ii, :), signal_sets(2:end), 'UniformOutput', false)');
    else
        ref_sigs{ii} = cell2mat(cellfun(@(signals_loc) signals_loc(:, ii)', signal_sets(2:end), 'UniformOutput', false)');
    end
    if ~isempty(mat_labels)
        ref_sig_labels{ii} = mat_labels;
    else
        ref_sig_labels{ii} = strsplit(num2str(1:length(signal_sets)));
    end
end

[fig, subplot_handles] = plot_signals(signals, time, signal_labels, xlab, plot_title, ...
    'num_plot_cols', num_plot_cols, 'plot_by_rows', plot_by_rows, 'markers', markers, 'vlines', vlines, ...
    'vline_labels', vline_labels, 'fig_title', fig_title, 'logy', logy, 'link_axes', link_axes, ...
    'ref_sigs', ref_sigs, 'ref_sig_labels', ref_sig_labels, 'linespec', linespec);
end