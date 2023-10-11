function updateButtonVisibility(approved) {
  if (approved) {
    $('.approve-button').hide();
    $('.disapprove-button').show();
    $('.book').show();
  } else {
    $('.approve-button').show();
    $('.disapprove-button').hide();
    $('.book').hide();
  }
}

$(document).ready(function() {
  
  var initialApprovedState = $('#bus-card').data('approved');
  updateButtonVisibility(initialApprovedState);

  $('.approve-button').on('click', function() {
    var busId = $(this).data('bus-id');
    $.ajax({
      url: '/approve/'+busId ,
      type: 'POST',
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      success: function(response) {
        if (response.status === 'success') {
          $(".custom_success").show().text(response.message)
          $(".custom_danger").hide();
          updateButtonVisibility(true);
          $('.status').text("Approved");
        } else {
          alert(response.message);
        }
      },
      error: function() {
        alert('Error in AJAX request');
      }
    });
  });

  $('.disapprove-button').on('click', function() {
    var busId = $(this).data('bus-id');
    
    $.ajax({
      url: '/disapprove/'+busId ,
      type: 'POST',
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      success: function(response) {
        if (response.status === 'success') {
          $(".custom_danger").show().text(response.message)
          $(".custom_success").hide()
          updateButtonVisibility(false);
          $('.status').text("Not approved");
        } else {
          alert(response.message);
        }
      },
      error: function() {
        alert('Error in AJAX request');
      }
    });
  });
});

