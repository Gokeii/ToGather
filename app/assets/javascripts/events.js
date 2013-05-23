$(document).ready(function() {
/***********************initialize calendar********************************/
	var date = new Date();
	var d = date.getDate();
	var m = date.getMonth();
	var y = date.getFullYear();

	var calendar = $('#calendar').fullCalendar({
		editable: true,
		selectable: true,
		selectHelper: true,
		defaultView: 'month',
		height:466,

		header: {
			left: 'prev,next today',
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
			  							<span class="add-on">start</span> \
			  							<input type="text" disabled value="' + formattedStart + '"> \
			  							<input class="choice-start" type="hidden" value="' + start + '"> \
										</div> \
										<div> \
			  							<span class="add-on">end&nbsp</span> \
			  							<input type="text" disabled value="' + formattedEnd + '"> \
			  							<input class="choice-end" type="hidden" value="' + end + '"> \
										</div> \
									</div> \
								</div> \
							</li>');
					}
				});

				if (!anyEarlier) {
					$('#choices').prepend(' \
						<li> \
							<div class="input-prepend span12"> \
	  						<button class="btn" type="button"><i class="icon-trash"></i></button> \
	  						<div class="input-prepend"> \
		  						<div> \
		  							<span class="add-on">start</span> \
		  							<input type="text" disabled value="' + formattedStart + '"> \
		  							<input class="choice-start" type="hidden" value="' + start + '"> \
									</div> \
									<div> \
		  							<span class="add-on">end&nbsp</span> \
		  							<input type="text" disabled value="' + formattedEnd + '"> \
		  							<input class="choice-end" type="hidden" value="' + end + '"> \
									</div> \
								</div> \
							</div> \
						</li>');					
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
	$('form').submit(function() {
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
})

/*************************************************************************/
});