function ret = normalized_corr(x, c)
[ndata, dimx] = size(x);
[ncentres, dimc] = size(c);
if dimx ~= dimc
	error('Data dimension does not match dimension of centres')
end

x1 = x-mean(x);
c1 = c-mean(c);
x2 = x1/sumsqr(x1);
c2 = c1/sumsqr(c1);
ret = x2*c2';
