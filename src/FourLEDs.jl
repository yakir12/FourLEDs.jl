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
    mainwin = Window("FourLEDs") |> (bx = Box(:v))
    msg = label("Connecting...")
    push!(bx, msg)
    Gtk.showall(mainwin)

    sp = get_port()
    if isnothing(sp)
        push!(msg, "LED strip not connected, try again...")
        sleep(3)
        destroy(mainwin)
        return nothing
    end
    push!(msg, "Connected!")
    @async begin
        sleep(1)
        push!(msg, "")
    end

    for i in 0x00:0x03
        push!(bx, connect_slider(sp, i))
    end

    Gtk.showall(mainwin)

    if !isinteractive()
        Gtk.waitforsignal(mainwin, :destroy)
        close(sp)
    else
        signal_connect(mainwin, :destroy) do widget
            close(sp)
        end
    end

    nothing

end

end


