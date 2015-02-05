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
            atom.commands.dispatch(@miniEditor.element, 'core:paste')
            text = @miniEditor.getText()
            @miniEditor.setText('')
            atom.commands.dispatch(document.querySelector(".tree-view"), 'tree-view:copy-full-path')
            atom.commands.dispatch(@miniEditor.element, 'core:paste')
            @uri = @miniEditor.getText()
            @miniEditor.setText(text)
            atom.commands.dispatch(@miniEditor.element, 'core:copy')
            @miniEditor.setText('')

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
            #xmlFilePath = atom.project.getDirectories()[0]?.resolve(name) + ".xml"
            uriSplit = @uri.split("\\")
            i = uriSplit.indexOf("src")
            i = 1 if i is -1
            category = ''
            for uriComponent in uriSplit[i+1..]
                category += uriComponent + "."
            fullName = category + name
            xmlFilePath = @uri + "\\" + name + ".xml"
            console.log(uriSplit)
            console.log xmlFilePath
            console.log fullName
            doc =
                'role':
                    '$':
                        'name': fullName
                        'source-version': '1.0.0'
                        'xmlns': 'http://www.masagroup.net/directia/schemas/bm'
            builder = new xml2js.Builder()
            xml = builder.buildObject(doc)
            fs.writeFileSync(xmlFilePath, xml)
            atom.workspace.open(xmlFilePath)
