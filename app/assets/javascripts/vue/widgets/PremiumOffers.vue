<template>

  <div>
    <div class="col-md-12">
      <h4>Widgets</h4>
    </div>
    <div
      v-for="(row, key) in rows"
      :key="key"
      class="form-row">
      <div class="form-row__header">
        <h4>Row # {{ parseInt(key) + 1 }} </h4>
        <span
          :class="(getRowWidth(row) !== 100 ) ? 'error': 'success'">
          {{ getRowWidth(row) }}
        </span>
        <span
          v-if="restrictedSizes(row)"
          class="error small">
          50%-small-colored works only with 50%-small-colored in one row
        </span>
        <i
          v-if="Object.keys(rows).length > 1"
          class="icon-remove form-row__remove"
          @click.prevent="removeRow(key)"/>
      </div>
      <div
        v-for="(widget, widget_id) in row.widgets"
        :key="widget_id">
        <div
          class="widget-header"
          @click="toggleWidget(widget)">
          <span>Widget # {{ parseInt(widget_id) + 1 }} </span>
          <span class="widget-width">{{ widget.type }}</span>
          <i
            v-if="!widget.show"
            class="icon-caret-left"/>
          <i
            v-if="widget.show"
            class="icon-caret-down"/>
        </div>
        <transition name="slide">
          <div
            v-show="widget.show"
            class="widget-form">
            <i
              class="icon-remove widget-form__remove"
              @click="removeWidget(widget_id, key)"/>
            <div class="form-group">
              <div class="col-md-8">
                <label>Widget Type</label>
                <select
                  v-model="widget.type"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][type]'"
                  class="form-control">
                  <option value="25">25% (WHOD25)</option>
                  <option value="25-2019">25% (SIMPLE_2019)</option>
                  <option value="25-full-bg">25% full bg (WBG25)</option>
                  <option value="25-colored">25% colored bg (WGO25)</option>
                  <option value="33-colored-full-bg">33% colored full bg (WBGO33)</option>
                  <option value="50">50% (PWC50)</option>
                  <option value="50-small">50% small colored (WB50)</option>
                  <option value="75">75% (PWC75)</option>
                  <option value="75-head-picture">75% header picture (PWCH75)</option>
                  <option value="100">100% (PWC100)</option>
                </select>
              </div>
            </div>
            <div class="form-group">
              <div
                v-if="widget.type !== '25-colored'"
                class="col-md-8">
                <label>
                  Background Image
                </label>
                <input
                  v-model="widget.background_url"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][background_url]'"
                  type="url"
                  class="form-control">
              </div>
              <div
                v-if="widget.type === '50-small' || widget.type === '25-colored' || widget.type === '33-colored-full-bg' "
                class="col-md-4">
                <label>Background Color</label>
                <select
                  v-model="widget.background_color"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][background_color]'"
                  class="form-control">
                  <option value="white">White/Default</option>
                  <option value="orange">Orange</option>
                  <option value="green">Green</option>
                  <option value="blue">Blue</option>
                  <option value="telegraph">Telegraph Green</option>
                  <option value="independent">Independent Red</option>
                  <option value="social">Social Blue</option>
                  <option value="gold">Gold Premium</option>
                  <option value="yellow">Yellow Paste</option>
                  <option value="pastel-purple">Pastel Purple</option>
                  <option value="bubblegum">Bubblegum Pink</option>
                  <option value="grey">grey</option>
                </select>
              </div>
            </div>
            <div class="form-group">
              <div
                v-if="widget.type !== '25-colored' && widget.type !== '25' && widget.type !== '25-2019'"
                class="col-md-6">
                <label>Background opacity</label>
                <select
                  v-model="widget.background_opacity"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][background_opacity]'"
                  class="form-control">
                  <option value="no">No</option>
                  <option value="white">White</option>
                  <option value="black">Black</option>
                </select>
              </div>
              <div
                v-if="widget.type !== '75-head-picture' && widget.type !== '25-colored' && widget.type !== '25-full-bg' && widget.type !== '25' && widget.type !== '25-2019'"
                class="col-md-6">
                <label>Background position</label>
                <select
                  v-model="widget.background_position"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][background_position]'"
                  class="form-control">
                  <option value=""/>
                  <option value="left">Left</option>
                  <option value="right">Right</option>
                </select>
              </div>
            </div>
            <div
              v-if="widget.type !== '25-2019'"
              class="form-group">
              <div class="col-md-12">
                <label>Headline</label>
                <input
                  v-model="widget.headline"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][headline]'"
                  type="text"
                  class="form-control">
              </div>
              <div class="col-md-12">
                <label>Content</label>
                <textarea
                  v-model="widget.content"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][content]'"
                  rows="5"
                  class="form-control"/>
              </div>
            </div>
            <div
              v-if="widget.type === '50' || widget.type=== '100' || widget.type === '75'"
              class="form-group">
              <div class="col-md-6">
                <label>Category</label>
                <input
                  v-model="widget.category_name"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][category_name]'"
                  type="text"
                  class="form-control">
              </div>
              <div class="col-md-6">
                <label>Category color</label>
                <select
                  v-model="widget.category_color"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][category_color]'"
                  class="form-control">
                  <option value="blue">Blue</option>
                  <option value="green">Green</option>
                  <option value="red">Red</option>
                  <option value="purple">Purple</option>
                  <option value="telegraph">Telegraph Green</option>
                  <option value="gold">Gold Premium</option>
                  <option value="independent">Independent Red</option>
                  <option value="social">Social Blue</option>
                  <option value="yellow">Yellow Paste</option>
                  <option value="pastel-purple">Pastel Purple</option>
                  <option value="bubblegum">Bubblegum Pink</option>
                  <option value="grey">grey</option>
                </select>
              </div>
            </div>
            <div
              v-if="widget.type !== '25-2019'"
              class="form-group">
              <div
                v-if="widget.type !== '50-small' && widget.type !== '25-full-bg'"
                class="col-md-4">
                <label>CTA Button Style</label>
                <select
                  v-model="widget.cta_style"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][cta_style]'"
                  class="form-control">
                  <option value="none">None</option>
                  <option value="see_details">See Details</option>
                  <option value="button">Button</option>
                </select>
              </div>
              <div
                v-if="widget.type !== '50-small' && widget.type !== '25-full-bg'"
                class="col-md-4">
                <label>CTA Button Text</label>
                <input
                  v-model="widget.cta_text"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][cta_text]'"
                  type="text"
                  class="form-control">
              </div>
            </div>
            <div class="form-group">
              <div class="col-md-4">
                <label>Coupon IDs</label>
                <input
                  v-model="widget.coupon_id"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][coupon_id]'"
                  type="text"
                  class="form-control">
              </div>
              <div class="col-md-4">
                <label>Clickout URL</label>
                <input
                  v-model="widget.url"
                  :name="'widget[premium_offer_rows]['+key+'][widgets][][url]'"
                  type="text"
                  class="form-control">
              </div>
            </div>
          </div>
        </transition>
      </div>
      <button
        :disabled="(getRowWidth(row)>=100)"
        class="btn btn-success"
        @click.prevent="addWidget(key)">
        Add widget
      </button>
    </div>
    <button
      class="btn btn-success"
      @click.prevent="addRow">
      Add Row
    </button>
  </div>
