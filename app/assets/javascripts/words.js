  // Add Cost Item row
  $('form').on('click', '#add_transl_btn', function(event) {
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    // Add ci row
    $(this).parent().before($(this).data('fields').replace(regexp, time) );
    event.preventDefault();
  });

   // Remove Cost Item row
  $('form').on('click', '.remove_word_btn', function(event) {
    // mark destroy field as 1
    $(this).prev('input[type=hidden]').val('1');
    // hide ci row
    $(this).parent().parent().parent().hide();
    event.preventDefault();
  }); 