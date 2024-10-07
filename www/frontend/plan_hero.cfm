<cfscript>
  param name = "url.g" default = "1" type = "numeric";
  if (url.g eq 1) {
    mainTitle = "Für Arbeitgeber";
    planDescription = "Als Arbeitgeber inserieren Sie bei Stellensuche.ch besonders günstig. Wählen Sie Ihren bevorzugten Plan:";
  } else if (url.g eq 2) {
    mainTitle = "Für Fachkräfte";
    planDescription = "Erstellen Sie Ihr Bewerbungsprofil und bewerben Sie sich mit nur einem Klick!";
  } else {
    location url = "#application.mainURL#" addtoken = "false";
  }
</cfscript>

<cfoutput>
  <div style="background-color: ##E6F0F2;" class="py-md-4 pb-4">
    <div class="container-xl mx-auto d-flex flex-column justify-content-center align-content-center column-gap-4 gap-btw">
      <div class="price-hero pt-4 pb-4">
        <h1>#mainTitle#</h1>
        <p>#planDescription#</p>
      </div>
      <div class="tabs" data-bs-toggle="tabs">
        <span class="tab-active"></span>
        <span class="tab active" data-bs-toggle="tab">Monatlich</span>
        <span class="tab">Jährlich</span>
      </div>
    </div>
  </div>
</cfoutput>

<script>

  document.addEventListener("DOMContentLoaded", function () {
    // Payment Price Tabs Function
    const TabContainer = document.querySelector(".tabs");
    const Tabs = TabContainer.querySelectorAll(".tab"); // Change .querySelectorAll(".tab") to .querySelectorAll(".tabs .tab")
    const ActiveTab = TabContainer.querySelector(".tab-active"); // Change .querySelector(".tab-active") to .querySelector(".tabs .tab-active")
    const MonthlyPrice = document.querySelectorAll(".monthly-price");
    const MonthlyPriceBtn = document.querySelectorAll(".monthly");
    const YearlyPrice = document.querySelectorAll(".yearly-price");
    const YearlyPriceBtn = document.querySelectorAll(".yearly");

    Tabs.forEach((tab) => {
      tab.addEventListener("click", () => {
        // Remove the 'active' class from all tabs
        Tabs.forEach((tab) => {
          tab
            .classList
            .remove("active");
        });

        // Add the 'active' class to the clicked tab
        tab
          .classList
          .add("active");

        // Update the border radius class for the active tab
        updateBorderRadiusClass(tab);

        // Get the left position of the clicked tab
        const leftPosition = tab.offsetLeft;

        // Set the left position of ActiveTab to match the clicked tab
        ActiveTab.style.left = `${leftPosition}px`;

        // Show/hide sections based on the clicked tab index
        const tabIndex = Array
          .from(Tabs)
          .indexOf(tab);
        if (tabIndex === 0) {
          // for monthly
          MonthlyPrice.forEach(price => price.style.display = "flex");
          MonthlyPriceBtn.forEach(price => price.style.display = "flex");
          YearlyPrice.forEach(price => price.style.display = "none");
          YearlyPriceBtn.forEach(price => price.style.display = "none");
        } else {
          // for yearly
          MonthlyPrice.forEach(price => price.style.display = "none");
          MonthlyPriceBtn.forEach(price => price.style.display = "none");
          YearlyPrice.forEach(price => price.style.display = "flex");
          YearlyPriceBtn.forEach(price => price.style.display = "flex");
        }
      });
    });

    // Function to update border radius class based on the position of the clicked tab on Price
    function updateBorderRadiusClass(clickedTab) {
      const lastTab = Tabs[Tabs.length - 1];

      // Remove 'right-tab' class from ActiveTab
      ActiveTab
        .classList
        .remove("right-tab");

      // Add 'right-tab' class if the clicked tab is the last one
      if (clickedTab === lastTab) {
        ActiveTab
          .classList
          .add("right-tab");
      }
    }
  })
</script>
