{$, $$, View} = require 'atom-space-pen-views'
fuzzyFilter = require('fuzzaldrin').filter

module.exports =
class EntitySelectView extends View
  constructor: (@index, @entityType, @editor) ->
      itemDiv = document.createElement('div')
      itemDiv.classList.add('select-list')
      @itemOl = document.createElement('ol')
      @itemOl.classList.add('list-group')
      itemIl = document.createElement('li')
      itemIl.classList.add('selected')



      itemDiv.appendChild(@itemOl)
      @panel = document.createElement('atom-panel')
      @panel.classList.add('modal')
      @panel.classList.add('skill-completion')
      @panel.appendChild(itemDiv)

      $(@panel).mousedown( (e) =>
          false
      )

      @editor.getModel().getBuffer().onDidChange =>
          #@populateList()
          populateCallback = =>
              @populateList()
          setTimeout(populateCallback, 50)

      $(@itemOl).on 'mousedown', 'li', (e) =>
          @selectItemView($(e.target).closest('li'))
          e.preventDefault()

      #$(@itemOl).on 'dblclick', 'li', =>
      # @confirm()

      $(@editor.element).on 'core:move-up', (e) =>
          @selectPreviousItemView()
          false
      $(@editor.element).on 'core:move-down', (e) =>
          @selectNextItemView()
          false
      $(@editor.element).on 'core:move-to-top', =>
          @selectItemView($(@itemOl).find('li:first'))
          $(@itemOl).scrollToTop()
          false
      $(@editor.element).on 'core:move-to-bottom', =>
          @selectItemView($(@itemOl).find('li:last'))
          $(@itemOl).scrollToBottom()
          false
      $(@editor.element).on 'core:confirm', =>
          @confirm()

      @panel.tabIndex = "-1"

  attach: ->
      @populateList()
      @editor.element.parentNode.appendChild(@panel)
      $(@panel).offset({
          top: $(@editor.element).offset().top + $(@editor.element).outerHeight()
          left: $(@editor.element).offset().left
      })

  detach: ->
      @editor.element.parentNode.removeChild(@panel)

  confirm: ->
      @editor.setText(@getSelectedItemView().text())
      @editor.element.classList.remove("invalid-uri")
      
  viewForItem: ({name}) ->
    $$ -> @li(name)

  populateList: ->
    filterQuery = @editor.getText()
    entries = (entry for entry in @index when entry.type is @entityType)
    if filterQuery.length
        filteredItems = fuzzyFilter(entries, filterQuery, key: "name")
    else
        filteredItems = entries

    $(@itemOl).empty()
    for i in [0...filteredItems.length]
      item = filteredItems[i]
      itemView = $(@viewForItem(item))
      itemView.data('select-list-item', item)
      $(@itemOl).append(itemView)

    if filteredItems.length
        @selectItemView($(@itemOl).find('li:first'))

  getSelectedItemView: ->
      $(@itemOl).find('li.selected')

  selectPreviousItemView: ->
      view = @getSelectedItemView().prev()
      if not view.length
          view = $(@itemOl).find('li:last')
      @selectItemView(view)

  selectNextItemView: ->
      view = @getSelectedItemView().next()
      if not view.length
          view = $(@itemOl).find('li:first')
      @selectItemView(view)

  selectItemView: (view) ->
      $(@itemOl).find('.selected').removeClass('selected')
      view.addClass('selected')
      @scrollToItemView(view)

  scrollToItemView: (view) ->
      scrollTop = $(@itemOl).scrollTop()
      desiredTop = view.position().top + scrollTop
      desiredBottom = desiredTop + view.outerHeight()
      if desiredTop < scrollTop
        $(@itemOl).scrollTop(desiredTop)
      else if desiredBottom > $(@itemOl).scrollBottom()
        $(@itemOl).scrollBottom(desiredBottom)

  #confirmed: ({name}) ->
    #@cancel()
  #  console.log("Confirmed : " + name)
