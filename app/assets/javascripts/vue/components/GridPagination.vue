<template>
  <td colspan="18">
    <div class="pagination">
      <ul class="pagination">
        <li v-if="(!isActive(1))">
          <a
            href="#"
            @click.prevent="setPage(currentPage - 1)">«</a>
        </li>
        <li
          v-for="(item, key) in pagesList"
          :key="key"
          :class="{active: isActive(item),disabled: isDots(item)}">
          <a
            href="#"
            @click.prevent="setPage(item)">
            {{ item }}
          </a>
        </li>
        <li v-if="(!isActive(numberOfPages))">
          <a
            href="#"
            @click.prevent="setPage(currentPage + 1)">»</a></li>
      </ul>
    </div>
    <div
      class="pagination_status">
      {{ currentRange }} / {{ totalItems }}
    </div>
  </td>
</template>

<script>
  import EventBus from "../eventBus";

  export default {
    name: "GridPagination",
    components: {
      EventBus
    },
    props: {
      perPage: {
        type: Number,
        default: 20
      }
    },
    data() {
      return {
        itemsPerPage: this.perPage,
        currentPage: 1,
        totalItems: 150,
        delta: 2
      };
    },

    computed: {
      numberOfPages() {
        const result = Math.ceil(this.totalItems / this.itemsPerPage);
        return (result < 1) ? 1 : result;
      },
      pagesList() {
        let range = [];
        let rangeWithDots = [];
        let l;
        let left = this.currentPage - this.delta;
        let right = this.currentPage + this.delta + 1;

        for (let i = 1; i <= this.numberOfPages; i++) {
          if (i === 1 || i === this.numberOfPages || i >= left && i < right) {
            range.push(i);
          }
        }

        for (let i of range) {
          if (l) {
            if (i - l === 2) {
              rangeWithDots.push(l + 1);
            } else if (i - l !== 1) {
              rangeWithDots.push('...');
            }
          }
          rangeWithDots.push(i);
          l = i;
        }

        return rangeWithDots;
      },
      currentRange() {
        let from = (this.currentPage * this.itemsPerPage) - (this.itemsPerPage - 1);
        let to = this.currentPage * this.itemsPerPage;
        return `${from} - ${to}`;
      }
    },
    created() {
      EventBus.$on("gridCreated", e => {
        this.currentPage = e.currentPage;
        this.totalItems = e.totalItems;
        this.itemsPerPage = e.perPage;
      });

      EventBus.$on("filterByField", () => {
        if (this.currentPage !== 1) {
          this.setPage(1);
        }
      });
    },
    methods: {
      setPage(item) {
        if (item !== "...") {
          this.currentPage = item;
          EventBus.$emit('setPage', item);
        }
      },
      isActive(num) {
        return this.currentPage === num;
      },
      isDots(item) {
        return item === "...";
      }
    },
  };
</script>

<style scoped>
  .pagination > .active > a {
    background: #AAA;
  }
</style>
