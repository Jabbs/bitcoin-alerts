$('document').ready(function() {
});

var channelModalActions = function() {
  $(".close-channel-modal").click(function(e) {
    e.preventDefault();
    $('#channelModal').modal('hide');
  });

  $('#channelModal').on('hidden.bs.modal', function (e) {
    $("#channel-modal-container").empty();
  });

  $("a.subscription-create-link").click(function(e) {
    $(this).parent().html("<i class='fa fa-spinner fa-2x fa-pulse'></i>");
  });
};
