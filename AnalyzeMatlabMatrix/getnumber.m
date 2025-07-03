function num = getnumber(varargin)
%FNC  Pack N bytes (little‑endian) into one integer
%   num = FNC(b0, b1, b2, ..., bN‑1) treats b0 as the low byte,
%   b1 as the next, etc., and returns
%     num = b0 + b1·256 + b2·256^2 + ⋯ + bN‑1·256^(N‑1).
%
%   Example:
%     fnc(0x20,0x01)   returns 0x0120
%     fnc(0x20,0x01,0x03,0x10) returns [0x0120, 0x1003]? No—
%       it packs *all* four into one:
%       0x10·256^3 + 0x03·256^2 + 0x01·256^1 + 0x20·256^0 = 0x10030120

    % collect inputs as a row vector of uint64
    bytes = uint64([varargin{:}]);
    % exponents 0:(N-1)
    exps  = uint64(0:numel(bytes)-1);
    % compute sum(bytes(i)*256^exps(i))
    num   = sum( bytes .* ( uint64(256) .^ exps ) );
    

end
