
<!--- This is a demo file which will be loaded into a widget on the dashboard. --->

<cfsetting showdebugoutput="no">
<div class="card">
    <div class="card-body">
    <div class="d-flex align-items-center">
        <div class="subheader">Sales</div>
        <div class="ms-auto lh-1">
        <div class="dropdown">
            <a class="dropdown-toggle text-muted" href="#" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Last 7 days</a>
            <div class="dropdown-menu dropdown-menu-end">
            <a class="dropdown-item active" href="#">Last 7 days</a>
            <a class="dropdown-item" href="#">Last 30 days</a>
            <a class="dropdown-item" href="#">Last 3 months</a>
            </div>
        </div>
        </div>
    </div>
    <div class="h1 mb-3">75%</div>
    <div class="d-flex mb-2">
        <div>Conversion rate</div>
        <div class="ms-auto">
        <span class="text-green d-inline-flex align-items-center lh-1">
            7% <!-- Download SVG icon from http://tabler-icons.io/i/trending-up -->
            <svg xmlns="http://www.w3.org/2000/svg" class="icon ms-1" width="24" height="24" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><polyline points="3 17 9 11 13 15 21 7" /><polyline points="14 7 21 7 21 14" /></svg>
        </span>
        </div>
    </div>
    <div class="progress progress-sm">
        <div class="progress-bar bg-blue" style="width: 75%" role="progressbar" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100">
        <span class="visually-hidden">75% Complete</span>
        </div>
    </div>
    </div>
</div>

