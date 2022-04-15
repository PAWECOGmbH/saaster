
<cfoutput>

<script src="#application.mainURL#/dist/js/jquery-3.6.0.min.js"></script>
<script src="#application.mainURL#/dist/js/dropify.min.js"></script>

<script src="#application.mainURL#/dist/js/tabler.min.js"></script>
<script src="#application.mainURL#/dist/js/litepicker.js"></script>

<!-- Sweet alert Plugin -->
<script src="#application.mainURL#/dist/js/sweetalert.min.js"></script>

<!--- Searching in a select --->
<script src="#application.mainURL#/dist/js/search_select.js"></script>

<!--- Drag'n'drop --->
<script src="#application.mainURL#/dist/js/jquery-ui.min.js"></script>

<!--- Trumbowyg editor --->
<script src="#application.mainURL#/dist/trumbowyg/trumbowyg.min.js"></script>


<!--- Custom JS --->
<script src="#application.mainURL#/dist/js/custom.js"></script>

</cfoutput>

<script>

<cfif thiscontent.thisPath eq "views/dashboard.cfm">
    // load content into widget
    $(document).ready(function(){
        var dataURL = $('.widget').attr('data-href');
        $('.widget').load(dataURL);
    });
</cfif>

$('.dropify').dropify();

$(document).ready(function () {
    $("#submit_form").submit(function () {
        $("#submit_button").attr("disabled", true).addClass("not-allowed");
        return true;
    });
});

</script>


<!--- Disable Browser-back after logout --->
<cfif structKeyExists(url, "logout")>
    <script>
        (function (global) {
            if(typeof (global) === "undefined") {
                throw new Error("window is undefined");
            }
            var _hash = "!";
            var noBackPlease = function () {
                global.location.href += "#";

                global.setTimeout(function () {
                    global.location.href += "!";
                }, 50);
            };
            global.onhashchange = function () {
                if (global.location.hash !== _hash) {
                    global.location.hash = _hash;
                }
            };
            global.onload = function () {
                noBackPlease();
                document.body.onkeydown = function (e) {
                    var elm = e.target.nodeName.toLowerCase();
                    if (e.which === 8 && (elm !== 'input' && elm  !== 'textarea')) {
                        e.preventDefault();
                    }
                    e.stopPropagation();
                };
            }
        })(window);
    </script>
</cfif>