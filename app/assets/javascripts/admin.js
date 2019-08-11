//= require flatty/jquery/jquery.min
//= require rails
//= require flatty/jquery/jquery.mobile.custom.min
//= require flatty/jquery/jquery-migrate.min
//= require flatty/jquery/jquery-ui.min
//= require bootstrap-3.3.7
//= require flatty/plugins/plugins
//= require flatty/theme
//= require flatty/jquery/jquery.cookie-1.4.1.min
//= require admin/template
//= require admin/jquery.simulateDragSortable
//= require admin/select2.sortable
//= require admin/warning.js
//= require tinymce-jquery
//= require_self

var IS_SUPER_ADMIN;
var HOME_MAX_WIDGETS = 10;
var DEFAULT_MAX_WIDGETS = 7;

function getCookie( cName ) {
  return jQuery.cookie(cName);
}

function setCookie( cName , value, path ) {
  return jQuery.cookie(cName, value, {path: (path || '/')});
}

function expireCookie( cName, path ) {
  jQuery.cookie(cName, null);
  return jQuery.removeCookie(cName, {path: (path || '/')});
}

$(document).ready(function() {

  var select2color = function(e) {
      color = e.element[0].dataset['hex'];
      return '<span class="label" style="background:'+color+';">&nbsp;</span> ' + e.text;
  };

  $(".select2-clear").select2({
    allowClear: true
  });

  $('#coupon_affiliate_network_id').select2({
    allowClear: true,
    placeholder: 'Please Select',
    width: 'resolve'
  });

  $('#coupon_shop_id').select2({
    allowClear: true,
    placeholder: 'Select Shop',
    width: 'resolve'
  });

  $('#coupon_campaign_id').select2({
    allowClear: true,
    placeholder: 'Select Campaign',
    width: 'resolve'
  });

  $(".select2-color").select2({
      formatResult: select2color,
      formatSelection: select2color,
      escapeMarkup: function(e) {
          return e;
      }
  });

  $("#search_box_shops").select2({
    maximumSelectionSize: 3
  });

  $("#search_box_shops_popular").select2({
    maximumSelectionSize: 8
  });

  select2_select_all();

  tinyMCE.init({
    forced_root_block : "",
    force_br_newlines : true,
    force_p_newlines : false,
    entity_encoding : "raw",
    valid_elements : '+*[*]',
    relative_urls: false,
    convert_urls: false,
    remove_script_host : false,
    valid_children : "+body[style]",
    selector: "textarea.tinymce",
    toolbar: ["styleselect | bold italic | alignleft aligncenter alignright | link image | undo redo","table | code"],
    plugins: "table,code,link,image"
  });

  if($('#more-activity').length){
    $(document).on('click', '#more-activity', function(e){
      btn = $(this);
      $.ajax({
        url: this.href,
        data: {'page': ACTIVITY_NEXT_PAGE },
        dataType: 'script',
        beforeSend: function(){
          btn.button('loading');
        },
        complete: function(){
          btn.button('reset');
        }
      });
      e.preventDefault();
    });
  }


  if($('.codearea').length){

    var dirty_state = false;

    $(window).bind('beforeunload', function(){
      return 'All unsaved changes will be lost!';
    });

    var myTextArea = $('.codearea')[0];

    var editor = CodeMirror.fromTextArea(myTextArea, {
      lineNumbers: false,
      lineWrapping: false,
      theme: 'monokai',
      mode: 'htmlmixed'
    });

    setCodeMirrorValue(editor, $('#template_select').val());

    editor.save = function(){
      $.ajax({
        method: 'POST',
        url: '/pcadmin/templates/save?template='+$('#template_select').val(),
        data: {"value":editor.getValue(), "template":$('#template_type').val()},
        success: function(d){
          alert('Layout Saved');
          $('#dirty_state').removeClass('label-danger').addClass('label-success');
        }
      });
    };


    $('.CodeMirror').bind('keydown', function(){
      $('#dirty_state').removeClass('label-success').addClass('label-danger');
    });

    $(document).bind('keydown', function(e) {
      if(e.ctrlKey && (e.which == 83)) {
        e.preventDefault();
        editor.save();
        return false;
      }
    });

    $(document).on('click', '#update_template_button', function(){
      editor.save();
    });
    $(document).on('click', '#default_template_button', function(){
      restoreDefaultLayout(editor);
    });
    $(document).on('click', '#delete_template_button', function(){
      deleteLayout(editor);
    });
  }

  // If JavaScript is active
  if ($('html').hasClass('js')) {

    $(document).on('click', '.btn-toolbar a[data-status]', function(e) {
      e.preventDefault();

      var button = $(this);
      var myArray = Array();

      $('.my_class.sel input:checked').each(function() {
        var input = $(this);
        myArray.push(input[0].value);
      });

      if (myArray.length) {
        $.ajax({
          async: false,
          type: 'get',
          url: '/pcadmin/' + button.data('location') + '/change_status',
          data: {
            ids: myArray,
            status: button.data('status')
          },
          success: function(data) {
            return true;
          },
          error: function(data) {
            return false;
          }
        });

        location.reload();
      } else {
        alert('Please select at least one item.');
      }
    });
  }

  initShopCouponsSortable();
  /**********
  * Widget Areas
  ***********/
  validateWidgetCount();
  initDraggable();
  initSortable();

  if($('#campaign_select').length){
    $(document).on('change', '#campaign_select', function() {
      var url = $(this).val() ? "?campaign="+$(this).val() : '/pcadmin/widgets';
      $(location).attr("href", url);
    });
  }
  if($('#country_select').length){
    $(document).on('change', '#country_select', function() {
      var url = $(this).val() ? "?f[country_id]="+$(this).val() : '/pcadmin/global_shop_mappings';
      $(location).attr("href", url);
    });
  }

  if($('#site_select').length){
    $(document).on('change', '#site_select', function() {
      var url = $(this).val() ? "?site_id="+$(this).val() : '/pcadmin/media';
      $(location).attr("href", url);
    });
  }


  if($('#template_select').length){
    $(document).on('change', '#template_select', function() {
      var url = $(this).val() ? "?template="+$(this).val() : '/pcadmin/templates';
      $(location).attr("href", url);
    });
  }

  /* Empty content of modal when hiding */
  $('body').on('hidden.bs.modal', '.modal', function () {
    $(this).removeData('bs.modal');
    $(this).empty();
  });

  /**********
  * DateRangePicker
  **********/
  if($('#daterange2').length){
    $("#daterange2").daterangepicker({
      format: "MM/DD/YYYY"
    }, function(start, end) {
      window.location.href = "?start_date=" + start.format("YYYY-MM-DD") + "&end_date=" + end.format("YYYY-MM-DD");
    });
  }

});

