{$, $$} = require 'atom-space-pen-views'

module.exports =
class EntitySelectView
  constructor: (@index, @editor) ->
      itemDiv = document.createElement('div')
      itemDiv.classList.add('select-list')
      itemOl = document.createElement('ol')
      itemOl.classList.add('list-group')
      itemIl = document.createElement('li')
      itemIl.classList.add('selected')
      itemIl.textContent = "one"
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'two'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)

      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)
      itemIl = document.createElement('li')
      itemIl.textContent = 'three'
      itemOl.appendChild(itemIl)



      itemDiv.appendChild(itemOl)
      @panel = document.createElement('atom-panel')
      @panel.classList.add('modal')
      @panel.classList.add('skill-completion')
      @panel.appendChild(itemDiv)

      @cptFocus = 0
      @panel.tabIndex = "-1"

      $(@editor).focus( (e) =>
          @cptFocus = @cptFocus + 1
          console.log "Editor focus : " + @cptFocus
      )

      $(@editor).blur( (e) =>
          @cptFocus = @cptFocus - 1
          if @cptFocus is 0
              @detach()
          console.log "Editor blur : " + @cptFocus
      )

      $(@panel).focus( (e) =>
          @cptFocus = @cptFocus + 1
          console.log "Panel focus : " + @cptFocus
      )

      $(@panel).blur( (e) =>
          @cptFocus = @cptFocus - 1
          if @cptFocus is 0
              @detach()
          console.log "Panel blur : " + @cptFocus
      )

  #cancelled: ->
  #  @hide()
  #  console.log("Cancelled")

  attach: ->
      @editor.element.parentNode.appendChild(@panel)
      $(@panel).offset({
          top: $(@editor.element).offset().top + $(@editor.element).outerHeight()
          left: $(@editor.element).offset().left
      })

  detach: ->
      @editor.element.parentNode.removeChild(@panel)

  viewForItem: ({name}) ->
    $$ -> @li(name)

  #confirmed: ({name}) ->
    #@cancel()
  #  console.log("Confirmed : " + name)
