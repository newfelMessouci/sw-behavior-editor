SwBehaviorEditorView = require './sw-behavior-editor-view'
{BufferedProcess} = require 'atom'
RoleEditorView = require './role-editor-view'
RoleWizard = require './role-wizard'
path = require 'path'

module.exports =
  swBehaviorEditorView: null

  config:
      licensePath:
          type: 'string'
          default: 'sword.lic'
      modelCompilerPath:
          type: 'string'
          default: 'bin/bmc.exe'

  activate: (state) ->
    @swBehaviorEditorView = new SwBehaviorEditorView(state.swBehaviorEditorViewState)
    atom.commands.add 'atom-workspace', 'sw-behavior-editor:new-role': => @newRole()
    atom.commands.add 'atom-workspace', 'sw-behavior-editor:build': => @build()
    atom.workspace.addOpener (uri) =>
        if path.extname(uri) is '.xml'
            if not @switchingXML?
                return new RoleEditorView(uri, this)
            @switchingXML = null

  deactivate: ->
    @swBehaviorEditorView.destroy()

  serialize: ->
    swBehaviorEditorViewState: @swBehaviorEditorView.serialize()

  newRole: ->
    wizard = new RoleWizard()
    wizard.attach()

  build: ->
    command = atom.config.get('sw-behavior-editor.modelCompilerPath')
    licensePath = atom.config.get('sw-behavior-editor.licensePath')
    args = [ '-rootpath', atom.project.path + "/src", '-rootpath', atom.project.path + "/directia.core", '-licpath', licensePath, atom.project.path + "/src" ]
    stdout = (output) -> console.log(output)
    stderr = (output) -> console.log("Error : " + output)
    exit = (code) -> if code is 0 then console.log("Build successful") else console.log("Build failed")
    process = new BufferedProcess({ command, args, stdout, stderr, exit })
