<template>
  <div>
    <a
      v-if="buttonsList.indexOf('active') !== -1"
      :disabled="selected.length === 0"
      class="btn btn-success"
      href="/spec/dummy/public#"
      @click.self.prevent="action('active')">
      <i class="icon-ok"/>
      Approve
    </a>

    <a
      v-if="buttonsList.indexOf('blocked') !== -1"
      :disabled="selected.length === 0"
      class="btn btn-danger"
      href="/spec/dummy/public#"
      @click.self.prevent="action('blocked')">
      <i class="icon-lock"/>
      Block
    </a>

    <a
      v-if="buttonsList.indexOf('pending') !== -1"
      :disabled="selected.length === 0"
      class="btn btn-warning"
      href="/spec/dummy/public#"
      @click.self.prevent="action('pending')">
      <i class="icon-time"/>
      Pending
    </a>

    <a
      v-if="buttonsList.indexOf('visible') !== -1"
      :disabled="selected.length === 0"
      class="btn"
      href="/spec/dummy/public#"
      @click.self.prevent="action('visible')">
      <i class="icon-play"/>
      Visible
    </a>

    <a
      v-if="buttonsList.indexOf('hidden') !== -1"
      :disabled="selected.length === 0"
      class="btn btn-inverse"
      href="/spec/dummy/public#"
      @click.self.prevent="action('hidden')">
      <i class="icon-stop"/>
      Hidden
    </a>

    <a
      v-if="buttonsList.indexOf('gone') !== -1"
      :disabled="selected.length === 0"
      class="btn btn-danger"
      href="/spec/dummy/public#"
      @click.self.prevent="action('gone')">
      <i class="icon-signout"/>
      Gone
    </a>

    <a
      v-if="buttonsList.indexOf('reset_votes') !== -1"
      :disabled="selected.length === 0"
      class="btn btn-danger"
      href="/spec/dummy/public#"
      @click.self.prevent="action('reset_votes')">
      <i class="icon-step-backward"/>
      Reset Votes
    </a>

    <a
      v-if="buttonsList.indexOf('editModal') !== -1"
      :disabled="selected.length === 0"
      class="btn btn-info"
      href="/spec/dummy/public#"
      @click.self.prevent="editModal">
      <i class="icon-edit"/>
      Bulk Edit
    </a>

    <Modal
      :show-modal="showModal"
      :body="modalContent"
      @hide-modal="showModal = false"
    >
      <template slot="title">
        Edit
      </template>
    </Modal>
  </div>
</template>

<script>
  import EventBus from "../eventBus";
  import axios from "axios";
  import Modal from "./Modal";

  export default {
    name: "GridActionButtons",
    components: {Modal},
    props: {
      buttonsList: {
        type: Array,
        default() {
          return ['active', 'blocked', 'pending']
        }
      }
    },
    data() {
      return {
        selected: [],
        showModal: false,
        modalContent: "",

      }
    },
    mounted() {
      EventBus.$on('selected', (e) => {
        this.selected = e;
      })
    },
    methods: {
      action(status) {
        EventBus.$emit('loading:start');

        let url = `${this.$route.name}/change_status`;
        axios.get(url, {
          params: {
            ids: this.selected,
            status
          }
        }).then(function() {
          EventBus.$emit('update');
        }).catch(error => console.log(error))
      },
      editModal() {
        let url = `${this.$route.name}/edit`;
        axios.get(url, {
          params: {
            ids: this.selected
          }
        }).then(response => {
          this.modalContent = response.data;
          this.showModal = true;
        }).catch(error => console.log(error));
      }
    }
  }
</script>

<style scoped>
  div {
    padding: 5px 0 10px;
  }
</style>
