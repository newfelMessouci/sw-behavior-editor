{TextEditorView, View} = require 'atom-space-pen-views'
fs = require 'fs-plus'

module.exports =
    class RoleWizard extends View
        @content: () ->
            @div class: 'block', =>
                @label 'Enter the role name:', class: 'icon', outlet: 'promptText'
                @subview 'miniEditor', new TextEditorView(mini: true)
                @div class: 'error-message', outlet: 'errorMessage'

        initialize: () ->
            atom.commands.add @element,
                'core:confirm': =>
                    @panel.destroy()
                    @createRole(@miniEditor.getText())
                'core:cancel': =>
                    @panel.destroy()
                    atom.workspace.getActivePane().activate()

        attach: ->
            @panel = atom.workspace.addModalPanel(item: this.element)
            @miniEditor.focus()

        createRole: (name) ->
            xmlFilePath = atom.project.getDirectories()[0]?.resolve(name) + ".xml"
            xml = """
                <?xml version="1.0" encoding="UTF-8"?>
                <role xmlns="http://www.masagroup.net/directia/schemas/bm" name="#{name}" source-version="1.0.0">
                <role/>
            """
            fs.writeFileSync(xmlFilePath, xml)
            atom.workspace.open(xmlFilePath)
