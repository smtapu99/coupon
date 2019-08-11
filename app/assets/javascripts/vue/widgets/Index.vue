<template>
  <div>
    <premium-offers
      v-if="widget === 'premium-offers'"
      :json="widgetData"/>
  </div>
</template>

<script>
  import premiumOffers from "./PremiumOffers";

  export default {
    name: "Index",
    components: {
      premiumOffers
    },
    data() {
      return {
        widget: "",
        widgetData: ""
      };
    },
    beforeMount() {
      let modalRoot = document.querySelector(".modal .widget-type");
      if (modalRoot) {
        this.widgetData = JSON.parse(modalRoot.dataset.json);
        this.widget = modalRoot.dataset.widgetType;
      }
    }
  };
</script>
