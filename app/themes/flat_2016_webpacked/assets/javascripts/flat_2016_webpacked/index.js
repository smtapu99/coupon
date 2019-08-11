window.$ = window.jQuery = require('jquery');
import "expose-loader?$!jquery"
import "expose-loader?jQuery!jquery"

import Rails from 'jquery-ujs';
const cssrelpreload = require('fg-loadcss/src/cssrelpreload');
import 'zeroclipboard';
import 'clipboard';
import Cookies from 'js-cookie';
window.Cookies = Cookies;

import './vendor/bootstrap.min';
import './vendor/jquery.flexslider-min'
//import 'jasny-bootstrap/dist/js/jasny-bootstrap';
import 'jasny-bootstrap/js/offcanvas';
// Our js


import './events';
import './tracking';
import './element-tracking';
import './plugins';
import './header';
import './home';
import './widget/featured_coupons';
import './widget/top_x_coupons';
import './widget/shop_bubbles';
import './widget/quickLinks';
import './card_bookmarks_index';
import './card_coupons_list';
import './shop';
import './card_text';
import './footer';
import './scroll_to_top';
import './clickout_page';
import './cookies_eu';
import './flyout';
import './defer';

