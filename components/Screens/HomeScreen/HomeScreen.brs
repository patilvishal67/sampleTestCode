Function init()
    ' find nodes
    m.homeScreenGridRowList = m.top.findNode("homeScreenGridRowList")
    m.video = m.top.findNode("video")

    ' handle api integration
    m.api = createObject("roSGNode","api")
    m.api.observeField("getMusicVideoData","onMusicVideoSuccess")
    m.api.observefield("errorFound","onErrorFound")
    
    musicVideoUrl = "https://raw.githubusercontent.com/XiteTV/frontend-coding-exercise/main/data/dataset.json"
    callApi({"Authorization":""},musicVideoUrl,"GET","","getMusicVideoData",1)
end function

' Call task node to handle api call
Function callApi(headers as object, url as String, method as String, data as dynamic, title as String, num as integer)
    m.api.errorFound = false
    context = createObject("roSGNode", "Node")
    params = {
        headers: headers,
        uri: url,
        method: method
    }
    context.addFields({
        parameters: params,
        title: title,
        data: data,
        num: num,
        response: {}
    })
    m.api.requestnumber = num
    m.api.request = { context: context }
end Function

' on api success function
function onMusicVideoSuccess()
    response = m.api.getMusicVideoData
    if response <> invalid AND response.count() > 0
        mapMusicVideoData(response)
    end if
end function

' mapping response data
function mapMusicVideoData(data as object)
    mapData = []
    for i = 0 to data.genres.count() - 1
        categorySet = {}
        categorySet.AddReplace("category", data.genres[i].name)
        videoSet = []
        for j = 0 to data.videos.count() - 1
            if data.genres[i].id = data.videos[j].genre_id
                videoSet.push(data.videos[j])
            end if
        end for
        categorySet.AddReplace("video", videoSet)
        
        mapData.push(categorySet)
    end for
    loadData(mapData)
end function

' set the mapped data to gris view
function loadData(videoData as object)
    dataContent = createObject("RoSGNode", "ContentNode")
    for i = 0 to videoData.count() - 1
        ' add condtion to handle 0 count category
        if videoData[i].video.count() > 0
            rowContent = dataContent.createChild("ContentNode")
            rowContent.title = videoData[i].category
            for j = 0 to videoData[i].video.count() - 1
                itemContent = rowContent.createChild("ContentNode")
                itemContent.title = videoData[i].video[j].title
                itemContent.FHDPosterUrl = videoData[i].video[j].image_url
                itemContent.Description = videoData[i].video[j].artist
            end for
        end if
    end for
    m.homeScreenGridRowList.content = dataContent
    m.homeScreenGridRowList.setFocus(true)
end function

Function onErrorFound()
    if m.api.errorFound = true
    end if
End Function

' set video details and and play video after selecting the item from grid view 
function onRowListItemSelected()
    selectedItemIndex = m.homeScreenGridRowList.rowItemSelected
    selectedItem = m.homeScreenGridRowList.content.getchild(selectedItemIndex[0]).getchild(selectedItemIndex[1])
    
    videoContent = createObject("RoSGNode", "ContentNode")
    videoContent.url = "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4"
    videoContent.title = selectedItem.title
    videoContent.streamformat = "mp4"

    m.video.content = videoContent
    m.video.control = "play"
    m.video.visible = true
    m.video.setFocus(true)
end function

' handled the screen control after finished and stopped video
function onState()
    if m.top.state = "finished" or m.top.state = "stopped"
        exitPlayer()
    end if
end function

' stop vidoe and set to none 
function exitPlayer()
    m.video.control = "stop"
    m.video.control = "none"
    m.video.visible = false
    m.homeScreenGridRowList.setFocus(true)
end function

' handled remote click event on video player
function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press then
        if key="back"
            if m.video.visible = true
                exitPlayer()
                result = true
            end if
        end if
    end if
    return result
end function
