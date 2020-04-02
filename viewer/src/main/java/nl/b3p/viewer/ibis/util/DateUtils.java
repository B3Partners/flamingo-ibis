/*
 * Copyright (C) 2015 B3Partners B.V.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.b3p.viewer.ibis.util;

import java.util.*;

/**
 * Utility class with various date manipulation methods.
 *
 * @author mprins
 */
public class DateUtils {
    /**
     * calculate difference in months between the arguments.
     *
     * @param beginningDate begin datum
     * @param endingDate eind datum
     * @return number of months
     *
     * @see #differenceInMonths(java.util.Calendar, java.util.Calendar)
     */
    public static int differenceInMonths(Date beginningDate, Date endingDate) {
        if (beginningDate == null || endingDate == null) {
            return 0;
        }
        Calendar cal1 = new GregorianCalendar();
        cal1.setTime(beginningDate);
        Calendar cal2 = new GregorianCalendar();
        cal2.setTime(endingDate);
        return differenceInMonths(cal1, cal2);
    }

    /**
     * calculate difference in months between the arguments.
     *
     * @param beginningDate begin datum
     * @param endingDate eind datum
     * @return number of months
     */
    public static int differenceInMonths(Calendar beginningDate, Calendar endingDate) {
        if (beginningDate == null || endingDate == null) {
            return 0;
        }
        int m1 = beginningDate.get(Calendar.YEAR) * 12 + beginningDate.get(Calendar.MONTH);
        int m2 = endingDate.get(Calendar.YEAR) * 12 + endingDate.get(Calendar.MONTH);
        return m2 - m1;
    }

    /**
     * add a month to the date.
     *
     * @param addTo begin datum
     * @return een maand later dan begin datum
     */
    public static Date addMonth(Date addTo) {
        Calendar cal = new GregorianCalendar();
        cal.setTime(addTo);
        cal.add(Calendar.MONTH, 1);
        return cal.getTime();
    }

    /**
     * get next date after reference date.
     *
     * @param dateList list of dates
     * @param refDate  reference date, must be part of {@code dateList}
     * @return next date after {@code refDate} from {@code dateList} or reference date if there are no later dates
     */
    public static Date getAfterDate(List<Date> dateList, Date refDate) {
        // System.out.println("datum after " + refDate + " from: " + dateList);
        final List<Date> afterDates = dateList.subList(dateList.indexOf(refDate), dateList.size());
        // System.out.println(afterDates);
        if (afterDates.size() > 0) {
            for (Date date : afterDates) {
                if (date.after(refDate)) {
                    return date;
                }
            }
        }
        return refDate;
    }

    /**
     * get previous date before reference date.
     *
     * @param dateList list of dates
     * @param refDate  reference date, must be part of {@code dateList}
     * @return previous date before {@code refDate} from {@code dateList} or reference date if there are no earlier dates
     */
    public static Date getBeforeDate(List<Date> dateList, Date refDate) {
        // System.out.println("datum before " + refDate + " from: " + dateList);
        final List<Date> beforeDates = dateList.subList(0, dateList.indexOf(refDate));
        Collections.reverse(beforeDates);
        // System.out.println(beforeDates);
        if (beforeDates.size() > 0) {
            for (Date date : beforeDates) {
                if (date.before(refDate)) {
                    return date;
                }
            }
        }
        return refDate;
    }

    /**
     * private constructor.
     */
    private DateUtils() {
    }
}
