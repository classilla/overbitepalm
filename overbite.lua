--[[
-- Mode: Lua; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-
-- vim: set ts=2 sts=2 et sw=2 tw=99:

 Overbite Palm
 Copyright 2009, 2012, 2015, 2022 Cameron Kaiser. All rights reserved.
 Descended from Port-A-Goph (rip)
 Distributed under the BSD 3-clause license.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

 3. Neither the name of the copyright holder nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF/
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

]]
--

aboutstr = "Overbite Palm v0.1-prelease\n"
  .. "THIS IS A TEST VERSION ONLY.\n\n"
  .. "(c)2009-2022 Cameron Kaiser\n"
  .. "All rights reserved.\n\n"
  .. "Open source under the BSD 3-clause license."

creator = "ovRb"

-- globals
-- We prefer to use separately named arrays rather than multidimensional ones
-- because it gets around the issue with PalmOS where an individual allocation
-- in the dynamic heap cannot exceed 64K (a PalmOS limitation, not Plua).
-- By using separate arrays, every single array can get up to that size. See
-- our note about strings below, as well.

-- history
hhosts = { "gopher.floodgap.com" }
hports = { 70 }
hsels = { "" }
hargses = { "" }
hitypes = { "1" }
hselis = { 1 }
hpos = 1

-- last cached menu (helps a LOT on 68K Palms)
chosts = {}
cports = {}
csels = {}
cdses = {}
citypes = {}
cmenu = 0

-- custom events
overbiteSuppress = -927 -- dummy event
overbiteLoad = -928 -- new host selected
overbiteRepaint = -929 -- screen destroyed; needs to be rebuilt

-- library stuff

function aboutstrr()
  local u, t

  u, t = os.mem()
  return aboutstr
    .. "\n\n"
    .. "OS: "
    .. _OS_VERSION
    .. "\n"
    .. "Memory used/total: "
    .. u
    .. "K/"
    .. t
    .. "K"
end

-- generic url parser
function parsegopherurl(s)
  local q, qq, qqq, r, rr, rrr, nhost, nport, nsel, nitype, nargs

  if string.len(s) < 1 then
    return 0, "No URL entered", nil, nil, nil, nil
  end
  if string.sub(s, 1, 9) == "gopher://" then
    if string.len(s) < 10 then
      return 0, "Bogus null URL", nil, nil, nil, nil
    end
    s = string.sub(s, 10)
  end

  nhost = s
  nport = 70
  nsel = ""
  nitype = "1"
  nargs = ""

  q, r = string.find(s, ":", 1)
  qq, rr = string.find(s, "/", 1)
  qqq, rrr = string.find(s, "?", 1)
  if qqq ~= nil then
    if qq == nil then
      return 0, "Badly formed URL", nil, nil, nil, nil
    else
      if qq > qqq then
        return 0, "Badly formed URL", nil, nil, nil, nil
      end
    end
    if q ~= nil and qqq < q then
      return 0, "Badly formed URL", nil, nil, nil, nil
    end
  end
  if q ~= nil then
    if q == 1 then
      return 0, "Badly formed URL", nil, nil, nil, nil
    end
    if qq ~= nil and qq == (q + 1) then
      return 0, "Badly formed URL", nil, nil, nil, nil
    end
    if qq ~= nil and qq < q then
      nport = 70
    else
      nhost = string.sub(s, 1, q - 1)
      if qq == nil then
        nport = string.sub(s, q + 1)
      else
        nport = string.sub(s, q + 1, qq - 1)
      end
      nport = tonumber(nport)
      if nport == nil or nport < 1 or nport > 65535 then
        return 0, "Invalid port number", nil, nil, nil, nil
      end
    end
  end
  if qq ~= nil then
    if q == nil then
      nhost = string.sub(s, 1, qq - 1)
    end
    if string.len(s) > qq then
      nitype = string.sub(s, qq + 1, qq + 1)
      if string.len(s) + 1 > qq then
        nsel = string.sub(s, qq + 2)
      end
    end
  end
  qqq, rrr = string.find(nsel, "?", 1)
  if qqq ~= nil then
    if string.len(nsel) > qqq then
      nargs = string.sub(nsel, qqq + 1)
    end
    nsel = string.sub(nsel, 1, qqq - 1)
  end

  return 1, nhost, nport, nsel, nitype, nargs
