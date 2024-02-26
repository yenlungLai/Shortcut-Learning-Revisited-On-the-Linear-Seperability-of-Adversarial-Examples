
clear all

avgs=[];
for n=[6000 7000 8000 9000 10000 ]

k=512; nter=50; %nter is the number of layer L, k is outputsize 512
margin=0.0;
recc=[];
for jj=1:1000  % generate 1000 random pair
   [v, u] = generateOrthogonalVectors(k); % generate vector u and v othogonal to each other
   v=randn(1,512);
   u=randn(1,512);

    ii=1;
  
    % Create variables to store old values
    old_u = u;
    old_v = v;



    u = u/norm(u);  % Normalize the vector
    v= v/norm(v);  % Normalize the vector


    initt=acos(dot(u, v))/pi; % compute their initial angle different, uncomment other for eucledian or hamming distances
%     initt=sum(sign(u)~=sign(v))/512; %compute normalized hamming distance
%     initt=norm(u-v)^2/4; %computed normalized euclidian distance
    while ii < nter  % now go into layer by layer (main algorithm)

        % Encoding for u
        [reduced_codeword,reduced_matrix]=Encoding(u',n,k); % Encoding is the linear neuaral network derivation, output the matrices W_l as reduced_matrix 
        fu1=reduced_codeword';
        u=fu1;

        % Projection for v
        fu2=reduced_matrix*(v');
        fu2=fu2';
        v=fu2;

        ii=ii+1;


        u = u/norm(u);  % Normalize the vector
        v = v/norm(v);  % Normalize the vector
        
        
        dis=acos(dot(u, v))/pi; % compute their transformed angle different, uncomment other for eucledian or hamming distances
%         dis=norm(u-v)^2/4;   %computed normalized hamming distance
%         dis=sum(sign(u)~=sign(v))/512; %computed normalized euclidian distance
      
        pointr=[pointr;dis];

      
        % Store current points as old points for the next iteration
        old_u = u;
        old_v = v;
    end


    % proces the stored data
    pointrR{jj}=pointr;
    indc=pointr(length(pointr));
    rec1=[initt, indc];
    recc=[recc;rec1];

    
end


beforet=recc(:,1);
aftert=recc(:,2);
scale=0;
for i=1: length(beforet)
    
    bfo=beforet(i); afo=aftert(i);
  % compute the marginal error, equal to total scale/ number of point
  % (1000)
    if (bfo<0.5-margin && afo>0.5) || (bfo>0.5+margin && afo<0.5)
    scale=scale+1;
    scale
    else


    end
end
avg=scale/1000; 

avgs=[avgs;avg]; % marginal error for various  n=[6000 7000 8000 9000 10000 ]

end

























function [yfil,frmat]=Encoding(x,n,t)
k=length(x);

rmat=randn(n,k);
% rmat=orth(rmat);
y=rmat*x;
absy=abs(y);
[sorted_data, sortedindex ]= sort(absy, 'descend');
topindex=(sortedindex(1:t));
frmat=rmat(topindex,:);

yfil=y(topindex);

end

% 
% 

function [u, v] = generateOrthogonalVectors(m)
    u = randn(1, m);  % Generate the first vector u
    u = u / norm(u);  % Normalize u

    % Generate a random angle in radians
    angle = rand() * 2 * pi;  % Angle in [0, 2*pi]
    
    % Create a rotation matrix
    R = getRotationMatrix(angle, m);  % Using a helper function
    
    % Rotate u to obtain v
    v = (R * u')';

    % Ensure v is orthogonal to u
    v = v - dot(u, v) / dot(u, u) * u;
    
    % Normalize the vectors
    v = v / norm(v);

end

function R = getRotationMatrix(angle, dim)
    R = zeros(dim, dim);
    for k = 1:dim
        for l = 1:dim
            if k == l
                R(k, l) = cos(angle);
            else
                R(k, l) = -sin(angle);
            end
        end
    end
    % Extend for higher dimensions if needed
end
