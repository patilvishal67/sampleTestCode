Sub init()
    ' set background image
    m.top.backgroundURI="pkg:/images/background.jpg"
    m.screens=m.top.findNode("screens")
    ' Create homescreen
    m.HomeScreen=m.screens.createChild("HomeScreen")
    m.HomeScreen.id="HomeScreen"
End Sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press then
        if key="back"

        else if key="up"

        else if key="down"

        else if key="left"

        else if key="options"

        else if key="right"

        end if
    end if
    return result
end function
