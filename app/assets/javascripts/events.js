$(document).ready(function() {

	//enable link to tab
	var url = document.location.toString();
	if (url.match('#')) {
	  $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show') ;
	}

	$('.launched-more').hide();
	$('.invited-more').hide();
	/*************************event index part**********************************/
	$('#btnMoreLaunched').click(function() {
		$('.launched-more').toggle('slow');
		if ($(this).html() == 'More')
			$(this).html('Less');
		else 
			$(this).html('More');
	})

	$('#btnMoreInvited').click(function() {
		$('.invited-more').toggle('slow');
		if ($(this).html() == 'More')
			$(this).html('Less');
		else 
			$(this).html('More');
	})

	/*************************event index part**********************************/

	/*************************event new part**********************************/
	/***********************initialize calendar*******************************/
	var date = new Date();
	var d = date.getDate();
	var m = date.getMonth();
	var y = date.getFullYear();

	var calendar = $('#calendar').fullCalendar({
		editable: true,
		selectable: true,
		selectHelper: true,
		defaultView: 'month',
		// height:466,

		header: {
			left: 'prev,next',
			center: 'title',
			right: 'month,agendaDay'
		},
		
		select: function(start, end, allDay) {
			if (allDay) {
				$(this).css('background-color', 'rgb(228,240,253)');
				calendar.fullCalendar('changeView', 'agendaDay').fullCalendar('gotoDate', start);
			}
			else {
				var formattedStart = $.fullCalendar.formatDate(start, 'HH:mm ddd, MMMM d, yyyy');
				var formattedEnd = $.fullCalendar.formatDate(end, 'HH:mm ddd, MMMM d, yyyy');
				var anyEarlier = false;

				$($('.choice-start').get().reverse()).each(function() {
					if (anyEarlier) return;

					if (new Date($(this).val()) < start) {
						anyEarlier = true;
						$(this).parent().parent().parent().parent().after(' \
							<li> \
							<div class="input-prepend span12"> \
							<button class="btn" type="button"><i class="icon-trash"></i></button> \
							<div class="input-prepend"> \
							<div> \
							<input type="text" disabled value="' + formattedStart + '"> \
							<input class="choice-start" type="hidden" value="' + start + '"> \
							</div> \
							<div style="display:none;"> \
							<input type="text" disabled value="' + formattedEnd + '"> \
							<input class="choice-end" type="hidden" value="' + end + '"> \
							</div> \
							</div> \
							</div> \
							</li>');
						/*
							<span class="add-on">start</span> \
							<span class="add-on">end&nbsp</span> \
							*/
					}
					else if (!(new Date($(this).val()) > start)) {
						anyEarlier = true;
						return;
					}
				});

				if (!anyEarlier) {
					$('#choices').prepend(' \
						<li> \
						<div class="input-prepend span12"> \
						<button class="btn" type="button"><i class="icon-trash"></i></button> \
						<div class="input-prepend"> \
						<div> \
						<input type="text" disabled value="' + formattedStart + '"> \
						<input class="choice-start" type="hidden" value="' + start + '"> \
						</div> \
						<div style="display:none;"> \
						<input type="text" disabled value="' + formattedEnd + '"> \
						<input class="choice-end" type="hidden" value="' + end + '"> \
						</div> \
						</div> \
						</div> \
						</li>');
					/*
						<span class="add-on">start</span> \
						<span class="add-on">end&nbsp</span> \
*/
				}
			}
		}

		/*dayClick: function(date, allDay, jsEvent, view) {

      if (allDay) {
        $(this).css('background-color', 'rgb(228,240,253)');
       	calendar.fullCalendar('changeView', 'agendaDay').fullCalendar('gotoDate', date);
      }else{
        $(this).css('background-color', 'rgb(228,240,253)');
      }
    },*/
  });

/*****************************delete choice***********************************/
$(document).on("click", "li .btn", function() {
	$(this).parent().parent().remove();
});

/**************************process before form submit**************************/
$('#new_form').submit(function() {
	var count = 1;
	$('.choice-start').each(function() {
		$(this).attr('name', 'choice-start-' + count);
		count++;
	});

	count = 1;
	$('.choice-end').each(function() {
		$(this).attr('name', 'choice-end-' + count);
		count++;
	});

	$('#choices').after('<input name="choices-count" type="hidden" value="' + (count-1) + '">');

	return true;
});

/********fix fullcalendar render problem with bootstrap tab********/

$('.nav-tabs > li > a').click(function (e) {
	e.preventDefault();
	$(this).tab('show');
	$('#calendar').fullCalendar('render');
	$('.fc-header-title h2').attr('style', 'font-size:24px');
})
/*************************event new part end**********************************/


/************************event show part**********************************/
/******************can't make it button process***************************/
$('input:checkbox').click(function() {
	if ($(this).is(':checked')) 
		$('#cantMakeIt').attr('disabled','disabled');
	else if (!$('input:checked').length)
		$('#cantMakeIt').removeAttr('disabled');
})
/********************show_form before submit check***********************/
$('#show_form').submit(function() {
	if (!$('#reply_name').val()){
		$('#choices_table').after(' \
			<div class="alert alert-error"> \
			<button type="button" class="close" data-dismiss="alert">&times;</button> \
			Please provide your name. \
			</div>');
		return false;
	}
})

$('#btnClose, #btnClose1').click(function() {
	var closeWindow = $('#closeEventWindow');
	var plotData = [];

	$('#page-cover').show().css('opacity',0.6);
	closeWindow.css('display', 'block');

	$.getJSON('/events/' + $('#eventID').val() + '.json', function(data) {
		i = 1;
		while (data['data']['choices'][i]) {
			count = data['data']['choices'][i]['count'];
			time = data['data']['choices'][i]['time'].replace('\\n', ' ');;
			plotData.push([count, time]);
			i++;
		}

		plotData.reverse();

	  // For horizontal bar charts, x an y values must will be "flipped"
	  // from their vertical bar counterpart.
	  var plot = $.jqplot('plot', [plotData], {
	  	animate: !$.jqplot.use_excanvas,
	  	seriesDefaults: {
	  		renderer:$.jqplot.BarRenderer,
        // Show point labels to the right ('e'ast) of each bar.
        // edgeTolerance of -15 allows labels flow outside the grid
        // up to 15 pixels.  If they flow out more than that, they 
        // will be hidden.
        pointLabels: { show: true, location: 'e', edgeTolerance: -15 },
        // Rotate the bar shadow as if bar is lit from top right.
        shadowAngle: 135,
        // Here's where we tell the chart it is oriented horizontally.
        rendererOptions: {
        	barDirection: 'horizontal',        	
        	varyBarColor: true,
        }
      },
      axes: {
      	xaxis:{
      		min: 0,
      		tickInterval: 1,
      	},
      	yaxis: {
      		renderer:$.jqplot.CategoryAxisRenderer,
      	}
      }
    });

	  for (i = 1; i <= plotData.length; i++) {
	  	tmp = plotData.length - i + 1;
	  	$('#closeCheckContainer').append('<input id="check-'+ i + '" type="checkbox" name="decision-' + i + '">');
	  	$('#check-' + i).css('position', 'absolute');
	  	var top = parseInt($('.jqplot-yaxis-tick:nth-child(' + tmp + ')').css('top')) + 60;
	  	$('#check-' + i).css('top', top + 'px');
	  }
	});

	/*	var height = closeWindow.height();
	var width = closeWindow.width();*/
	closeWindow.css('position', 'fixed');
	closeWindow.css('top', ($(window).height() - closeWindow.outerHeight())/2);
	closeWindow.css('left', ($(window).width() - closeWindow.outerWidth())/2);
})

$('#cancelCloseEvent').click(function() {
	$('#closeCheckContainer').empty();
	$('#plot').empty();
	$('#closeEventWindow').hide();
	$('#page-cover').hide();
	return false;
})

$('#submitCloseEvent').click(function() {
	var count = 0;
	$('#closeCheckContainer').children().each(function() {
		if ($(this).is(':checked'))
			count++;
	})
	$('#closeCheckContainer').append('<input type="hidden" name="decision-count" value="' + count + '">');

	$.ajax({
		url: '/events/' + $('#eventID').val(),
		dataType: 'html',
		type: 'PUT',
		data: $("#closeEventForm").serialize(),
		success: function(result) {
       location.reload();
    }
  });

	return false;
})

/**************************edit: process before form submit**************************/
$('#edit_form').submit(function() {
	var count = 1;
	$('.choice-start').each(function() {
		$(this).attr('name', 'choice-start-' + count);
		count++;
	});

	count = 1;
	$('.choice-end').each(function() {
		$(this).attr('name', 'choice-end-' + count);
		count++;
	});

	$('#choices').after('<input name="choices-count" type="hidden" value="' + (count-1) + '">');

	return true;
});

});