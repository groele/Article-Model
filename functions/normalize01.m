function y = normalize01(x)
%NORMALIZE01  Rescale array to [0, 1] range.
%  y = (x − min(x)) / (max(x) − min(x))
%  A small eps is added to the denominator to avoid division by zero
%  when x is constant.
x = x(:);
y = (x - min(x)) ./ (max(x) - min(x) + eps);
end
