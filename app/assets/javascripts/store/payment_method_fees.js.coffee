$ ->
  $("#add-payment-method-fee").on "click", (e) ->
    html = undefined
    id = undefined
    id = new Date().getTime()
    html = $(this).data("fields").replace(/XYZ/g, id)
    $("#fee-fields").append html
    e.preventDefault()

  $(".container").on "click", ".remove-payment-method-fee", (e) ->
    $(this).next("[name*=_destroy]").val true
    $(this).closest(".currency-fields").hide()
    e.preventDefault()

  $("#gtwy-type").on "change", (e) ->
    unless $(this).find("option:selected").val() is "Spree::PaymentMethod::Check"
      $("#payment-methods-fees-wrapper").hide()
    else
      $("#payment-methods-fees-wrapper").show()
    e.preventDefault()