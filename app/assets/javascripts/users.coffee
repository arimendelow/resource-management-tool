# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.togglePassword = () ->
  console.log("TogglePassword run!")
  # Function for toggling the visibilty of the password in a form
  # Need to check if the element is found first, else it'll throw an error as it'll be setting onclick of null
  if (document.getElementById('toggle_password') == null) then return
  document.getElementById('toggle_password').onclick = ->
    passfield = document.querySelector('#password_field')
    # console.log("toggling password!")
    if (passfield.type == 'password') then (passfield.type = 'text') else (passfield.type = 'password')
    return
