function dots = genDotPatterns(ndots, type, varargin)
% Prototype can be supplied by the user. If not supplied, a new prototype is generated

%% Set up input
if ~any(strcmp(type, {'prototype', 'low', 'med', 'high'}))
    error('genDotPatterns:UnrecognizedOption', ...
        'Unrecognized Type Option\nType input must match one of the following: ''prototype'', ''low'', ''med'', ''high''');
end


numvarargs = length(varargin);
if numvarargs == 0
    % set defaults for optional inputs
    proto = genPrototype(ndots);
    optargs = {proto};
end

% put varargin into a new variable skipping any empty inputs
newVals = cellfun(@(x) ~isempty(x), varargin);

% now put these defaults into the valuesToUse cell array, and overwrite the ones specified in varargin.
optargs(newVals) = varargin(newVals);

% Place optional args in memorable variable names
prototype = optargs{:};

%% Call functions which generate the appropriate dot pattern
switch type
    case 'prototype'
        dots = genPrototype(ndots);
    case 'low'
        dots = distortPrototype(prototype, 'low');
    case 'med'
        dots = distortPrototype(prototype, 'med');
    case 'high'
        dots = distortPrototype(prototype, 'high');
end

if size(unique(dots, 'rows'), 1) ~= ndots || min(pdist(dots, 'CityBlock')) <= 2
    dots = genDotPatterns(ndots, type, optargs{1});
end

%% FUNCTIONS

% Distort prototype to specific level
function newpattern = distortPrototype(prototype, level)
newpattern = zeros(size(prototype)); % Preload

% Distortion levels (note original levels 4 and 5 are not symmetric
L1 = [0 0];                   levelpoints{1} = L1;
L2 = allcomb(-1:1, -1:1);     levelpoints{2} = L2(~all([ismember(L2(:,1), L1(:,1)), ismember(L2(:,2), L1(:,2))], 2),:);
L3 = allcomb(-2:2, -2:2);     levelpoints{3} = L3(~all([ismember(L3(:,1), [L1(:,1); L2(:,1)]), ismember(L3(:,2), [L1(:,2); L2(:,2)])], 2),:);
% L4 = allcomb(-4:5, -4:5);     levelpoints{4} = L4(~all([ismember(L4(:,1), [L1(:,1); L2(:,1); L3(:,1)]), ismember(L4(:,2), [L1(:,2); L2(:,2); L3(:,2)])], 2),:);
L4 = allcomb(-5:5, -5:5);     levelpoints{4} = L4(~all([ismember(L4(:,1), [L1(:,1); L2(:,1); L3(:,1)]), ismember(L4(:,2), [L1(:,2); L2(:,2); L3(:,2)])], 2),:);
% L5 = allcomb(-9:10, -9:10);   levelpoints{5} = L5(~all([ismember(L5(:,1), [L1(:,1); L2(:,1); L3(:,1); L4(:,1)]), ismember(L5(:,2), [L1(:,2); L2(:,2); L3(:,2); L4(:,2)])], 2),:);
L5 = allcomb(-10:10, -10:10); levelpoints{5} = L5(~all([ismember(L5(:,1), [L1(:,1); L2(:,1); L3(:,1); L4(:,1)]), ismember(L5(:,2), [L1(:,2); L2(:,2); L3(:,2); L4(:,2)])], 2),:);

% For each x/y pair, choose a level and then choose a particular point in that level
for didx = 1:size(prototype, 1)
    dotx = prototype(didx, 1);
    doty = prototype(didx, 2);
    
    newpattern(didx, 1:2) = [dotx doty];
    
    % Select the dot region
    whatregion = rand;
    levels = {'proto'; 'low'; 'med'; 'high'};
    regionprobs = [1.0 0.0 0.0 0.0 0.0;  % Prototype is always region 1
                   .36 .48 .06 .05 .05;  % Low is Posner level 4
                   .00 .40 .32 .15 .13;  % Med is Posner level 6
                   .00 .24 .16 .30 .30]; % High is Posner level 7.7
    region = find(whatregion <= cumsum(regionprobs(strmatch(level, levels), :)), 1, 'first');
    
    % Now permute the dots
    dx = 0; dy = 0;
    
    notrun = 1;
    while dotx + dx < -25 || dotx + dx > 24 ||...
          doty + dy < -25 || doty + dy > 24 || notrun
        
        notrun = 0;
        dpoint = randint(1,size(levelpoints{region}, 1));
        dx = levelpoints{region}(dpoint, 1);
        dy = levelpoints{region}(dpoint, 2);
    end
    
    newpattern(didx, 1:2) = newpattern(didx, 1:2) + [dx dy];
end

%% Generate prototype
function dots = genPrototype(ndots)
% DOTS = GENPROTOTYPE(N) generates N random points in interval -15 to 16
dots = randint(-15, 15 + 1, ndots, 2);

%% Generate random integer on interval a, b
function r = randint(a, b, varargin)
% R = RANDINT(A, B, N, D) Generates N random integers of dimension d in the
% interval A - B
% Defaults: N = 1, D = 1;

% Set defaults
N = 1; D = 1;
optargs = {N, D};

% put varargin into a new variable skipping any empty inputs
newVals = cellfun(@(x) ~isempty(x), varargin);

% now put these defaults into the valuesToUse cell array, and overwrite the ones specified in varargin.
optargs(newVals) = varargin(newVals);

% Place optional args in memorable variable names
[n, d] = optargs{:};

%
r = round(a + (b - a) * rand(n, d));
%%

% Todd's code
% 		# create prototype for this subject
% 		self.prototype = self.create_prototype(ndots)
%
% 		# create the 10 high distortions for this subject
% 		self.old_highs = self.create_prototype_distortions(npatterns, "med")  # changed from "med" to "high"  4/12/06 # back 4/13
%
% 		# create 10 more high distortions (for test)
% 		self.new_highs = self.create_prototype_distortions(10, "med") # changed from "med" to "high" 4/12/06 # back 4/13
%
% 		# create 2 low distortions
% 		self.new_lows = self.create_prototype_distortions(2, "low")
%
% 		# create 20 random patterns
% 		self.randoms = self.create_random(20, "med") # changed from "med" to "high" 4/12/06 # back 4/13