end

-- update url and location
function urlandlocation()
  host = hhosts[hpos]
  port = hports[hpos]
  sel = hsels[hpos]
  itype = hitypes[hpos]
  parg = hargses[hpos]
  if parg == nil then
    parg = ""
  end

  if itype == "builtin" then
    url = ""
    return
  end

  url = host
  if port ~= 70 then
    url = url .. ":" .. port
  end
  url = url .. "/" .. itype .. sel
  if string.len(parg) > 0 then
    url = url .. "?" .. parg
  end
end

function navigateto(nhost, nport, nsel, nitype, nargs)
  cdses = dses
  chosts = hosts
  cports = ports
  citypes = itypes
  csels = sels
  cargs = argses
  cmenu = 1

  hselis[hpos] = seli
  hpos = hpos + 1
  hhosts[hpos] = nhost
  hports[hpos] = nport
  hitypes[hpos] = nitype
  hsels[hpos] = nsel
  hargses[hpos] = nargs
  hselis[hpos] = 1

  return overbiteLoad
end

function navigateback()
  if hpos > 1 then
    hpos = hpos - 1
    if (hitypes[hpos] == "1" or hitypes[hpos] == "7") and cmenu > 0 then
      -- If cached, use the cache. It's always the last menu we were in.
      -- Recover the memory as quickly as we can; we're often tight!
      -- Start with the smallest and work our way up.
      itypes = citypes
      citypes = {}
      ports = cports
      cports = {}
      hosts = chosts
      chosts = {}
      sels = csels
      csels = {}
      -- Do DSes last, so we have enough
      -- memory for both copies.
      dses = cdses
      cdses = {}
      cmenu = cmenu - 1
      urlandlocation()
      return overbiteRepaint
    else
      gui.title("Loading...")
      return overbiteLoad
    end
  else
    gui.alert("Nothing on history stack.")
    return ctlSelect
  end
end

-- handle common controls for both text and menu modes
function generalcontrols(b1, b2, b3, uf, urlf)
  if id == b1 then -- Back
    return navigateback()
  end
  if id == b2 then -- Reload
    return overbiteLoad
  end
  if id == b3 then -- Wordwrap
    u, t = os.mem()
    if (t - u) < 1024 then
      -- Warn the user about the additional memory requirements, and
      -- force a restart so everything is as clean as possible on low
      -- memory systems.
      if dowrap then
        os.setprefs(creator, 5, "false")
        gui.alert("Menu wordwrap DISABLED. Please restart.")
        os.exit()
        return appStop
      else
        resp = gui.confirm("Menu wordwrap may consume more memory. Continue?")
        if resp then
          os.setprefs(creator, 5, "true")
          gui.alert("Menu wordwrap ENABLED. Please restart.")
          os.exit()
          return appStop
        else
          return ctlSelect
        end
      end
    else
      if dowrap then
        dowrap = false
        os.setprefs(creator, 5, "false")
      else
        dowrap = true
        os.setprefs(creator, 5, "true")
      end
      return overbiteLoad
    end
  end
  if id == uf then -- Go to URL
    s = gui.gettext(urlf)
    if s == url then
      return ctlSelect
    end
    ok, nhost, nport, nsel, nitype, nargs = parsegopherurl(s)
    if ok == 0 then
      gui.alert(nhost)
      return ctlSelect
    end
    return navigateto(nhost, nport, nsel, nitype, nargs)
  end
end

function menumenu()
  -- This appears to be the maximum number of menu elements allowed.
  gui.menu({
    "About Overbite Palm",
    "H:Home gopher",
    "A:Bookmark A",
    "B:Bookmark B",
    "C:Bookmark C",
    "-",
    "Set home gopher",
    "Set bookmark A",
    "Set bookmark B",
    "Set bookmark C",
  })
