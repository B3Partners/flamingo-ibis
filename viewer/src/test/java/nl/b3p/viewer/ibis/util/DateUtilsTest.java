/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.viewer.ibis.util;

import static org.junit.Assert.assertEquals;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import static nl.b3p.viewer.ibis.util.DateUtils.differenceInMonths;
import static nl.b3p.viewer.ibis.util.DateUtils.addMonth;
import org.junit.Test;

/**
 * testcases for {@link DateUtils}.
 *
 * @author Mark Prins <mark@b3partners.nl>
 */
public class DateUtilsTest {

    private final SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");

    @Test
    public void testDateDifferenceInMonths() throws ParseException {
        assertEquals(12, differenceInMonths(sdf.parse("2014/03/22"), sdf.parse("2015/03/22")));
        assertEquals(11, differenceInMonths(sdf.parse("2014/01/01"), sdf.parse("2014/12/25")));
        assertEquals(88, differenceInMonths(sdf.parse("2014/03/22"), sdf.parse("2021/07/05")));
        assertEquals(6, differenceInMonths(sdf.parse("2014/01/22"), sdf.parse("2014/07/22")));
        assertEquals(1, differenceInMonths(sdf.parse("2014/01/22"), sdf.parse("2014/02/22")));
    }

    @Test
    public void testCalendarDifferenceInMonths() throws ParseException {
        Calendar c1 = new GregorianCalendar();
        c1.set(2014, 3, 22);
        Calendar c2 = new GregorianCalendar();
        c2.set(2015, 3, 23);
        assertEquals(12, differenceInMonths(c1, c2));
    }

    @Test
    public void testAddMonth() {
        Date now = new Date();
        assertEquals(1, differenceInMonths(now, addMonth(now)));
    }
}
