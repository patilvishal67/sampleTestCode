' Find the nodes and start the task excution
sub init()
    m.port = createObject("roMessagePort")
    m.requestTimer = m.top.findNode("requestTimer")
    m.requestTimer.observeField("fire","onTimeOut")
    m.top.observeField("request", m.port)
    m.top.functionName = "startObserving"
    m.top.control = "RUN"
end sub

' This function excute when request processing time out
Function onTimeOut()
    m.top.error = "Request timed out."
    m.top.errorFound = true
End Function

' Start the request peocessing
Function startObserving()
    m.jobsById = {}
    while true
        msg = wait(0, m.port)
        messageTypeValue = type(msg)
        if messageTypeValue = "roSGNodeEvent"
            if msg.getField() = "request"
                if addRequest(msg.getData()) <> true then print ""
            end if
        else if messageTypeValue = "roUrlEvent"
            processResponse(msg)
        end if
    end while
End Function

' Retrive the API request details and prepare the request to generate response
Function addRequest(request as Object) as Boolean
    if type(request) = "roAssociativeArray"
        context = request.context
        if type(context) = "roSGNode"
            parameters = context.parameters
            if type(parameters) = "roAssociativeArray"
                headers = parameters.headers
                method = parameters.method
                uri = parameters.uri
                if type(uri) = "roString"
                    urlXfer = createObject("roUrlTransfer")
                    urlXfer.SetCertificatesFile("pkg:/certs/certs.pem")
                    urlXfer.InitClientCertificates()
                    urlXfer.setUrl(uri)
                    urlXfer.setPort(m.port)
                    urlXfer.EnableEncodings(true)
                    urlXfer.EnableFreshConnection(false)
                    urlXfer.RetainBodyOnError(true)
                    for each header in headers
                        urlXfer.AddHeader(header, headers.lookup(header))
                    end for
                    idKey = stri(urlXfer.getIdentity()).trim()
                    ' if method = "POST" OR method = "PUT" OR method = "DELETE"
                    '     urlXfer.setRequest(method)
                    '     data = context.data
                    '     if type(data) = "roAssociativeArray"
                    '         urlXfer.AddHeader("Content-Type", "application/json")
                    '         data = FormatJson(data)
                    '         ok = urlXfer.AsyncPostFromString(data)
                    '     else
                    '         urlXfer.AddHeader("Content-type","application/x-www-form-urlencoded")
                    '         ok = urlXfer.AsyncPostFromString(data)
                    '     end if
                    ' else
                        urlXfer.AddHeader("Content-type","application/x-www-form-urlencoded")
                        ok = urlXfer.AsyncGetToString()
                    ' end if
                    if ok then
                        m.jobsById[idKey] = {
                        context: request,
                        xfer: urlXfer
                      }
                    end if
                    m.requestTimer.control = "stop"
                    m.requestTimer.control = "none"
                    m.requestTimer.control = "start"
                end if
            else
                return false
            end if
        else
            return false
        end if
    else
        return false
    end if
    return true
End Function

' Get the prepare request and proceed to get the response
Function processResponse(msg as Object)
    m.requestTimer.control = "stop"
    m.requestTimer.control = "none"
    idKey = stri(msg.GetSourceIdentity()).trim()
    job = m.jobsById[idKey]
    if job <> invalid
        context = job.context
        parameters = context.context.parameters
        title = context.context.title
        uri = parameters.uri
        jobnum = job.context.context.num
        method = parameters.method
        result = {
            code : msg.GetResponseCode(),
            headers : msg.GetResponseHeaders(),
            content : msg.GetString(),
            num : jobnum
        }
        m.jobsById.delete(idKey)
        job.context.context.response = result
        if msg.GetResponseCode() = 200
            if result.num = 1
                parseMusicVideoResponse(msg)
            end if
        else
            m.top.requestnumber = result.num
            m.top.errorFound = true
        end if
    else
        m.top.requestnumber = result.num
        m.top.error = m.global.errorString
        m.top.errorFound = true
    end if
End Function

Function parseMusicVideoResponse(msg as Object)
    JSONstring = msg.GetString()
    JSON = ParseJSON(JSONstring)
    if JSON.DoesExist("genres") and JSON.DoesExist("videos")
        m.top.getMusicVideoData = JSON
    else
        m.top.errorFound = true
    end if
End Function
