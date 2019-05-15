
function compress(data)
    local compress = zlib.deflate()
    local deflated, compress_eof, compress_in, compress_out
	deflated, compress_eof, compress_in, compress_out = compress(data, "finish")
    -- if _G.isLocalDevelopMode then printx(0, "compress " .. compress_in .. " " .. compress_out, compress_eof) end
	if deflated == false then
		assert(false, "compress error:"..tostring(compress_eof)..",data:"..tostring(data))
		return nil
	else
		return deflated
	end
end

function uncompress(data)
    local uncompress = zlib.inflate()
    local inflated, uncompress_eof, uncompress_in, uncompress_out
	inflated, uncompress_eof, uncompress_in, uncompress_out = uncompress(data, "finish")
	if inflated == false then
		assert(false, "uncompress error:"..tostring(uncompress_eof)..",data:"..tostring(data))
		return nil
	else
		return inflated
	end
end
