$(document).on('ready turbolinks:load', function() {
    $('.mobile-lead-stage-select-link').on('click', function(e) {
      e.preventDefault();
  
      var stageData = $(this).data("stage");
  
      $('.mobile-lead-stage-selected-name').text(stageData);
  
      if (stageData === "all") {
        $('.mobile-lead-stage-lead-item').removeClass('active').addClass('active');
      } else {
        $('.mobile-lead-stage-lead-item').removeClass('active');
        $('.mobile-lead-stage-lead-item[data-stage="' + stageData + '"]').addClass('active');
      }
    });
  });
  