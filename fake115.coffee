`// ==UserScript==
// @name         fake 115Browser
// @namespace    http://github.com/kkHAIKE/fake115
// @version      1.3.9
// @description  伪装115浏览器
// @author       kkhaike
// @match        *://115.com/*
// @grant        GM_xmlhttpRequest
// @grant        unsafeWindow
// @grant        GM_log
// @connect      proapi.115.com
// @require      https://rawgit.com/kkHAIKE/jsencrypt/balabala/bin/jsencrypt.js
// @require      https://cdn.bootcdn.net/ajax/libs/blueimp-md5/2.18.0/js/md5.min.js
// @run-at       document-start
// ==/UserScript==
(function() {
    'use strict'`

g_kts = [
    0xF0, 0xE5, 0x69, 0xAE, 0xBF, 0xDC, 0xBF, 0x5A, 0x1A, 0x45, 0xE8, 0xBE, 0x7D, 0xA6, 0x73, 0x88,
    0xDE, 0x8F, 0xE7, 0xC4, 0x45, 0xDA, 0x86, 0x94, 0x9B, 0x69, 0x92, 0x0B, 0x6A, 0xB8, 0xF1, 0x7A,
    0x38, 0x06, 0x3C, 0x95, 0x26, 0x6D, 0x2C, 0x56, 0x00, 0x70, 0x56, 0x9C, 0x36, 0x38, 0x62, 0x76,
    0x2F, 0x9B, 0x5F, 0x0F, 0xF2, 0xFE, 0xFD, 0x2D, 0x70, 0x9C, 0x86, 0x44, 0x8F, 0x3D, 0x14, 0x27,
    0x71, 0x93, 0x8A, 0xE4, 0x0E, 0xC1, 0x48, 0xAE, 0xDC, 0x34, 0x7F, 0xCF, 0xFE, 0xB2, 0x7F, 0xF6,
    0x55, 0x9A, 0x46, 0xC8, 0xEB, 0x37, 0x77, 0xA4, 0xE0, 0x6B, 0x72, 0x93, 0x7E, 0x51, 0xCB, 0xF1,
    0x37, 0xEF, 0xAD, 0x2A, 0xDE, 0xEE, 0xF9, 0xC9, 0x39, 0x6B, 0x32, 0xA1, 0xBA, 0x35, 0xB1, 0xB8,
    0xBE, 0xDA, 0x78, 0x73, 0xF8, 0x20, 0xD5, 0x27, 0x04, 0x5A, 0x6F, 0xFD, 0x5E, 0x72, 0x39, 0xCF,
    0x3B, 0x9C, 0x2B, 0x57, 0x5C, 0xF9, 0x7C, 0x4B, 0x7B, 0xD2, 0x12, 0x66, 0xCC, 0x77, 0x09, 0xA6
]

g_key_s = [
  0x29, 0x23, 0x21, 0x5E
]

g_key_l = [
  0x42, 0xDA, 0x13, 0xBA, 0x78, 0x76, 0x8D, 0x37, 0xE8, 0xEE, 0x04, 0x91
]

m115_getkey = (length, key) ->
  if key?
    return (((key[i] + g_kts[length * i]) & 0xff) ^ g_kts[length * (length - 1 - i)] for i in [0...length])
  if length is 12
    return g_key_l[..]
  return g_key_s[..]

xor115_enc = (src, srclen, key, keylen) ->
  mod4 = srclen % 4
  ret = []
  if mod4 isnt 0
    for i in [0...mod4]
      ret.push src[i] ^ key[i % keylen]
  for i in [mod4...srclen]
    ret.push src[i] ^ key[(i - mod4) % keylen]
  return ret

m115_sym_encode = (src, srclen, key1, key2) ->
  k1 = m115_getkey 4, key1
  k2 = m115_getkey 12, key2
  ret = xor115_enc src, srclen, k1, 4
  ret.reverse()
  ret = xor115_enc ret, srclen, k2, 12
  return ret

m115_sym_decode = (src, srclen, key1, key2) ->
  k1 = m115_getkey 4, key1
  k2 = m115_getkey 12, key2
  ret = xor115_enc src, srclen, k2, 12
  ret.reverse()
  ret = xor115_enc ret, srclen, k1, 4
  return ret

stringToBytes = (s) ->
  ret = []
  for i in [0...s.length]
    ret.push s.charCodeAt i
  return ret

bytesToString = (b) ->
  ret = ''
  for i in b
    ret += String.fromCharCode i
  return ret

prsa = new JSEncrypt()
prsa.setPublicKey """
  -----BEGIN RSA PUBLIC KEY-----
  MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDR3rWmeYnRClwLBB0Rq0dlm8Mr
  PmWpL5I23SzCFAoNpJX6Dn74dfb6y02YH15eO6XmeBHdc7ekEFJUIi+swganTokR
  IVRRr/z16/3oh7ya22dcAqg191y+d6YDr4IGg/Q5587UKJMj35yQVXaeFXmLlFPo
  kFiz4uPxhrB7BGqZbQIDAQAB
  -----END RSA PUBLIC KEY-----
  """
