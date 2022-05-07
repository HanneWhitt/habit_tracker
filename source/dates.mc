using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.Lang;


var __MONTH_NAMES__ = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
var __DAYS_OF_WEEK__ = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];


function daysInMonth(month, year) {
		if (month.equals("Feb")) {
			// Check if it's a leap year
			if (year % 4 == 0) {
				return 29;
			} else {
				return 28;
			}
		} else {
			if (contains(["Apr", "Jun", "Sep", "Nov"], month)) {
				return 30;
			} else if (contains(["Jan", "Mar", "May", "Jul", "Aug", "Oct", "Dec"], month)) {
				return 31;
			} else {
				throw new InvalidValueException("daysInMonth() got month arg with unexpected value '" + month + "'");
			}
		}
	}

function daysInYear(year) {
	if (year % 4 == 0) {
		return 366;
	} else {
		return 365;
	}
}

// function to calculate the number of days since Dec 31st 2019. Used as a simpler language for dates internally
function dayNumber(day, month, year) {
	
	var days_since_31122019 = 0;
	
	// years...
	if (year > 2020) {
		for (var y = 2020; y < year; y += 1) {
			days_since_31122019 += daysInYear(y);
		} 
	} else if (year < 2020) {
		throw new InvalidValueException("dayNumber() only handles dates beyond 1st Jan 2020.");
	}
	
	// months... 
	if (month > 12) {
		throw new InvalidValueException("Month number greater than 12 submitted to dayNumber()");
	}
	if (month < 1) {
		throw new InvalidValueException("Month number less than 1 submitted to dayNumber()");
	}
	
	if (month > 1) {
		for (var m = 1; m < month; m += 1) {
			var m_str = __MONTH_NAMES__[m-1];
			days_since_31122019 += daysInMonth(m_str, year);
		}
	}
	
	// days...
	if (day > daysInMonth(__MONTH_NAMES__[month-1], year)) {
		throw new InvalidValueException("day value submitted to dayNumber() larger than number of days in month");
	}
	if (month < 1) {
		throw new InvalidValueException("day value less than 1 submitted to dayNumber()");
	}
	
	days_since_31122019 += day;
	
	return days_since_31122019;
	
}


function yearFromDaynum(daynum) {
	
	if (daynum <= 0) {
		throw new InvalidValueException("daynum must be >0");
	}

	for (var y = 2020; y < 2520; y += 1) {
		if (daynum <= dayNumber(31, 12, y)) {
			return y;
		}
	}
	
	throw new InvalidValueException("Are you really using my crappy app in 2521??");

}


function DayInYear(daynum) {
	var y = yearFromDaynum(daynum);
	if (y == 2020) {
		return daynum;
	} else {
		return daynum - dayNumber(31, 12, y - 1);
	}
}

var time;
var duration;

// Get current time information
function getTime(time_difference) {

	time = Time.now();

	if (time_difference != null) {
		if (time_difference instanceof Lang.Dictionary) {
			duration = Gregorian.duration(time_difference);
		} else {
			duration = Gregorian.duration({:days => time_difference});
		}
		time = time.add(duration);
	}

	var now = Gregorian.info(time, Time.FORMAT_MEDIUM);
	var days_in_month = daysInMonth(now.month, now.year);
	var monthnum_today = __MONTH_NAMES__.indexOf(now.month);
	var daynum_today = dayNumber(now.day, monthnum_today, now.year);
	var time_info = {"day" => now.day, 
		"day_of_week" => now.day_of_week,
		"month_name" => now.month,
		"month_num" =>  monthnum_today,
		"year" => now.year,
		"days_in_month" => days_in_month,
		"day_num" => daynum_today
	};

	return time_info;
}

	
function month_day_string(day) {
	var last_char = day.toString().toCharArray().reverse()[0];
	var day_string = day.toString();
	if (last_char == "1") {
		day_string = "1st";
	} else if (last_char == "2") {
		day_string = "2nd";
	} else if (last_char == "3") {
		day_string = "3rd";
	} else {
		day_string = day_string + "th";
	}
	return day_string;
}

function abbreviate_weekday(day_of_week) {
	var char_array = day_of_week.toCharArray();
	print(char_array);
	var abbreviation = char_array[0].toString();
	print(abbreviation);
	
	if (abbreviation.equals("T")) {
		abbreviation = "T" + char_array[1].toString();
	} else if (abbreviation.equals("S")) {
		abbreviation = "S" + char_array[1].toString();
	}
	return abbreviation;
}


function day_of_week_by_index(day_today, index_difference) {
	var today_index = __DAYS_OF_WEEK__.indexOf(day_today);
	var return_day_index = (today_index + index_difference) % 7;
	return __DAYS_OF_WEEK__[return_day_index];
}
	


