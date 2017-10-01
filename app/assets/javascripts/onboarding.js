$('document').ready(function() {
  $('#editRoleModal').modal('show');

  $("a.passreset-link").click(function(e) {
    e.preventDefault();
    $('#signupOptionsModal, #signupModal, #loginModal').modal('hide');
    $('#passresetModal').modal('show');
    $("#pass_reset_email input.form-control").focus();
  });

  $(".login-link, .login-link-inner").click(function(e) {
    e.preventDefault();
    $('#signupModal, #signupOptionsModal, #passresetModal').modal('hide');
    $('#loginModal').modal('show');
    $(".login-form #login_email").focus();
  });

  $(".signup-link, .signup-link-inner").click(function(e) {
    e.preventDefault();
    $('#loginModal, #signupOptionsModal, #passresetModal').modal('hide');
    $('#signupModal').modal('show');
    $("input#user_first_name").focus();
  });

  $(".signup-options-link").click(function(e) {
    e.preventDefault();
    $('#loginModal, #signupModal, #passresetModal').modal('hide');
    $('#signupOptionsModal').modal('show');
  });
});
