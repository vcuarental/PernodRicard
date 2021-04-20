public without sharing class ASI_CRM_DateUtil {

    public static final String DATE_FORMAT_YYYYMMDD = 'yyyyMMdd';

    public static Date parseDate(String dateValue, String dateFormat) {

        if (DATE_FORMAT_YYYYMMDD.equals(dateFormat)) {
            try {
                final Integer year = Integer.valueOf(dateValue.substring(0, 4));
                final Integer month = Integer.valueOf(dateValue.substring(4, 6));
                final Integer day = Integer.valueOf(dateValue.substring(6, 8));

                return Date.newInstance(year, month, day);
            } catch (Exception e) {
                throw new DateParseException(e.getMessage());
            }
        }
        return null;
    }

    public class DateParseException extends Exception {
    }

}