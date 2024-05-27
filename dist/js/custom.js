
function sweetAlert(type, thisURL, textOne, textTwo, buttonOne, buttonTwo) {

	if (type == "warning") {
		dangerMode = true;
	} else {
		dangerMode = false;
	}

	if (buttonTwo != '') {

		swal({
			title: textOne,
			text: textTwo,
			icon: type,
			buttons: [buttonOne, buttonTwo],
			dangerMode: dangerMode,
		})
		.then((willDelete) => {
			if (willDelete) {
				window.location.href = thisURL;
			};
			refreshButton();
		});

	} else {

		swal({
			title: textOne,
			text: textTwo,
			icon: type,
			buttons: [buttonOne]
			})
			.then(function(){
				refreshButton();
		});

	}

};

function refreshButton(){
	$('a.plan').each(function(i, obj) {
		$(this).text(obj.text);
		$(this).removeClass('disabled');
	});
}

// Save payment
function sendPayment() {
	var paymentModal = $('#dyn_modal-content');
	var formData = $("#sendPayment").serialize();
	var formAction = $("#sendPayment").attr("action");
	var formReturn = $("#sendPayment").data("return");
	$.ajax({
		type: "POST",
		url: formAction,
		data: formData,
		success: function (){
			paymentModal.load(formReturn);
		}
	});
}

// Delete payment
function deletePayment(paymentID) {

	var paymentModal = $('#dyn_modal-content');
	var formData = 'delete_payment=' + paymentID;
	var formAction = $("#sendPayment").attr("action");
	var formReturn = $("#sendPayment").data("return");
	$.ajax({
		type: "POST",
		url: formAction,
		data: formData,
		success: function(data){
			paymentModal.load(formReturn);
		}
	});
}

// for invoices (sysadmin)
function showResult(str) {
	if (str.length==0) {
		document.getElementById("livesearch").innerHTML="";
		return;
	}
	var xmlhttp=new XMLHttpRequest();
	xmlhttp.onreadystatechange=function() {
		if (this.readyState==4 && this.status==200) {
			document.getElementById("livesearch").innerHTML=this.responseText;
		}
	}
	xmlhttp.open("GET","/backend/core/views/sysadmin/ajax_search_customer.cfm?search="+str,true);
	xmlhttp.send();
}
function intoTf(c, i) {
	var customer_name = document.getElementById("searchfield");
	customer_name.value = c;
	var customer_id = document.getElementById("customer_id");
	customer_id.value = i;
}
function hideResult() {
	document.getElementById("livesearch").innerHTML="";
	return;
}


