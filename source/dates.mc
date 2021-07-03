using Toybox.Time.Gregorian;
using Toybox.Time;


var month_to_number = {"Jan" => 1, "Feb" => 2, "Mar" => 3, "Apr" => 4, "May" => 5, "Jun" => 6, "Jul" => 7, "Aug" => 8, "Sep" => 9, "Oct" => 10, "Nov" => 11, "Dec" => 12};
var number_to_month = {1 => "Jan", 2 => "Feb", 3 => "Mar", 4 => "Apr", 5 => "May", 6 => "Jun", 7 => "Jul", 8 => "Aug", 9 => "Sep", 10 => "Oct", 11 => "Nov", 12 => "Dec"};


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
			var m_str = number_to_month[m];
			days_since_31122019 += daysInMonth(m_str, year);
		}
	}
	
	// days...
	if (day > daysInMonth(number_to_month[month], year)) {
		throw new InvalidValueException("day value submitted to dayNumber() larger than number of days in month");
	}
	if (month < 1) {
		throw new InvalidValueException("day value less than 1 submitted to dayNumber()");
	}
	
	days_since_31122019 += day;
	
	return days_since_31122019;
	
}


// Get current time information
function getTime() {
	var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	// var days_in_month = daysInMonth(now.month, now.year);
	// var time_info = [now.day, now.month, month_to_number[now.month], now.year];

	// The time is, for dev, fixed as if the day is 7th Jan 2021. 
	var time_info = {"day" => 7, "month_name" => "Jan", "month_num" =>  1, "year" => 2021, "days_in_month" => 31, "day_num" => 371};

	return time_info;

}