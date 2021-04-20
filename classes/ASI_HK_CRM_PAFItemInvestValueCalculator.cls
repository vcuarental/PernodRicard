public with sharing class ASI_HK_CRM_PAFItemInvestValueCalculator extends ASI_HK_CRM_TriggerAbstract {
    // public static ID rtid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__c');
    
    private static String[] REQUIRED_FIELDS = new String[] {
        'ASI_HK_CRM_SKU_Lookup__c'
        , 'ASI_HK_CRM_Target_Volume_Qty__c'
        , 'ASI_HK_CRM_Price__c'
    };
    private static Map<String, Schema.SObjectField> FIELD_DESCRIBE_MAP;
    private static ID RTID_FOC = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_FOC).Id;
    private static ID RTID_FOC_BULK = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_FOC_BULK).Id;
    private static ID RTID_VARIABLE = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_VARIABLE).Id;
    private static ID RTID_FIXED = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_FIXED).Id;
    private static ID RTID_FIXED_BOTTLE = ASI_HK_CRM_PreApprovalFormItemGenerator.getRecordTypeByDevName(ASI_HK_CRM_PreApprovalFormItemGenerator.RT_FIXED_BOTTLE).Id;
    private static final String FIELD_NAME_FOC_BUY = 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_{0}__c';
    private static final String FIELD_NAME_FOC_FREE = 'ASI_HK_CRM_FOC_Free_Bottle_Option_{0}__c';
    private static final ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
    private static Map<id,Boolean> skuCheckMap = new Map<id,Boolean>(); //20160317, added by Leo
    
    public ASI_HK_CRM_PAFItemInvestValueCalculator() {
        super('ASI_HK_CRM_PAFItemInvestValueCalculator');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
            && !isBypassByCurrentUser()) {
                Set<String> prodSet = new Set<String>();

                List<ASI_HK_CRM_Pre_Approval_Form_Item__c> pafItemList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)sObjList;
                Decimal allPercent = 0;
                Decimal allDisc = 0;

                for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : pafItemList)
                {
                    if (item.ASI_CRM_HK_All_Product__c)
                    {
                        if (item.ASI_HK_CRM_Rebate_Disc_Percent__c != null)
                        {
                            allPercent += item.ASI_HK_CRM_Rebate_Disc_Percent__c;
                        }
                        else if (item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null)
                        {
                            allDisc += item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                        }
                    }
                }
                
                for (ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem : pafItemList) {
                    try {
                        //existingSet.add(pafItem.Id);
                        validateLineItem(pafItem);
                        //if(tAction == TriggerAction.BEFORE_UPDATE) //20160322, added by Leo
                        //{
                        if(!pafItem.ASI_CRM_HK_All_Product__c)
                            calculateInvestmentValue(pafItem, allPercent, allDisc);

                    } catch (ASI_HK_CRM_CustomException e) {
                        pafItem.addError(e.getMessage());
                    } catch (Exception e) {
                        pafItem.addError(e);
                    }

                    if (!prodSet.contains(pafItem.ASI_HK_CRM_SKU_Lookup__c))
                        prodSet.add(pafItem.ASI_HK_CRM_SKU_Lookup__c);
                }

                List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechanics = [
                    select ID, ASI_HK_CRM_Code__c
                    from ASI_HK_CRM_Pre_Approval_Form_Mechanic__c
                ];

                

                for (String key : prodSet)
                {
                    System.debug('key: ' + key);
                    List<ASI_HK_CRM_Pre_Approval_Form_Item__c> itemList = getItems(pafItemList, key);

                    Decimal totalInvest = 0;
                    Decimal investBottle = 0;
                    Decimal targetVolume = 0;
                    Decimal price = 0;
                    for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : itemList)
                    {
                        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech = getMechanic(mechanics, item.ASI_HK_CRM_Mechanic__c);

                        if (targetVolume == 0 && item.ASI_HK_CRM_Target_Volume_Qty__c != null)
                        {
                            targetVolume = item.ASI_HK_CRM_Target_Volume_Qty__c;
                        }
                        
                        if (price == 0 && item.ASI_HK_CRM_Price__c != null)
                        {
                            price = item.ASI_HK_CRM_Price__c;

                            if (allPercent > 0)
                            {
                                totalInvest += (targetVolume * price * (allPercent / 100));
                                // price -= (price * allPercent / 100);
                            }

                            if (allDisc > 0)
                            {
                                totalInvest += (targetVolume * allDisc);
                                // price -= allDisc;
                            }
                        }

                        if (mech != null)
                        {
                            if (mech.ASI_HK_CRM_Code__c == 'A04'
                                || mech.ASI_HK_CRM_Code__c == 'A02' || mech.ASI_HK_CRM_Code__c == 'B01'
                                || mech.ASI_HK_CRM_Code__c == 'A03' || mech.ASI_HK_CRM_Code__c == 'A11' || mech.ASI_HK_CRM_Code__c == 'A17'
                                || mech.ASI_HK_CRM_Code__c == 'A07' || mech.ASI_HK_CRM_Code__c == 'A09'
                                || mech.ASI_HK_CRM_Code__c == 'A06' || mech.ASI_HK_CRM_Code__c == 'A10' || mech.ASI_HK_CRM_Code__c == 'A12'
                                || mech.ASI_HK_CRM_Code__c == 'A14' || mech.ASI_HK_CRM_Code__c == 'A15' || mech.ASI_HK_CRM_Code__c == 'A16')
                            {
                                totalInvest += (item.ASI_HK_CRM_Investment_Value__c != null ? item.ASI_HK_CRM_Investment_Value__c : 0);
                            }
                            
                            if (mech.ASI_HK_CRM_Code__c == 'A02'
                                || mech.ASI_HK_CRM_Code__c == 'A03'
                                || mech.ASI_HK_CRM_Code__c == 'A11'
                                || mech.ASI_HK_CRM_Code__c == 'A17')
                            {
                                investBottle += ((item.ASI_HK_CRM_Investment_Value__c != null ? item.ASI_HK_CRM_Investment_Value__c : 0) / price);
                            }
                        }
                    }

                    Decimal totalBottle = targetVolume + investBottle;
                    Decimal grossSales = totalBottle * price;
                    Decimal netSales = grossSales - totalInvest;
                    Decimal nnp = totalBottle == 0 ? 0 : netSales / totalBottle;
                    
                    for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : itemList)
                    {
                        item.ASI_HK_CRM_NNP__c = nnp;
                    }
                }
            }
    }

    private static ASI_HK_CRM_Pre_Approval_Form_Mechanic__c getMechanic(List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechanics, ID mid)
    {
        for (ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech : mechanics)
        {
            if (mech.ID == mid)
            {
                return mech;
            }
        }

        return null;
    }

    private static void calculateInvestmentValue(ASI_HK_CRM_Pre_Approval_Form_Item__c lineItem,decimal allPercent, decimal allDisc) {
        lineItem.ASI_HK_CRM_Investment_Value__c = null;
        lineItem.ASI_HK_CRM_NNP__c = null;
        if (lineItem.RecordTypeId != null && !lineItem.ASI_CRM_HK_All_Product__c) { //20160318, edited by Leo, add bypass all product
            ID rtId = lineItem.RecordTypeId;
            Decimal finalInvAmt = 0;
            Decimal investBottle = 0;

            if (RTID_FOC == rtId || RTID_FOC_BULK == rtId) {
                Decimal maxInvAmt = null;
                for (Integer i = 1; i <= ASI_HK_CRM_PreApprovalFormItemGenerator.MAX_NUM_OF_FOC_PAIR; i++) {
                    Decimal buyCount = (Decimal)lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.buyField(i));
                    Decimal freeCount = (Decimal)lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.freeField(i));
                    if (buyCount != null && freeCount != null) {
                        Decimal netPrice=lineItem.ASI_HK_CRM_Price__c- allDisc -lineItem.ASI_CRM_NetPrice_Discount__c ;
                        if(allPercent>0)
                            netPrice=netPrice*(1-allPercent/100) ;
                        netPrice-= lineItem.ASI_CRM_Extra_Discount__c;
                        Decimal curInvAmt = intNearestToZero(lineItem.ASI_HK_CRM_Target_Volume_Qty__c / buyCount) * freeCount * netPrice;
                        if (maxInvAmt == null || curInvAmt > maxInvAmt)
                            maxInvAmt = curInvAmt;                        
                    }
                }
                //20160311, added by Leo
                if(lineItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null && lineItem.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c != null)
                {
                    Decimal temp1 = intNearestToZero(lineItem.ASI_HK_CRM_Target_Volume_Qty__c / lineItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c) * lineItem.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c * lineItem.ASI_HK_CRM_Price__c;
                    Integer temp2 = Math.mod(Integer.valueOf(lineItem.ASI_HK_CRM_Target_Volume_Qty__c),Integer.valueOf(lineItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c));
                    if(temp2 > 0)
                    {
                        Decimal temp3 = intNearestToZero(temp2 / lineItem.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c) * lineItem.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c * lineItem.ASI_HK_CRM_Price__c;
                        finalInvAmt = temp1 + temp3;    
                    }
                    else
                    {
                        finalInvAmt = maxInvAmt;
                    }
                }//end if
                else //20160311, added by Leo
                {
                    finalInvAmt = maxInvAmt;
                }

                investBottle = finalInvAmt / lineItem.ASI_HK_CRM_Price__c;
            } else if (RTID_FIXED_BOTTLE == rtId) {
                Decimal maxInvAmt = null;
                for (Integer i = 1; i <= ASI_HK_CRM_PreApprovalFormItemGenerator.MAX_NUM_OF_FOC_PAIR; i++) {
                    Decimal buyCount = (Decimal)lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.buyField(i));
                    Decimal freeCount = (Decimal)lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.freeField(i));
                    if (buyCount != null && freeCount != null) {                        
                        Decimal curInvAmt = (lineItem.ASI_HK_CRM_Target_Volume_Qty__c >= buyCount ? 1 : 0) * freeCount * lineItem.ASI_HK_CRM_Price__c;
                        if (maxInvAmt == null || curInvAmt > maxInvAmt)
                            maxInvAmt = curInvAmt;                        
                    }
                }
                
                finalInvAmt = maxInvAmt;
                investBottle = finalInvAmt / lineItem.ASI_HK_CRM_Price__c;
            } else if (RTID_VARIABLE == rtId) {
                if (lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c != null) {
                    finalInvAmt = lineItem.ASI_HK_CRM_Target_Volume_Qty__c * (lineItem.ASI_HK_CRM_Price__c-(lineItem.ASI_CRM_NetPrice_Discount__c==null?0:lineItem.ASI_CRM_NetPrice_Discount__c)) * (lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c / 100);
                } else if (lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null) {
                    finalInvAmt = lineItem.ASI_HK_CRM_Target_Volume_Qty__c * lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                }
            } else if (RTID_FIXED == rtId) {
                if (lineItem.ASI_HK_CRM_Fixed_Amount__c != null) {
                    finalInvAmt = lineItem.ASI_HK_CRM_Fixed_Amount__c;
                }
            }
            
            lineItem.ASI_HK_CRM_Investment_Value__c = finalInvAmt;

            // Decimal totalBottle = lineItem.ASI_HK_CRM_Target_Volume_Qty__c + investBottle;
            // Decimal grossSales = totalBottle * lineItem.ASI_HK_CRM_Price__c;
            // Decimal netSales = grossSales - finalInvAmt;
            // lineItem.ASI_HK_CRM_NNP__c = netSales / totalBottle;
        }
    }
    
    private static void validateLineItem(ASI_HK_CRM_Pre_Approval_Form_Item__c lineItem) {
        for (String requiredField : REQUIRED_FIELDS) {
            if (!isNotEmptyForField(lineItem, requiredField) && !lineItem.ASI_CRM_HK_All_Product__c) { //20160317, edited by Leo, add codition check sku
                if (FIELD_DESCRIBE_MAP == null)
                    FIELD_DESCRIBE_MAP = Schema.SObjectType.ASI_HK_CRM_Pre_Approval_Form_Item__c.fields.getMap();
                Schema.SObjectField f = FIELD_DESCRIBE_MAP.get(requiredField);
                String fieldLabel = f != null ? f.getDescribe().getLabel() : '[Unknown Field]';
                throw new ASI_HK_CRM_CustomException(String.format('{0} cannot be empty', new String[] {fieldLabel}));
            }
        }
        if (lineItem.RecordTypeId != null) {
            ID rtId = lineItem.RecordTypeId;
            if (RTID_FOC == rtId || RTID_FOC_BULK == rtId || RTID_FIXED_BOTTLE == rtId) {
                Boolean isValid = true;
                if (lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.buyField(1)) == null || lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.freeField(1)) == null)
                    isValid = false;
                else {
                    for (Integer i = 2; i <= ASI_HK_CRM_PreApprovalFormItemGenerator.MAX_NUM_OF_FOC_PAIR; i++) {
                        if ((lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.buyField(i)) == null) != (lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.freeField(i)) == null)) {
                            isValid = false;
                            break;
                        }
                    }
                }
                if (!isValid) {
                    throw new ASI_HK_CRM_CustomException('Invalid FOC inputs');
                }
                if (RTID_FOC_BULK == rtId) {
                    if (thresholdValueSetting != null && thresholdValueSetting.ASI_HK_CRM_PAF_FOC_Bulk_Min_Buy__c != null) {
                        for (Integer i = 1; i <= ASI_HK_CRM_PreApprovalFormItemGenerator.MAX_NUM_OF_FOC_PAIR; i++) {
                            Decimal buyValue = (Decimal)lineItem.get(ASI_HK_CRM_PreApprovalFormItemGenerator.buyField(i));
                            if (buyValue != null && buyValue < thresholdValueSetting.ASI_HK_CRM_PAF_FOC_Bulk_Min_Buy__c)
                                throw new ASI_HK_CRM_CustomException(String.format('FOC Bulk requires at least {0} buy bottles', new String[] {String.valueOf(thresholdValueSetting.ASI_HK_CRM_PAF_FOC_Bulk_Min_Buy__c)}));
                        }
                    }
                }
            } else if (RTID_VARIABLE == rtId) {
                if ((lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c == null) == (lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c == null)) {
                    throw new ASI_HK_CRM_CustomException('Invalid variable amount inputs');
                }
            } else if (RTID_FIXED == rtId) {
                if (lineItem.ASI_HK_CRM_Fixed_Amount__c == null) {
                    throw new ASI_HK_CRM_CustomException('Fixed amount is missing');
                }
            }
        }
    }
    private static Boolean isNotEmptyForField(sObject sObj, String field) {
        Object val = sObj.get(field);
        return val != null
            && !(val instanceof String && ((String)val).trim() == '');
    }
    private static String buyField(Integer index) { return String.format(FIELD_NAME_FOC_BUY, new String[] {String.valueOf(index)}); }
    private static String freeField(Integer index) { return String.format(FIELD_NAME_FOC_FREE, new String[] {String.valueOf(index)}); }
    
    //Return the positive integer nearest to zero
    private static Integer intNearestToZero(Decimal dec) {
        if (dec == null) return null;
        Integer result = Math.floor(Math.abs(dec)).intValue();
        if (dec < 0) result *= -1;
        return result;
    }
    
    public static void setRequiredFields(){
        REQUIRED_FIELDS.add('Test1');
    }
    
    public static void setField(){
        String temp1 = buyField(1);
        String temp2 = freeField(1);
    }
    
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> getItems(List<ASI_HK_CRM_Pre_Approval_Form_Item__c> itemList, String lookupName)
    {
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> retList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();

        for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : itemList)
        {
            if (item.ASI_HK_CRM_SKU_Lookup__c == lookupName)
            {
                retList.add(item);
            }
        }

        return retList;
    }
}