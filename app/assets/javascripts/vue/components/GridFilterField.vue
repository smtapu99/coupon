<template>
  <div
    v-if="filter.type==='text'"
    class="filter-field">
    <input
      v-model="currentValue"
      :placeholder="filter.placeholder"
      type="search"
      class="form-control input-sm">

    <span
      v-if="currentValue"
      class="filter-field__reset"
      @click="resetInput">×</span>
  </div>

  <div v-else-if="filter.type==='select'">
    <select
      v-if="externalData.length"
      v-model="currentValue"
      class="form-control input-sm">
      <option
        v-for="(item, key) in externalData"
        :key="key"
        :value="Object.keys(item)[0]">
        {{ Object.values(item)[0] }}
      </option>
    </select>

    <select
      v-else
      v-model="currentValue"
      class="form-control input-sm">
      <option
        v-for="(item, key) in filter.values"
        :key="key"
        :value="item">
        {{ item }}
      </option>
    </select>
  </div>

  <div v-else-if="filter.type ==='date'">
    <datepicker
      :value="currentValue"
      :typeable="true"
      :input-class="'form-control input-sm'"
      :placeholder="filter.placeholder"
      :format="formatData"
      :clear-button="filter.clearButton"
      @input="fallbackForDatepicker"/>
  </div>

  <div v-else-if="filter.type ==='date-range'">
    <datepicker
      :value="rangeFrom"
      :typeable="true"
      :input-class="'form-control input-sm'"
      :placeholder="filter.placeholder_from"
      :disabled-dates="dataRangeState.disabledDates.from"
      :format="formatData"
      :clear-button="filter.clearButton"
      @input="handleDateRange('from', $event)"/>

    <datepicker
      :value="rangeTo"
      :typeable="true"
      :input-class="'form-control input-sm'"
      :placeholder="filter.placeholder_to"
      :disabled-dates="dataRangeState.disabledDates.to"
      :format="formatData"
      :clear-button="filter.clearButton"
      @input="handleDateRange('to', $event)"/>
  </div>

</template>

<script>
  import debounce from 'lodash/debounce';
  import Datepicker from 'vuejs-datepicker';
  import format from 'date-fns/format';
  import EventBus from '../eventBus';

  export default {
    name: "GridFilterField",
    components: {
      Datepicker
    },
    props: {
      name: {
        type: String,
        default: ""
      },
      filter: {
        type: Object,
        default() {
          return {};
        }
      },
      activeFilters: {
        type: Object,
        default() {
          return {};
        }
      },
      externalData: {
        type: Array,
        default() {
          return [];
        }
      }
    },
    data() {
      return {
        rangeFrom: "",
        rangeTo: "",
        firstRun: Boolean,
        dataRangeState: {
          disabledDates: {
            from: {
              from: "",
              to: ""
            },
            to: {
              from: "",
              to: ""
            }
          }
        }
      };
    },
    computed: {
      currentValue: {
        get() {
          return this.activeFilters[this.name] || '';
        },
        set(data) {
          if (data && this.filter.type === 'date') {
            data = format(new Date(data), this.filter.format);
          }

          if (data !== undefined && !this.firstRun) {
            this.update(data);
            this.firstRun = false;
          }
        }
      }
    },
    beforeMount() {
      this.firstRun = true;
      this.currentValue = this.activeFilters[this.name];

      if (this.filter.type === 'select' && !this.currentValue) {
        this.currentValue = this.filter.default;
      }

      if (this.filter.type === 'date-range') {
        this.rangeFrom = this.activeFilters[this.filter.name_from];
        this.rangeTo = this.activeFilters[this.filter.name_to];
        this.dataRangeState.disabledDates.to.to = new Date(this.rangeFrom);
        this.dataRangeState.disabledDates.from.from = new Date(this.rangeTo);
      }
    },
    mounted() {
      if (this.filter.default) {
        this.sendData(this.filter.default, null, true);
      }
      this.firstRun = false;
    },
    methods: {
      update: debounce(function(data) {
        this.filter.min = this.filter.min || 0;

        if (data.length >= this.filter.min || data.length === 0) {
          this.sendData(data);
        }
      }, 700),

      sendData(data, field, setDefaults = false) {
        if (!field) {
          field = this.name;
        }
        EventBus.$emit('filterByField', {field, data, setDefaults});
        EventBus.$emit('session:check');
      },

      formatData(data) {
        return format(new Date(data), this.filter.format);
      },

      fallbackForDatepicker(data) {
        if (data) {
          data = format(new Date(data), this.filter.format);

          if (data !== this.currentValue) {
            this.currentValue = data;
          }
        } else {
          this.currentValue = '';
        }
      },
      handleDateRange(name, event) {
        switch (name) {
          case 'from':
            this.rangeFrom = event ? this.formatData(event) : '';

            if (event instanceof Date) {
              event.setHours(0, 0, 0);
            }

            this.dataRangeState.disabledDates.to.to = event;
            this.sendData(this.rangeFrom, this.filter.name_from);
            break;

          case 'to':
            this.rangeTo = event ? this.formatData(event) : '';

            if (event instanceof Date) {
              event.setHours(23, 59, 59);
            }

            this.dataRangeState.disabledDates.from.from = event;
            this.sendData(this.rangeTo, this.filter.name_to);
            break;

          default:
            console.error('wrong name');
            break;
        }
      },
      resetInput() {
        this.currentValue = "";
      }
    }
  };
</script>

<style lang="scss">

  .filter-field {
    position: relative;

    &__reset {
      position: absolute;
      top: 50%;
      right: 6px;
      transform: translateY(-50%);
    }
  }

  .vdp-datepicker {
    white-space: normal;

    &__calendar {
      right: 0;
    }

    &__clear-button {
      position: absolute;
      top: 50%;
      right: -10px;
      transform: translateY(-50%);
    }
  }
</style>