end

function generalmenu(id)
  if id == 1 then
    --if itype == "1" or itype == "7" then
    return navigateto("builtin", 70, "/about", "builtin", "")
    --end
    --s = aboutstrr()
    --hitypes[hpos] = "builtin"
    --urlandlocation()
    --return overbiteRepaint
  end
  if id == 2 or id == 3 or id == 4 or id == 5 then
    nurl = homeurl
    if id == 3 then
      nurl = bookmark1
    elseif id == 4 then
      nurl = bookmark2
    elseif id == 5 then
      nurl = bookmark3
    end
    ok, nhost, nport, nsel, nitype, nargs = parsegopherurl(nurl)
    if ok == 0 then
      gui.alert(nhost)
      return menuSelect
    else
      return navigateto(nhost, nport, nsel, nitype, nargs)
    end
  end
  -- 6 is separator
  if id == 7 or id == 8 or id == 9 or id == 10 then
    if itype == "builtin" then
      gui.alert("Builtin resources cannot be used.")
      return menuSelect
    end
    os.setprefs(creator, id - 6, url)
    if id == 7 then
      homeurl = url
    elseif id == 8 then
      bookmark1 = url
    elseif id == 9 then
      bookmark2 = url
    elseif id == 10 then
      bookmark3 = url
    end
    gui.alert("Setting saved.")
    return menuSelect
  end
  return menuSelect
end

function buildui(nowrap)
  screen.moveto(0, sy)

  screen.moveto(sx)
  urlf = gui.field(2, (width - (8 * wf)) / fw, 512, url, true, true)
  gui.nl()

  screen.moveto(sx / 2)
  uf = gui.button("Go >>")
  b1 = gui.button("Back")
  b2 = gui.button("Reload")
  if nowrap == nil or nowrap == 0 then
    b3 = gui.button("Wordwrap")
  else
    b3 = nil
  end
  gui.nl()

  menumenu()
  screen.moveto(sx)
end

function debounce()
  local e, f

  e = keyDown
  -- Events don't seem to be reliably debounced with a timeout
  -- of less than 200ms.
  while 1 do
    -- keyUpEvent is 0x4000 in Palm documentation; keyHoldEvent is 0x4001.
    while e == keyDown or e == 16384 or e == 16385 do
      e = gui.event(200)
    end
    -- If a dpad key is held, we get keyDown nilEvent keyDown nilEvent etc.
    -- So we debounce that by checking again.
    e = gui.event(200)
    if e == nilEvent then
      return
    end
  end
end

screensize = 30

-- Word wrapping is hard to do fast for non-proportional fonts. 30 CPL is our
-- rule of thumb; most text will fit. If it doesn't, carve chars off the end.
-- Back off quickly so that we don't spend a lot of time on complex menus.
function wordwrap(t, s, newsize)
  local i, q, r, ns, w, h
  if newsize < 2 then
    gui.alert("ASSERTION: wordwrap size > 1 " .. s)
    table.insert(t, s)
    return ""
  end

  if string.len(s) < newsize then
    w, h = screen.textsize(s)
    if w > tw then
      return wordwrap(t, s, (newsize - 3))
    end
    table.insert(t, s)
    return ""
  end
  q, r = string.find(s, " ", 1)
  if q == nil or q > newsize then
    w, h = screen.textsize(string.sub(s, 1, newsize))
    if w > tw then
      return wordwrap(t, s, (newsize - 3))
    end
    table.insert(t, string.sub(s, 1, newsize))
    return string.sub(s, newsize + 1)
  end
  i = q + 1
  while 1 do
    q, r = string.find(s, " ", i)
    if q == nil or q > newsize then
      break
    end
    i = q + 1
  end
  w, h = screen.textsize(string.sub(s, 1, i - 2))
  if w > tw then
    return wordwrap(t, s, (newsize - 3))
  end
  table.insert(t, string.sub(s, 1, i - 2))
  return string.sub(s, i)
end

-- init and load prefs

homeurl = os.getprefs(creator, 1)
if homeurl == nil then
  homeurl = "gopher.floodgap.com"
