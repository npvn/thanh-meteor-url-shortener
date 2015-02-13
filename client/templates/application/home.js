Template.home.events({
  'submit form': function(e) {
    e.preventDefault();
    var longUrl = $(e.target).find('#long-url-input').val(),
        customUrl = $(e.target).find('#custom-url-input').val(),
        isPrivate = $('#private').is(':checked') ? true : false,
        urlInput = {
          longUrl: longUrl,
          customUrl: customUrl,
          isPrivate: isPrivate
        };

    Helpers.validateLongUrl(longUrl);
    if ( customUrl ) {
      Helpers.validateCustomUrl(customUrl);
    }

    Meteor.call('urlInsert', urlInput, function(error, result) {
      if (error) {
        Errors.insert({message: error.reason});
      } else  {
        $('#long-url-input').val('');
        $('#custom-url-input').val('');
        $('#private').prop('checked', false);
      }
    });
  }
});