$(document).ajaxSuccess(function(){
  $('#widgetareas li').removeClass('ui-draggable');
  validateWidgetCount();
  initSortable();
  initDraggable();
});

// Return a helper with preserved width of cells
var fixHelper = function(e, ui) {
  ui.children().each(function() {
    $(this).width($(this).width());
  });
  return ui;
};


function initSortable(){

  $( "#main ul, #sidebar ul, #footer ul, #archive ul" ).sortable({
    receive: function(event, ui) {
      sortableIn = 1;
    },
    over: function(e, ui) { sortableIn = 1; },
    out: function(e, ui) { sortableIn = 0; },
    beforeStop: function(e, ui) {
      if (sortableIn == 0) {
        ui.item.remove();
      }
    },
    stop: function (event, ui) {

      $(this).find('li').each(function(index, value){
        $(value).attr('id', 'widget_order_' + $(this).attr('data-widget-id'));
      });

      var data = $(this).sortable('serialize');

      if(CAMPAIGN_CURRENT !== undefined || CAMPAIGN_CURRENT !== '0'){
        data += '&campaign=' + CAMPAIGN_CURRENT;
      }

      $.ajax({
        data: data + "&name="+$(this).parent().attr('id'), // + '&authenticity_token=' + AUTH_TOKEN,
        type: 'GET',
        url: 'widgets/update_widget_area'
      });
    }
  });

  $("ul, li").disableSelection();
}

