

<cfinclude template="top.cfm">

<div class="card-body">

    <div class="steps steps-counter steps-blue">
        <span href="#" class="step-item active"></span>
        <span href="#" class="step-item"></span>
        <span href="#" class="step-item"></span>
    </div>

    <h2 class="card-title text-center mb-4">Country based or worldwide</h2>
    <p>
        Do you want to offer your project worldwide or only in certain countries?
    </p>

    <cfoutput>
    <form action="step2.cfm" method="post">
        <div class="mb-3">
            <label class="form-label">Make your choice:</label>
            <div class="form-selectgroup">
                <label class="form-selectgroup-item">
                    <input type="radio" name="world" value="1" class="form-selectgroup-input" checked>
                    <span class="form-selectgroup-label">
                        <i class="fas fa-globe-americas"></i>
                        Worldwide
                    </span>
                </label>
                <label class="form-selectgroup-item">
                    <input type="radio" name="world" value="0" class="form-selectgroup-input">
                    <span class="form-selectgroup-label w-100">
                        <i class="fas fa-flag-usa"></i>
                        Country based
                    </span>
                </label>
            </div>
        </div>
        <div class="mb-3 text-center">
            <button type="submit" class="btn btn-primary w-100">Save and next</button>
        </div>
    </form>
    </cfoutput>

</div>

<cfinclude template="bottom.cfm">