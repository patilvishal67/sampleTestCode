sub init()
    m.top.id = "gridListItem"
    m.programPoster = m.top.findNode("programPoster")
    m.programTitle = m.top.findNode("programTitle")
    m.programArtist = m.top.findNode("programArtist")
end sub

sub showContent()
    itemcontent = m.top.itemContent
    ' set data to grid item
    if itemcontent <> invalid
        m.programPoster.uri = itemcontent.FHDPosterUrl
        m.programTitle.text = itemcontent.title
        m.programArtist.text = itemcontent.title
    end if
end sub
