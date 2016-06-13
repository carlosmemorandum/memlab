// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require foundation
//= require_tree .

var setDisabled = function(trigger, element) {
	  trigger.onsubmit = function() {
		element.setAttribute("disabled", "disabled");
		return true;
	}
};

var resetDisabled = function(trigger, element) {
	 trigger.onclick = function() {
		 element.removeAttribute("disabled");
		 element.value = "Enviar";
	}
}

$(function() {
	$(document).on('ready page:load', function () {
		$(document).foundation();

		var isAdvancedUpload = function() {
	  	var div = document.createElement('div');
	  	return (('draggable' in div) || ('ondragstart' in div && 'ondrop' in div)) && 'FormData' in window && 'FileReader' in window;
		}();

		var $form = $('.form-dragndrop');

		//mySubmit.setAttribute('disabled', 'disabled');

		if (isAdvancedUpload) {

			$form.addClass('has-advanced-upload');
			$

		  var droppedFiles = false,
		  		$input    = $form.find('input[type="file"]'),
			    $label    = $('.box__label'),
			    showFiles = function(files) {
			      $label.text(files.length > 1 ? ($input.attr('data-multiple-caption') || '').replace( '{count}', files.length ) : files[ 0 ].name);
			    };

		  $form.on('drag dragstart dragend dragover dragenter dragleave drop', function(e) {
		    e.preventDefault();
		    e.stopPropagation();
		  })
		  .on('dragover dragenter', function() {
		    $form.addClass('is-dragover');
		  })
		  .on('dragleave dragend drop', function() {
		    $form.removeClass('is-dragover');
		  })
		  .on('drop', function(e) {
		    droppedFiles = e.originalEvent.dataTransfer.files; // the files that were dropped
  			showFiles( droppedFiles );
  			mySubmit.removeAttribute('disabled');
		    console.log(droppedFiles.length);
		  });
		  $input.on('change', function(e) {
			  showFiles(e.target.files);
			  console.log(e.target.files);

			  if (e.target.files) {
			  	mySubmit.removeAttribute('disabled');
			  }
			});

		}
		$form.on('submit', function(e) {
		 

		  if ($form.hasClass('is-uploading')) return false;

		  $form.addClass('is-uploading').removeClass('is-error');

		  if (isAdvancedUpload) {
		    e.preventDefault();

			  var ajaxData = new FormData($form.get(0));

			  if (droppedFiles) {
			    $.each( droppedFiles, function(i, file) {
			      ajaxData.append( $input.attr('name'), file );
			    });
			  }

			  $.ajax({
			    url: $form.attr('action'),
			    type: $form.attr('method'),
			    data: ajaxData,
			    dataType: 'js',
			    cache: false,
			    contentType: false,
			    processData: false,
			    complete: function() {
			      $form.removeClass('is-uploading');
			      window.location = '/' + $export + '/export';
			    },
			    success: function(data) {
			      $form.addClass( data.success == true ? 'is-success' : 'is-error' );
			      if (!data.success) $errorMsg.text(data.error);
			    },
			    error: function() {
			      // Log the error, show an alert, whatever works for you
			    }
			  });

		  } else {
		    var iframeName  = 'uploadiframe' + new Date().getTime();
		    $iframe   = $('<iframe name="' + iframeName + '" style="display: none;"></iframe>');

			  $('body').append($iframe);
			  $form.attr('target', iframeName);

			  $iframe.one('load', function() {
			    var data = JSON.parse($iframe.contents().find('body' ).text());
			    $form
			      .removeClass('is-uploading')
			      .addClass(data.success == true ? 'is-success' : 'is-error')
			      .removeAttr('target');
			    if (!data.success) $errorMsg.text(data.error);
			    $form.removeAttr('target');
			    $iframe.remove();
			  });
		  }

		});
		});

});