end
bookmark1 = os.getprefs(creator, 2)
bookmark2 = os.getprefs(creator, 3)
bookmark3 = os.getprefs(creator, 4)
if bookmark1 == nil then
  bookmark1 = "gopher.floodgap.com"
end
if bookmark2 == nil then
  bookmark2 = "gopher.floodgap.com"
end
if bookmark3 == nil then
  bookmark3 = "gopher.floodgap.com"
end
ok, nhost, nport, nsel, nitype, nargs = parsegopherurl(homeurl)
if ok == 0 then
  gui.alert("Home URL is bad, using default: " .. nhost)
  homeurl = "gopher.floodgap.com"
else
  hhosts[hpos] = nhost
  hports[hpos] = nport
  hsels[hpos] = nsel
  hitypes[hpos] = nitype
  hargses[hpos] = nargs
end
os.setprefs(creator, 1, homeurl)
os.setprefs(creator, 2, bookmark1)
os.setprefs(creator, 3, bookmark2)
os.setprefs(creator, 4, bookmark3)

dowrap = os.getprefs(creator, 5)
if dowrap == nil then
  -- default. if we have less than 128K of memory free, don't wrap by default.
  -- It uses substantial amounts of memory to build that list, and it's slower.
  dowrap = true
  u, t = os.mem()
  if (t - u) < 1024 then
    dowrap = false
  end
else
  if dowrap == "false" then
    dowrap = false
  else
    dowrap = true
  end
end
if dowrap then
  os.setprefs(creator, 5, "true")
else
  os.setprefs(creator, 5, "false")
end

-- main program

gui.title("Overbite Palm is starting...")
width, height, depth, hasColor = screen.mode()
fw, fh = screen.font(0)
hf = height / 160
wf = width / 160
sy = 20 * hf
sx = 4 * wf
tw = width - (24 * wf)

ctev = overbiteLoad

-- main loop

