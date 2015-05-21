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
]]

local cidr = ffi.load("cidr")

local errs = {
  EINVAL = 22,
  ENOENT = 2,
  ENOMEM = 12,
  EFAULT = 14,
  EPROTO = 71,
}

local _M = {}

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

  return result
end

function _M.to_str(string)
  local result = cidr.cidr_to_str(string, 0)
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

  return result
end

function _M.contains(big, little)
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
