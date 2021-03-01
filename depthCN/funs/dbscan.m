function [labs, labscore] = dbscan(a,Eps,MinPts)
%  DBSCAN clustering
% [labs labscore] = dbscan(A,Eps,MinPts)
%
% DBSCAN clustering of data matrix in A. labels is a vector with 
% cluster labels for each vector.
% 
% In case of publication of any application of this method,
% please, cite the original work:
% Thanh N. Tran*, Klaudia Drab, Michal Daszykowski, "Revised DBSCAN algorithm 
% to cluster data with dense adjacent clusters", Chemometrics and Intelligent 
% Laboratory Systems, 120:92–96.
% DOI: 10.1016/j.chemolab.2012.11.006 


UNCLASSIFIED = 0;
BORDER = -2;
    % Square Eps in order not to square all distances of points
    %eps = eps^2;
    
     m = size(a,1);
     labs = zeros(m,1);
     ClusterId = 1;
     for i=1:m
        if labs(i) == UNCLASSIFIED                 
            
           % Expand cluster ClusterId
           % Get a set of points of distance < eps
           [ExpandClusterReturn labs]= ExpandCluster(a,labs,i,ClusterId,Eps, MinPts);
           if ExpandClusterReturn
               ClusterId = ClusterId +1;
           end
        end
     end

     % Step 3:
     labscore = labs; core_index = find(labscore > 0);
     border_points = find(labs==BORDER);
     % For xborder in border_list but has no ClusterId
     for i=1:length(border_points)
            % xborder in border_list
            currentB = border_points(i);
            d=distance(+a(currentB,:),+a(core_index,:),1);
            % the closest core-points 
            [tmp nearest_core]=min(d);
            nearest_core_index=core_index(nearest_core);
            %Assign xborder to ClusterId of the closest core-points 
            labs(currentB)=labs(nearest_core_index);
     end
end

function [ExpandClusterReturn labs]= ExpandCluster(a,labs,i,ClusterId, Eps, MinPts)
UNCLASSIFIED = 0;
NOISE = -1;
BORDER = -2;
           % calculate distances
           d=distance(+a(i,:),+a(:,:),1);
           
           % seeds = Retrieve_Neighbors(xi, Eps) 
           seeds = find(d < Eps);
           
           % If |seeds | < MinPts
           if size(seeds,2) < MinPts, 
               labs(i) = NOISE;                 % Assign xi as noise
               ExpandClusterReturn = 0;         % Return without expansion success 
           else
               	% STEP 1: xi is a identified as a starting core-point for ClusterId
                %labs(i) = ClusterId;  %        % Thanh changed in May 2012
                % Exclude xi from the Seeds
                %seeds = setdiff(seeds, i);     % Thanh changed in May 2012
                % STEP 2:  Identify chains
                % For all xj in seeds
                while ~isempty(seeds) % Not an empty seeds
                    % current point is the first point in seeds

                    currentP = seeds(1);
                    d=distance(+a(currentP,:),+a(:,:),1);
                    % NEps(xj)= Retrieve_Neighbors(xj,Eps)
                    result = find(d <= Eps);
                    %If | NEps(xj) | >= MinPts                              // xj is a core point
                    if length(result) >= MinPts 
                        % Assign xj  to ClusterId
                        labs(currentP) = ClusterId;
                        % Add all UNCLASSIFIED in NEps(xj) to seeds
                        result_unclassified = result(find(labs(result)==UNCLASSIFIED));
                        result_noise = result(find(labs(result)==NOISE));
                        % Temperary complete the intermediate chain ... the chain can be extended in the comming steps.
                        % The border points have not yet been assigned to any cluster
                        labs([result_unclassified result_noise]) = BORDER;   % first assign to a border-point... later will be reassigned to e.g. core-point
                        seeds = union(seeds,result_unclassified);
                    end
                  % Exclude the current point in seeds and go back to the loop
                  seeds = seeds(2:size(seeds,2));
                end % end while
                % Return with expansion success 
                ExpandClusterReturn = 1;    % return true 
           end
end

function d = distance(X,Y, dosqrt)
% function d = distance(X,Y, dosqrt);
% dosqrt: default 0: No square root to reduce computation time (only for comparation perpose)
% Euclidean distance matrix between row vectors in X and Y

if nargin < 3, dosqrt = 0; end

U=~isnan(Y); Y(~U)=0;
V=~isnan(X); X(~V)=0;
if ~dosqrt d=abs(X.^2*U'+V*Y'.^2-2*X*Y');
else
    d=sqrt(X.^2*U'+V*Y'.^2-2*X*Y');
end
end