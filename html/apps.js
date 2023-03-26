window.addEventListener("message", function (event) {
    data = event.data;

    if (data.action == true) {
        if (data.secJob != null) {
            $("#Sec_Jobs").html(data.secJob);
        }else{
            $("#Sec_Jobs").html("Pengangguran");
        }
        if (data.firstJob != null) {
            $("#First_Jobs").html(data.firstJob);
        }else{
            $("#First_Jobs").html("Job Primary");
        }
        $(".sec_job_container").fadeIn();
    } else {
        $(".sec_job_container").fadeOut();
    }
});

window.addEventListener("keyup", function onEvent(event) {
    // Close menu when key is released
    if (event.key == 'F6') {
      $.post("http://esx_joblisting/cJobs", JSON.stringify({}));
    }
  });