{$, $$, ScrollView, TextEditorView} = require 'atom-space-pen-views'
EntitySelectView = require './entity-select-view'
path = require 'path'
xml2js = require 'xml2js'
xml = require 'xml'
fs = require 'fs-plus'

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
                        #@div class: 'select-list', =>
                        #    @ol class: 'list-group', =>
                        #        @li class: 'selected', 'one'
                        #        @li 'two'
                        #        @li 'three'

            @div class: 'block', =>
                @button outlet: 'switchXMLButton', class: 'btn', 'Switch to XML Text Editor'

    initialize: (@uri, @behaviorEditor) ->
        super
        @load()
        atom.commands.add 'atom-workspace', 'core:save': =>
            if atom.workspace.getActivePaneItem() is this
                @save()
        atom.commands.add 'atom-workspace', 'core:save-all': =>
                @save()
        @title = path.basename(@uri)
        @isCollapsed = false
        @editorDescription.element.classList.add('description-editor')
        @skillItems = [ @miniEditorSkill.element ]
        @skillEditors = [ @miniEditorSkill ]
        @setCallbackSkillEditor(@miniEditorSkill.element)
        @switchXMLButton.on 'click', (e) =>
            atom.workspace.getActivePane().destroyActiveItem()
            @behaviorEditor.switchingXML = true
            atom.workspace.open(@uri)
        @on 'click', '.skill-list', (e) =>
            if @isCollapsed
                @isCollapsed = false
                e.currentTarget.classList.remove("collapsed")
                for skillElement in @skillItems
                    item = document.createElement("li")
                    item.classList.add("list-item", "mini-editor-skill")
                    item.appendChild(skillElement)
                    e.currentTarget.parentNode.appendChild(item)
            else
                @isCollapsed = true
                e.currentTarget.classList.add("collapsed")
                for skillElement in @skillItems
                    e.currentTarget.parentNode.removeChild(skillElement.parentNode)
        @on 'blur', 'atom-text-editor', (e) =>
            text = ''
            if e.currentTarget is @miniEditorSuperRole.element
                text = @miniEditorSuperRole.getText()
            else if @skillItems.indexOf(e.currentTarget) >= 0
                text = @skillEditors[@skillItems.indexOf(e.currentTarget)].getText()
            if @isValidFullName(text)
                e.currentTarget.classList.remove("invalid-uri")
            else
                e.currentTarget.classList.add("invalid-uri")
        @on 'keydown', 'atom-text-editor', (e) =>
            if e.ctrlKey and e.keyCode is 68 # ctrl-d
                text = ''
                if e.currentTarget is @miniEditorSuperRole.element
                    text = @miniEditorSuperRole.getText()
                if text isnt ''
                    atom.workspace.open(@toUri(text))
        @on 'focus', '.mini-editor-skill atom-text-editor', (e) =>
            @entitySelectView = new EntitySelectView(@behaviorEditor.index, 'skill', @skillEditors[@skillItems.indexOf(e.currentTarget)])
            @entitySelectView.attach()
        @on 'blur', '.mini-editor-skill atom-text-editor', (e) =>
            @entitySelectView?.detach()

    toUri: (text) ->
        return atom.project.getPaths()[0] + "\\src\\" + text.replace(/\./g, '\\') + ".xml"

    isValidFullName: (text) ->
        if text isnt ''
            uri = @toUri(text)
            return fs.existsSync(uri)
        else
            return true

    setCallbackSkillEditor: (e) ->
        @currentSkillConfirm = atom.commands.add e,
            'core:confirm': =>
                @confirmActiveSkillEditor()

    confirmActiveSkillEditor: (text) ->
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
        @skillItems.push(skillElement.firstElementChild)
        @skillEditors[@skillEditors.length - 1].setText(text) if text?
        @skillEditors.push(textEditor)
        textEditor.focus()
        @currentSkillConfirm.dispose()
        @setCallbackSkillEditor(textEditor.element)

    getURI: -> @uri

    getTitle: -> @title

    load: ->
        parser = new xml2js.Parser()
        fs.readFile @uri, (err, data) =>
            parser.parseString data, (err, result) =>
                if result
                    @fillView(result)
                else
                    @showError(err)

    save: ->
        # Invoked twice if 'Save' command is issued
        name = @miniEditorName.getText()
        role = [{ '_attr':
            'name': name
            'source-version': '1.0.0'
            'xmlns': 'http://www.masagroup.net/directia/schemas/bm'
        }]
        superRole = @miniEditorSuperRole.getText()
        if superRole isnt ''
            role[0]._attr.extends = superRole
        description = @editorDescription.getText()
        if description isnt ''
            role.push({'description': description})
        skills = []
        for skillEditor in @skillEditors
            skillName = skillEditor.getText()
            if skillName isnt ''
                skill = [
                    {'_attr': 
                        {'name': skillEditor.getText()}
                    }
                ]
                skills.push({skill: skill})
        if skills.length
            role.push({'skills': skills})
        xmlDocString = xml({'role': role}, {declaration: true, indent: '    '}) # 4 spaces indent
        fs.writeFileSync(@uri, xmlDocString)

    showError: (err) ->
        block = document.createElement('span')
        block.classList.add('inline-block')
        block.classList.add('highlight-error')
        block.textContent = 'Error: ' + err.message
        @element.appendChild(block)

    fillView: (doc) ->
        role = doc.role
        @miniEditorName.setText(role.$.name)
        @miniEditorSuperRole.setText(role.$.extends) if role.$.extends
        if role.description
            @editorDescription.setText(role.description[0])
        if role.skills and typeof role.skills[0] isnt 'string'
            for skill in role.skills[0].skill
                @confirmActiveSkillEditor(skill.$.name)
