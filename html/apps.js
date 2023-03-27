window.addEventListener("message", function (event) {
    data = event.data;

    if (data.action == true) {
        if (data.firstJob != null) {
            $("#First_Jobs").html("Job 1 - "+data.firstJob);
            $("#First_Jobs_Button").attr("value", data.firstJobName)
        }else{
            $("#First_Jobs").html("Job Primary");
        }
        if (data.secJob != null) {
            $("#Sec_Jobs").html("Job 2 - "+data.secJob);
            $("#Sec_Jobs_Button").attr("value", data.secJobName)
        }else{
            $("#Sec_Jobs").html("Pengangguran");
        }
        $(".sec_job_container").fadeIn();
    } else {
        $(".sec_job_container").fadeOut();
    }
});

$("#First_Jobs_Button").click(function () {
	$.post('http://esx_joblisting/setFirstJobs', JSON.stringify({
		jobsName: $("#First_Jobs_Button").val(),
        jobsGrade: data.firstGrade
	}));
});

$("#Sec_Jobs_Button").click(function () {
	$.post('http://esx_joblisting/setSecJobs', JSON.stringify({
		jobsName: $("#Sec_Jobs_Button").val()
	}));
});

window.addEventListener("keyup", function onEvent(event) {
    // Close menu when key is released
    if (event.key == 'F6') {
      $.post("http://esx_joblisting/cJobs", JSON.stringify({}));
    }
  });