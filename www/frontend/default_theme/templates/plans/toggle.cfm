<cfoutput>

<div class="container-sm py-4 px-3 mx-auto w-25">

    <div class="mb-5">
        <div class="btn-group w-100 mt-3" role="group">

            <!-- Monthly Option -->
            <input type="radio" class="btn-check" name="payment_changer" id="monthly" value="monthly" checked>
            <label class="btn btn-outline-primary monthly" for="monthly">#getTrans('txtMonthly')#</label>

            <!-- Yearly Option -->
            <input type="radio" class="btn-check" name="payment_changer" id="yearly" value="yearly">
            <label class="btn btn-outline-primary yearly" for="yearly">#getTrans('txtYearly')#</label>

        </div>
    </div>

</div>

</cfoutput>