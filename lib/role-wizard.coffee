{TextEditorView, View} = require 'atom-space-pen-views'
fs = require 'fs-plus'
xml2js = require 'xml2js'

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
            doc =
                'role':
                    '$':
                        'name': name
                        'source-version': '1.0.0'
                        'xmlns': 'http://www.masagroup.net/directia/schemas/bm'
            builder = new xml2js.Builder()
            xml = builder.buildObject(doc)
            fs.writeFileSync(xmlFilePath, xml)
            atom.workspace.open(xmlFilePath)
