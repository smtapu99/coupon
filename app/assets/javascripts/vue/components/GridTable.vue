<template>
  <div>
    <table class="table table-striped">
      <i
        v-if="isLoading"
        class="icon-spinner icon-spin icon-loading"/>

      <thead>
        <tr>
          <th class="sel">
            <input
              v-if="checkboxes && !editButton.hide"
              v-model="selectAll"
              type="checkbox">
          </th>
          <th
            v-for="key in columns"
            :key="key"
            :class="{ active: sortOrder === key }"
            @click="sortBy(key)">
            {{ key | humanize }}
            <span
              :class="sortDirection"
              class="arrow"/>
          </th>
        </tr>
        <tr
          v-if="isFilterFields">
          <th/>
          <th
            v-for="key in columns"
            :key="key">
            <grid-filter-field
              :name="key"
              :filter="filterFields[key]"
              :active-filters="filterField"
              :external-data="filtersData[key]"/>

          </th>
        </tr>
      </thead>
      <tbody :class="{loading: isLoading}">
        <tr
          v-for="(entry, index) in filteredData"
          :key="index"
          :class="[(index % 2) ? 'even' : 'odd', highlighted(entry) ? 'highlighted':'']">
          <td class="my_class sel">
            <input
              v-if="checkboxes && !editButton.hide"
              v-model="selected"
              :value="entry.id"
              type="checkbox">
            <a
              v-if="editButton && !editButton.hide"
              :href="getEditUrl(entry.id, entry)"
              :class="[editButton.class ? editButton.class :'btn btn-primary btn-edit']"
              :target="[editButton.target ? editButton.target : '_self']"
              :title="editButton.title"
              @click="showEditModal(entry.id, $event)">
              <i
                :class="[editButton.icon ? editButton.icon : 'icon-pencil']"></i>
            </a>
            <span
              v-if="removeButton && showRemoveButton(entry)"
              :title="removeButton.title"
              :class="[removeButton.class ? removeButton.class :'btn btn-danger']"
              @click="removeItem(entry.id)">
              <i
                :class="[removeButton.icon ? removeButton.icon : 'icon-remove']"/>
            </span>
            <span
              v-if="copyButton"
              :class="[copyButton.class ? copyButton.class :'btn btn-info']"
              :title="copyButton.title"
              @click="copyToClipboard(entry[copyButton.field])">
              <i
                :class="[copyButton.icon ? copyButton.icon : 'icon-copy']"/>
            </span>
          </td>
          <td
            v-for="key in columns"
            :key="key">
            <grid-table-cell
              v-model="entry[key]"
              :type="customFormat[key]"
              @change.native="updateField(entry)"
              @fieldIsValid="checkValidity"/>
          </td>
        </tr>
      </tbody>
    </table>
    <Modal
      :show-modal="showModal"
      :body="modalContent"
      @hide-modal="showModal = false"
      @update="getData">
      <template slot="title">
        Edit {{ $route.name }}
      </template>
    </Modal>
    <transition name="bounce">
      <div
        v-if="copied"
        class="copied">
        Copied
      </div>
    </transition>
  </div>
</template>

