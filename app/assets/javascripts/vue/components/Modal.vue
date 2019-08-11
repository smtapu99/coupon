<template>
  <transition name="modal">
    <div
      v-show="showModal"
      class="modal-mask">
      <div
        @click.self="$emit('hide-modal')"
        class="modal-wrapper"
      >
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <button
                type="button"
                class="close"
                @click="hideModal">&times;
              </button>
              <h4
                id="myModalLabel"
                class="modal-title">
                <slot name="title">Modal Title</slot>
              </h4>
            </div>
            <div
              ref="body"
              class="modal-body"
              v-html="body">
            </div>
            <slot></slot>
            <div class="modal-footer">
              <slot name="footer"></slot>
              <button
                type="button"
                class="btn btn-default"
                @click="hideModal">Close
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
  import axios from 'axios';
  import EventBus from '../eventBus';

  export default {
    name: "Modal",
    props: {
      showModal: {
        type: Boolean,
        default: false
      },
      body: {
        type: String,
        default: "<p>Modal Body</p>"
      }
    },
    updated() {
      let form = this.$refs['body'].querySelector('form');
      if (form) {
        let url = form.getAttribute('action');

        form.addEventListener('submit', e => {
          e.preventDefault();
          let data = new FormData(form);

          axios.post(url, data).then((e) => {
            EventBus.$emit('update');
            this.$refs['body'].innerHTML = e.data;
          }).catch(error => console.log(error));
        })
      }
    },
    methods: {
      hideModal() {
        this.$emit('hide-modal');
      }
    }
  }
</script>

<style scoped>
  .modal-mask {
    position: fixed;
    z-index: 9998;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, .5);
    transition: opacity .3s ease;
    overflow-x: hidden;
    overflow-y: auto;
  }

  .modal-dialog {
    width: 800px;
  }

  .modal-enter {
    opacity: 0;
  }

  .modal-leave-active {
    opacity: 0;
  }

  .modal-enter .modal-container,
  .modal-leave-active .modal-container {
    -webkit-transform: scale(1.1);
    transform: scale(1.1);
  }

</style>