</template>

<script>
  export default {
    name: "PremiumOffers",
    props: {
      json: {
        type: Object,
        default: ()=>{}
      }
    },
    data() {
      return {
        rows: this.json || {},
        baseWidget: {
          type: 25,
          background_url: "",
          background_color: "",
          background_opacity: "no",
          background_position: "right",
          category_name: "",
          category_color: "",
          headline: "",
          content: "",
          url: "",
          cta_style: "see_details",
          cta_text: "See Details",
          coupon_id: "",
          show: false
        },
        submitButton: document.querySelector('.modal input[type=submit]'),
      };
    },
    methods: {
      removeRow(id) {
        if (confirm("Do you really want to remove this row?")) {
          this.$delete(this.rows, id);
          this.sortObj(this.rows);
        }
      },
      addWidget(id) {
        this.rows[id].widgets.push(JSON.parse(JSON.stringify(this.baseWidget)));
      },
      removeWidget(widgetId, key) {
        if (confirm("Do you really want to remove this widget?")) {
          this.rows[key].widgets.splice(widgetId, 1);
        }
      },
      addRow() {
        let recentRow = Object.keys(this.rows).length;
        this.$set(this.rows, recentRow, {widgets: []});
      },
      sortObj(obj) {
        let orderNumber = 0;
        for (let key in obj) {
          if (orderNumber.toString() !== key) {
            this.$set(obj, orderNumber, obj[key]);
            this.$delete(obj, key);
          }
          orderNumber++;
        }
      },
      toggleWidget(widget) {
        this.$set(widget, "show", !widget.show);
      },
      getRowWidth(row) {
        let width = 0;

        if (row.hasOwnProperty("widgets") && row.widgets.length) {
          for (let i = 0, length = row.widgets.length; i < length; i++) {
            let typeText = row.widgets[i].type;
            if (typeof typeText === "string") {
              width += parseInt(typeText.split("-")[0]);
            } else {
              width += typeText;
            }
          }
        }

        this.preventUnfilledFormSend(width);

        return width;
      },
      preventUnfilledFormSend(rowWidth) {
        this.submitButton.disabled = (rowWidth > 100 || this.formError);
      },
      restrictedSizes(row) {
        let previous, error;
        let widgets = row.widgets;

        for (let widget in widgets) {

          if (widgets[widget].type !== '50-small' && previous !== '50-small' || widgets[widget].type === '50-small' && previous === '50-small') {
            error = false;
          }

          if (widgets[widget].type === '50-small' && previous !== '50-small') {
            error = true;
          }

          previous = widgets[widget].type;
        }

        this.formError = error;
        return error;
      }
    }
  };
</script>

<style scoped lang="scss">
  .form-row {
    margin-bottom: 10px;
    padding: 3px;
    border: 1px solid lightgray;

    &__header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      height: 45px;
      padding: 0 20px;
      font-weight: 700;
    }

    &__remove {
      cursor: pointer;
    }
  }

  .widget-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    height: 45px;
    margin-bottom: -1px;
    padding: 0 20px;
    font-weight: 700;
    background: #EEE;
    border: 1px solid lightgray;
    cursor: pointer;
  }

  .widget-form {
    position: relative;
    padding: 10px 15px;
    overflow: hidden;
    border: 1px solid #DDD;
    transform-origin: top;

    &__remove {
      position: absolute;
      top: 5px;
      right: 5px;
      cursor: pointer;
    }
  }

  h4 {
    margin-top: 20px;
  }

  .icon-caret-down,
  .icon-caret-left {
    width: 8px;
  }

  .success {
    color: #25DB49;
  }

  .btn.btn-success {
    display: block;
    margin: 10px auto;
  }

  .error {
    color: #EE4925;

    &.small {
      position: absolute;
      align-self: flex-end;
      width: 100%;
      font-size: 12px;
      text-align: center;
    }
  }

  /* Animations */

  .slide-enter-active {
    transition: all 0.2s ease;
  }

  .slide-leave-active {
    transition: all 0.2s ease;
  }

  .slide-enter,
  .slide-leave-to {
    height: 0;
    padding: 0 15px;
  }

</style>
