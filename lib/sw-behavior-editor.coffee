SwBehaviorEditorView = require './sw-behavior-editor-view'
{BufferedProcess} = require 'atom'
#WizardRole = require './role-wizard'

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

  deactivate: ->
    @swBehaviorEditorView.destroy()

  serialize: ->
    swBehaviorEditorViewState: @swBehaviorEditorView.serialize()

  newRole: ->
    console.log 'New role'
    #console.log atom.project.path
    #@panel = atom.workspace.addModalPanel(item: new WizardRole())
    #@panel.show()

  build: ->
    command = atom.config.get('sw-behavior-editor.modelCompilerPath')
    #args = [ '-rootpath', "E:/models/sw.models/data/data/models/ada/decisional/dia5/models/src", '-rootpath', "E:/models/sw.models/data/data/models/ada/decisional/dia5/models/directia.core/directia.core.bml", '-licpath', "E:/SW_INSTALL/applications/nmi.lic", "E:/models/sw.models/data/data/models/ada/decisional/dia5/models/src"]
    licensePath = atom.config.get('sw-behavior-editor.licensePath')
    args = [ '-rootpath', atom.project.path + "/src", '-rootpath', atom.project.path + "/directia.core/directia.core.bml", '-licpath', licensePath, atom.project.path + "/src" ]
    stdout = (output) -> console.log(output)
    stderr = (output) -> console.log("Error : " + output)
    exit = (code) -> if code is 0 then console.log("Build successful") else console.log("Build failed")
    process = new BufferedProcess({ command, args, stdout, stderr, exit })