$(document).ready(function(){

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


	$(".hand").mouseup(function(){
		$(".hand").css( "cursor","grab");
	}).mousedown(function(){
		$(".hand").css( "cursor","grabbing");
	});


	$("#checkAll").change(function () {
		$("input:checkbox").prop('checked', $(this).prop("checked"));
	});
	$('#checkall tr').click(function(event) {
		if (event.target.type !== 'checkbox') {
			$(':checkbox', this).trigger('click');
		}
	});

	// load modal with dynamic content (general)
	$('.openPopup').on('click',function(){
		var dataURL = $(this).attr('data-href');
		$('#dyn_modal-content').load(dataURL,function(){
			$('#dynModal').modal('show');
			window.Litepicker && (new Litepicker({
				element: document.getElementById('date1'),
				buttonText: {
					previousMonth: `<i class="fas fa-angle-left" style="cursor: pointer;"></i>`,
					nextMonth: `<i class="fas fa-angle-right" style="cursor: pointer;"></i>`,
				},
			}));
			window.Litepicker && (new Litepicker({
				element: document.getElementById('date2'),
				buttonText: {
					previousMonth: `<i class="fas fa-angle-left" style="cursor: pointer;"></i>`,
					nextMonth: `<i class="fas fa-angle-right" style="cursor: pointer;"></i>`,
				},
			}));
		});
	});

	// load modal with dynamic content (general big)
	$('.openPopup_big').on('click',function(){
		var dataURL = $(this).attr('data-href');
		$('#dyn_modal-content').load(dataURL,function(){
			$('#dynModal_big').modal('show');
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

	// Change plan prices
	$('.radio-toggle').toggleInput();
	$('.form-check-label').click(function() {
		if ($(this).hasClass("yearly")) {
			$(".price_box.yearly").show();
			$(".price_box.monthly").hide();
		}
		else if ($(this).hasClass("monthly")){
			$(".price_box.yearly").hide();
			$(".price_box.monthly").show();
		}
	});

	// Picture upload field
	$('.dropify').dropify();

	$("#submit_form").submit(function () {
		$("#submit_button").attr("disabled", true).addClass("not-allowed");
		return true;
	});


	//Dashboard widget sorting
	$('div.dashboard').sortable({
		handle: '.move-widget',
		tolerance: 'pointer',
		placeholder: 'widget-placeholder',
		start: function(event, ui ){
			var classes = ui.item.attr('class').split(/\s+/);
			for(var x=0; x<classes.length; x++){
			  	if (classes[x].indexOf("col") > -1){
					ui.placeholder.addClass(classes[x]);
				}
			}
			ui.placeholder.css({
				width: ui.item.innerWidth() - 30 + 1,
				height: ui.item.innerHeight() - 15 + 1,
				padding: ui.item.css("padding")
			});
	   	},
		stop: function(event, ui) {
			$.post('/dashboard-settings', {sortorder:$(this).sortable('serialize')});
		}
	}).disableSelection();

	$('.disable-widget').on('change', function(){

		var $isvisible = $(this).closest('div.card-header').find('span.isvisible');
		var $isinvisible = $(this).closest('div.card-header').find('span.isinvisible');
		var $targetWidget = $(this).closest('div.card').find('div.card-body');

		if( $(this).prop('checked') ){
			$.post('/dashboard-settings', {action:'disable', id:$(this).val(), active:1}, function(){
				$targetWidget.removeClass('widget-disabled');
				$isinvisible.hide();
				$isvisible.show();
			});
		}else{
			$.post('/dashboard-settings', {action:'disable', id:$(this).val(), active:0}, function(){
				$targetWidget.addClass('widget-disabled');
				$isvisible.hide();
				$isinvisible.show();
			});
		}
	});


	// Disable button when changing a module
	$('body').on('click', 'a.activate-module', function(e){

		e.preventDefault();
		var moduleUrl = $(this).attr('href');

		$('a.activate-module').addClass('pe-none');
		$('a.activate-module').attr('aria-disabled', true);

		$('i.activate-lock').each(function(i, obj) {
			$(obj).parent().addClass('pe-none');
			$(obj).replaceWith('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>&nbsp;');
		});

		location.href = moduleUrl;
	});


	// Disable button when changing a plan
	$('body').on('click', 'a.plan', function(e){

		e.preventDefault();
		var planUrl = $(this).attr('href');

		$('a.plan').each(function(i, obj) {
			$(obj).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>&nbsp;' + obj.text);
			$(obj).addClass('disabled');
		});

		location.href = planUrl;
	});

	// Update the plan
	$('.plan_edit').on('click', function(){

		var plan_id = $(this).val();
		var recurring = '';

		$('.plan_recurring').each(function(){
			if( $(this).prop('checked') ){
				recurring = $(this).val();
			}
		});

		if(recurring == ''){
			$(".plan_recurring[value='monthly']").prop('checked', true);
			recurring = 'monthly';
		}

		$('#change_plan').load('/backend/core/views/plan_calc.cfm?plan_id=' + plan_id + '&recurring=' + recurring);

	});

	$('.plan_recurring').on('click', function(){

		var plan_id;
		var recurring = $(this).val();


		$('.plan_edit').each(function(){
			if( $(this).prop('checked') ){
				plan_id = $(this).val();
			}
		});

		$('#change_plan').load('/backend/core/views/plan_calc.cfm?plan_id=' + plan_id + '&recurring=' + recurring);


	});

	let in1 = document.getElementById('otc-1'),
    ins = document.querySelectorAll('input[type="number"]'),
	 splitNumber = function(e) {
		let data = e.data || e.target.value;
		if ( ! data ) return;
		if ( data.length === 1 ) return;

		popuNext(e.target, data);
	},
	popuNext = function(el, data) {
		el.value = data[0];
		data = data.substring(1);
		if ( el.nextElementSibling && data.length ) {
			popuNext(el.nextElementSibling, data);
		}
	};

	ins.forEach(function(input) {
		input.addEventListener('keyup', function(e){
			if (e.keyCode === 16 || e.keyCode == 9 || e.keyCode == 224 || e.keyCode == 18 || e.keyCode == 17) {
				return;
			}

			if ( (e.keyCode === 8 || e.keyCode === 37) && this.previousElementSibling && this.previousElementSibling.tagName === "INPUT" ) {
				this.previousElementSibling.select();
			} else if (e.keyCode !== 8 && this.nextElementSibling) {
				this.nextElementSibling.select();
			}

			if ( e.target.value.length > 1 ) {
				splitNumber(e);
			}
		});

		input.addEventListener('focus', function(e) {
			if ( this === in1 ) return;

			if ( in1.value == '' ) {
				in1.focus();
			}

			if ( this.previousElementSibling.value == '' ) {
				this.previousElementSibling.focus();
			}
		});
	});

	in1.addEventListener('input', splitNumber);

	$('input[name="mfa_6"]').keyup(function(){
		if(validateCode()){
			$("#mfa_form").submit();
		}
	});

	$("#mfa_form input").on("paste", function(){
		setTimeout(function() {
			$("#mfa_form").submit();
		});
	});

});

function generateUUID()
{
	var d = new Date().getTime();

	if( window.performance && typeof window.performance.now === "function" )
	{
		d += performance.now();
	}

	var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c)
	{
		var r = (d + Math.random()*16)%16 | 0;
		d = Math.floor(d/16);
		return (c=='x' ? r : (r&0x3|0x8)).toString(16);
	});

return uuid;
}

$( '#keygen' ).on('click',function()
{
	$( '#apiKey' ).val( generateUUID() );
});

function validateCode()
{
	mfacode1 = $("#otc-1").val();
	mfacode2 = $("#otc-2").val();
	mfacode3 = $("#otc-3").val();
	mfacode4 = $("#otc-4").val();
	mfacode5 = $("#otc-5").val();
	mfacode6 = $("#otc-6").val();
	if(mfacode1.length != '' && mfacode2.length != '' && mfacode3.length != '' && mfacode4.length != '' && mfacode5.length != '' && mfacode6.length != ''){
		return true;
	} else {
		return false;
	}
}

function validateInput(input) {

	input.value = input.value.replace(/\s/g, '');

	if (input.value.length > 1) {
		input.value = input.value.slice(0, 1);
	}
}

function onlyDigits(event) {
	var charCode = (event.which) ? event.which : event.keyCode;
	if (charCode > 31 && (charCode < 48 || charCode > 57)) {
		event.preventDefault();
		return false;
	}
	return true;
}

$(document).ready(function(){

	$('input[name="sysadmin"]').on('click', function(){
		if($('input[name="sysadmin"]').prop('checked')){
			$('input[name="superadmin"]').prop('checked', true);
			$('input[name="admin"]').prop('checked', true);
		}
	});

	$('input[name="superadmin"]').on('click', function(){
		if($('input[name="superadmin"]').prop('checked')){
			$('input[name="admin"]').prop('checked', true);
		} else {
			$('input[name="sysadmin"]').prop('checked', false);
		}
	});

	$('input[name="admin"]').on('click', function(){
		if(!$('input[name="admin"]').prop('checked')){
			$('input[name="sysadmin"]').prop('checked', false);
			$('input[name="superadmin"]').prop('checked', false);
		}
	});

	// Sysadmin settings for Swiss QR Bill
    $('#roundFactorSelect').change(function() {
        var selectedValue = $(this).val();
        if (selectedValue === '5') {
            $('#QrBillContainer').show();
        } else {
            $('#QrBillContainer').hide();
            $('#QrBillCheckbox').val('0');
            $('#extraLink').hide();
        }
    });
    $('#QrBillCheckbox').change(function() {
        if ($(this).val() === '1') {
            $('#extraLink').show();
        } else {
            $('#extraLink').hide();
        }
    });
    if ($('#roundFactorSelect').val() === '5') {
        $('#QrBillContainer').show();
        if ($('#QrBillCheckbox').val() === '1') {
            $('#extraLink').show();
        } else {
            $('#extraLink').hide();
        }
    } else {
        $('#QrBillContainer').hide();
        $('#extraLink').hide();
    }

});


// Frontend-Mapping + Modal
$(document).ready(function() {
    const maxPixels = {
        metatitle: 580,
        metadescription: 1000
    };

    function updatePixelCount(inputId, progressId, progressBarId, maxPixels, fontSettings) {
        const input = document.getElementById(inputId);
        const progress = document.getElementById(progressId);
        const progressbar = document.getElementById(progressBarId);
        const text = input.value;
        const pixels = getTextWidth(text, fontSettings);
        const percentage = (pixels / maxPixels) * 100;
        progress.style.width = percentage + '%';

        progressbar.textContent = pixels + ' px / ' + maxPixels + ' px';

        if (percentage <= (200 / maxPixels) * 100) {
            progress.style.backgroundColor = 'orange';
        } else if (percentage > 100) {
            progress.style.backgroundColor = 'red';
        } else {
            progress.style.backgroundColor = 'green';
        }
    }

    function getTextWidth(text, fontSettings) {
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        context.font = fontSettings;
        return Math.round(context.measureText(text).width);
    }

    $('[id^=input]').each(function() {
        const id = $(this).attr('id').replace('input', '');
        const maxPixelValue = id.includes('Desc') ? maxPixels.metadescription : maxPixels.metatitle;
        const fontSettings = id.includes('Desc') ? '400 14px Arial, sans-serif' : '400 20px Roboto, HelveticaNeue, Arial, sans-serif';
        updatePixelCount(`input${id}`, `progress${id}`, `progressbar${id}`, maxPixelValue, fontSettings);

        $(this).on('input', function() {
            updatePixelCount(`input${id}`, `progress${id}`, `progressbar${id}`, maxPixelValue, fontSettings);
        });
    });

    // Event listener for modal shown
    $(document).on('shown.bs.modal', '.modal', function (e) {
        const targetId = $(e.relatedTarget).data('bs-target');

        if (targetId && (targetId.includes('frontend_metatitle') || targetId.includes('frontend_metadescription'))) {
            const modal = $(e.target);
            const textareas = modal.find('textarea');

            textareas.each(function() {
                const textarea = $(this);
                const textareaId = textarea.attr('id') || `textarea${Date.now() + Math.random().toString(36).substr(2, 9)}`;
                textarea.attr('id', textareaId); // Ensure textarea has an ID
                const progressId = `progress${textareaId}`;
                const progressbarId = `progressbar${textareaId}`;
                const maxPixelValue = targetId.includes('metadescription') ? maxPixels.metadescription : maxPixels.metatitle;
                const fontSettings = targetId.includes('metadescription') ? '400 14px Arial, sans-serif' : '400 20px Roboto, HelveticaNeue, Arial, sans-serif';

                // Add progress bar HTML dynamically
                if (!document.getElementById(progressId)) {
                    textarea.after(`
                        <div class="d-flex mt-2">
                            <div class="progress-bar" style="flex-grow: 1;">
                                <div id="${progressId}" class="progress"></div>
                            </div>
                            <div id="${progressbarId}" class="progress-text" style="margin-left: 10px;">0 px / ${maxPixelValue} px</div>
                        </div>
                    `);
                }

                updatePixelCount(textareaId, progressId, progressbarId, maxPixelValue, fontSettings);

                textarea.on('input', function() {
                    updatePixelCount(textareaId, progressId, progressbarId, maxPixelValue, fontSettings);
                });
            });
        }
    });
});








