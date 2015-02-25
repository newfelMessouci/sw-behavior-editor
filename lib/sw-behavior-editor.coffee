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
    index = @getIndex()
    console.log 'model indexed'
    #console.dir index

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

  getIndex: ->
      root = atom.project.getDirectories()[0]
      @src = root.getSubdirectory('src')
      @callbacks = {}
      @files = @getXMLFiles(@src)
      fullNames = []
      for file in @files
          if path.extname(file) is '.xml'
              fullName = @getFullName(file)
              fullNames.push(fullName)
      return fullNames
      
  getXMLFiles: (dir) ->
      files = []
      for entry in dir.getEntriesSync()
          if entry.isFile()
              p = entry.getPath()
              ext = path.extname(p)
              if ext is '.xml' or ext is '.lua' or ext is '.bms'
                  files.push(p)
                  if ext is '.xml'
                      @callbacks[p] = entry.onDidRename( (() => oldPath = p; newEntry = entry; () => @rename(oldPath, newEntry.getPath(), newEntry) )()  )
          else if entry.isDirectory()
              dirFiles = @getXMLFiles(entry)
              files = files.concat(dirFiles)
      return files

  rename: (oldPath, newPath, newFile) ->
      console.log "Old path: " + oldPath
      console.log "New path: " + newPath
      
      i = @files.indexOf(oldPath)
      if i < 0
          console.log "Old path not found in index"

      @files[i] = newPath
      @callbacks[newPath] = newFile.onDidRename( (() => oldPath2 = newPath; newEntry = newFile; () => @rename(oldPath2, newEntry.getPath(), newEntry) )() )
          
      oldName = @getFullName(oldPath)
      newName = @getFullName(newPath)
      oldRegex = oldName.replace(/\./g, '\\.') + '(?=[^0-9A-Za-z_])'
      
      atom.workspace.replace(new RegExp(oldRegex), newName, @files, (options) -> 
          if options?
              console.log 'in ' + options.filePath + ': ' + options.replacements + ' replacements')
      
      @callbacks[oldPath].dispose()
      
  getFullName: (path) ->
      relPath = @src.relativize(path)
      relPath.replace('.xml', '').replace(/\\/g, '.')
      