var getUrlParameter = function getUrlParameter(sParam) {
  var sPageURL = window.location.search.substring(1),
    sURLVariables = sPageURL.split('&'),
    sParameterName,
    i;

  for (i = 0; i < sURLVariables.length; i++) {
    sParameterName = sURLVariables[i].split('=');

    if (sParameterName[0] === sParam) {
      return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
    }
  }
};

function validateWidgetCount() {
  var type = getUrlParameter('campaign') ? 'campaign' : 'home';
  var max = type == 'home' ? HOME_MAX_WIDGETS : DEFAULT_MAX_WIDGETS;
  var ele = $('#main').parents('.box-bordered').find('.box-header');
  var count = $('#main li').length;


  if (count > 5) {
    if (count > max) {
      ele.find('span').text('(Speed-Score: Critical)');
      ele.attr('class', 'box-header red-background');
      return;
    }
    ele.find('span').text('(Speed-Score: Danger)');
    ele.attr('class', 'box-header orange-background');
  } else {
    ele.find('span').text('(Speed-Score: Ok)');
    ele.attr('class', 'box-header green-background');
  }
}


function initDraggable() {
  $("#widgets li[data-type='text']").draggable({
    connectToSortable: (IS_SUPER_ADMIN == true ? '#main ul, #sidebar ul, #footer ul' : '#main ul'),
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='raw_html']").draggable({
    connectToSortable: (IS_SUPER_ADMIN == true ? '#main ul, #sidebar ul, #footer ul' : '#main ul'),
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='newsletter']").draggable({
    connectToSortable: '#main ul, #sidebar ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='featured_coupons']").draggable({
    connectToSortable: '#main ul, #sidebar ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='shop_list_columns']").draggable({
    connectToSortable: '#main ul, #sidebar ul, #footer ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='sponsor_bar']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='popup']").draggable({
    connectToSortable: '#main ul, #sidebar ul, #footer ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='featured_images']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='quicklinks']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='about']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='hot_offers']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='premium_offers']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='subpage_teaser']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='premium_hero']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='top_sales']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='shop_bubbles']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='discount_bubbles']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='image']").draggable({
    connectToSortable: '#main ul, #sidebar ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='countdown_header']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='help']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='coupons_lists']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='top_x_coupons']").draggable({
    connectToSortable: '#main ul, #sidebar ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='blog_posts']").draggable({
    connectToSortable: '#main ul, #sidebar ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='rotated_coupons']").draggable({
    connectToSortable: '#main ul, #sidebar ul',
    helper: "clone",
    revert: 'invalid'
  });
  $("#widgets li[data-type='premium_widget']").draggable({
    connectToSortable: '#main ul',
    helper: "clone",
    revert: 'invalid'
  });
}

function initShopCouponsSortable(){

  $( "#sortable_coupons ul" ).sortable({
    stop: function (event, ui) {

      validateWidgetCount();

      $(this).find('li').each(function(index, value){
        $(value).attr('id', 'coupon_order_' + $(this).attr('data-coupon-id'));
      });

      var data = $(this).sortable('serialize');

      if(SHOP_CURRENT !== undefined || SHOP_CURRENT !== '0'){
        data += '&id=' + SHOP_CURRENT;
      }

      $.ajax({
        data: data, //# + '&authenticity_token=',// + AUTH_TOKEN,
        type: 'GET',
        url: '/pcadmin/shops/update_coupon_order'
      });
    }
  });

  $("ul, li").disableSelection();
}

