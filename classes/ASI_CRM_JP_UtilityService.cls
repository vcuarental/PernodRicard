public class ASI_CRM_JP_UtilityService {

  public class CustomException extends Exception {}

  public static final String COMPANY_NAME = 'Pernod Ricard Japan';

  public static Set<String> getObjectPropertySet(List<SObject> objects, SObjectField objectField) {
    List<String> objectPropertyList = getObjectPropertyList(objects, objectField);

    return new Set<String> (objectPropertyList);
  }

  public static List<String> getObjectPropertyList(List<SObject> objects, SObjectField objectField) {
    final List<String> propertyList = new List<String>();

    for (SObject obj : objects) {
      Object value = obj.get(objectField.getDescribe().getName());
      if (value == null) continue;

      propertyList.add(String.valueOf(value));
    }
    return propertyList;
  }

  public static Set<Id> getObjectIdPropertySet(List<SObject> objects, SObjectField objectField) {
    List<Id> objectPropertyList = getObjectIdPropertyList(objects, objectField);

    return new Set<Id> (objectPropertyList);
  }

  public static List<Id> getObjectIdPropertyList(List<SObject> objects, SObjectField objectField) {
    final List<Id> propertyList = new List<Id>();

    for (SObject obj : objects) {
            system.debug(obj);
      Object value = obj.get(objectField.getDescribe().getName());
      if (value == null) continue;

      propertyList.add(String.valueOf(value));
    }
    return propertyList;
  }

  public static String generateQuerySelectFields(Schema.SObjectType objectType) {
    final Map<String, Schema.SObjectField> fieldNameObjectTypeMap = objectType.getDescribe().fields.getMap();
    final List<String> queryFields = new List<String>();

    for (String fieldName : fieldNameObjectTypeMap.keySet()) {
      queryFields.add(fieldName);
    }

    return String.join(queryFields, ', ');
  }

  public static Map<Id, ASI_CRM_JP_Item_Availability__c> getItemAvailabilityMap(
      List<ASI_CRM_JP_Item_Availability__c> itemAvailabilityList
      ) {
    final Map<Id, ASI_CRM_JP_Item_Availability__c> itemAvailabilityMap =
        new Map<Id, ASI_CRM_JP_Item_Availability__c>();

    for (ASI_CRM_JP_Item_Availability__c itemAvailability : itemAvailabilityList) {
      //itemAvailabilityMap.put(itemAvailability.ASI_SKU__c, itemAvailability);
      itemAvailabilityMap.put(itemAvailability.Id, itemAvailability);
    }

    return itemAvailabilityMap;
  }

  public static List<ASI_CRM_JP_Item_Availability__c> getItemAvailabilityListByIds(Set<Id> ids) {
    return [
        SELECT Id, Name, RecordTypeId, ASI_Quantity_Availability__c, ASI_SKU__c, ASI_SFDC_SO_Commit__c
        FROM ASI_CRM_JP_Item_Availability__c
        WHERE Id IN :ids
    ];
  }

  public static Map<String, User> getStaffCodeUserMap(Set<String> staffCodes) {

    final Map<String, User> staffCodeUserMap = new Map<String, User>();
    for (User u : getUsersByStaffCodes(staffCodes)) {
      staffCodeUserMap.put(u.ASI_TnE_Sub_Ledger__c, u);
    }

    return staffCodeUserMap;
  }

  public static List<User> getUsersByStaffCodes(Set<String> staffCodes) {
    return [
        SELECT Id, ASI_TnE_Sub_Ledger__c
        FROM User
        WHERE CompanyName = :COMPANY_NAME
        AND ASI_TnE_Sub_Ledger__c IN :staffCodes
    ];
  }

  public static List<ASI_CRM_Purchase_Contract__c> findPurchaseContractByIds(Set<Id> purchaseContactIds) {
    return [
        SELECT Id, ASI_CRM_Staff_Code__c, ASI_CRM_Status__c
        FROM ASI_CRM_Purchase_Contract__c
        WHERE Id IN :purchaseContactIds
    ];
  }

  public static void clearApprovers(ASI_CRM_Purchase_Contract__c purchaseContract) {
    purchaseContract.ASI_CRM_Sys_Current_Approver__c = null;
    purchaseContract.ASI_CRM_Approver_1__c = null;
    purchaseContract.ASI_CRM_Approver_2__c = null;
    purchaseContract.ASI_CRM_Approver_3__c = null;
    purchaseContract.ASI_CRM_Approver_4__c = null;
    purchaseContract.ASI_CRM_Approver_5__c = null;
    purchaseContract.ASI_CRM_Approver_6__c = null;
    purchaseContract.ASI_CRM_Approver_7__c = null;
    purchaseContract.ASI_CRM_Approver_8__c = null;
    purchaseContract.ASI_CRM_Approver_9__c = null;
    purchaseContract.ASI_CRM_Approver_10__c = null;
  }

  public static Integer getCurrentFiscalYear() {
    final Date today = Date.today();

    if (today.month() <= 6) {
      return today.addYears(-1).year();
    }

    if (today.month() > 6) {
      return today.year();
    }

    return null;
  }

  public static Date getDateBasedOnFiscalYear(Date startDate, Date endDate, Boolean returnEndDate) {

    if (startDate == null || (returnEndDate && endDate == null)) return null;
    if (endDate == null) endDate = startDate;

    final Integer fiscalYear = getCurrentFiscalYear();
    final Integer durationInYears = endDate.year() - startDate.year();
    final Date referenceDate = returnEndDate ? endDate : startDate;
    final Integer month = referenceDate.month();

    Integer day = referenceDate.day();

    if (returnEndDate) {
      final Integer year = fiscalYear + durationInYears;

      if (isLeapYearDate(referenceDate) && !isLeapYear(year)) day--;

      return Date.newInstance(year, month, day);
    }

    if (isLeapYearDate(referenceDate) && !isLeapYear(fiscalYear)) day--;

    return Date.newInstance(fiscalYear, month, day);
  }
  @testVisible
  private static Boolean isLeapYear(Date inputDate) {
    return isLeapYear(inputDate.year());
  }
@testVisible
  private static Boolean isLeapYear(Integer year) {
    return Math.mod(year, 4) == 0 ? true : false;
  }
@testVisible
  private static Boolean isLeapYearDate(Date inputDate) {
    return (isLeapYear(inputDate) && inputDate.month() == 2 && inputDate.day() == 29);
  }

}