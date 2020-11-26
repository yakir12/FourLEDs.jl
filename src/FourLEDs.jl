module FourLEDs

using GtkReactive, Gtk.ShortNames, LibSerialPort, COBS

export main

baudrate = 115200
portfile = joinpath(DEPOT_PATH[1], "fourledsport")

function connect_slider(sp, id)
    sl = slider(0x00:0xff, value = 0x00)
    h = map(sl) do i
        encode(sp, [id, i])
    end
    return sl
end

function get_current_port_list(vb, msg, ok, win)
    hb = Box(:h)
    push!(vb, hb)
    msg = label(msg)
    ok = button(ok)
    push!(hb, msg)
    push!(hb, ok)
    ports = map(ok) do _
        LibSerialPort.get_port_list()
    end
    Gtk.showall(win)
    c = Condition()
    h = map(ok) do _
        notify(c)
    end
    wait(c)
    destroy(hb)
    return value(ports)
end

function get_port(vb, win)
    without = get_current_port_list(vb, "Is the LED strip disconnected?", "Yes", win)
    with = get_current_port_list(vb, "Now, connect the LED strip", "OK", win)
    port =  only(setdiff(with, without))
    open(portfile, "w") do o
        println(o, port)
    end
    return port
end

function get_sp(vb, win)
    if isfile(portfile) 
        port = readline(portfile) 
        try 
            sp = LibSerialPort.open(port, baudrate)
            return sp
        catch ex
            rm(portfile)
        end
    end
    port = get_port(vb, win)
    sleep(1)
    return LibSerialPort.open(port, baudrate)
end


function main()
    win = Window("FourLEDs") 
    vb = Box(:v)
    push!(win, vb)

    sp = get_sp(vb, win)

    for i in 0x00:0x03
        push!(vb, connect_slider(sp, i))
    end

    Gtk.showall(win)

    if !isinteractive()
        Gtk.waitforsignal(win, :destroy)
        close(sp)
    else
        signal_connect(win, :destroy) do widget
            close(sp)
        end
    end

    nothing

end

end

