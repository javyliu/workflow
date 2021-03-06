window.wrap_msgs = ($con)->
  return  if $con.length < 1
  new_con = []
  _reg = /失败|not/
  uname = ""
  _reg_uname = /\[(.+)\]/
  for item,i in $con.html().split("<br>")
    do (item,i) ->
      uname = item.match(_reg_uname) if i==0
      cls = if _reg.test(item) then 'err' else 'succ'
      new_con.push "<span class='#{cls}'>#{item.replace(_reg_uname,"")}</span>"
  uname =  if uname? then uname[1] else ""
  if uname == ""
    $con.html(new_con.join('<br>'))
  else
    $con.html("<h6>账号#{uname}操作结果如下：</h6>#{new_con.join('<br>')}<p style='padding-left:5em;'> <small>如有问题请联系MIS部</small></p>")

$(->

  $.extend to_js_url: (url)->
    if /\.js|\.html|\.htm/.test(url)
      url
    else if /\?/.test(url)
      url.replace('?', '.js?')
    else
      url + '.js'


  $(document).on('ajax:success','[data-remote][data-replace-with]', (event, data) ->
    _this = $(this)
    $(_this.data('replace-with')).html(data)
    _this.trigger('ajax:replaced')
  ).on('click','.toggle',->
    $($(this).attr("ref")).toggleClass("hidden")
  ).on("ajax:success","[data-remote][data-method=delete]",(e,data)->
    $(this).closest($(this).data("destroy") || "tr").remove()
  )


  $(document).on("ajax:success",".pagination a",(event,data,status,xhr)->
    $("#content").html(data)
  )

  #for top-bar
  $(document).on 'ready page:load', ->
    $('.has-dropdown').removeClass("active")
    $('ul.dropdown li.active').closest("li.has-dropdown").addClass("active")
    #for episode new
    $('#episode_form').on "change",".holiday_select", ->
      unit = window.check_type[this.value]
      $(this).closest(".row").find(".child_unit").html(unit).end().find(".child_total").data("unit",unit)

    $("#episode_form").on("click",'.delete',(e)->
      e.preventDefault()
      $(this).closest(".row").find(".is_delete").val(1).end().hide()
      $(".child_total:visible").trigger("blur")
    )

    $("#episode_form").on("blur",'.child_total',(e)->
      #console.log($(this))
      _sum = 0
      unit =  $(this).data("unit")
      if $(".child_total:visible").length < 2
        _sum = $(this).val()
        $(".unit").text(unit)
      else
        $(".unit").text("天")
        $(".child_total:visible").each ->
          unit =  $(this).data("unit")
          if unit == "天"
            _sum += parseFloat($(this).val())
          else if unit == "小时"
            _sum += parseInt($(this).val())/8

      $("#total_time").val(_sum)

    )
    #页面加载成功后触发
    $("#episode_form .child_total:visible:last").trigger("blur")

    $("#more_episode").click (e)->
      e.preventDefault()
      _row = $("#parent_episode").clone()
      _row.find(".child_total").val("").end().find("div:last").append("<input class='is_delete' type='hidden' value='false' name='episode[_destroy]'><a href='#' class='delete button tiny inline-button'>删除</a>")
      _row.html(_row.html().replace(/episode\[(.*)\]/g,"episode[children_attributes]["+$.now()+"][$1]"))
      $(".child_episodes").append(_row.find(".datetimepicker").datetimepicker({ format:'Y-m-d H:i', inline:false, lang:'zh' }).end())
      $(".child_total:visible:last").trigger("blur")


  $(document).on 'ready page:load', -> $('.datetimepicker').datetimepicker({ format:'Y-m-d H:i', inline:false, lang:'zh' })
  $(document).on 'ready page:load', -> $('.datepicker').datetimepicker({timepicker:false, format:'Y-m-d', inline:false, lang:'zh' })
  $(document).on 'ready page:load', ->
    $('.datepicker.need_change_event').datetimepicker({timepicker:false, format:'Y-m-d', inline:false, lang:'zh', onClose: (_time,_input) ->
      if _input.val().length > 0
        Turbolinks.visit(_input.data("url")+_input.val())
    })

  $(document).on('click',".export_xls", ->
    _this = $(this)
    unless _this.data('url')
      _this.data('url',_this.attr("href"))

    _this.attr("href",_this.data("url") + "?" + _this.closest("form").serialize())
  )

  #reveal modal
  $(document).on('opened', '[data-reveal]', ->
    _modal = $(this)
    if $("a.close-reveal-modal",_modal).length == 0
      _modal.append('<a class="close-reveal-modal" aria-label="Close">&#215;</a>')
  )


  #implement the rest place editor form
  #window.RestInPlaceEditor.forms =
  #  "input" :
  #    activateForm : ->
  #      value = $.trim(@elementHTML())
  #      @$element.html("<form action='javascript:void(0)' style='display:inline;'>
  #        <input type='text' class='rest-in-place-#{@attributeName}' placeholder='#{@placeholder}'>
  #        </form>")
  #      @$element.find('input').val(value)
  #      @$element.find('input')[0].select()
  #      @$element.find("form").submit =>
  #        @update()
  #        false
  #      @$element.find("input").keyup (e) =>
  #        @abort() if e.keyCode == ESC_KEY
  #      @$element.find("input").blur => @abort()

  #    getValue : ->
  #      @$element.find("input").val()

  #  "textarea" :
  #    activateForm : ->
  #      value = $.trim(@elementHTML())
  #      @$element.html("""<form action='javascript:void(0)' style='display:inline;'>
  #        <textarea class='rest-in-place-#{@attributeName}' placeholder='#{@placeholder}'></textarea>
  #        </form>""")
  #      @$element.find('textarea').val(value)
  #      @$element.find('textarea')[0].select()
  #      @$element.find("textarea").keyup (e) =>
  #        @abort() if e.keyCode == ESC_KEY
  #      @$element.find("textarea").blur => @update()

  #    getValue : ->
  #      @$element.find("textarea").val()
  ##
  $(document).on "ready page:load ajax:success", (event)->
    $("tr.need_update td[class^=c_aff]").restInPlace()
    $("td.edit-in-place").restInPlace()

  $(document).on 'success.rest-in-place',"tr.need_update td[class^=c_aff]", (event,data)->
    if data.error
      $(this).data("restInPlaceEditor").abort()
      alert(data.error)

  $(document).on 'failure.rest-in-place',"tr.need_update td[class^=c_aff]", (event,data)->
    if data.error
      $(this).data("restInPlaceEditor").abort()
      alert(data.error)

  #for new approve
  $(document).on "click","#new_approve .button", (e)->
    if $(this).hasClass("success")
      $("#approve_state").val(1)
    else
      if $("#approve_des").val().length < 1
        e.preventDefault()
        alert("请在简要说明中填写驳回理由!")
        return false

      $("#approve_state").val(2)

  $(document).on "ready page:load", ->
    $(".confirm_button a[data-method=post]").on "click",(e)->
      $("tr.need_update").each ->
        if $.trim($("td.c_aff",this).text()).length < 1
          e.preventDefault()
          e.stopPropagation()
          alert("白色背景行每行至少填写1项!")
          return false

)
