SwBehaviorEditorView = require './sw-behavior-editor-view'
{BufferedProcess} = require 'atom'
RoleEditorView = require './role-editor-view'
RoleWizard = require './role-wizard'
path = require 'path'
xml2js = require 'xml2js'
_ = require 'underscore-plus'

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
    @index = @getIndex()
    console.log 'model indexed'
    atom.workspace.addOpener (uri) =>
        if path.extname(uri) is '.xml'
            name = @getFullName(uri)
            entry = @getIndexEntry(name)
            if not @switchingXML? and entry?.type is 'role'
                return new RoleEditorView(uri, this)
            @switchingXML = null
    #console.dir @index

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
    projectPath =  atom.project.getPaths()[0]
    args = [ '-rootpath', projectPath + "/src", '-rootpath', projectPath + "/directia.core", '-licpath', licensePath, projectPath + "/src" ]
    stdout = (output) -> console.log(output)
    stderr = (output) -> console.log("Error : " + output)
    exit = (code) -> if code is 0 then console.log("Build successful") else console.log("Build failed")
    process = new BufferedProcess({ command, args, stdout, stderr, exit })

  getIndex: ->
      root = atom.project.getDirectories()[0]
      @src = root.getSubdirectory('src')
      @callbacks = {}
      @files = @getXMLFiles(@src)
      entries = [] # index entries
      for file in @files
          if path.extname(file) is '.xml'
              fullName = @getFullName(file)
              entry = {name: fullName}
              @setEntityType(file, entry) # asynchronously
              entries.push(entry)
      return entries

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

  setEntityType: (path, indexEntry) ->
      parser = new xml2js.Parser()
      fs.readFile path, (err, data) =>
          parser.parseString data, (err, doc) =>
              if doc
                  # Return the name of the root element, if any
                  roots = (root for own root of doc)
                  if roots.length
                      indexEntry.type = roots[0]
              else
                  console.log err
    
  getIndexEntry: (name) ->
      return _.find(@index, (entry) -> return entry.name is name)
      