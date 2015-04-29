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
  $(document).on("click",".export_xls", ->
    $(this).attr("href",$(this).attr("href")+"?"+$(this).closest("form").serialize())
  )

  #for top-bar
  $(document).on 'ready page:load', ->
    $('.has-dropdown').removeClass("active")
    $('ul.dropdown li.active').closest("li.has-dropdown").addClass("active")

  $(document).on 'ready page:load', -> $('.datetimepicker').datetimepicker({ format:'Y-m-d H:i', inline:false, lang:'zh' })
  $(document).on 'ready page:load', -> $('.datepicker').datetimepicker({timepicker:false, format:'Y-m-d', inline:false, lang:'zh' })
  $(document).on 'ready page:load', ->
    $('.datepicker.need_change_event').datetimepicker({timepicker:false, format:'Y-m-d', inline:false, lang:'zh', onClose: (_time,_input) ->
      if _input.val().length > 0
        Turbolinks.visit(_input.data("url")+_input.val())
    })

  $(document).on('click',".export_xls", ->
      $(this).attr("href",$(this).attr("href")+"?"+$(this).closest("form").serialize())
  )

  #reveal modal
  $(document).on('opened', '[data-reveal]', ->
    _modal = $(this)
    if $("a.close-reveal-modal",_modal).length == 0
      _modal.append('<a class="close-reveal-modal" aria-label="Close">&#215;</a>')
  )


  $(document).on "ready page:load ajax:success", (event)->
    $("tr.need_update td[class^=c_aff]").restInPlace()
    $("td.edit-in-place").restInPlace()

  $(document).on 'success.rest-in-place',"tr.need_update td[class^=c_aff]", (event,data)->
    if data.error
      $(this).data("restInPlaceEditor").abort()
      alert(data.error)
  $(document).on("ajax:success","[data-remote][data-method=delete]",(e,data) ->
    $(this).closest($(this).data("destroy") || "tr").remove()
  )
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

  $(document).on "click",".confirm_button a[data-method=post]", (e)->
    $("tr.need_update").each ->
      if $.trim($("td.c_aff",this).text()).length < 1
        e.preventDefault()
        alert("白色背景行每行至少填写1项!")
        return false

)
