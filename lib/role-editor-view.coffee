{$, $$, ScrollView, TextEditorView} = require 'atom-space-pen-views'
path = require 'path'

module.exports =
class RoleEditorView extends ScrollView

    @content: ->
        @div class: 'block sw-behavior-editor-role-view', =>
            @div class: 'block', =>
                @div class: 'block', =>
                    @label 'Name:', class: 'text-highlight'
                    @subview 'miniEditorName', new TextEditorView(mini: true, placeholderText: "Enter role name")
                @div class: 'block', =>
                    @label 'Super Role:', class: 'text-highlight'
                    @subview 'miniEditorSuperRole', new TextEditorView(mini: true, placeholderText: "Enter super role name")
                @div class: 'block', =>
                        @label 'Description:', class: 'text-highlight'
                        @subview 'editorDescription', new TextEditorView(placeholderText: "Enter role description")
                @ul class: 'list-tree has-collapsable-children skill-ul', =>
                    @li class: 'list-nested-item skill-list', =>
                        @div class: 'list-item', =>
                            @label 'Skills', class: 'text-highlight'
                    @li class: 'list-item mini-editor-skill', =>
                        @subview 'miniEditorSkill', new TextEditorView(mini: true, placeholderText: "Enter skill name")
            @div class: 'block', =>
                @button outlet: 'switchXMLButton', class: 'btn', 'Switch to XML Text Editor'

    initialize: (@uri, @behaviorEditor) ->
        @title = path.basename(@uri)
        @miniEditorName.setText(@title.replace(/\.[^/.]+$/, ""))
        @isCollapsed = false
        @skillItems = [ @miniEditorSkill.element ]
        @setCallbackSkillEditor(@miniEditorSkill.element)
        @switchXMLButton.on 'click', (e) =>
            console.log("Uri : " + @uri)
            atom.workspace.getActivePane().destroyActiveItem()
            @behaviorEditor.switchingXML = true
            atom.workspace.open(@uri)
        @on 'click', '.skill-list', (e) =>
            console.log(e)
            if @isCollapsed
                @isCollapsed = false
                e.currentTarget.classList.remove("collapsed")
                console.log("Deuxieme")
                for skillElement in @skillItems
                    item = document.createElement("li")
                    item.classList.add("list-item", "mini-editor-skill")
                    item.appendChild(skillElement)
                    e.currentTarget.parentNode.appendChild(item)
            else
                @isCollapsed = true
                e.currentTarget.classList.add("collapsed")
                console.log("Premiere")
                for skillElement in @skillItems
                    console.log(e.currentTarget)
                    console.log(e.currentTarget.parentNode)
                    e.currentTarget.parentNode.removeChild(skillElement.parentNode)


    setCallbackSkillEditor: (e) ->
        @currentSkillConfirm = atom.commands.add e,
            'core:confirm': =>
                #item = document.createElement("LI")
                #item.classList.add("list-item")
                #textEditor = new TextEditorView(mini: true, placeholderText: "Enter skill name")
                #item.appendChild(textEditor.element)

                textEditor = new TextEditorView(mini: true, placeholderText: "Enter skill name")
                skillElement = ( $$ ->
                    @li class: 'list-item mini-editor-skill', =>
                        @subview 'miniEditorSkill', textEditor)[0]
                #$('.skill-ul')[0].appendChild(skillElement)
                @miniEditorSkill.element.parentNode.parentNode.appendChild(skillElement)
                #$('.skill-ul')[0].appendChild(( $$ ->
                #    @li class: 'list-item', =>
                #        @subview 'miniEditorSkill2', new TextEditorView(mini: true, placeholderText: "Enter skill name"))[0])
                console.log(skillElement)
                console.log(skillElement.parentNode)
                @skillItems.push(skillElement.firstElementChild)
                textEditor.focus()
                @currentSkillConfirm.dispose()
                @setCallbackSkillEditor(textEditor.element)

    getURI: -> @uri

    getTitle: -> @title
