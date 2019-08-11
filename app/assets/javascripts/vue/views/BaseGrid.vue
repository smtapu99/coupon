<template>
  <div>
    <gridActionButtons
      :buttonsList="buttonsList"
      v-if="buttonsList.length"/>

    <gridTable
      :columns="gridSettings.columns"
      :customFormat="gridSettings.customFormat"
      :editButton="gridSettings.editButton"
      :copyButton="gridSettings.copyButton"
      :filterFields="gridSettings.filterFields"
      :sortType="gridSettings.sortType"
      :highlight="gridSettings.highlight"
      :checkboxes="gridSettings.checkboxes"
      :removeButton="gridSettings.removeButton"
      :skipSortingField="gridSettings.skipSortingField"
      :saveUrl="gridSettings.saveUrl"
      :saveFields="gridSettings.saveFields"/>
    <grid-pagination/>
    <session-timeout-helper/>
  </div>
</template>

<script>
  import GridTable from "../components/GridTable";
  import GridPagination from "../components/GridPagination";
  import GridActionButtons from "../components/GridActionButtons";
  import SessionTimeoutHelper from "../components/SessionTimeoutHelper";

  export default {
    name: "BaseGrid",
    components: {
      GridPagination,
      GridTable,
      GridActionButtons,
      SessionTimeoutHelper
    },
    props: {
      gridSettings: {
        type: Object,
        default: function() {
          return {};
        }
      },
      paginationSetting: {
        type: Object,
        default: function() {
          return {};
        }
      },
      buttonsList: {
        type: Array,
        default: function() {
          return [];
        }
      }
    }
  };
</script>
