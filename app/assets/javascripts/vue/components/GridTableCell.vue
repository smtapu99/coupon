<template>
  <span
    v-if="type === 'text' || type=== 'date'"
    v-html="value">
  </span>
  <span
    v-else-if="type === 'icon'"
    v-html="getIcon(value)">
  </span>
  <span
    v-else-if="type === 'icon-reverse'"
    v-html="getIcon(!value)">
  </span>
  <span
    v-else-if="type === 'thumb'">
    <img class="img-responsive img-thumbnail" :src="value">
  </span>
  <span
    v-else-if="type === 'download'">
    <a :href="value" target="_blank">Download</a>
  </span>
  <span
    v-else-if="type === 'input-url'"
    :class="{'has-error': !isValid}">
    <input
      :value="value"
      @input="$emit('input', $event.target.value)"
      @change="validate($event.target)"
      type="url"
      class="form-control">
  </span>

</template>

<script>
  export default {
    name: "GridTableCell",
    props: {
      value: {
        type: [String, Number, Boolean],
        default: ''
      },
      type: {
        type: String,
        default: 'text'
      }
    },
    data() {
      return {
        isValid: true
      };
    },
    methods: {
      getIcon(status) {
        if (status !== undefined) {
          switch (status.toString()) {
            case "active":
            case "true":
              return '<i class="text-success icon-circle text-center big-icon"></i>';
            case "blocked":
            case "false":
            case "inactive":
              return '<i class="text-danger icon-circle text-center big-icon"></i>';
            case 'pending':
              return '<i class="text-warning icon-time text-center big-icon"></i>';
            case 'gone':
              return '<i class="icon-signout  big-icon text-center"></i>';
            default:
              return status;
          }
        }
      },
      validate(element) {
        this.isValid = element.checkValidity();
        this.$emit("fieldIsValid", element.checkValidity());
      }
    }
  };
</script>

<style scoped>
  div {
    display: inline-block;
  }
</style>
