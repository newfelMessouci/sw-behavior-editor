module.exports =
class SwBehaviorEditorView
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('sw-behavior-editor',  'overlay', 'from-top')

    # Create message element
    message = document.createElement('div')
    message.textContent = "Enter the role name"
    message.classList.add('message')

    textBox = document.createElement('INPUT')
    textBox.setAttribute("type", "text")
    textBox.classList.add(

    )
    @element.appendChild(message)
    @element.appendChild(textBox)

    # Register command that toggles this view
    atom.commands.add 'atom-workspace', 'sw-behavior-editor:toggle': => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  # Toggle the visibility of this view
  toggle: ->
    console.log 'SwBehaviorEditorView was toggled!'

    if @element.parentElement?
      @element.remove()
    else
      atom.workspaceView.append(@element)
