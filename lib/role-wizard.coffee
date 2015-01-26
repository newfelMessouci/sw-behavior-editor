{TextEditorView, View} = require 'atom-space-pen-views'

module.exports =
    class RoleWizard extends View
        @content: () ->
            @div class: 'block', =>
                @label 'Enter the role name:', class: 'icon', outlet: 'promptText'
                @subview 'miniEditor', new TextEditorView(mini: true)
                @div class: 'error-message', outlet: 'errorMessage'
