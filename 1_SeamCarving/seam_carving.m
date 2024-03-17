%   Copyright  2024, Renjie Chen @ USTC


%% read image
im = imread('peppers.png');

%% draw 2 copies of the image
fig=figure('Units', 'pixel', 'Position', [100,100,1000,700], 'toolbar', 'none');
subplot(121); imshow(im); title({'Input image'});
subplot(122); himg = imshow(im*0); title({'Resized Image', 'Use the blue button to resize the input image'});
hToolResize = uipushtool('CData', reshape(repmat([0 0 1], 100, 1), [10 10 3]), 'TooltipString', 'apply seam carving method to resize image', ...
                        'ClickedCallback', @(~, ~) set(himg, 'cdata', seam_carve_image(im, size(im,1:2)-[0 100])));

%% TODO: implement function: searm_carve_image
% check the title above the image for how to use the user-interface to resize the input image
function im = seam_carve_image(im, sz)

% im = imresize(im, sz);

costfunction = @(im) sum( imfilter(im, [0.5 1 0.5; 1 -6 1; 0.5 1 0.5]).^2, 3 );

k = size(im,2) - sz(2);
for i = 1:k
    G = costfunction(im);
    %% find a seam in G
    [n, m] = size(im, 1:2);
    
    prev = zeros(n, m, 'int32');
    F = zeros(n, m);
    for r = 2:n
        for c = 1:m
            F(r, c) = F(r-1, c);
            if c>1 && F(r-1, c-1) < F(r, c)
                F(r, c) = F(r-1, c-1);
                prev(r, c) = -1;
            end
            if c<m && F(r-1, c+1) < F(r, c)
                F(r, c) = F(r-1, c+1);
                prev(r, c) = 1;
            end
            F(r, c) = F(r, c) + G(r, c);
        end
    end
    
    now = 1;
    val = F(n, 1);
    for c = 1:m
        if F(n, c) < val
            val = F(n, c);
            now = c;
        end
    end

    pos = zeros(n);
    for r = n:-1:1
        pos(r) = now;
        now = now + prev(r, now);
        if now<1 || now>m
            error('Postition excess');
        end
    end
    
    %% remove seam from im
    newim = zeros(n, m-1, 3, 'uint8');
    for r = 1:n
        for c = 1:(pos(r)-1)
            newim(r, c, 1) = im(r, c, 1);
            newim(r, c, 2) = im(r, c, 2);
            newim(r, c, 3) = im(r, c, 3);
        end
        for c = pos(r):(m-1)
            newim(r, c, 1) = im(r, c+1, 1);
            newim(r, c, 2) = im(r, c+1, 2);
            newim(r, c, 3) = im(r, c+1, 3);
        end
    end
    im = newim;

end

end