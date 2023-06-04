  $(document).ready(function() {
    var input = $('#search_input');
    var results = $('#search_results');

    input.on('input', function() {
      var query = input.val();

      if (query.length >= 2) {
        $.ajax({
          url: '/users/search',
          type: 'POST',
          data: { search_query: query },
          success: function(response) {
            results.html(response);
          },
          error: function() {
            results.html('<p>Error occurred while searching.</p>');
          }
        });
      } else {
        results.empty();
      }
    });
  });