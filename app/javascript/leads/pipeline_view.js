const makeDraggable = (selector) => {
  $(selector).draggable({
    stack: ".draggable",
    scroll: "true",
    revert: "invalid",
    containment: "body",
  });
};

const makeDropzone = (selector) => {
  $(selector).droppable({
    drop: function (event, ui) {
      var draggedElement = $(ui.draggable);
      var targetList = event.target;

      updateLeadStage(draggedElement, targetList);
    },
  });
};

// without this, the drop position would not be correct
const clearOffset = (element) => {
  $(element).css("top", "0").css("left", 0);
};

const appendIntoTarget = (item, target) => {
  $(target).append(item);
};

const updateLeadStage = (draggedElement, targetList) => {
  const id = $(draggedElement).data("lead-id");
  const stage = $(targetList).data("stage-name");
  const url = `${window.location.origin}/leads/${id}/change_stage`;

  payload = {
    lead: { stage: stage },
  };

  $.ajax({
    url: url,
    method: "PATCH",
    data: payload,
    success: function (data) {
      draggedElement.detach();
      appendIntoTarget(draggedElement, targetList);
      clearOffset(draggedElement);
      makeDraggable(draggedElement);
    },
  });
};

const attachClickListenersToLeads = () => {
  $(".lead").click(function (event) {
    const id = $(this).data("lead-id");
    const url = `${window.location.origin}/leads/${id}/edit`;

    $.ajax({
      url: url,
      method: "GET",
    });
  });
};

window.reloadDropzone = function() {
  makeDraggable(".draggable");
  makeDropzone(".dropzone");
  attachClickListenersToLeads(); // should be attached after the attachment of draggable event
}