function setCodeMirrorValue(editor, type){
  type = type || 'cl';
  $.ajax({
    method: 'GET',
    url: '/pcadmin/templates/get_layout?template='+type,
    complete: function(d){
      editor.setValue(d.responseText);
      $('#dirty_state').removeClass('label-danger').addClass('label-success');
    }
  });
};

var dates;
function restoreDefaultLayout(editor){
  $.ajax({
    method: 'GET',
    url: '/pcadmin/templates/restore_default?template='+$('#template_select').val(),
    beforeSend: function(){
      if(!confirm('Are you sure that you want to get the default layout? All modifications will be lost!'))
      {
        return false;
      }
    },
    complete: function(d){
      editor.setValue(d.responseText);
      $('#dirty_state').removeClass('label-danger').addClass('label-success');
    }
  });
};

function deleteLayout(editor){
  $.ajax({
    method: 'DELETE',
    url: '/pcadmin/templates/delete_layout?template='+$('#template_select').val(),
    beforeSend: function(){
      if(!confirm('Are you sure that you want to delete the layout? All modifications will be lost!'))
      {
        return false;
      }
    },
    complete: function(d){
      editor.setValue('');
      $('#dirty_state').removeClass('label-danger').addClass('label-success');
    }
  });
};

jQuery(document).ready(function($) {
  $(document).on('change', '.fileupload-buttonbar .btn input[type="file"]', function() {
    $('form#new_medium').submit();
  });
});

window.onload = function() {
  if (window.location.pathname === '/pcadmin/widgets' && getUrlParameter('widget_id') !== undefined) {
    $('li[data-widget-id="' + getUrlParameter('widget_id') + '"] .icon-pencil').first().trigger('click');
  }
};

function dynamicSnippetAlerts() {
  function isCategoriesEditPage() {
    var url = window.location.pathname.split("/");
    return (url[2] === 'categories' && url[4] === 'edit');
  }

  function alertAccepted() {
    return confirm("DYNAMIC SNIPPETS STATUS - THIS CHANGE WILL AFFECT DYNAMIC SNIPPETS INTEGRATIONS - ARE YOU SURE YOU WANT TO CONTINUE?");
  }

  if (isCategoriesEditPage()) {
    var $inputFields = $('.select2-container-multi');

    $inputFields.each(function() {
      var select = $(this).next('select');
      var alertShown = false;
      var $select2choices = select.siblings('.select2-container').find('.select2-choices');

      $select2choices.on('sortout', function() {
        if (!alertShown && !alertAccepted()) {
          $select2choices.sortable("cancel");
        } else {
          alertShown = true;
        }
      });

      select.on('select2-open', function() {
        if (!alertShown && !alertAccepted()) {
          select.select2('close');
        } else {
          alertShown = true;
        }
      }).on('select2-removing', function(e) {
        if (!alertShown && !alertAccepted()) {
          e.preventDefault();
        } else {
          alertShown = true;
        }
      });
    });
  }
}

