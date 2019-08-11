import Vue from 'vue';
import VueRouter from 'vue-router';
import qs from 'qs';
import BaseGrid from './views/BaseGrid';

Vue.use(VueRouter);

const router = new VueRouter({
  mode: 'history',
  base: '/pcadmin/',
  parseQuery: function(query) {
    return qs.parse(query);
  },
  stringifyQuery: function(query) {
    return qs.stringify(query, {addQueryPrefix: true});
  },

  routes: [{
    path: '/coupons/',
    component: BaseGrid,
    name: 'coupons',
    props: () => ({
      buttonsList: ['active', 'blocked', 'pending'],
      gridSettings: {
        columns: ['status', 'expired', 'id', 'title', 'affiliate_network_slug', 'shop_slug', 'code', 'is_top', 'is_exclusive', 'is_free', 'start_date', 'end_date', 'created_at', 'priority_score'],
        customFormat: {
          'status': 'icon',
          'start_date': 'date',
          'end_date': 'date',
          'created_at': 'date',
          'expired': 'icon-reverse'
        },
        highlight: {'expired': 'true'},
        sortType: "backend",
        editButton: true,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'active', 'blocked', 'pending'],
            default: 'active'
          },
          'expired': {
            type: 'select',
            values: ['true', 'false'],
            default: 'false',
          },
          'is_top': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'is_exclusive': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'is_free': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'title': {
            type: 'text',
            placeholder: 'Title',
            min: 2
          },
          'shop_slug': {
            type: 'text',
            placeholder: 'Shop Slug',
            min: 2,
          },
          'affiliate_network_slug': {
            type: 'text',
            placeholder: 'Affiliate Network Slug',
            min: 2,
          },
          'start_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'start_date_from',
            name_to: 'start_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'end_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'end_date_from',
            name_to: 'end_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'created_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'created_at_from',
            name_to: 'created_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'code': {
            type: 'text',
            placeholder: 'Code',
            min: 2,
          },
          'priority_score': {
            type: 'text',
            placeholder: 'score',
            min: 1,
          }
        }
      },
    })
  }, {
    path: '/shops/',
    component: BaseGrid,
    name: 'shops',
    props: () => ({
      buttonsList: ['active', 'blocked', 'pending', 'visible', 'hidden', 'gone', window.authorized_to_reset_votes ? 'reset_votes' : ''],
      gridSettings: {
        columns: ['id', 'tier_group', 'title', 'slug', 'status', 'is_top', 'is_hidden', 'priority_score', 'updated_at'],
        customFormat: {'status': 'icon', 'is_top': 'icon', 'is_hidden': 'icon-reverse', 'updated_at': 'date'},
        sortType: "backend",
        editButton: true,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'tier_group': {
            type: "text",
            placeholder: 'Tier Group',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'active', 'blocked', 'pending', 'gone'],
            default: ''
          },
          'is_top': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'is_hidden': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'title': {
            type: 'text',
            placeholder: 'Title',
            min: 2,
          },
          'slug': {
            type: 'text',
            placeholder: 'Slug',
            min: 2,
          },
          'updated_at': {
            type: 'date',
            placeholder: 'Updated At',
            format: 'YYYY-MM-DD',
            clearButton: false
          },
          'priority_score': {
            type: 'text',
            placeholder: 'score',
            min: 1,
          },
        }
      }
    })
  }, {
    path: '/categories/',
    component: BaseGrid,
    name: 'categories',
    props: () => ({
      buttonsList: window.authorized_to_change_status ? ['active', 'blocked', 'pending'] : [],
      gridSettings: {
        columns: ['status', 'id', 'name', 'slug', 'main_category', 'parent'],
        customFormat: {'status': 'icon', 'main_category': 'icon'},
        sortType: "backend",
        editButton: true,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'active', 'blocked', 'pending', 'gone'],
            default: ''
          },
          'site': {
            type: 'text',
            placeholder: 'Site',
            min: 2,
          },
          'name': {
            type: 'text',
            placeholder: 'Name',
            min: 2,
          },
          'slug': {
            type: 'text',
            placeholder: 'Slug',
            min: 2,
          },
          'main_category': {
            type: "select",
            values: ['', 'yes', 'no'],
            default: ''
          },
          'parent': {
            type: 'text',
            placeholder: 'Parent',
            min: 2,
          },
        }
      }
    })
  }, {
    path: '/media/',
    component: BaseGrid,
    name: 'media',
    props: () => ({
      gridSettings: {
        columns: ['id', 'file_name', 'thumbnail', 'created_at'],
        customFormat: {'created_at': 'date', 'thumbnail': 'thumb'},
        sortType: "backend",
        editButton: false,
        copyButton: {
          field: "file_name",
          title: "Copy picture URL to Clipboard"
        },
        checkboxes: false,
        skipSortingField: ['thumbnail'],
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'site': {
            type: "text",
            placeholder: 'Site Url',
            min: 2,
          },
          'file_name': {
            type: "text",
            placeholder: 'Image Url',
            min: 2,
          },
          'created_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'created_at_from',
            name_to: 'created_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
        }
      }
    })
  }, {
    path: '/users/',
    component: BaseGrid,
    name: 'users',
    props: () => ({
      gridSettings: {
        columns: ['status', 'id', 'first_name', 'last_name', 'email', 'role'],
        customFormat: {'status': 'icon'},
        sortType: "backend",
        editButton: true,
        checkboxes: false,
        filterFields: {
          'status': {
            type: "select",
            values: ['', 'active', 'blocked'],
            default: ''
          },
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'first_name': {
            type: "text",
            placeholder: 'First Name',
            min: 2,
          },
          'last_name': {
            type: "text",
            placeholder: 'Last Name',
            min: 2,
          },
          'email': {
            type: 'text',
            placeholder: 'Email',
            min: 2,
          },
          'role': {
            type: 'text',
            placeholder: 'Role',
            min: 2,
          }
        }
      }
    })
  }, {
    path: '/sites/',
    component: BaseGrid,
    name: 'sites',
    props: () => ({
      gridSettings: {
        columns: ['status', 'id', 'name', 'hostname', 'time_zone', 'country'],
        customFormat: {'status': 'icon'},
        sortType: "backend",
        editButton: true,
        checkboxes: false,
        filterFields: {
          'status': {
            type: "select",
            values: ['', 'active', 'inactive'],
            default: ''
          },
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'name': {
            type: "text",
            placeholder: 'Name',
            min: 1,
          },
          'hostname': {
            type: 'text',
            placeholder: 'HostName',
            min: 2,
          },
          'time_zone': {
            type: 'text',
            placeholder: 'Time Zone',
            min: 2,
          },
          'country': {
            type: 'text',
            placeholder: 'Country',
            min: 2,
          }
        }
      }
    })
  }, {
    path: '/countries/',
    component: BaseGrid,
    name: 'countries',
    props: () => ({
      gridSettings: {
        columns: ['name', 'locale'],
        sortType: "backend",
        editButton: true,
        checkboxes: false,
        filterFields: {
          'name': {
            type: "text",
            placeholder: 'Name',
            min: 2,
          },
          'locale': {
            type: "text",
            placeholder: 'Locale',
            min: 1,
          },
        }
      }
    })
  }, {
    path: '/globals/',
    component: BaseGrid,
    name: 'globals',
    props: () => ({
      gridSettings: {
        columns: ['id', 'name', 'model_type'],
        sortType: "backend",
        editButton: {
          hide: !window.authorized_to_edit
        },
        checkboxes: false,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'model_type': {
            type: "select",
            values: ['', 'Shop'],
            default: ''
          },
          'name': {
            type: "text",
            placeholder: 'Name',
            min: 2,
          },
        }
      }
    })
  }, {
    path: '/globals/shop_mappings',
    component: BaseGrid,
    name: 'shop_mappings',
    props: () => ({
      gridSettings: {
        columns: ['id', 'name', 'url_home', 'domain', 'affiliate_networks'],
        customFormat: {
          'url_home': 'input-url',
        },
        saveUrl: "/pcadmin/globals/update_shop_mapping",
        saveFields: {
          shop_mapping: {
            id: "",
            country_id: document.getElementById("country_select").value,
            url_home: ""
          }
        },
        skipSortingField: ['affiliate_networks'],
        sortType: "backend",
        editButton: false,
        checkboxes: false,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'name': {
            type: "text",
            placeholder: 'Name',
            min: 2,
          },
          'url_home': {
            type: "text",
            placeholder: 'URL Home',
            min: 2,
          },
          'domain': {
            type: "text",
            placeholder: 'Domain',
            min: 2,
          },
        }
      }
    })
  }, {
    path: '/tag_imports/',
    component: BaseGrid,
    name: 'tag_imports',
    props: () => ({
      gridSettings: {
        columns: ['id', 'file', 'status', 'created_at'],
        customFormat: {},
        sortType: "backend",
        editButton: true,
        removeButton: true,
        checkboxes: false,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'file': {
            type: "text",
            placeholder: 'File name',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'done', 'error', 'pending', 'running'],
            default: ''
          },
          'created_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'created_at_from',
            name_to: 'created_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          }
        }
      }
    })
  }, {
    path: '/affiliate_networks/',
    component: BaseGrid,
    name: 'affiliate_networks',
    props: () => ({
      gridSettings: {
        columns: ['status', 'id', 'name', 'slug'],
        customFormat: {
          'status': 'icon'
        },
        sortType: "backend",
        editButton: true,
        checkboxes: false,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'active', 'blocked'],
            default: ''
          },
          'name': {
            type: "text",
            placeholder: 'Name',
            min: 2,
          },
          'slug': {
            type: "text",
            placeholder: 'Slug',
            min: 2,
          },
        }
      }
    })
  }, {
    path: '/tags/',
    component: BaseGrid,
    name: 'tags',
    props: () => ({
      gridSettings: {
        columns: ['id', 'word', 'category', 'is_blacklisted', 'api_hits'],
        sortType: "backend",
        editButton: true,
        checkboxes: true,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'word': {
            type: "text",
            placeholder: 'Word',
            min: 2,
          },
          'category': {
            type: "select",
            values: []
          },
          'is_blacklisted': {
            type: "select",
            values: ['', 'yes', 'no'],
            default: ''
          },
          'api_hits': {
            type: "text",
            placeholder: 'API Hits',
            min: 1,
          },
        }
      }
    })
  }, {
    path: '/static_pages/',
    component: BaseGrid,
    name: 'static_pages',
    props: () => ({
      gridSettings: {
        columns: ['status', 'site', 'title', 'slug'],
        customFormat: {'status': 'icon'},
        sortType: "backend",
        checkboxes: false,
        editButton: true,
        filterFields: {
          'status': {
            type: "select",
            values: ['', 'active', 'blocked',],
            default: ''
          },
          'title': {
            type: 'text',
            placeholder: 'Title',
            min: 2,
          },
          'site': {
            type: 'text',
            placeholder: 'Site',
            min: 2,
          },
          'slug': {
            type: 'text',
            placeholder: 'Slug',
            min: 2,
          },

        }
      }
    })
  }, {
    path: '/campaigns/',
    component: BaseGrid,
    name: 'campaigns',
    props: () => ({
      gridSettings: {
        columns: ['status', 'is_root_campaign', 'name', 'slug', 'parent', 'shop', 'blog_feed_url', 'start_date', 'end_date'],
        customFormat: {
          'status': 'icon',
          'is_root_campaign': 'icon',
          'start_date': 'date',
          'end_date': 'date',
        },
        sortType: "backend",
        editButton: true,
        checkboxes: false,
        filterFields: {
          'status': {
            type: "select",
            values: ['', 'active', 'blocked', 'gone'],
            default: ''
          },
          'is_root_campaign': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'name': {
            type: 'text',
            placeholder: 'Name',
            min: 2
          },
          'slug': {
            type: 'text',
            placeholder: 'Slug',
            min: 2,
          },
          'parent': {
            type: 'text',
            placeholder: 'Parent',
            min: 2,
          },
          'shop': {
            type: 'text',
            placeholder: 'Shop',
            min: 2,
          },
          'blog_feed_url': {
            type: 'text',
            placeholder: 'Url',
            min: 2,
          },
          'start_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'start_date_from',
            name_to: 'start_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'end_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'end_date_from',
            name_to: 'end_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          }
        }
      }
    })
  }, {
    path: '/redirect_rules/',
    component: BaseGrid,
    name: 'redirect_rules',
    props: () => ({
      gridSettings: {
        columns: ['active', 'source', 'destination'],
        customFormat: {'active': 'icon'},
        sortType: "backend",
        editButton: true,
        removeButton: true,
        checkboxes: false,
        filterFields: {
          'active': {
            type: "select",
            values: ['', 'active', 'blocked'],
            default: ''
          },
          'source': {
            type: "text",
            placeholder: 'Source',
            min: 1,
          },
          'destination': {
            type: "text",
            placeholder: 'Destination',
            min: 1,
          },
        }
      }
    })
  }, {
    path: '/csv_exports/',
    component: BaseGrid,
    name: 'csv_exports',
    props: () => ({
      gridSettings: {
        columns: ['id', 'export_type', 'status', 'file', 'user', 'params', 'created_at', 'last_executed'],
        customFormat: {'file': 'download'},
        sortType: "backend",
        editButton: true,
        removeButton: true,
        checkboxes: false,
        skipSortingField: ['params'],
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'export_type': {
            type: "select",
            values: ['', 'Campaign', 'Coupon', 'Shop', 'Tag'],
            default: ''
          },
          'status': {
            type: "select",
            values: ['', 'done', 'error', 'pending', 'running'],
            default: ''
          },
          'file': {
            type: "text",
            placeholder: 'File name',
            min: 1,
          },
          'user': {
            type: "select",
            values: []
          },
          'created_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'created_at_from',
            name_to: 'created_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'last_executed': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'last_executed_from',
            name_to: 'last_executed_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
        }
      }
    })
  }, {
    path: '/coupon_imports/',
    component: BaseGrid,
    name: 'coupon_imports',
    props: () => ({
      gridSettings: {
        columns: ['id', 'user', 'file', 'status', 'created_at'],
        customFormat: {},
        sortType: "backend",
        editButton: true,
        removeButton: true,
        checkboxes: false,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'user': {
            type: "select",
            values: []
          },
          'file': {
            type: "text",
            placeholder: 'File name',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'done', 'error', 'pending', 'running'],
            default: ''
          },
          'created_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'created_at_from',
            name_to: 'created_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          }
        }
      }
    })
  }, {
    path: '/shop_imports/',
    component: BaseGrid,
    name: 'shop_imports',
    props: () => ({
      gridSettings: {
        columns: ['id', 'user', 'file', 'status', 'created_at'],
        customFormat: {},
        sortType: "backend",
        editButton: true,
        removeButton: true,
        checkboxes: false,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'user': {
            type: "select",
            values: []
          },
          'file': {
            type: "text",
            placeholder: 'File name',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'done', 'error', 'pending', 'running'],
            default: ''
          },
          'created_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'created_at_from',
            name_to: 'created_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          }
        }
      }
    })
  }, {
    path: '/campaign_imports/',
    component: BaseGrid,
    name: 'campaign_imports',
    props: () => ({
      gridSettings: {
        columns: ['id', 'user', 'file', 'status', 'created_at'],
        customFormat: {},
        sortType: "backend",
        editButton: true,
        removeButton: true,
        checkboxes: false,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'user': {
            type: "select",
            values: []
          },
          'file': {
            type: "text",
            placeholder: 'File name',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'done', 'error', 'pending', 'running'],
            default: ''
          },
          'created_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'created_at_from',
            name_to: 'created_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          }
        }
      }
    })
  }, {
    path: '/coupon_codes/',
    component: BaseGrid,
    name: 'coupon_codes',
    alias: '/coupons/:coupon_id/coupon_codes/',
    props: () => ({
      gridSettings: {
        columns: ['coupon_id', 'code', 'tracking_user_id', 'is_imported', 'end_date', 'used_at', 'created_at', 'updated_at'],
        customFormat: {},
        sortType: "backend",
        editButton: true,
        checkboxes: false,
        filterFields: {
          'coupon_id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'code': {
            type: "text",
            placeholder: 'Code',
            min: 2
          },
          'tracking_user_id': {
            type: "text",
            placeholder: 'User ID',
            min: 1,
          },
          'is_imported': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'end_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'end_date_from',
            name_to: 'end_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'used_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'used_at_from',
            name_to: 'used_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'created_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'created_at_from',
            name_to: 'created_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'updated_at': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'updated_at_from',
            name_to: 'updated_at_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          }
        }
      }
    })
  }, {
    path: '/alerts/',
    component: BaseGrid,
    name: 'alerts',
    props: () => ({
      gridSettings: {
        columns: ['status', 'is_critical', 'alert_type', 'model', 'model_id', 'message', 'date'],
        sortType: "backend",
        checkboxes: false,
        editButton: {
          type: "URL",
          value: "${edit_path}",
          icon: "icon-link",
          target: "_blank",
          title: 'Fix it'
        },
        removeButton: {
          showCondition: {
            status: 'active'
          },
          icon: 'icon-check',
          class: 'btn btn-success',
          title: 'Mark alert inactive'
        },
        customFormat: {
          'date': 'date',
          'status': 'icon'
        },
        filterFields: {
          'is_critical': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'status': {
            type: "select",
            values: ['', 'active', 'inactive'],
            default: 'active'
          },
          'model': {
            type: "select",
            values: ['', 'Coupon', 'WidgetBase'],
            default: ''
          },
          'model_id': {
            type: "text",
            placeholder: 'Model ID',
            min: 1,
          },
          'alert_type': {
            type: "select",
            values: ['', 'uniq_codes_empty', 'coupons_expiring', 'widget_coupons_expiring_3_days'],
            default: ''
          },
          'message': {
            type: "text",
            placeholder: 'Message',
            min: 2,
          },
          'date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'date_from',
            name_to: 'date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
        }
      }
    })
  }, {
    path: '/banners/',
    component: BaseGrid,
    name: 'banners',
    props: () => ({
      gridSettings: {
        columns: ['status', 'name', 'image_url', 'banner_type', 'theme', 'start_date', 'end_date'],
        sortType: "backend",
        checkboxes: false,
        editButton: true,
        removeButton: true,
        customFormat: {
          'start_date': 'date',
          'end_date': 'date',
          'image_url': 'thumb',
          'status': 'icon'
        },
        skipSortingField: ['image_url'],
        filterFields: {
          'status': {
            type: "select",
            values: ['', 'active', 'inactive'],
            default: 'active'
          },
          'name': {
            type: "text",
            placeholder: 'Name',
            min: 2,
          },
          'banner_type': {
            type: "select",
            values: ['', 'sticky_banner', 'shop_banner', 'sidebar_banner'],
            default: ''
          },
          'theme': {
            type: "text",
            placeholder: 'Theme',
            min: 2,
          },
          'start_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'start_date_from',
            name_to: 'start_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'end_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'end_date_from',
            name_to: 'end_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
        }
      }
    })
  }, {
    path: '/quality/active_coupons',
    component: BaseGrid,
    name: 'active_coupons',
    props: () => ({
      gridSettings: {
        columns: ['id', 'tier_group', 'title', 'slug', 'priority_score', 'status', 'is_top', 'is_hidden', 'best_offer_valid', 'today', '3_days', '7_days'],
        customFormat: {'status': 'icon', 'is_top': 'icon', 'is_hidden': 'icon-reverse'},
        sortType: "backend",
        checkboxes: false,
        editButton: {
          type: "URL",
          value: "/pcadmin/coupons?f[shop_slug]=${slug}",
          icon: "icon-link",
          target: "_blank",
          title: 'See active coupons'
        },
        skipSortingField: ['best_offer_valid'],
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'tier_group': {
            type: "text",
            placeholder: 'Tier Group',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'active', 'blocked', 'pending', 'gone'],
            default: 'active'
          },
          'is_top': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'is_hidden': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'title': {
            type: 'text',
            placeholder: 'Title',
            min: 2,
          },
          'slug': {
            type: 'text',
            placeholder: 'Slug',
            min: 2,
          },
          'priority_score': {
            type: 'text',
            placeholder: 'score',
            min: 1,
          },
          'today': {
            type: 'text',
            placeholder: 'Active Coupons',
            min: 1,
          },
          '3_days': {
            type: 'text',
            placeholder: 'Active Coupons',
            min: 1,
          },
          '7_days': {
            type: 'text',
            placeholder: 'Active Coupons',
            min: 1,
          }
        }
      }
    })
  }, {
    path: '/quality/http_links',
    component: BaseGrid,
    name: 'http_links',
    props: () => ({
      gridSettings: {
        columns: ['object_id', 'object_type', 'message'],
        sortType: "backend",
        skipSortingField: ['message'],
        checkboxes: false,
        editButton: {
          type: "URL",
          value: "/pcadmin/${object_type}s/${object_id}/edit",
          icon: "icon-link",
          target: "_blank",
          title: 'Edit'
        },
        filterFields: {
          'object_id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'object_type': {
            type: "select",
            values: ['', 'Shop', 'Campaign', 'StaticPage'],
            default: ''
          }
        }
      }
    })
  }, {
    path: '/quality/expired_exclusives',
    component: BaseGrid,
    name: 'expired_exclusives',
    props: () => ({
      buttonsList: [window.authorized_to_edit ? 'editModal' : ''],
      gridSettings: {
        columns: ['status', 'expired', 'id', 'title', 'affiliate_network_slug', 'shop_slug', 'is_exclusive', 'start_date', 'end_date',],
        customFormat: {
          'status': 'icon',
          'start_date': 'date',
          'end_date': 'date',
          'created_at': 'date',
          'expired': 'icon-reverse'
        },
        highlight: {'expired': 'true'},
        sortType: "backend",
        editButton: {
          type: 'modal',
          hide: !window.authorized_to_edit
        },
        checkboxes: true,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'status': {
            type: "select",
            values: ['', 'active', 'blocked', 'pending'],
            default: 'active'
          },
          'expired': {
            type: 'select',
            values: ['true', 'false'],
            default: 'true',
          },
          'is_exclusive': {
            type: "select",
            values: ['', 'true', 'false'],
            default: ''
          },
          'title': {
            type: 'text',
            placeholder: 'Title',
            min: 2
          },
          'shop_slug': {
            type: 'text',
            placeholder: 'Shop Slug',
            min: 2,
          },
          'affiliate_network_slug': {
            type: 'text',
            placeholder: 'Affiliate Network Slug',
            min: 2,
          },
          'start_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'start_date_from',
            name_to: 'start_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
          'end_date': {
            type: 'date-range',
            placeholder_from: 'From Date',
            placeholder_to: 'To Date',
            name_from: 'end_date_from',
            name_to: 'end_date_to',
            format: 'YYYY-MM-DD',
            clearButton: true
          },
        }
      },
    })
  }, {
    path: '/quality/invalid_urls',
    component: BaseGrid,
    name: 'invalid_urls',
    props: () => ({
      gridSettings: {
        columns: ['id', 'shop_slug', 'affiliate_network_slug', 'url'],
        customFormat: {},
        highlight: {},
        sortType: "backend",
        editButton: {
          type: "URL",
          value: "${edit_path}",
          icon: "icon-link",
          target: "_blank",
          title: 'Fix it'
        },
        checkboxes: false,
        filterFields: {
          'id': {
            type: "text",
            placeholder: 'ID',
            min: 1,
          },
          'shop_slug': {
            type: 'text',
            placeholder: 'Shop Slug',
            min: 2,
          },
          'affiliate_network_slug': {
            type: 'text',
            placeholder: 'Affiliate Network Slug',
            min: 2
          },
          'url': {
            type: 'text',
            placeholder: 'URL',
            min: 2,
          }
        }
      },
    })
  }]
});
export default router;
