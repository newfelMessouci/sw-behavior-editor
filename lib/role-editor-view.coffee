{ScrollView, TextEditorView} = require 'atom-space-pen-views'
path = require 'path'

module.exports =
class RoleEditorView extends ScrollView

    @content: ->
        @div class: 'block', =>
            @label 'Name:', class: 'text-highlight'
            @subview 'miniEditor', new TextEditorView(mini: true)

    initialize: (@uri) ->
        @title = path.basename(@uri)

    getURI: -> @uri

    getTitle: -> @title
