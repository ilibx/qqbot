
log = console.log

class QQBot
    constructor: (@name) ->
        @buddy_info = {}
        @group_info = {}
        @groupmember_info = {}
    
    # @format PROTOCOL `用户分组信息格式`
    save_buddy_info: (@buddy_info)->
    
    # @format PROTOCOL `群分组信息格式`
    save_group_info: (@group_info) ->
    
    # 获取用户信息
    # @return {nick,uin,flag,face}
    get_user: (uin) ->
        # TODO:加速查询
        users = @buddy_info.info.filter (item)-> item.uin == uin            
        users.pop()
        
    # 获取群信息，只支持群 ，支持多关键词搜索
    # @options {key:value} 
    # @return {gid,code,name,flag}
    get_group: (options)->
        groups = @group_info.gnamelist.filter (item)-> 
            for key ,value of options
                return item[key] == value
        groups.pop()
        
    handle_poll_responce: (resp)->
        code = resp.retcode
        return if code != 0
        for idx,event of resp.result
            @_handle_poll_event(event)
        
    _handle_poll_event : (event) ->
        switch event.poll_type
          when 'group_message' then @_on_group_message(event)
          when 'message'       then @_on_message(event)
          else log "unimplemented event",event.poll_type
        
    _on_message : (event)->
        msg = @_create_message event
        log "[好友消息]","#{msg.from_user.nick}:#{msg.content} #{msg.time}"
        
    _on_group_message : (event)->
        msg = @_create_message event
        log "[群消息]","[#{msg.from_group.name}] #{msg.from_user.nick}:#{msg.content} #{msg.time}"
    
    _create_message : (event)->
        value = event.value
        msg = 
            content : value.content.slice(-1).pop()
            time    : new Date(value.time * 1000)
            from_uin: value.from_uin
            type    : if value.group_code then 'group' else 'buddy'
            
        if msg.type == 'group'
            msg.from_gid = msg.from_uin
            msg.from_uin = value.send_uin # 这才是用户
            msg.from_group = @get_group({gid:msg.from_gid} )
            msg.from_user  = @get_user( msg.from_uin )
        else if msg.type == 'buddy'
            msg.from_user = @get_user( msg.from_uin )
        msg
        
            
# class Message
#     constructor: (@struct)->
#         @content = @struct.content.slice(-1).pop
#         @time    = new Date(@struct.time * 1000)
            
            
module.exports = QQBot    