/**
 * Created by user on 2019-04-19.
 */

trigger ASI_EV_Detected_Item_Trigger on ASI_EV_Detected_Item__c (after insert, after update) {


    Set<Id> pStatusIds = new Set<Id>();

    for(ASI_EV_Detected_Item__c item : Trigger.new){

        pStatusIds.add(item.Promotion_Status__c);
    }

    system.debug('=== pStatusIds.size() : ' + pStatusIds.size());

    List<ASI_CRM_Promotion_Status__c> pmsList = [
            SELECT Id, Name, ASI_CRM_Promotion__c, ASI_CRM_Done__c
                , (SELECT Id, Detected_Quantity__c, Checked_Quantity__c, Sub_brand__c FROM ASI_EV_Detected_Items__r)
            FROM ASI_CRM_Promotion_Status__c WHERE Id IN :pStatusIds
    ];

    //Set<Id> promotionId = new Set<Id>();
    // Promotion 별로 Unit 별 수량 Map 을 담을 Map
    Map<Id, Map<Id, Decimal>> pUnitsMap = new Map<Id, Map<Id, Decimal>>();
    for(ASI_CRM_Promotion_Status__c pms : pmsList){
        pUnitsMap.put(pms.ASI_CRM_Promotion__c, null);
    }

    List<ASI_HK_CRM_Promotion__c> promotionList = [
            SELECT Id
                , (SELECT Id, ASI_CRM_Sub_brand__c, ASI_CRM_Qty__c FROM Promotion_Units__r)
            FROM ASI_HK_CRM_Promotion__c WHERE Id IN :pUnitsMap.keySet()
    ];

    // Promotion 별로 Unit 별 수량 Map 을 담을 Map 을 셋팅
    pUnitsMap.clear();
    for(ASI_HK_CRM_Promotion__c p : promotionList){

        Map<Id, Decimal> unitQuantityMap = new Map<Id, Decimal>();
        for(ASI_CRM_Promotion_Unit__c pmu : p.Promotion_Units__r){
            // 중복되는 unit 이 없다고 가정
            unitQuantityMap.put(pmu.ASI_CRM_Sub_brand__c, pmu.ASI_CRM_Qty__c);
        }
        system.debug('=== unitQuantityMap : ' + unitQuantityMap.size());

        pUnitsMap.put(p.Id, unitQuantityMap);
    }

    for(ASI_CRM_Promotion_Status__c pms : pmsList){

        Map<Id, Decimal> unitQuantityMap;

        if(pUnitsMap.containsKey(pms.ASI_CRM_Promotion__c)) unitQuantityMap = pUnitsMap.get(pms.ASI_CRM_Promotion__c);
        else unitQuantityMap = new Map<Id, Decimal>();

        //List<ASI_EV_Detected_Item__c> itemList = pms.ASI_EV_Detected_Items__r;

        Map<Id, ASI_EV_Detected_Item__c> itemMap = new Map<Id, ASI_EV_Detected_Item__c>();
        for(ASI_EV_Detected_Item__c item : pms.ASI_EV_Detected_Items__r){
            itemMap.put(item.Sub_brand__c, item);
        }

        Boolean checkFlag = true;

        for(Id itemId : unitQuantityMap.keySet()){

            if(itemMap.containsKey(itemId)){

                Decimal unitQuantity = unitQuantityMap.get(itemId);

                ASI_EV_Detected_Item__c item = itemMap.get(itemId);

                // 비교 할 수량은 기본적으로 Detected_Quantity__c 이지만, 사용자가 Checked_Quantity__c 을 입력했다면 Checked_Quantity__c 로 비교
                Decimal qtyItem = item.Detected_Quantity__c;
                if(item.Checked_Quantity__c != null) qtyItem = item.Checked_Quantity__c;

                // EV 가 인식한 품목 수량이 Promotion Unit 에 입력되어있는 수량보다 한 품목이라도 작으면 Done = false
                if(qtyItem < unitQuantity) {
                    checkFlag = false;
                    break;
                }

            } else {
                checkFlag = false;
                break;
            }
        }

        pms.ASI_CRM_Done__c = checkFlag;

        /*
        // Promotion Unit 과 Detected Item 의 갯수가 다르면 Done 필드 false 처리
        if(itemList.size() != unitQuantityMap.size()) pms.ASI_CRM_Done__c = false;
        // size 가 같으면 일단 모든 품목들에 대해서는 맵핑된다고 가정하고 수량을 비교
        else {

            Boolean checkFlag = true;

            for(ASI_EV_Detected_Item__c item : itemList){

                Decimal unitQuantity = 0;
                if(unitQuantityMap.containsKey(item.Sub_brand__c)) unitQuantity = unitQuantityMap.get(item.Sub_brand__c);
                else {
                    checkFlag = false;
                    break;
                }

                // 비교 할 수량은 기본적으로 Detected_Quantity__c 이지만, 사용자가 Checked_Quantity__c 을 입력했다면 Checked_Quantity__c 로 비교
                Decimal qtyItem = item.Detected_Quantity__c;
                if(item.Checked_Quantity__c != null) qtyItem = item.Checked_Quantity__c;

                // EV 가 인식한 품목 수량과 Promotion Unit 에 입력되어있는 수량이 한 품목이라도 다르면 Done = false
                if(qtyItem != unitQuantity) {
                    checkFlag = false;
                    break;
                }
            }

            pms.ASI_CRM_Done__c = checkFlag;
        }
        */
    }

    /*
    for(ASI_CRM_Promotion_Status__c pms : pmsList){

        Map<Id, Decimal> unitQuantityMap;

        if(pUnitsMap.containsKey(pms.ASI_CRM_Promotion__c)) unitQuantityMap = pUnitsMap.get(pms.ASI_CRM_Promotion__c);
        else unitQuantityMap = new Map<Id, Decimal>();

        List<ASI_EV_Detected_Item__c> itemList = pms.ASI_EV_Detected_Items__r;

        // itemList 나 unitQuantityMap 의 size 가 0인 경우에 대한 처리 고민

        // Promotion Unit 과 Detected Item 의 갯수가 다르면 Done 필드 false 처리
        if(itemList.size() != unitQuantityMap.size()) pms.ASI_CRM_Done__c = false;
        // size 가 같으면 일단 모든 품목들에 대해서는 맵핑된다고 가정하고 수량을 비교
        else {

            Boolean checkFlag = true;

            for(ASI_EV_Detected_Item__c item : itemList){

                Decimal unitQuantity = 0;
                if(unitQuantityMap.containsKey(item.Sub_brand__c)) unitQuantity = unitQuantityMap.get(item.Sub_brand__c);
                else {
                    checkFlag = false;
                    break;
                }

                // 비교 할 수량은 기본적으로 Detected_Quantity__c 이지만, 사용자가 Checked_Quantity__c 을 입력했다면 Checked_Quantity__c 로 비교
                Decimal qtyItem = item.Detected_Quantity__c;
                if(item.Checked_Quantity__c != null) qtyItem = item.Checked_Quantity__c;

                // EV 가 인식한 품목 수량과 Promotion Unit 에 입력되어있는 수량이 한 품목이라도 다르면 Done = false
                if(qtyItem != unitQuantity) {
                    checkFlag = false;
                    break;
                }
            }

            pms.ASI_CRM_Done__c = checkFlag;
        }
    }
    */

    update pmsList;
}