srsa = new JSEncrypt()
srsa.setPrivateKey """
  -----BEGIN RSA PRIVATE KEY-----
  MIICXAIBAAKBgQCMgUJLwWb0kYdW6feyLvqgNHmwgeYYlocst8UckQ1+waTOKHFC
  TVyRSb1eCKJZWaGa08mB5lEu/asruNo/HjFcKUvRF6n7nYzo5jO0li4IfGKdxso6
  FJIUtAke8rA2PLOubH7nAjd/BV7TzZP2w0IlanZVS76n8gNDe75l8tonQQIDAQAB
  AoGANwTasA2Awl5GT/t4WhbZX2iNClgjgRdYwWMI1aHbVfqADZZ6m0rt55qng63/
  3NsjVByAuNQ2kB8XKxzMoZCyJNvnd78YuW3Zowqs6HgDUHk6T5CmRad0fvaVYi6t
  viOkxtiPIuh4QrQ7NUhsLRtbH6d9s1KLCRDKhO23pGr9vtECQQDpjKYssF+kq9iy
  A9WvXRjbY9+ca27YfarD9WVzWS2rFg8MsCbvCo9ebXcmju44QhCghQFIVXuebQ7Q
  pydvqF0lAkEAmgLnib1XonYOxjVJM2jqy5zEGe6vzg8aSwKCYec14iiJKmEYcP4z
  DSRms43hnQsp8M2ynjnsYCjyiegg+AZ87QJANuwwmAnSNDOFfjeQpPDLy6wtBeft
  5VOIORUYiovKRZWmbGFwhn6BQL+VaafrNaezqUweBRi1PYiAF2l3yLZbUQJAf/nN
  4Hz/pzYmzLlWnGugP5WCtnHKkJWoKZBqO2RfOBCq+hY4sxvn3BHVbXqGcXLnZPvo
  YuaK7tTXxZSoYLEzeQJBAL8Mt3AkF1Gci5HOug6jT4s4Z+qDDrUXo9BlTwSWP90v
  wlHF+mkTJpKd5Wacef0vV+xumqNorvLpIXWKwxNaoHM=
  -----END RSA PRIVATE KEY-----
  """

m115_asym_encode = (src, srclen) ->
  m = 128 - 11
  ret = ''
  for i in [0...(srclen + m - 1) // m]
    ret += window.atob prsa.encrypt bytesToString src[i * m...Math.min((i + 1) * m, srclen)]
  return window.btoa ret

m115_asym_decode = (src, srclen) ->
  m = 128
  ret = ''
  for i in [0...(srclen + m - 1) // m]
    ret += srsa.decrypt window.btoa bytesToString src[i * m...Math.min((i + 1) * m, srclen)]
  return stringToBytes ret

m115_encode = (src, tm) ->
  key = stringToBytes md5 "!@###@##{tm}DFDR@#@#"
  tmp = stringToBytes src
  tmp = m115_sym_encode tmp, tmp.length, key, null
  tmp = key[0...16].concat tmp
  return {data:m115_asym_encode(tmp, tmp.length), key}

m115_decode = (src, key) ->
  tmp = stringToBytes window.atob src
  tmp = m115_asym_decode tmp, tmp.length
  return bytesToString m115_sym_decode tmp[16..], tmp.length - 16, key, tmp[0...16]

CreateDownloadTask_ = (f, cb) ->
  tmus = (new Date()).getTime()
  tm = tmus // 1000

  {data, key} = m115_encode JSON.stringify(
    pickcode: f.pc
    ), tm

  GM_xmlhttpRequest
    method: 'POST'
    url: "http://proapi.115.com/app/chrome/downurl?t=#{tm}"
    data: "data=#{encodeURIComponent(data)}"
    headers:
      'Content-Type': 'application/x-www-form-urlencoded'
    onload: (response)->
      json = JSON.parse response.responseText
      if not json.state
        alert json.msg
      else
        cb JSON.parse m115_decode json.data, key

CreateDownloadTask = (o) ->
  rs = []
  n = 0
  cb = (r) ->
    for x of r
      rs.push r[x]
      break

    if rs.length is n
      GM_log rs

      con = $ '<ul/>'
      for f in rs
        con.append "<li><a href='#{f.url.url}'>#{f.file_name}</a></li>"

      win = new Core.DialogBase
        title: '文件下载'
        content: con
        width: 530
      win.Open null

  for f in o.list
    if not f.is_dir
      n++
      CreateDownloadTask_ f, cb

browserInterface = unsafeWindow.browserInterface ? {}
browserInterface.CreateDownloadTask = (s) ->
  try
    CreateDownloadTask JSON.parse decodeURIComponent s
  catch error
    GM_log "#{error.message}\n#{error.stack}"

if typeof cloneInto isnt 'function'
  cloneInto = (x) -> x

unsafeWindow.browserInterface = cloneInto browserInterface, unsafeWindow, {cloneFunctions: true}

`})()`