$(->
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
)
