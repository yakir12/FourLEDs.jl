module FourLEDs

using GtkReactive, Gtk.ShortNames, LibSerialPort, COBS

export main

baudrate = 115200

function get_port()
    for port in LibSerialPort.get_port_list()
        try 
            sp = LibSerialPort.open(port, baudrate)
            sleep(3)
            encode(sp, [0x00,0x00])
            return sp
        catch ex
        end
    end
    return nothing
end

function connect_slider(sp, id)
    sl = slider(0x00:0xff, value = 0x00)
    h = map(sl) do i
        encode(sp, [id, i])
    end
    return sl
end

function main()
    win = Window("FourLEDs") 
    vb = Box(:v)
    push!(win, vb)
    hb = Box(:h)
    push!(vb, hb)
    msg = label("Is the LED strip disconnected?")
    ok = button("Yes")
    push!(hb, msg)
    push!(hb, ok)

    without = map(ok) do _
        LibSerialPort.get_port_list()
    end
    Gtk.showall(win)
    c = Condition()
    h = map(ok) do _
        notify(c)
    end
    wait(c)

    destroy(hb)

    hb = Box(:h)
    push!(vb, hb)
    msg = label("Now, connect the LED strip")
    ok = button("OK")
    push!(hb, msg)
    push!(hb, ok)
    with = map(ok) do _
        LibSerialPort.get_port_list()
    end
    Gtk.showall(win)
    c = Condition()
    h = map(ok) do _
        notify(c)
    end
    wait(c)


    h = map(with, without) do w, wo
        @show with, without
        for port in setdiff(w, wo)
            push!(msg, "")
            sp = LibSerialPort.open(port, baudrate)

            for i in 0x00:0x03
                push!(vb, connect_slider(sp, i))
            end

            Gtk.showall(win)
        end
    end

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

