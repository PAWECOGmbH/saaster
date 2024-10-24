/* ===========================================================
 * trumbowyg.pasteimage.js v1.0
 * Basic base64 paste plugin for Trumbowyg
 * http://alex-d.github.com/Trumbowyg
 * ===========================================================
 * Author : Alexandre Demode (Alex-D)
 *          Twitter : @AlexandreDemode
 *          Website : alex-d.fr
 */

(function ($) {
    'use strict';

    $.extend(true, $.trumbowyg, {
        plugins: {
            pasteImage: {
                init: function (trumbowyg) {
                    trumbowyg.pasteHandlers.push(function (pasteEvent) {
                        try {
                            var items = (pasteEvent.originalEvent || pasteEvent).clipboardData.items,
                                mustPreventDefault = false,
                                reader;

                            var taskid = $(pasteEvent.delegateTarget.nextSibling).data('taskid');
                            
                            console.log( taskid );


                            for (var i = items.length - 1; i >= 0; i -= 1) {
                                if (items[i].type.match(/^image\//)) {
                                    
                                    reader = new FileReader();
                                    /* jshint -W083 */
                                    reader.onloadend = function (event) {

                                        var blob = dataURItoBlob(event.target.result);
                                        var formData = new FormData();
                                        formData.append('picture', blob);
                                        formData.append('taskid', taskid);

                                        $.ajax({
                                            url: baseFolder + '/upload-screenshot.cfm', 
                                            type: "POST",
                                            cache: false,
                                            contentType: false,
                                            processData: false,
                                            data: formData
                                        }).done(function(result){
                                                var jsresult = JSON.parse(result);
                                                console.log(jsresult);
                                                trumbowyg.execCmd('insertImage', jsresult.URL, false, true);
                                            });

                                        //prosave(event.target.result);
                                        //trumbowyg.execCmd('insertImage', dataURI, false, true);

                                        
                                    };
                                    /* jshint +W083 */
                                    reader.readAsDataURL(items[i].getAsFile());

                                    mustPreventDefault = true;
                                }
                            }

                            if (mustPreventDefault) {
                                pasteEvent.stopPropagation();
                                pasteEvent.preventDefault();
                            }
                        } catch (c) {
                        }
                    });
                }
            }
        }
    });

	function dataURItoBlob(dataURI) {
		'use strict'
		var byteString, 
			mimestring 
	
		if(dataURI.split(',')[0].indexOf('base64') !== -1 ) {
			byteString = atob(dataURI.split(',')[1])
		} else {
			byteString = decodeURI(dataURI.split(',')[1])
		}
	
		mimestring = dataURI.split(',')[0].split(':')[1].split(';')[0]
	
		var content = new Array();
		for (var i = 0; i < byteString.length; i++) {
			content[i] = byteString.charCodeAt(i)
		}
	
		return new Blob([new Uint8Array(content)], {type: mimestring});
	}
	
	function prosave(dataURI) {
	
		var blob = dataURItoBlob(dataURI);
		
        var myzone = Dropzone.forElement("div.dropzone");
        //myzone.addFile(dataURI);
        myzone.addFile(blob, "pastefile");
	
	}



})(jQuery);

function insertToEditor(dataURI) {
	
    //alert('hier');
    trumbowyg.execCmd('insertImage', dataURI, false, true);

}
