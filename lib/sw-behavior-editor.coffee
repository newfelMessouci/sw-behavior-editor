SwBehaviorEditorView = require './sw-behavior-editor-view'
{BufferedProcess} = require 'atom'
WizardRole = require './role-wizard'

module.exports =
  swBehaviorEditorView: null

  activate: (state) ->
    @swBehaviorEditorView = new SwBehaviorEditorView(state.swBehaviorEditorViewState)
    atom.commands.add 'atom-workspace', 'sw-behavior-editor:new-role': => @newRole()
    atom.commands.add 'atom-workspace', 'sw-behavior-editor:build': => @build()

  deactivate: ->
    @swBehaviorEditorView.destroy()

  serialize: ->
    swBehaviorEditorViewState: @swBehaviorEditorView.serialize()

  newRole: ->
    #console.log 'Salut 2'
    #console.log atom.project.path
    @panel = atom.workspace.addModalPanel(item: new WizardRole())
    @panel.show()

  build: ->
    command = 'E:/sw.directia/bin/bmc.exe'
    #args = [ '-rootpath', "E:/models/sw.models/data/data/models/ada/decisional/dia5/models/src", '-rootpath', "E:/models/sw.models/data/data/models/ada/decisional/dia5/models/directia.core/directia.core.bml", '-licpath', "E:/SW_INSTALL/applications/nmi.lic", "E:/models/sw.models/data/data/models/ada/decisional/dia5/models/src"]
    args = [ '-rootpath', atom.project.path + "/src", '-rootpath', atom.project.path + "/directia.core/directia.core.bml", '-licpath', "E:/SW_INSTALL/applications/nmi.lic", atom.project.path + "/src" ]
    stdout = (output) -> console.log(output)
    stderr = (output) -> console.log("Error : " + output)
    exit = (code) -> if code is 0 then console.log("Build successful") else console.log("Build failed")
    process = new BufferedProcess({ command, args, stdout, stderr, exit })