window.select2_select_all = function(elem) {

  if (typeof elem !== "undefined") {
    var $inputFields = elem
  } else {
    var $inputFields = $('.select2-container-multi');
  }

  $inputFields.each(function() {
    var button = $('<button type="button" class="select2_select_all">Select All</button>');
    var select = $(this).next('select');
    var options = select.find('option');
    var state = {
      opened: false,
      selectedItems: 0,
      selectedAll: false,
      action: 'selectAll',
      buttonText: 'Select All'
    };

    $(this).append(button);

    select.on('select2-open', function(e) {
      state.opened = true;
      updateState();
    });

    select.on('select2-close', function(e) {
      state.opened = false;
      updateState();
    });

    select.on('change.select2', function(e) {
      state.selectedItems = $(this).val();
      updateState();
    });


    $(this).keydown(function(e) {
      if (e.ctrlKey && e.keyCode === 65) {
        selectMatched();
      }
    });

    button.click(function(e) {
      e.preventDefault();

      switch (state.action) {
        case 'selectAll':
          selectAll();
          break;
        case 'unselectAll':
          unselectAll();
          break;
      }
    });

    function selectAll() {

      if (!isDangerous(options)) {
        options.each(function() {
          $(this).prop('selected', 'selected');
        });

        select.trigger('change.select2');
        updateState()
      }
    }

    function unselectAll() {
      options.each(function() {
        $(this).prop('selected', false);
      });

      select.trigger('change.select2');
      updateState();
    }

    function selectMatched() {
      var matched = $('.select2-result-label');

      if(!isDangerous(matched)) {
        matched.each(function(i, item) {
          select.find("option:contains('" + $(item).text() + "')").prop("selected", "selected");
        });
        select.trigger('change.select2');
        updateState();
      }

    }

    function updateState() {
      if (state.opened && !state.selectedItems) {
        state.buttonText = 'CTRL + A';
        state.action = 'selectmatched';
      } else if (state.opened && state.selectedItems > 0) {
        state.buttonText = 'Unselect Matched';
        state.action = 'unselectmatched';
      } else if (!state.opened && !state.selectedItems) {
        state.buttonText = 'Select All';
        state.action = 'selectAll';
      } else {
        state.buttonText = 'Unselect All';
        state.action = 'unselectAll';
      }
      button.text(state.buttonText);
    }

    function isDangerous(options){
      var isDangerous = false;
      var length = options.length;
      if (length > 50) {
        isDangerous = !confirm("you're going to select " + length + " items, it could be dangerous! Continue?");
      }
      return isDangerous;
    }

  })
};

function initBannerSettingsSelector() {

  var $bannerSelector = $("#banner_theme");

  if (!$bannerSelector.length) {
    return false;
  }

  var $fieldset = $("#default-banner-fieldset");

  //initial
  handleBannerSelectorChange();

  $bannerSelector.on('change', handleBannerSelectorChange)

  function handleBannerSelectorChange() {
    $fieldset.toggle($bannerSelector.val() === 'default');
  }
}

// This snippet fixes the fonticons bug in Google Chrome
function fixChromeFontIconsBug() {
  var oldOffset = $('body').offset();
  $('body').offset(oldOffset);
}

function openMenuInQASection(){
  var page = window.location.pathname.split("/")[2];
  if (page === "quality") {
    var menuItem = $(".nav-item--qa .dropdown-collapse");
    var dropdown = menuItem.siblings(".nav.nav-stacked");
    menuItem.addClass("in");
    dropdown.addClass("in").slideDown();
  }
}

jQuery(document).ready(function($){
  fixChromeFontIconsBug();
  initBannerSettingsSelector();
  openMenuInQASection();
});

;(function($) {
  var expired = $('#grid > table span.expired');

  if (expired.length) {
    expired.each(function() {
      var $this = $(this);

      $this.parent().parent().css('color', '#999');
    });
  }

  // This snippet fixes the fonticons bug in Google Chrome
  jQuery(document).ready(function($){
    $(document).on('change', '.expired-filter', function(){
      $($(this).parents('form').submit());
    })
  });
})(jQuery);

;(function($) {
  function initSelect2Draggables() {
    $('.select2').select2Sortable({bindOrder: 'sortableStop'});
  }
  $(document).ready(function() {
    initSelect2Draggables();
    dynamicSnippetAlerts();
  });
})(jQuery);


;(function($) {
  var shop_update_button = $('.btn.update-shop')

  shop_update_button.on('click', function(ev){
    if(shop_update_button.length > 0) {
      if($('#shop_status option:selected').text() == 'blocked') {
        var result = confirm("Alert!!! Coupons and Shops will also get 'blocked'. Fine?");

        if(!result) {
          ev.preventDefault();
        }
      }
    }
  })
})(jQuery);
