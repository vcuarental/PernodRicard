@IsTest (IsParallel=true)
private class EUR_CRM_FilterBuilderControllerTest {

    public static final String PRODUCT_CATALOG_OBJECT_NAME = 'EUR_CRM_ProductCatalog__c';

    
    @TestSetup
    private static void init() {
        insert new EUR_CRM_ProductCatalog__c(Name = 'Name_1');
        insert new EUR_CRM_ProductCatalog__c(Name = 'Name_2');
    }

    @IsTest
    private static void getObjectFieldsSelectOptions() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_FilterBuilderController.getSObjectFieldsSelectOptions(PRODUCT_CATALOG_OBJECT_NAME);
        }
    }

    @IsTest
    private static void getSObjectAvailableTypes() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            EUR_CRM_FilterBuilderService.getSObjectAvailableTypes(PRODUCT_CATALOG_OBJECT_NAME);
        }
    }

    @IsTest
    private static void testDescribeSObjectFields() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<String> accountFieldApiNames = new List<String> { 'CreatedDate', 'Name', 'IsDeleted' };
            String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, accountFieldApiNames);
            List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);

            System.assertEquals(fieldDescribeWrappers[0].name.toUpperCase(), accountFieldApiNames[0].toUpperCase());
            System.assertEquals(fieldDescribeWrappers[0].fieldType, 'DATETIME');
            System.assertEquals(fieldDescribeWrappers[0].picklistOptions, null);
            System.assertEquals(fieldDescribeWrappers[0].operatorOptions.size(), EUR_CRM_FilterBuilderController.typesOperatorsMap.get(fieldDescribeWrappers[0].fieldType).size());

            System.assertEquals(fieldDescribeWrappers[1].name.toUpperCase(), accountFieldApiNames[1].toUpperCase());
            System.assertEquals(fieldDescribeWrappers[1].fieldType, 'STRING');
            System.assertEquals(fieldDescribeWrappers[1].picklistOptions, null);
            System.assertEquals(fieldDescribeWrappers[1].operatorOptions.size(), EUR_CRM_FilterBuilderController.typesOperatorsMap.get(fieldDescribeWrappers[1].fieldType).size());

            System.assertEquals(fieldDescribeWrappers[2].name.toUpperCase(), accountFieldApiNames[2].toUpperCase());
            System.assertEquals(fieldDescribeWrappers[2].fieldType, 'BOOLEAN');
            System.assertEquals(fieldDescribeWrappers[2].picklistOptions, null);
            System.assertEquals(fieldDescribeWrappers[2].operatorOptions.size(), EUR_CRM_FilterBuilderController.typesOperatorsMap.get(fieldDescribeWrappers[2].fieldType).size());
        }
    }

    @IsTest
    private static void testSuccessValidateFilters() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_ProductCatalog__c> catalogs = [SELECT Id FROM EUR_CRM_ProductCatalog__c LIMIT 1];
            Set<String> filterItemsFieldTypes = new Set<String>();
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EUR_CRM_FilterBuilderControllerMock());
            Test.stopTest();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (filterItemsFieldTypes.contains(fieldType)) continue;
                EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem;
                if (fieldType == 'STRING') {
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'contains';
                    filterItem.value = 'Test';
                    filterItems.add(filterItem);
                } else if (fieldType == 'PICKLIST') {
                    List<String> accountFieldApiNames = new List<String> {
                        dfield.getName()
                    };
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, accountFieldApiNames);
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = fieldDescribeWrappers[0].picklistOptions[0];
                    filterItems.add(filterItem);
                } else if (fieldType == 'DATE') {
                    DateTime currentDate = DateTime.now();
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'less or equal';
                    filterItem.value = String.valueOf(Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day() + 1).format());
                    filterItems.add(filterItem);
                } else if (fieldType == 'DATETIME') {
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'less or equal';
                    filterItem.value = String.valueOf(Datetime.now().addDays(1).format());
                    filterItems.add(filterItem);
                }