while true do
  s = ""

  if ctev == overbiteLoad then
    urlandlocation()
    -- Make a guess at how much we can load into memory.
    -- Some PalmOS devices may be very limited on dynamic heap,
    -- particularly PalmOS 4 systems. Assign a reasonable
    -- maximum. Bail if less than 2K is available.
    --
    -- Since the cache is usually aliased to the current
    -- menu in memory, clearing it not only is unprofitable,
    -- but clearing itypes/dses/etc. wipes the cache. Sadly,
    -- there isn't much we can do to free additional memory
    -- if we're short.
    u, t = os.mem()
    kfree = math.floor((t - u) / 8)
    -- The text gadget seems to double memory requirements.
    if itype == "0" then
      kfree = math.floor(kfree / 2)
    end
    bfree = kfree * 1024
    if kfree < 2 then
      gui.alert("Out of memory")
    end

    -- fetch from network

    if kfree < 2 or (itype ~= "0" and itype ~= "1" and itype ~= "7") then
      s = "Overbite Palm does not support this item type."
      if itype == "builtin" then
        s = aboutstrr()
      end
      if kfree < 2 then
        itype = "builtin"
        s = "Not enough memory to display ("
          .. u
          .. "K used of "
          .. t
          .. "K)\n\nWeird things may start happening.\n"
      end
      -- opens in text mode
    else
      eh, et, es = io.open("tcp:/" .. host .. ":" .. port, "rw")
      if eh == nil then
        gui.alert("ack! " .. et)
      else
        if string.len(parg) > 0 then
          eh:write(sel .. "\t" .. parg .. "\r\n")
        else
          eh:write(sel .. "\r\n")
        end
        while true do
          ev = gui.event()
          if ev == ioPending then
            buf = eh:read(1024)
            if buf == nil then
              break
            else
              buf = string.gsub(buf, "\r", "")
              s = s .. buf
              gui.title(string.len(s) .. " bytes read")

              -- On low memory systems, truncate instead of abort.
              if itype == "0" and string.len(s) >= bfree then
                s = "[Truncated to " .. kfree .. "K.]\n" .. s
                break
              end
              if string.len(s) >= bfree then
                s = "iTruncated menu to "
                  .. kfree
                  .. "K.\t\terror.host\t1\ni \t\terror.host\t1\n"
                  .. s
                break
              end
            end
          end
          if ev == appStop or ev == keyDown then
            break
          end
        end
        eh:close()
      end
    end
    gui.title("Processing...")
  end

  -- display on screen

  if (itype == "1") or (itype == "7") then
    if ctev == overbiteLoad then
      itypes = {}
      dses = {}
      sels = {}
      hosts = {}
      ports = {}
      argses = {}
      pos = 1
      -- This will bail at the slightest sign of trouble.
      while 1 do
        -- find next newline
        q, r = string.find(s, "\n", pos)
        if q == nil then
          break
        end
        p = string.sub(s, pos, q - 1)
        pos = r + 1
        remm = ""

        -- split into five fields
        q, r = string.find(p, "\t", 1)
        if q == nil or q < 2 then
          break
        end
        this_itype = string.sub(p, 1, 1)
        table.insert(itypes, this_itype)
        if q == 2 then
          table.insert(dses, "")
        else
          leader = this_itype .. "> "
          if this_itype == "i" then
            leader = "    "
          end
          if dowrap then
            remm = wordwrap(
              dses,
              leader .. string.sub(p, 2, q - 1),
              screensize
            )
          else
            table.insert(dses, leader .. string.sub(p, 2, q - 1))
          end
        end
        if this_itype ~= "i" then
          -- only process if this is a selectable menu item.
          r = r + 1
          t = r
          q, r = string.find(p, "\t", r)
          if q == nil then
            table.insert(sels, "")
            table.insert(hosts, "")
            table.insert(ports, 0)
            break
          end
          if t == q then
            table.insert(sels, "")
          else
            -- XXX: store only the unique part of the selector?
            table.insert(sels, string.sub(p, t, q - 1))
          end
          r = r + 1
          t = r
          q, r = string.find(p, "\t", r)
          if q == nil or t == q then
            table.insert(hosts, "")
            table.insert(ports, 0)
            break
          end
          pn = tonumber(string.sub(p, q + 1))
          if pn == nil or pn < 1 or pn > 65535 then
            table.insert(hosts, "")
            table.insert(ports, 0)
          else
            -- Try to conserve memory. If it's same host:port,
            -- put in a dummy value.
            hn = string.sub(p, t, q - 1)
            if hn == host and pn == port then
              table.insert(hosts, "")
              table.insert(ports, -999)
            else
              table.insert(hosts, string.sub(p, t, q - 1))
              table.insert(ports, pn)
            end
          end
        else
          table.insert(sels, "")
          table.insert(hosts, "")
          table.insert(ports, 0)
        end

        while string.len(remm) > 0 do
          remm = wordwrap(dses, remm, screensize)
          table.insert(itypes, "i")
          table.insert(sels, "")
          table.insert(hosts, "")
          table.insert(ports, 0)
        end
      end
    end

    gui.destroy()
    gui.title("Overbite Palm: Menu")
    buildui()

    mlist = gui.list((height - (72 * hf)) / fh, (width - (8 * wf)) / fw, dses)
    gui.nl()
    seli = hselis[hpos]
    if table.getn(dses) > 0 then
      if seli > table.getn(dses) then
        seli = 1
      end
      gui.setstate(mlist, seli)
    end

    -- event loop for menu

    lastsel = -1
    ev = nilEvent
    while true do
      ev, id, arg = gui.event()
      if ev == menuSelect then
        ev = generalmenu(id)
        lastsel = -1
      end
      if (ev == ctlSelect) and (ev ~= lstSelect) then
        lastsel = -1
        ev = generalcontrols(b1, b2, b3, uf, urlf)
      end
      if ev == keyDown then
        -- 11 = up
        -- 12 = down
        -- 310/7 = centre
        -- 308 = left
        -- 309 = right
        -- 516 = home
        -- 517 = calendar
        -- 518 = contacts
        -- 519 = web
        --
        -- Dana: 10/30/31 (conventional keys)
        --
        -- Dana throws an 8192 for undefined keys.
        if id < 512 or id == 8192 then
          ev = overbiteSuppress
        end

        -- Up down
        if (id == 12 or id == 31) and seli < table.getn(dses) then
          seli = seli + 1
          gui.setstate(mlist, seli)
        end
        if (id == 11 or id == 30) and seli > 1 then
          seli = seli - 1
          gui.setstate(mlist, seli)
        end

        -- Left as back
        -- Don't use Dana's keys here; they might be seen on the URL field.
        if id == 308 then
          debounce()
          ev = navigateback()
        end

        -- Centre
        -- Zire 72 uses 310
        -- TX uses 317
        if id == 310 or id == 317 or id == 10 then
          debounce()
          arg = seli
          lastsel = seli
          ev = lstSelect
        end
      end
      if ev == lstSelect then
        seli = arg
        if lastsel == arg then
          if itypes[lastsel] == "i" or ports[lastsel] == 0 then
            gui.alert(dses[lastsel])
          elseif
            itypes[lastsel] == "0"
            or itypes[lastsel] == "1"
            or itypes[lastsel] == "7"
          then
            if itypes[lastsel] ~= "7" then
              nhost = hosts[lastsel]
              nport = ports[lastsel]
              if nport == -999 then
                nhost = host
                nport = port
              end
              resp = gui.confirm(
                dses[lastsel]
                  .. "\n\nContinue to? "
                  .. nhost
                  .. ":"
                  .. nport
                  .. "/"
                  .. itypes[lastsel]
                  .. sels[lastsel]
              )
            else
              resp = gui.input("Enter parameters")
            end
            if resp then
              nargs = ""
              if itypes[lastsel] == "7" then
                nargs = resp
              end
              gui.title("Loading...")
              ev = navigateto(
                nhost,
                nport,
                sels[lastsel],
                itypes[lastsel],
                nargs
              )
            end
          else
            -- give up
            gui.alert(
              dses[lastsel]
                .. "\n\nOverbite does not support item type "
                .. itypes[lastsel]
                .. "."
            )
          end
          lastsel = -1
        else
          lastsel = arg
        end
      end
      if ev == appStop or ev == keyDown or ev <= overbiteLoad then
        break
      end
    end

    if ev == appStop or ev == keyDown then
      break
    end
    -- overbiteLoad cycles the loop
  else
    gui.destroy()
    if itype == "0" then
      gui.title("Overbite Palm: Text")
    else
      gui.title("Overbite Palm")
    end

    buildui(1)

    -- leave room for scrollbar
    tfield = gui.field(
      (height - (72 * hf)) / fh,
      (width - (12 * wf)) / fw,
      string.len(s),
      s,
      nil,
      nil
    )
    gui.setfocus(tfield)
    seli = 1
    gui.setstate(tfield, seli)

    -- event loop for text

    ev = nilEvent
    while true do
      ev, id, arg = gui.event()
      if ev == menuSelect then
        ev = generalmenu(id)
      end
      if ev == ctlSelect then
        ev = generalcontrols(b1, b2, b3, uf, urlf)
      end
      if ev == keyDown then
        if id < 512 or id == 8192 then
          ev = overbiteSuppress
        end

        if (id == 11 or id == 30) and seli > 1 then
          seli = seli - 35
          if seli < 1 then
            seli = 1
          end
          gui.setstate(tfield, seli)
        end
        if id == 12 or id == 31 then
          seli = seli + 35
          if seli > string.len(s) then
            sel = string.len(s)
          end
          gui.setstate(tfield, seli)
        end

        -- Left as back
        -- Don't use Dana's keys here; they might be seen on the URL field.
        if id == 308 then
          debounce()
          ev = navigateback()
        end
      end
      if ev == appStop or ev == keyDown or ev <= overbiteLoad then
        break
      end
    end

    if ev == appStop or ev == keyDown then
      break
    end
  end

  ctev = ev -- remember our event
end

-- exit to launcher
gui.destroy()