<script>
  import merge from "lodash/merge";
  import axios from "axios";
  import GridFilterField from "./GridFilterField";
  import GridTableCell from "./GridTableCell";
  import Modal from "./Modal";
  import EventBus from "../eventBus";
  import qs from 'qs';

  export default {
    name: "GridTable",
    components: {
      EventBus,
      GridFilterField,
      GridTableCell,
      Modal
    },
    filters: {
      humanize: str => {
        let frags = str.split('_');
        for (let i = 0; i < frags.length; i++) {
          frags[i] = frags[i].charAt(0).toUpperCase() + frags[i].slice(1);
        }
        return frags.join(' ');
      }
    },
    props: {
      columns: {
        type: Array,
        default() {
          return ["id"];
        }
      },
      type: {
        type: String,
        default: ""
      },
      filterKey: {
        type: String,
        default: ""
      },
      sortType: {
        type: String,
        default: "frontend"
      },
      skipSortingField: {
        type: Array,
        default() {
          return [];
        }
      },
      customFormat: {
        type: Object,
        default() {
          return {};
        }
      },
      highlight: {
        type: Object,
        default() {
          return {};
        }
      },
      checkboxes: {
        type: Boolean,
        default: true,
      },
      editButton: {
        type: [Boolean, Object],
        default: false
      },
      removeButton: {
        type: [Boolean, Object],
        default: false
      },
      filterFields: {
        type: [Object],
        default: function() {
          return {};
        }
      },
      copyButton: {
        type: [Boolean, Object],
        default: false
      },
      saveUrl: {
        type: String,
        default: ""
      },
      saveFields: {
        type: Object,
        default() {
          return {};
        }
      }
    },
    data() {
      let sortOrders = {};
      this.columns.forEach(function(key) {
        sortOrders[key] = 1;
      });

      return {
        sortKey: "",
        data: [],
        showModal: false,
        sortOrders,
        selected: [],
        page: this.$route.query.page || 1,
        perPage: 10,
        sortOrder: this.$route.query.order || "id",
        sortDirection: this.$route.query.order_direction || "desc",
        totalItems: "",
        isLoading: false,
        filtersData: {},
        modalContent: "",
        copied: false,
        fieldIsValid: false
      };
    },
    computed: {
      filteredData() {
        let sortKey = this.sortKey;
        let filterKey = this.filterKey && this.filterKey.toLowerCase();
        let order = this.sortOrders[sortKey] || 1;
        let data = this.data;

        if (filterKey) {
          data = data.filter(function(row) {
            return Object.keys(row).some(function(key) {
              return (
                String(row[key]).toLowerCase().indexOf(filterKey) > -1
              );
            });
          });
        }

        if (sortKey) {
          data = data.slice().sort(function(a, b) {
            a = a[sortKey];
            b = b[sortKey];
            return (a === b ? 0 : a > b ? 1 : -1) * order;
          });
        }
        return data;
      },

      selectAll: {
        set(checked) {
          if (checked) {
            this.selected = [];
            this.data.forEach((item, idx) => {
              this.selected.push(this.data[idx].id);
            });
          } else {
            this.selected = [];
          }
        },
        get() {
          return this.data ? this.data.length === this.selected.length : false;
        }
      },

      isFilterFields() {
        return Object.keys(this.filterFields).length !== 0;
      },

      filterField() {
        return this.$route.query.f ? JSON.parse(JSON.stringify(this.$route.query.f)) : {};
      }
    },
    watch: {
      selected() {
        EventBus.$emit('selected', this.selected);
      }
    },
    beforeCreate() {
      axios.defaults.headers.common = {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      };

      EventBus.$on('update', () => {
        this.getData();
      });

      EventBus.$on('setPage', e => {
        this.setQuery({page: e});
      });

      EventBus.$on('loading:start', () => {
        this.isLoading = true;
      });

      EventBus.$on("gridCreated", () => {
        EventBus.$emit("session:check");
      });

      EventBus.$on('filterByField', e => {
        this.filterByField(e);
      });
    },
    mounted() {
      this.setQuery();
    },
    methods: {
      sortBy(key) {
        if (this.skipSortingField.indexOf(key) !== -1) {
          return false;
        }

        if (this.sortType === "frontend") {
          this.sortKey = key;
          this.sortOrders[key] = this.sortOrders[key] * -1;
        } else {
          if (key === this.sortOrder) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
            this.setQuery({});
          } else {
            this.setQuery({order: key});
          }
        }
      },

      getData() {
        this.isLoading = true;
        let link = `${this.$route.name}.json?${qs.stringify(this.getQuery())}`;
        axios
          .get(link)
          .then(response => {
            this.data = response.data.records;
            this.page = parseInt(response.data.page);
            this.sortOrder = response.data.order;
            this.sortDirection = response.data.order_direction;
            this.totalItems = response.data.count;
            this.perPage = response.data.per_page;
            this.filtersData = response.data.filters;
            EventBus.$emit("gridCreated", {
              currentPage: this.page,
              totalItems: this.totalItems,
              perPage: this.perPage
            });
            this.isLoading = false;
          });
      },

      getQuery() {
        return {
          page: this.page,
          order: this.sortOrder,
          order_direction: this.sortDirection,
          f: this.filterField
        };
      },

      setQuery(obj) {
        obj = obj || {};

        this.page = obj.page || this.page;
        this.sortOrder = obj.order || this.sortOrder;
        this.sortDirection = obj.direction || this.sortDirection;

        if (obj.filterField) {
          this.filterField[obj.filterField.field] = obj.filterField.data;
          if (!obj.filterField.data) {
            delete this.filterField[obj.filterField.field];
          }
        }

        let query = this.getQuery();
        this.$router.push({query});

        if (Object.keys(obj).length > 0 && obj.filterField) { //not empty
          if (!obj.filterField.setDefaults) {
            this.getData();
          }
        } else {
          this.getData();
        }
      },
      filterByField(e) {
        this.setQuery({filterField: e});
      },

      getEditUrl(id, entry) {
        if (typeof this.editButton === 'object' && this.editButton.type === "URL") {
          return this.templateSting(this.editButton.value, entry);
        } else {
          var action = this.editButton.action ? this.editButton.action : 'edit';
          return `${this.$route.name}/${id}/${action}`;
        }
      },

      showRemoveButton(entry) {
        if (typeof this.removeButton === 'object' && this.removeButton.showCondition) {
          let show = true;

          for (let arg in this.removeButton.showCondition) {
            if (!show) {
              break;
            }
            show = this.removeButton.showCondition[arg] === entry[arg];
          }
          return show;
        }
        return true;
      },
      templateSting(str, data) {
        let formatted = str;

        if (str.indexOf('${' > -1)) {
          for (let arg in data) {
            formatted = formatted.replace(new RegExp("\\${" + arg + "}", 'g'), data[arg]);
          }
        }

        return formatted;
      },

      removeItem(id) {
        if (confirm('Are you sure?')) {
          this.isLoading = true;
          axios.delete(`${this.$route.name}/${id}`, {
            responseType: 'json'
          }).then(() => {
            this.getData();
          }).catch(error => console.log(error));
        }
      },
      copyToClipboard(text) {
        var dummy = document.createElement("textarea");
        document.body.appendChild(dummy);
        dummy.value = text;
        dummy.select();
        document.execCommand("copy");
        document.body.removeChild(dummy);
        this.copied = true;

        setTimeout(() => {
          this.copied = false;
        }, 3000);
      },
      highlighted(entry) {
        if (this.highlighted) {
          let attr = Object.keys(this.highlight)[0];
          let value = String(this.highlight[attr]);
          if (String(entry[attr]) === value && value !== 'undefined') {
            return true;
          }
        }
      },

      showEditModal(id, event) {
        if (typeof this.editButton === 'object' && this.editButton.type === "modal") {
          event.preventDefault();
          axios
            .get(this.getEditUrl(id))
            .then(response => {
              this.modalContent = response.data;
              this.showModal = true;
            }).catch(error => console.log(error));
        }
      },

      updateField(entry) {
        if (this.fieldIsValid) {

          let ObjectToSave = merge({}, this.saveFields);
          let key = Object.keys(ObjectToSave)[0];

          for (let elKey in ObjectToSave[key]) {
            if (entry[elKey]) {
              ObjectToSave[key][elKey] = entry[elKey];
            }
          }

          axios.post(this.saveUrl, ObjectToSave)
            .then(response => {
              this.getData();
            }).catch(error => {
            alert(error);
          });
        }
      },

      checkValidity(event) {
        this.fieldIsValid = event;
      }
    }
  };
