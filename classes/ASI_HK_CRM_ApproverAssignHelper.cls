public with sharing class ASI_HK_CRM_ApproverAssignHelper {
//Version 0.0.1
//Last modified Date: 20130815
//Modified By: Abel Ku  
    private static Integer MAX_MATCH_NUM_RHEAD;
    private static Integer MAX_MATCH_NUM_RDETAIL;
    private static final String FN_RHEAD_FIELD = 'ASI_HK_CRM_Field_API_Name_{0}__c';
    private static final String FN_RHEAD_VALUE = 'ASI_HK_CRM_Value_{0}__c';
    private static final String FN_RDETAIL_FIELD = 'ASI_HK_CRM_Field_API_Name_{0}__c';
    private static final String FN_RDETAIL_VALUE = 'ASI_HK_CRM_Value_{0}__c';
    private static final String RTDEVNAME_SPECIFIC_USER = ASI_HK_CRM_RoutingTableGenerator.RT_DetailSpecificUser;
    private static final String RTDEVNAME_USER_FIELD = ASI_HK_CRM_RoutingTableGenerator.RT_DetailUserField;
    
    // Settings
    public Integer maxNumOfApprover = 8;
    public String approverFieldFormat = 'ASI_HK_CRM_SYS_Approver_{0}__c';
    public Set<String> relevantUserFields = new Set<String> {
        'UserRoleId'
        , 'UserRole.DeveloperName'
        , 'ManagerId'
        , 'ASI_HK_CRM_Sales_Director_Approver__c'
    };
    public String relevantUserProfileNameLike = 'ASI%HK CRM%';
    
    private String objTypeStr;
    private List<ASI_HK_CRM_SO_Routing_Table_Header__c> routingInfos;
    private Map<ID, User> userMap;
    
    public ASI_HK_CRM_ApproverAssignHelper(String objTypeStr) {
        this.objTypeStr = objTypeStr;
    }
    
    public void init() {
        Set<String> routingHeaderFields = ASI_HK_CRM_CommonUtils.allFieldsOfSObject('ASI_HK_CRM_SO_Routing_Table_Header__c');
        Set<String> routingDetailFields = ASI_HK_CRM_CommonUtils.allFieldsOfSObject('ASI_HK_CRM_SO_Routing_Table_Detail__c');
        routingDetailFields.add('recordtype.developername');
        routingHeaderFields.add(
            '(' + ASI_HK_CRM_CommonUtils.genQueryString(
                routingDetailFields
                , 'SO_Routing_Table_Details__r'
            ) + ')'
        );
        this.routingInfos = (List<ASI_HK_CRM_SO_Routing_Table_Header__c>)database.query(
            ASI_HK_CRM_CommonUtils.genQueryString(
                routingHeaderFields
                , 'ASI_HK_CRM_SO_Routing_Table_Header__c'
                , 'RecordType.DeveloperName = \'' + ASI_HK_CRM_RoutingTableGenerator.RT_HeaderDefault + '\''
            )
        );
        
        //Retrieve the userMap where the Profile.Name Prefix is ASI HK CRM
        this.userMap = new Map<ID, User>((List<User>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(relevantUserFields, 'User', 'Profile.Name LIKE :relevantUserProfileNameLike')));
        // Find out the max num of index for some index fields
        if (MAX_MATCH_NUM_RHEAD == null) {
            ASI_HK_CRM_SO_Routing_Table_Header__c tempRHeader = new ASI_HK_CRM_SO_Routing_Table_Header__c();
            Integer index = 1, tempCount = 0;
            Boolean foundMaxIndex = false;
            
            //Just Calculate the total number of ASI_HK_CRM_Field_API_Name_ in the routing table and put into MAX_MATCH_NUM_RHEAD
            do {
                try {
                    String fn = rHeaderMatchFieldFieldName(index);
                    tempRHeader.get(fn);
                    tempCount++;
                } catch (Exception e) {
                    foundMaxIndex = true;
                }
                index++;
            } while (foundMaxIndex != true);
            MAX_MATCH_NUM_RHEAD = tempCount;
        }
        
        //Just Calculate the total number of ASI_HK_CRM_Field_API_Name_ in the routing table and put into MAX_MATCH_NUM_RDETAIL 
        //Different Object compare to the upper Code
        if (MAX_MATCH_NUM_RDETAIL == null) {
            ASI_HK_CRM_SO_Routing_Table_Detail__c tempRDetail = new ASI_HK_CRM_SO_Routing_Table_Detail__c();
            Integer index = 1, tempCount = 0;
            Boolean foundMaxIndex = false;
            do {
                try {
                    String fn = rDetailMatchFieldFieldName(index);
                    tempRDetail.get(fn);
                    tempCount++;
                } catch (Exception e) {
                    foundMaxIndex = true;
                }
                index++;
            } while (foundMaxIndex != true);
            MAX_MATCH_NUM_RDETAIL = tempCount;
        }
    }
    
    //Process Record. At least we have sobject = ASI_HK_CRM_Sales_Order__c
    public void processRecord(sObject sObj) {
        processRecord(sObj, 1, this.maxNumOfApprover);
    }
    public void processRecord(sObject sObj, Integer fromApproverIndex, Integer toApproverIndex) {
        // Find the first matched routing header
        ASI_HK_CRM_SO_Routing_Table_Header__c matchedRHeader = firstMatchedRoutingHeader(sObj);
        System.debug('clk2 ' + matchedRHeader);
        System.debug('sObjclk ' + sObj);
        if (matchedRHeader != null) {
            // Reset all approvers
            for (Integer i = 1; i <= this.maxNumOfApprover; i++)
                sObj.put(approverFieldName(i), null);
                System.debug('tvc');
            ID lastApproverId = (ID)sObj.get('OwnerId');
            // Handle the approver fields one by one
            for (Integer approverIndex = fromApproverIndex; approverIndex <= toApproverIndex && approverIndex <= maxNumOfApprover; approverIndex++) {
                // Find the first matched routing detail for current approver index
                ASI_HK_CRM_SO_Routing_Table_Detail__c matchedRDetail = firstMatchedRoutingDetail(sObj, matchedRHeader, approverIndex, lastApproverId);
                System.debug('clk3 ' + matchedRDetail);
                if (matchedRDetail != null) {
                    // Assign approver user ID
                    RoutingDetail convertedRDetail = routingDetailFromRoutingDetail(matchedRDetail, lastApproverId);
                    System.debug('clk4 ' + convertedRDetail);
                    if (!convertedRDetail.skipAssignApprover)
                    {
                        sObj.put(approverFieldName(approverIndex), convertedRDetail.approverId);
                        System.debug('clk5 ' + convertedRDetail.approverId);
                    }
                    if (convertedRDetail.jumpToNewApprover && convertedRDetail.approverId != null)
                    {
                        lastApproverId = convertedRDetail.approverId;
                        System.debug('clk6 ' + lastApproverId);
                    }
                }
            }
        }
    }
    
    private ASI_HK_CRM_SO_Routing_Table_Header__c firstMatchedRoutingHeader(sObject sObj) {
        for (ASI_HK_CRM_SO_Routing_Table_Header__c rHeader : this.routingInfos) {
            Boolean hasNotMatched = false;
            for (Integer i = 1; i <= MAX_MATCH_NUM_RHEAD; i++) {
                if (!isMatchedCriteria(sObj, rHeader, rHeaderMatchFieldFieldName(i), rHeaderMatchValueFieldName(i))) {
                    hasNotMatched = true;
                    break;
                }
            }
            if (!hasNotMatched)
                return rHeader;
        }
        return null;
    }
    private ASI_HK_CRM_SO_Routing_Table_Detail__c firstMatchedRoutingDetail(sObject sObj, ASI_HK_CRM_SO_Routing_Table_Header__c rHeader, Integer approverIndex, ID relevantUserId) {
        List<ASI_HK_CRM_SO_Routing_Table_Detail__c> rDetails = rHeader.SO_Routing_Table_Details__r;
        if (rDetails != null) {
            for (ASI_HK_CRM_SO_Routing_Table_Detail__c rDetail : rDetails) {
                Integer curApproverNum = rDetail.ASI_HK_CRM_Approver_No__c.intValue();
                if (curApproverNum == approverIndex) {
                    Boolean hasNotMatched = false;
                    for (Integer i = 1; i <= MAX_MATCH_NUM_RDETAIL; i++) {
                        if (!isMatchedCriteria(sObj, rDetail, rDetailMatchFieldFieldName(i), rDetailMatchValueFieldName(i))) {
                            hasNotMatched = true;
                            break;
                        }
                    }
                    if (!hasNotMatched) {
                        Boolean notMatchRole = false;
                        if (!String.isBlank(rDetail.ASI_HK_CRM_Approver_Role_Name__c)) {
                            notMatchRole = true;
                            ID approverId = approverIdFromRoutingDetail(rDetail, relevantUserId);
                            User approver = approverId != null ? this.userMap.get(approverId) : null;
                            String roleName = approver != null && approver.UserRoleId != null ? approver.UserRole.DeveloperName : null;
                            if (roleName != null) {
                                List<String> targetUserRoleList = rDetail.ASI_HK_CRM_Approver_Role_Name__c.split('\\|\\|', 0);
                                for (String targetUserRole : targetUserRoleList) {
                                    if (targetUserRole.trim() == roleName) {
                                        notMatchRole = false;
                                        break;
                                    }
                                }
                            }
                        }
                        if (!notMatchRole)
                            return rDetail;
                    }
                }
            }
        }
        return null;
    }
    
    private RoutingDetail routingDetailFromRoutingDetail(ASI_HK_CRM_SO_Routing_Table_Detail__c rDetail, ID relevantUserId) {
        RoutingDetail result = new RoutingDetail();
        result.skipAssignApprover = rDetail.ASI_HK_CRM_Skip_this_Step__c == true;
        result.jumpToNewApprover = rDetail.ASI_HK_CRM_Jump_to_New_User__c == true;
        result.approverId = approverIdFromRoutingDetail(rDetail, relevantUserId);
        return result;
    }
    
    private ID approverIdFromRoutingDetail(ASI_HK_CRM_SO_Routing_Table_Detail__c rDetail, ID relevantUserId) {
        ID resultId = null;
        if (RTDEVNAME_SPECIFIC_USER == rDetail.RecordType.DeveloperName) {
            resultId = rDetail.ASI_HK_CRM_Approver__c;
        } else if (RTDEVNAME_USER_FIELD == rDetail.RecordType.DeveloperName) {
            User relevantUser = relevantUserId != null ? this.userMap.get(relevantUserId) : null;
            if (relevantUser != null && rDetail.ASI_HK_CRM_User_Field__c != null) {
                try {
                    resultId = (ID)relevantUser.get(rDetail.ASI_HK_CRM_User_Field__c);
                } catch (Exception e) {
                    resultId = null;
                }
            }
        }
        System.debug('clk22 ' + resultId);
        return resultId;
    }
    
    private static Boolean isMatchedCriteria(sObject targetObj, sObject checkByObj, String matchFieldFN, String matchValueFN) {
        String matchFN = (String)checkByObj.get(matchFieldFN);
        if (matchFN == null || matchFN.trim() == '') return true;
        String matchValue = (String)checkByObj.get(matchValueFN);
        Object recordCurValue = targetObj.get(matchFN);
        // Check whether matchValue == recordCurrentValue
        try {
            if (String.isBlank(matchValue)) {
                return recordCurValue == null;
            }
            if (recordCurValue instanceof String) {
                return (String)recordCurValue == matchValue;
            } else if (recordCurValue instanceof Decimal) {
                return (Decimal)recordCurValue == Decimal.valueOf(matchValue.trim());
            } else if (recordCurValue instanceof ID) {
                return (String)recordCurValue == matchValue.trim();
            } else if (recordCurValue instanceof Boolean) {
                return (Boolean)recordCurValue == (
                    matchValue.toLowerCase() == 'true'
                    || matchValue.toLowerCase() == 'yes'
                    || matchValue.toLowerCase() == 'y'
                    || matchValue == '1'
                );
            } else if (recordCurValue instanceof Datetime) {
                return (Datetime)recordCurValue == Datetime.valueOf(matchValue.trim());
            } else if (recordCurValue instanceof Date) {
                return (Date)recordCurValue == Date.valueOf(matchValue.trim());
            }
        } catch (Exception e) {
            System.debug(e);
            return false;
        }
        return false;
    }
    
    //Return the Name with index
    private String approverFieldName(Integer index) {
        System.debug('clk27 ' + String.format(approverFieldFormat, new String[] {String.valueOf(index)}));
        return String.format(approverFieldFormat, new String[] {String.valueOf(index)});
    }
    
    private static String rHeaderMatchFieldFieldName(Integer index) {
        System.debug('clk26 ' + String.format(FN_RHEAD_FIELD, new String[] {String.valueOf(index)}));
        return String.format(FN_RHEAD_FIELD, new String[] {String.valueOf(index)});
    }
    private static String rHeaderMatchValueFieldName(Integer index) {
        System.debug('clk25 ' + String.format(FN_RHEAD_VALUE, new String[] {String.valueOf(index)}));
        return String.format(FN_RHEAD_VALUE, new String[] {String.valueOf(index)});
    }
    private static String rDetailMatchFieldFieldName(Integer index) {
        System.debug('clk24 ' + String.format(FN_RDETAIL_FIELD, new String[] {String.valueOf(index)}));
        return String.format(FN_RDETAIL_FIELD, new String[] {String.valueOf(index)});
    }
    private static String rDetailMatchValueFieldName(Integer index) {
        System.debug('clk23 ' + String.format(FN_RDETAIL_VALUE, new String[] {String.valueOf(index)}));
        return String.format(FN_RDETAIL_VALUE, new String[] {String.valueOf(index)});
    }
    
    public class RoutingDetail {
        public ID approverId;
        public Boolean skipAssignApprover;
        public Boolean jumpToNewApprover;
    }
    
}