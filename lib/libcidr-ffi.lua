local ffi = require("ffi")
ffi.cdef[[
typedef struct {
  int     version;
  uint8_t addr[16];
  uint8_t mask[16];
  int     proto;
} CIDR;
CIDR *cidr_from_str(const char *);
char *cidr_to_str(const CIDR *, int);
int cidr_contains(const CIDR *, const CIDR *);
void cidr_free(CIDR *);
void free(void *);
]]

local cidr = ffi.load("cidr")

local lshift = bit.lshift

local errs = {
  EINVAL = 22,
  ENOENT = 2,
  ENOMEM = 12,
  EFAULT = 14,
  EPROTO = 71,
}

local _M = {
  _VERSION = "0.1.3"
}

_M.flags = {
  NOFLAGS     = 0,
  NOCOMPACT   = 1, -- Don't do :: compaction
  VERBOSE     = lshift(1, 1), -- Don't minimize leading zeros
  USEV6       = lshift(1, 2), -- Use v6 form for v4 addresses
  USEV4COMPAT = lshift(1, 3), -- Use v4-compat rather than v4-mapped
  NETMASK     = lshift(1, 4), -- Show netmask instead of pflen
  ONLYADDR    = lshift(1, 5), -- Only show the address
  ONLYPFLEN   = lshift(1, 6), -- Only show the pf/mask
  WILDCARD    = lshift(1, 7), -- Show wildcard-mask instead of netmask
  FORCEV6     = lshift(1, 8), -- Force treating as v6 address
  FORCEV4     = lshift(1, 9), -- Force treating as v4 address
  REVERSE     = lshift(1, 10), -- Return a DNS PTR name
}

function _M.from_str(string)
  local result = cidr.cidr_from_str(string)
  if result == nil then
    local errno = ffi.errno()
    if errno == errs.EFAULT then
      return nil, "Passed NULL"
    elseif errno == errs.EINVAL then
      return nil, "Can't parse the input string"
    elseif errno == errs.ENOENT then
      return nil, "Internal error"
    end
  end

  result = ffi.gc(result, cidr.cidr_free)

  return result
end

function _M.to_str(struct, flags)
  if type(struct) ~= "cdata" then
    return nil, "Invalid argument (bad block or flags)"
  end

  if type(flags) ~= "number" then
    flags = 0
  end

  local result = cidr.cidr_to_str(struct, flags)
  if result == nil then
    local errno = ffi.errno()
    if errno == errs.EINVAL then
      return nil, "Invalid argument (bad block or flags)"
    elseif errno == errs.ENOENT then
      return nil, "Internal error"
    elseif errno == errs.ENOMEM then
      return nil, "malloc() failed"
    end
  end

  local string = ffi.string(result)
  ffi.C.free(result)

  return string
end

function _M.contains(big, little)
  if big == nil or little == nil then
    return nil, "Passed NULL"
  elseif type(big) ~= "cdata" or type(little) ~= "cdata" then
    return nil, "Invalid argument"
  end

  local result = cidr.cidr_contains(big, little)
  if result == 0 then
    return true
  else
    local errno = ffi.errno()
    if errno == errs.EFAULT then
      return nil, "Passed NULL"
    elseif errno == errs.EINVAL then
      return nil, "Invalid argument"
    elseif errno == errs.ENOENT then
      return nil, "Internal error"
    elseif errno == errs.EPROTO then
      return nil, "Protocols don't match"
    end

    return false
  end
end

return _M
