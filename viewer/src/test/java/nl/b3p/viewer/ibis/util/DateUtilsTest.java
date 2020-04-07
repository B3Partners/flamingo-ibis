/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.b3p.viewer.ibis.util;

import static org.junit.Assert.assertEquals;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import static nl.b3p.viewer.ibis.util.DateUtils.*;

import org.junit.BeforeClass;
import org.junit.Test;

/**
 * testcases for {@link DateUtils}.
 *
 * @author mprins
 */
public class DateUtilsTest {

    private static final SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");

    private static Date[] dates5;
    private static Date[] dates2;
    private static Date[] dates1;
    private static Date[] dates2same;

    @BeforeClass
    public static void setupDateList() throws ParseException {
        dates5 = new Date[]{
                sdf.parse("2013/03/04"),
                sdf.parse("2014/03/01"),
                sdf.parse("2014/03/02"),
                sdf.parse("2014/04/01"),
                sdf.parse("2015/03/01"),
        };
        dates1 = new Date[]{dates5[1]};
        dates2 = new Date[]{dates5[1],dates5[2]};
        dates2same = new Date[]{dates5[1],dates5[1]};
    }

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
        assertEquals("added one month to current date", 1, differenceInMonths(now, addMonth(now)));
        assertEquals("added two months to current date", 2, differenceInMonths(now, addMonth(addMonth(now))));
    }

    @Test
    public void testGetBeforeDate5() {
        assertEquals("first date", dates5[0], getBeforeDate(Arrays.asList(dates5), dates5[0]));
        assertEquals("2nd date", dates5[0], getBeforeDate(Arrays.asList(dates5), dates5[1]));
        assertEquals("3rd date", dates5[1], getBeforeDate(Arrays.asList(dates5), dates5[2]));
        assertEquals("4th date", dates5[2], getBeforeDate(Arrays.asList(dates5), dates5[3]));
        assertEquals("last date", dates5[3], getBeforeDate(Arrays.asList(dates5), dates5[4]));
    }

    @Test
    public void testGetAfterDate5() {
        assertEquals("first date", dates5[1], getAfterDate(Arrays.asList(dates5), dates5[0]));
        assertEquals("2nd date", dates5[2], getAfterDate(Arrays.asList(dates5), dates5[1]));
        assertEquals("3rd date", dates5[3], getAfterDate(Arrays.asList(dates5), dates5[2]));
        assertEquals("4th date", dates5[4], getAfterDate(Arrays.asList(dates5), dates5[3]));
        assertEquals("last date", dates5[4], getAfterDate(Arrays.asList(dates5), dates5[4]));
    }

    @Test
    public void testGetBeforeDate2() {
        assertEquals("first date", dates2[0], getBeforeDate(Arrays.asList(dates2), dates2[0]));
        assertEquals("last date", dates2[0], getBeforeDate(Arrays.asList(dates2), dates2[1]));
    }

    @Test
    public void testGetAfterDate2() {
        assertEquals("first date", dates2[1], getAfterDate(Arrays.asList(dates2), dates2[0]));
        assertEquals("last date", dates2[1], getAfterDate(Arrays.asList(dates2), dates2[0]));
    }

    @Test
    public void testGetBeforeDate1() {
        assertEquals("first date", dates1[0], getBeforeDate(Arrays.asList(dates1), dates1[0]));
        assertEquals("last date", dates1[0], getBeforeDate(Arrays.asList(dates1), dates1[0]));
    }

    @Test
    public void testGetAfterDate1() {
        assertEquals("first date", dates1[0], getAfterDate(Arrays.asList(dates1), dates1[0]));
        assertEquals("last date", dates1[0], getAfterDate(Arrays.asList(dates1), dates1[0]));
    }

    @Test
    public void testGetBeforeDate2same() {
        assertEquals("first date", dates2same[0], getBeforeDate(Arrays.asList(dates2same), dates2same[0]));
        assertEquals("last date", dates2same[0], getBeforeDate(Arrays.asList(dates2same), dates2same[1]));
    }

    @Test
    public void testGetAfterDate2same() {
        assertEquals("first date", dates2same[0], getAfterDate(Arrays.asList(dates2same), dates2same[0]));
        assertEquals("last date", dates2same[0], getAfterDate(Arrays.asList(dates2same), dates2same[0]));
    }
}
