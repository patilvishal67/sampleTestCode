Function Main(args as Dynamic) as Void
	showChannelSGScreen(args)        
end Function

sub showChannelSGScreen(args)
    'Indicate this is a Roku SceneGraph application'
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    'Create a scene and load MainScene.xml'
    scene = screen.CreateScene("MainScene")
    scene.signalBeacon("AppLaunchComplete")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub

