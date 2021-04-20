public with sharing class ASI_CRM_NumberUtil {

    public static Integer getIntegerValue(String value) {
        try {
            return Integer.valueOf(value);
        } catch (Exception e) {
            throw new ASI_CRM_CommonRoutine.ParseException(e.getMessage());
        }
    }

	public static String getCurrencyFormattedValue(Decimal value) {
		final List<String> config = new List<String> {'0', 'number', '###,###,##0.00'};
		return String.format(value.format(), config);
	}

	public static String getCurrencyFormattedValue(Decimal value, String currencySymbol) {
		return currencySymbol + getCurrencyFormattedValue(value);
	}

}