//            else if(fieldType == 'TEXTAREA') {
//                filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
//                filterItem.field = dfield.getName();
//                filterItem.operator = 'contains';
//                filterItem.value = 'Test';
//                filterItems.add(filterItem);
//            }
                else if (fieldType == 'ID') {
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = catalogs[0].Id;
                    filterItems.add(filterItem);
                } else if (fieldType == 'URL') {
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = 'Test';
                    filterItems.add(filterItem);
                } else if (fieldType == 'REFERENCE') {
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = catalogs[0].Id;
                    filterItems.add(filterItem);
                } else if (fieldType == 'DOUBLE') {
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'not equal to';
                    filterItem.value = '0';
                    filterItems.add(filterItem);
                } else if (fieldType == 'BOOLEAN') {
                    filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'not equal to';
                    filterItem.value = 'false';
                    filterItems.add(filterItem);
                }
                filterItemsFieldTypes.add(fieldType);
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            System.debug('result ' + result);

            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
            System.assertEquals(resultMap.get('message'), 'OK');
        }
    }

    @IsTest
    private static void testWrongDoubleValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DOUBLE') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = 'Incorrect value';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), false);
            System.assert(String.valueOf(resultMap.get('message')).contains(Label.EUR_CRM_TM_Invalidnumber));
        }
    }

    @IsTest
    private static void testWrongDateValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATE') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = 'Incorrect value';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), false);
            System.assert(String.valueOf(resultMap.get('message')).contains(Label.EUR_CRM_TM_InvalidDateError.replace('{value}', Date.today().format())));
        }
    }

    @IsTest
    private static void testWrongDateTimeValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATETIME') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = 'Incorrect value';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), false);
            System.assert(String.valueOf(resultMap.get('message')).contains(Label.EUR_CRM_TM_InvalidDateError.replace('{value}', DateTime.now().format())));
        }
    }

    @IsTest
    private static void testWrongPickListValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PICKLIST') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = 'SOME PICKLIST VALUES DOES NOT EXIST';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), false);
            System.assert(String.valueOf(resultMap.get('message')).contains(Label.EUR_CRM_TM_PicklistError.replace('{value}', filterItems[0].value)));
        }
    }

    @IsTest
    private static void testWrongBooleanValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'BOOLEAN') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = '1';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), false);
            System.assert(String.valueOf(resultMap.get('message')).contains(Label.EUR_CRM_TM_BoolConditionError));
        }
    }

    @IsTest
    private static void testWrongIdValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'ID') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = 'wrongId';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), false);
            System.assert(String.valueOf(resultMap.get('message')).contains(filterItems[0].value));
        }
    }

    @IsTest
    private static void testWrongReferenceValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'REFERENCE') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = 'wrongRefId';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), false);
            System.assert(String.valueOf(resultMap.get('message')).contains(filterItems[0].value));
        }
    }

    @IsTest
    private static void testWrongOperatorEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'STRING') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'less or equal';
                    filterItem.value = '';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), false);
            System.assert(String.valueOf(resultMap.get('message')).contains(Label.EUR_CRM_TM_OperatorValueError));
        }
    }

    @IsTest
    private static void testDateLiteralValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATE') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'less than';
                    filterItem.value = 'TODAY';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDateTimeLiteralValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();

            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATETIME') {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = 'equals';
                    filterItem.value = 'LAST_N_DAYS:5';
                    filterItems.add(filterItem);
                    break;
                }
            }
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testStringTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'STRING') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = 'Test';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testStringTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'STRING') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = 'Test, Test2';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testStringTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            Integer i = 0;
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'STRING') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = 'Test, ,Test2,';
                            filterItems.add(filterItem);
                        }
                    }
                    if (i ++ > 20) break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    /*@IsTest
    private static void testTextAreaTypeOperators() {
    List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {}

        List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
        for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
            Schema.DescribeFieldResult dfield = sfield.getDescribe();
            String fieldType = String.valueOf(dfield.getType());
            if (fieldType == 'TEXTAREA') {
                // get field info and available operators
                String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String>{
                        dfield.getName()
                });
                List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                // add item for each operator
                for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                    EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                    filterItem.field = dfield.getName();
                    filterItem.operator = operator;
                    filterItem.value = 'Test';
                    filterItems.add(filterItem);
                }
                break;
            }
        }
        // try to validate items
        String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(resultMap.get('success'), false);
    }*/

    @IsTest
    private static void testTextAreaTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'TEXTAREA' && dfield.getLength() <= 255) {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = 'Test, Test2';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testTextAreaTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'TEXTAREA' && dfield.getLength() <= 255) {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = 'Test, ,Test2,';
                            filterItems.add(filterItem);
                        }
                    }
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDoubleTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DOUBLE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = '0';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDoubleTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DOUBLE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = '0, 10';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDoubleTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DOUBLE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = '0, ,10,';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDateTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            DateTime currentDate = DateTime.now();
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = String.valueOf(Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day() + 1).format());
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDateTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            DateTime currentDate = DateTime.now();
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = String.valueOf(Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()).format()) + ', ' +
                            String.valueOf(Date.newInstance(currentDate.year() + 1, currentDate.month(), currentDate.day()).format());
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDateTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            DateTime currentDate = DateTime.now();
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = String.valueOf(Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()).format()) + ', ,' +
                                String.valueOf(Date.newInstance(currentDate.year() + 1, currentDate.month(), currentDate.day()).format()) + ',';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDateTimeTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATETIME') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = String.valueOf(Datetime.now().addDays(1).format());
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDateTimeTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATETIME') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = String.valueOf(Datetime.now().addDays(1).format()) + ', ' +
                            String.valueOf(Datetime.now().addYears(1).format());
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testDateTimeTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'DATETIME') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = String.valueOf(Datetime.now().addDays(1).format()) + ', ,' +
                                String.valueOf(Datetime.now().addYears(1).format()) + ',';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPickListTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EUR_CRM_FilterBuilderControllerMock());
            Test.stopTest();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PICKLIST') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    System.assertNotEquals(fieldDescribeWrappers[0].picklistOptions, null);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = fieldDescribeWrappers[0].picklistOptions[0];
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPickListTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EUR_CRM_FilterBuilderControllerMock());
            Test.stopTest();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PICKLIST') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    System.assertNotEquals(fieldDescribeWrappers[0].picklistOptions, null);
                    // add item for each operator
                    if (fieldDescribeWrappers[0].picklistOptions.size() < 2) continue;
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = fieldDescribeWrappers[0].picklistOptions[0] + ', ' +
                            fieldDescribeWrappers[0].picklistOptions[1];
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPickListTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EUR_CRM_FilterBuilderControllerMock());
            Test.stopTest();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PICKLIST') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    System.assertNotEquals(fieldDescribeWrappers[0].picklistOptions, null);
                    // add item for each operator
                    if (fieldDescribeWrappers[0].picklistOptions.size() < 2) continue;
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = fieldDescribeWrappers[0].picklistOptions[0] + ', ,' +
                                fieldDescribeWrappers[0].picklistOptions[1] + ',';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testIdTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_ProductCatalog__c> catalogs = [SELECT Id FROM EUR_CRM_ProductCatalog__c];
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'ID') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = catalogs[0].Id;
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testIdTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_ProductCatalog__c> catalogs = [SELECT Id FROM EUR_CRM_ProductCatalog__c];
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'ID') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = catalogs[0].Id + ', ' + catalogs[1].Id;
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testIdTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_ProductCatalog__c> catalogs = [SELECT Id FROM EUR_CRM_ProductCatalog__c];
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'ID') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = catalogs[0].Id + ', ,' + catalogs[1].Id + ',';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testReferenceTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_ProductCatalog__c> catalogs = [SELECT Id FROM EUR_CRM_ProductCatalog__c];
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'REFERENCE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = catalogs[0].Id;
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testReferenceTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_ProductCatalog__c> catalogs = [SELECT Id FROM EUR_CRM_ProductCatalog__c];
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'REFERENCE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = catalogs[0].Id + ', ' + catalogs[1].Id;
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testReferenceTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_ProductCatalog__c> catalogs = [SELECT Id FROM EUR_CRM_ProductCatalog__c];
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'REFERENCE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = catalogs[0].Id + ', ,' + catalogs[1].Id + ',';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testURLTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'URL') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = URL.getSalesforceBaseUrl().toExternalForm();
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testURLTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'URL') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = URL.getSalesforceBaseUrl().toExternalForm() + ', https://www.google.com';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testURLTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'URL') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = URL.getSalesforceBaseUrl().toExternalForm() + ', ,https://www.google.com,';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPhoneTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PHONE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = '754-3010';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPhoneTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            Set<String> filterItemsFieldTypes = new Set<String>();
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PHONE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = '754-3010, 754-3020';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPhoneTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PHONE') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = '754-3010, ,754-3020,';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testEmailTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'EMAIL') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = 'testmail@gmail.com';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testEmailTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'EMAIL') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = 'testmail@gmail.com, anothermail@gmail.com';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testEmailTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'EMAIL') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = 'testmail@gmail.com, ,anothermail@gmail.com,';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testBooleanTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'BOOLEAN') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = 'true';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testBooleanTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'BOOLEAN') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = 'true, false';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testBooleanTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'BOOLEAN') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = 'true, ,false,';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testCurrencyTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'CURRENCY') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = '0';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testCurrencyTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'CURRENCY') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = '0, 10';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testCurrencyTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'CURRENCY') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = '0, ,10,';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPercentTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PERCENT') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = '0';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPercentTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PERCENT') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = '0, 10';
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testPercentTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'PERCENT') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    // add item for each operator
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = '0, ,10,';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testMultiPickListTypeOperators() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EUR_CRM_FilterBuilderControllerMock());
            Test.stopTest();
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'MULTIPICKLIST') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    System.assertNotEquals(fieldDescribeWrappers[0].picklistOptions, null);
                    // add item for each operator
                    System.debug('fieldDescribeWrappers ' + fieldDescribeWrappers);
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = fieldDescribeWrappers[0].picklistOptions[0];
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }


            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testMultiPickListTypeOperatorsMultValues() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EUR_CRM_FilterBuilderControllerMock());
            Test.stopTest();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'MULTIPICKLIST') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    System.assertNotEquals(fieldDescribeWrappers[0].picklistOptions, null);
                    // add item for each operator
                    if (fieldDescribeWrappers[0].picklistOptions.size() < 2) continue;
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                        filterItem.field = dfield.getName();
                        filterItem.operator = operator;
                        filterItem.value = fieldDescribeWrappers[0].picklistOptions[0] + ', ' +
                            fieldDescribeWrappers[0].picklistOptions[1];
                        filterItems.add(filterItem);
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    @IsTest
    private static void testMultiPickListTypeOperatorsWithEmptyValue() {
        List<User> users = getEMEAandEURsystemAdminUser();
        System.assertEquals(1, users.size(), 'There are no users with a role EMEA and profile EUR System Admin!');

        System.runAs(users[0]) {
            List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper> filterItems = new List<EUR_CRM_FilterBuilderService.FiltersItemsWrapper>();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EUR_CRM_FilterBuilderControllerMock());
            Test.stopTest();
            for (Schema.SObjectField sfield : EUR_CRM_FilterBuilderController.getSObjectFields(PRODUCT_CATALOG_OBJECT_NAME).values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                String fieldType = String.valueOf(dfield.getType());
                if (fieldType == 'MULTIPICKLIST') {
                    // get field info and available operators
                    String describeResult = EUR_CRM_FilterBuilderController.describeFields(PRODUCT_CATALOG_OBJECT_NAME, new List<String> {
                        dfield.getName()
                    });
                    List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper> fieldDescribeWrappers = (List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>)
                        JSON.deserialize(describeResult, List<EUR_CRM_FilterBuilderController.FieldDescribeWrapper>.class);
                    System.assertNotEquals(fieldDescribeWrappers[0].picklistOptions, null);
                    // add item for each operator
                    if (fieldDescribeWrappers[0].picklistOptions.size() < 2) continue;
                    for (String operator : fieldDescribeWrappers[0].operatorOptions) {
                        if (EUR_CRM_FilterBuilderService.emptyValueAllowedOperators.contains(operator)) {
                            EUR_CRM_FilterBuilderService.FiltersItemsWrapper filterItem = new EUR_CRM_FilterBuilderService.FiltersItemsWrapper();
                            filterItem.field = dfield.getName();
                            filterItem.operator = operator;
                            filterItem.value = fieldDescribeWrappers[0].picklistOptions[0] + ', ,' +
                                fieldDescribeWrappers[0].picklistOptions[1] + ',';
                            filterItems.add(filterItem);
                        }
                    }
                    break;
                }
            }
            // try to validate items
            String result = EUR_CRM_FilterBuilderController.validateFilterItems(PRODUCT_CATALOG_OBJECT_NAME, null, JSON.serialize(filterItems));
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assertEquals(resultMap.get('success'), true);
        }
    }

    private static List<User> getEMEAandEURsystemAdminUser() {
        return [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'EUR System Admin'
                AND UserRole.Name = 'EMEA'
            LIMIT 1
        ];
    }

}