

function sweetAlert(type, thisURL, textOne, textTwo, buttonOne, buttonTwo) {

	if (type == 'warning') {

		swal({
			title: textOne,
			text: textTwo,
			icon: "warning",
			buttons: [buttonOne, buttonTwo],
			dangerMode: true,
		  })
		  .then((willDelete) => {
			if (willDelete) {
				window.location.href = thisURL;
			}
		});

	} else {

		swal({
			title: textOne,
			text: textTwo,
			icon: "success"
		})

	}

};


$('#dragndrop_body').sortable({
	handle: ".move",
	start: function (event, ui) {
		if (navigator.userAgent.toLowerCase().match(/firefoxy/) && ui.helper !== undefined) {
			alert('ff');
			ui.helper.css('position', 'absolute').css('margin-top', $(window).scrollTop());
			//wire up event that changes the margin whenever the window scrolls.
			$(window).bind('scroll.sortableplaylist', function () {
				ui.helper.css('position', 'absolute').css('margin-top', $(window).scrollTop());
			});
		}
	},
	beforeStop: function (event, ui) {
		if (navigator.userAgent.toLowerCase().match(/firefoxy/) && ui.offset !== undefined) {
			$(window).unbind('scroll.sortableplaylist');
			ui.helper.css('margin-top', 0);
		}
	},
	helper: function (e, ui) {
	ui.children().each(function () {
		$(this).width($(this).width());
	});
	return ui;
	},
	scroll: true,
	stop: function (event, ui) {
		fnSaveSort();
	}
});

$(document).ready(function() {
	$(".hand").mouseup(function(){
		$(".hand").css( "cursor","grab");
	}).mousedown(function(){
		$(".hand").css( "cursor","grabbing");
	});
});

$(document).ready(function() {
	$("#checkAll").change(function () {
		$("input:checkbox").prop('checked', $(this).prop("checked"));
	});
	$('#checkall tr').click(function(event) {
		if (event.target.type !== 'checkbox') {
			$(':checkbox', this).trigger('click');
		}
	});
});

// load modal with dynamic content
$(document).ready(function(){
    $('.openPopup').on('click',function(){
        var dataURL = $(this).attr('data-href');
        $('#dyn_modal-content').load(dataURL,function(){
            $('#dynModal').modal('show');
        });
    });
});

// Load trumbowyg editor
$('.editor').each(function(index, element){
    var $this = $(element);
    $this.trumbowyg({
		btns: [
			['viewHTML'], ['bold', 'italic'], ['link'], ['formatting'], ['justifyLeft', 'justifyCenter', 'justifyRight', 'justifyFull'], ['unorderedList', 'orderedList']
		]
    });
});

