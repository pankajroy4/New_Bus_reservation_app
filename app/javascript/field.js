
$(document).ready(function() {
  $('#user_role').change(function() {
    updateFormFields();
  });

  updateFormFields();

  function updateFormFields() {
    var selectedRole = $('#user_role').val();

    $('#registrationNumberField').hide();

    if (selectedRole === 'bus_owner') {
      $('#registrationNumberField').show();
    } else  {
      $('#registrationNumberField').hide();
    }
  }
});