</script>

<style scoped lang="scss">
  .arrow {
    display: inline-block;
    vertical-align: middle;
    width: 6px;
    height: 6px;
    margin-left: 5px;
  }

  .active .arrow.asc {
    border-left: 4px solid transparent;
    border-right: 4px solid transparent;
    border-bottom: 4px solid #000;
  }

  .active .arrow.desc {
    border-left: 4px solid transparent;
    border-right: 4px solid transparent;
    border-top: 4px solid #000;
  }

  table {
    thead {
      th {
        min-width: 70px;
        white-space: nowrap;
        cursor: pointer;

        &:first-child {
          min-width: auto;
        }
      }
    }

    .sel {
      white-space: nowrap;
    }
  }

  .btn-edit {
    margin-left: 5px;
  }

  tbody {
    transition: opacity .5s;

    &.loading {
      opacity: 0.5;
    }
  }

  .highlighted,
  .highlighted td {
    background-color: #FAE1BC !important;
  }


  .copied {
    position: fixed;
    top: 0;
    z-index: 1000;
    left: 50%;
    padding: 5px 15px;
    display: inline-block;
    background: rgba(0, 0, 0, 0.5);
    color: #FFF;
    border-bottom-left-radius: 7px;
    border-bottom-right-radius: 7px;
    font-size: 18px;
  }

  .icon-loading {
    color: #444;
    position: fixed;
    top: 45%;
    left: 50%;
    transform: translate(-50%, 0);
    font-size: 40px;
  }

  .bounce-enter-active {
    animation: bounce-in .5s;
  }

  .bounce-leave-active {
    animation: bounce-in .5s reverse;
  }

  @keyframes bounce-in {
    0% {
      transform: scale(0);
    }
    50% {
      transform: scale(1.5);
    }
    100% {
      transform: scale(1);
    }
  }
</style>
