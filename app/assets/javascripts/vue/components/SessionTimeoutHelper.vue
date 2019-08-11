<template>
  <div>
    <Modal
      :show-modal="showModal"
      :body="modalBody"
      @hide-modal="showModal = false">

      <template slot="title">Session Timeout</template>

      <div class="modal-body">

        <div
          v-if="warning"
          class="warning">

          <h2>You are about to be logged off in <span class="timer">{{signOffTimer}}</span> sec.</h2>

          <p>Press
            <button type="button" class="btn btn-primary" @click="updateTimer">the button</button>
            to stay here
          </p>

        </div>

      </div>

    </Modal>

  </div>

</template>

<script>
  import EventBus from "../eventBus";
  import Modal from "./Modal";

  export default {
    name: "SessionTimeoutHelper",
    components: {
      EventBus,
      Modal
    },
    data() {
      return {
        WARNING_TIMEOUT: 15 * 60 * 1000,
        PAGE_TO_PING: "/pcadmin/home",
        SIGN_IN_PAGE: "/pcadmin/users/sign_in",
        SIGN_OUT_PAGE: "/pcadmin/users/sign_out",
        signOffTimer: 60,
        showModal: false,
        loginForm: false,
        warning: false,
        modalBody: "",
        updateWarning: null,
        sessionSetTimeout: null,
        warningSetTimeout: null
      };
    }
    ,
    mounted() {
      this.updateTimer();

      EventBus.$on("session:check", () => {
        this.updateTimer();
      });
    },
    methods: {
      showWarning() {
        this.warning = true;
        this.showModal = true;

        clearInterval(this.updateWarning);
        this.updateWarning = setInterval(() => {
          if (this.signOffTimer === 0) {
            clearInterval(this.updateWarning);
            this.warning = false;
            this.showLoginForm();
          } else {
            this.signOffTimer--;
          }
        }, 1000);

      },
      showLoginForm() {
        this.warning = false;

        fetch(this.SIGN_OUT_PAGE).then(() => {
          fetch(this.SIGN_IN_PAGE)
            .then((response) => {
              return response.text();
            })
            .then((html) => {
              var parser = new DOMParser();
              var doc = parser.parseFromString(html, "text/html");
              this.modalBody = doc.querySelector(".validate-form").outerHTML;

              this.showModal = true;
              this.loginForm = true;
            })
            .catch(function(err) {
              console.log('Failed to fetch page: ', err);
            });
        }).catch(function(err) {
          console.log(err);
        });


      },
      updateTimer() {
        this.modalBody = null;
        this.showModal = false;
        this.signOffTimer = 60;

        clearInterval(this.updateWarning);

        clearTimeout(this.warningSetTimeout);
        this.warningSetTimeout = setTimeout(this.showWarning, this.WARNING_TIMEOUT);
      }
    }
  };
</script>

<style scoped>
  .modal-body {
    padding-top: 0;
  }
</style>
