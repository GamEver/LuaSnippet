module('https', package.seeall)

local ffi = require 'ffi'

ffi.cdef[[
	int curl_global_init(long flags );
    void *curl_easy_init();
    int curl_easy_setopt(void *curl, int option, ...);
    int curl_easy_perform(void *curl);
    void curl_easy_cleanup(void *curl);
    char *curl_easy_strerror(int code);
]]

local libcurl = ffi.load('libcurl')
assert(libcurl)

local CURLOPT_URL = 10002
local CURLOPT_WRITEFUNCTION = 20011

local CURLOPT_SSL_VERIFYPEER = 64
local CURLOPT_SSL_VERIFYHOST = 81

function get(url)
	local result = nil
	local function process_data(a,b,c,d)
		result = ffi.string(a, b*c)
	end
	local fptr = ffi.cast("void (*)(char *, size_t, size_t, void *)", process_data)

	local curl = libcurl.curl_easy_init()
	if curl then
		libcurl.curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0);
		libcurl.curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0);
		libcurl.curl_easy_setopt(curl, CURLOPT_URL, url)
		libcurl.curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, fptr)
		libcurl.curl_easy_perform(curl)
		libcurl.curl_easy_cleanup(curl)
	end
	return result
end
