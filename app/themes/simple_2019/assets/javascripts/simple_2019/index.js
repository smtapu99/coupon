import "@babel/polyfill";
import {App} from "./core/facade";

axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

require('./pages');

document.addEventListener('DOMContentLoaded', function() {
  App.log("%cSimple%c_2019", "color:green;font-size:1.5rem", "color:red;font-size:1.5rem");
  App.start();
});

