(($, window) ->
  "use strict"

  class BootstrapSwitch
    defaults:
      state: true
      size: null
      animate: true
      disabled: false
      readonly: false
      onColor: "primary"
      offColor: "default"
      onText: "ON"
      offText: "OFF"
      labelText: "&nbsp;"

    constructor: (element, options = {}) ->
      @$element = $ element
      @options = $.extend {}, @defaults, options,
        state: @$element.is ":checked"
        size: @$element.data "size"
        animate: @$element.data "animate"
        disabled: @$element.is ":disabled"
        readonly: @$element.is "[readonly]"
        onColor: @$element.data "on-color"
        offColor: @$element.data "off-color"
        onText: @$element.data "on-text"
        offText: @$element.data "off-text"
        labelText: @$element.data "label-text"
      @$on = $ "<span>",
        class: "switch-handle-on switch-#{@options.onColor}"
        html: @options.onText
      @$off = $ "<span>",
        class: "switch-handle-off switch-#{@options.offColor}"
        html: @options.offText
      @$label = $ "<label>",
        for: @$element.attr "id"
        html: @options.labelText
      @$wrapper = $ "<div>",
        class: =>
          classes = ["switch"]

          classes.push if @options.state then "switch-on" else "switch-off"
          classes.push "switch-#{@options.size}" if @options.size?
          classes.push "switch-animate" if @options.animate
          classes.push "switch-disabled" if @options.disabled
          classes.push "switch-readonly" if @options.readonly
          classes.push "switch-id-#{@$element.attr("id")}" if @$element.attr "id"
          classes.join " "

      # reassign elements after dom modification
      @$div = @$element.wrap($("<div>")).parent()
      @$wrapper = @$div.wrap(@$wrapper).parent()

      # insert handles and label
      @$element.before(@$on).before(@$label).before @$off

      @_elementHandlers()
      # @_wrapperHandlers()
      @_handleHandlers()
      @_labelHandlers()
      @_form()

      # TODO: @$label.hasClass "label-change-switch" in toggleState

    _constructor: BootstrapSwitch

    state: (value, skip) ->
      return @options.state if typeof value is "undefined"
      return @$element if @options.disabled or @options.readonly

      @$element.prop("checked", not not value).trigger "change", skip
      @$element

    toggleState: (skip) ->
      return @$element if @options.disabled or @options.readonly

      @$element.prop("checked", not @options.state).trigger "change", skip

    ###
    TODO: refactor
    toggleRadioState: (uncheck, skip) ->
      $element = @$element.not ":checked"

      if uncheck
        $element.trigger "change", skip
      else
        $element.prop("checked", not @$element.is ":checked").trigger "change", skip
      @$element
    ###

    size: (value) ->
      return @options.size if typeof value is "undefined"

      @$wrapper.removeClass "switch-#{@options.size}" if @options.size?
      @$wrapper.addClass "switch-#{value}"
      @options.size = value
      @$element

    animate: (value) ->
      return @options.animate if typeof value is "undefined"

      value = not not value

      @$wrapper[if value then "addClass" else "removeClass"]("switch-animate")
      @options.animate = value
      @$element

    disabled: (value) ->
      return @options.disabled if typeof value is "undefined"

      value = not not value

      @$wrapper[if value then "addClass" else "removeClass"]("switch-disabled")
      @$element.prop "disabled", value
      @options.disabled = value
      @$element

    toggleDisabled: ->
      @$element.prop "disabled", not @options.disabled
      @$wrapper.toggleClass "switch-disabled"
      @options.disabled = not @options.disabled
      @$element

    readonly: (value) ->
      return @options.readonly if typeof value is "undefined"

      value = not not value

      @$wrapper[if value then "addClass" else "removeClass"]("switch-readonly")
      @$element.prop "readonly", value
      @options.readonly = value
      @$element

    toggleReadonly: ->
      @$element.prop "readonly", not @options.readonly
      @$wrapper.toggleClass "switch-readonly"
      @options.readonly = not @options.readonly
      @$element

    onColor: (value) ->
      color = @options.onColor

      return color if typeof value is "undefined"

      @$on.removeClass "switch-#{color}" if color?
      @$on.addClass "switch-#{value}"
      @options.onColor = value
      @$element

    offColor: (value) ->
      color = @options.offColor

      return color if typeof value is "undefined"

      @$off.removeClass "switch-#{color}" if color?
      @$off.addClass "switch-#{value}"
      @options.offColor = value
      @$element

    onText: (value) ->
      return @options.onText if typeof value is "undefined"

      @$on.html value
      @options.onText = value
      @$element

    offText: (value) ->
      return @options.offText if typeof value is "undefined"

      @$off.html value
      @options.offText = value
      @$element

    labelText: (value) ->
      return @options.labelText if typeof value is "undefined"

      @$label.html value
      @options.labelText = value
      @$element

    destroy: ->
      $form = @$element.closest "form"

      $form.off("reset.bootstrapSwitch").removeData "bootstrap-switch" if $form.length
      @$div.children().not(@$element).remove()
      @$element.unwrap().unwrap().off(".bootstrapSwitch").removeData "bootstrap-switch"
      @$element

    _elementHandlers: ->
      @$element.on
        "change.bootstrapSwitch": (e, skip) =>
          e.preventDefault()
          e.stopPropagation()
          e.stopImmediatePropagation()

          checked = @$element.is ":checked"

          return if checked is @options.state

          @options.state = checked
          @$wrapper
          .removeClass(if checked then "switch-off" else "switch-on")
          .addClass if checked then "switch-on" else "switch-off"

          @$element.trigger "switchChange", el: @$element, value: checked if not skip
        "focus.bootstrapSwitch": (e) =>
          e.preventDefault()
          e.stopPropagation()
          e.stopImmediatePropagation()

          @$wrapper.addClass "switch-focused"
        "blur.bootstrapSwitch": (e) =>
          e.preventDefault()
          e.stopPropagation()
          e.stopImmediatePropagation()

          @$wrapper.removeClass "switch-focused"
        "keydown.bootstrapSwitch": (e) =>
          return if not e.which or @options.disabled or @options.readonly

          switch e.which
            when 32
              e.preventDefault()
              e.stopPropagation()
              e.stopImmediatePropagation()

              @toggleState()
            when 37
              e.preventDefault()
              e.stopPropagation()
              e.stopImmediatePropagation()

              @state false
            when 39
              e.preventDefault()
              e.stopPropagation()
              e.stopImmediatePropagation()

              @state true

    _handleHandlers: ->
      @$on.on "click.bootstrapSwitch", (e) =>
        @state false
        @$element.trigger "focus"
      @$off.on "click.bootstrapSwitch", (e) =>
        @state true
        @$element.trigger "focus"

    _labelHandlers: ->
      @$label.on
        "mousemove.bootstrapSwitch": (e) =>
          return unless @drag

          percent = ((e.pageX - @$wrapper.offset().left) / @$wrapper.width()) * 100
          left = 25
          right = 75

          if percent < left
            percent = left
          else if percent > right
            percent = right

          @$div.css "margin-left", "#{percent - right}%"
          @$element.trigger "focus"
        "mousedown.bootstrapSwitch": (e) =>
          return if @drag or @options.disabled or @options.readonly

          @drag = true
          @$wrapper.removeClass "switch-animate" if @options.animate
          @$element.trigger "focus"
        "mouseup.bootstrapSwitch": (e) =>
          return unless @drag

          @drag = false
          @$element.prop("checked", (parseInt(@$div.css("margin-left"), 10) > -25)).trigger "change"
          @$div.css "margin-left", ""
          @$wrapper.addClass "switch-animate" if @options.animate
        "click.bootstrapSwitch": (e) =>
          e.preventDefault()
          e.stopImmediatePropagation()

          @toggleState()
          @$element.trigger "focus"

    _form: ->
      $form = @$element.closest "form"

      return if $form.data "bootstrap-switch"

      $form
      .on "reset.bootstrapSwitch", ->
        window.setTimeout ->
          $form
          .find("input")
          .filter( -> $(@).data "bootstrap-switch")
          .each -> $(@).bootstrapSwitch "state", false
        , 1
      .data "bootstrap-switch", true

  $.fn.extend bootstrapSwitch: (option, args...) ->
    ret = @
    @each ->
      $this = $(@)
      data = $this.data "bootstrap-switch"

      $this.data "bootstrap-switch", data = new BootstrapSwitch @, option if not data
      ret = data[option].apply data, args if typeof option is "string"
    ret

  $.fn.bootstrapSwitch.Constructor = BootstrapSwitch
) window.jQuery, window
