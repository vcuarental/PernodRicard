global without sharing class ASI_MFM_CN_POSM_StockinRequestListCls {
    
    @RemoteAction
    global static ResultObj confirmRequest(String dataSet, boolean isDelete) {
        try {
            Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
            List<Object> dataList = (List<Object>)dataMap.get('requestList');
            
            if(dataList.size() == 0 || dataList == Null){
                return new ResultObj(false, 'No lines to be ' + (isDelete ? 'deleted' : 'confirmed'), null);
            }
            
            List<ASI_MFM_Stock_In_Request__c> sirList = new List<ASI_MFM_Stock_In_Request__c>();
            List<ASI_MFM_PO_POSM_Line__c> posmLineList = new List<ASI_MFM_PO_POSM_Line__c >();
            Set<String> posmIdSet = new Set<String>();
            
            for(Object dataObj : dataList) {
                String jsonData = JSON.serialize(dataObj);
            	StockinReq sirObj = (StockinReq)JSON.deserialize(jsonData, StockinReq.class);
                ASI_MFM_Stock_In_Request__c sir = new ASI_MFM_Stock_In_Request__c(id=sirObj.id, ASI_MFM_Status__c='Confirmed', ASI_MFM_NotificationtoOperation__c=True);	//AM 20181219: use SIR to send notification
                if(!posmIdSet.contains(sirObj.posmLineId)){
                    posmLineList.add(new ASI_MFM_PO_POSM_Line__c(id = sirObj.posmLineId, ASI_MFM_Notification_to_Operation__c = True));
                    posmIdSet.add(sirObj.posmLineId);
                }
                sirList.add(sir);
            }
            
            if(isDelete){
                Delete sirList;
            }else{ 
                update sirList;
                Update posmLineList;
            }     
            
        	return new ResultObj(true, 'success',  null);
            
        } catch(Exception e) {
            return new ResultObj(false, e.getMessage(), null);
        }
    }
    
	@RemoteAction
    global static ResultObj searchRequest(String dataSet) {
        try {
            Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
            String ponum = (String)dataMap.get('ponum');
            System.debug(LoggingLevel.INFO, '*** ponum: ' + ponum);
            
           
            Id sirRTID = Global_recordTypeCache.getRtId('ASI_MFM_Stock_In_Request__cASI_MFM_CN_Stock_In_Request');
            String sqlStr = 'SELECT id, Name, ASI_MFM_Delivery_Address__c, ASI_MFM_PO_Number__r.name, ASI_MFM_PO_POSM_Line_Number__r.name, ASI_MFM_Status__c, ASI_MFM_Total_Number_Of_Box__c, ';
            sqlStr += 'ASI_MFM_Lot_Quantity__c, ASI_Delivery_Date__c, ASI_MFM_Net_Weight__c, ASI_MFM_Box_Net_Weight__c, ASI_MFM_Total_Quantity__c, ASI_MFM_Lot_Number__c, ';
            sqlStr += 'ASI_MFM_Min_Unit_Price__c, ASI_MFM_Qty_Per_Bag_Box__c, ASI_MFM_Qty_Per_Box__c, ASI_MFM_Total_Qty_Per_Bag_Box__c, ASI_MFM_Fraction_Qty__c, ';
            sqlStr += 'ASI_MFM_Box_Size_M3__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_PO_POSM_Line_Number__c ';
            sqlStr += 'FROM ASI_MFM_Stock_In_Request__c ';
            
            if(String.isNotBlank(ponum))
            {
                sqlStr += 'WHERE ((ASI_CTY_CN_Vendor_SIR_Approval_Status__c = \'Pending Confirm\' AND  ASI_CTY_CN_Vendor_SIR_ApprovalUser__c = \''+ UserInfo.getUserId() +'\') OR (ASI_MFM_Status__c = \'Pending Confirm\' AND ASI_CTY_CN_Vendor_SIR_Approval_Status__c = null)) AND RecordTypeId=\''+sirRTID+'\' ';
                sqlStr += 'AND ASI_MFM_PO_Number__r.name LIKE \''+ ponum +'\'';
            }
            else
            {
               sqlStr += 'WHERE ASI_CTY_CN_Vendor_SIR_Approval_Status__c = \'Pending Confirm\' AND  ASI_CTY_CN_Vendor_SIR_ApprovalUser__c = \''+ UserInfo.getUserId() +'\' AND RecordTypeId=\''+sirRTID+'\' ';
            }
           // sqlStr += 'AND ASI_CTY_CN_Vendor_SIR_ApprovalUser__c = \''+ UserInfo.getUserId() +'\'';
            /*if(ponum!=null&ponum!='') {
            sqlStr += 'AND ASI_MFM_PO_Number__r.name LIKE \'%'+ponum+'%\'';
            }*/
            List<ASI_MFM_Stock_In_Request__c> sirList = database.query(sqlStr);
            List<StockinReq> reqList = new List<StockinReq>();
            for(ASI_MFM_Stock_In_Request__c sir : sirList) {
                reqList.add(new StockinReq(sir));
            }
            
            
            return new ResultObj(true, ''+ponum, reqList);
            
            
            //return new ResultObj(true, '', new List<StockinReq>());
            
        } catch(Exception  e) {
            return new ResultObj(false, e.getMessage(), null);
        }
    }

    @RemoteAction
    global static ResultObj confirmNewRequest(String dataSet, String type) {
        try {
            System.debug(LoggingLevel.INFO, '*** dataSet: ' + dataSet);
            List<String> dataList= (List<String>)JSON.deserialize(dataSet, List<String>.class);
             System.debug(LoggingLevel.INFO, '*** dataList: ' + dataList);
            List<ASI_MFM_Stock_In_Request__c> stocknewList = [SELECT Id,ASI_MFM_Status__c,ASI_CTY_CN_Vendor_SIR_Approval_Status__c,ASI_MFM_PO_POSM_Line_Number__c from ASI_MFM_Stock_In_Request__c WHERE Id IN:dataList];
            List<ASI_MFM_Stock_In_Request__c> sirList = new List<ASI_MFM_Stock_In_Request__c>();
            List<ASI_MFM_PO_POSM_Line__c> posmLineList = new List<ASI_MFM_PO_POSM_Line__c >();
            Set<String> posmIdSet = new Set<String>();
            Map<Id,ASI_MFM_Stock_In_Request__c> stockMap = new Map<Id,ASI_MFM_Stock_In_Request__c>();


               //1:确认；2：拒绝
               Set<Id> oldstockIds = new Set<Id>();
               Set<Id> stockIds = new Set<Id>();
               // 查找对应的审批流
               for(ASI_MFM_Stock_In_Request__c stock:stocknewList)
               {   
                  if(null != stock.ASI_CTY_CN_Vendor_SIR_Approval_Status__c)
                  {
                     stockIds.add(stock.Id);
                  }
                  else
                  {
                    oldstockIds.add(stock.Id);
                  }
                  
                  stockMap.put(stock.Id,stock);
               }

               List<ProcessInstanceWorkitem> piws=[SELECT Id,ActorId,OriginalActorId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.Status='Pending' AND ProcessInstance.TargetObjectId IN:stockIds];
               System.debug(LoggingLevel.INFO, '*** stockIds: ' + stockIds);
               for(ProcessInstanceWorkitem workitem :piws)
               {
                   Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                   req.setWorkitemId(workitem.id);
                   if(type.equals('1'))
                   {
                     req.setAction('Approve');
                   }
                   else
                   {
                      req.setAction('Reject');
                   }
                  
                   Approval.ProcessResult result2 =  Approval.process(req);
                   System.debug(LoggingLevel.INFO, '*** result2: ' + result2);
                   
               }

               // 旧数据处理
               for(Id ids:oldstockIds)
               {
                    ASI_MFM_Stock_In_Request__c sir =  stockMap.get(ids);
                    sir.ASI_MFM_Status__c='Confirmed';
                    sir.ASI_MFM_NotificationtoOperation__c=True;
                    if(!posmIdSet.contains(sir.ASI_MFM_PO_POSM_Line_Number__c)){
                        posmLineList.add(new ASI_MFM_PO_POSM_Line__c(id = sir.ASI_MFM_PO_POSM_Line_Number__c, ASI_MFM_Notification_to_Operation__c = True));
                        posmIdSet.add(sir.ASI_MFM_PO_POSM_Line_Number__c);
                    }
                    sirList.add(sir);
               }
            
                if(type.equals('1'))
                {
                    update sirList;
                    Update posmLineList;
                }
                else
                {
                     delete sirList;
                }
            return new ResultObj(true, 'success',  null);
            
        } catch(Exception e) {
            return new ResultObj(false, e.getMessage(), null);
        }
    }
    
    global class ResultObj {
    	public String message;
        public Boolean success;
        public List<StockinReq> requestList;
        public ResultObj(Boolean b, String m, List<StockinReq> rl){
            message = m;
            success = b;
            requestList = rl;
        }
    }
    
    global class StockinReq {
        public String  id;
        public String  itemCode;
        public Decimal boxSizeM3;
        public String  deliveryAddr;
        public String  poNum;
        public String  posmLineNum;
        public String  status;
        public Decimal totalNumBox;
        public Decimal lotQty;
        public String  deliveryDate;
        public Decimal netWeight;
        public Decimal  boxNetWeight;
        public Decimal totalQty;
        public String  lotNum;
        public Decimal minUnitPrice;
        public Decimal qtyPerBagBox;
        public Decimal qtyPerBox;
        public Decimal totalQtyPerBagBox;
        public Decimal fractionQty;
        public String posmLineId;
        public String name;
        
        public StockinReq(ASI_MFM_Stock_In_Request__c sir) {
            id = sir.Id;
            name = sir.name;
            posmLineId = sir.ASI_MFM_PO_POSM_Line_Number__c != Null ? sir.ASI_MFM_PO_POSM_Line_Number__c : '';
            itemCode = (sir.ASI_MFM_Item_Group_Code__c!=null)?sir.ASI_MFM_Item_Group_Code__c:'';
			if(sir.ASI_MFM_Box_Size_M3__c!=null) boxSizeM3=sir.ASI_MFM_Box_Size_M3__c;
            deliveryAddr = (sir.ASI_MFM_Delivery_Address__c!=null)? sir.ASI_MFM_Delivery_Address__c:'';
            poNum = (sir.ASI_MFM_PO_Number__r.name!=null)? sir.ASI_MFM_PO_Number__r.name:'';
            posmLineNum = (sir.ASI_MFM_PO_POSM_Line_Number__r.name!=null)? sir.ASI_MFM_PO_POSM_Line_Number__r.name:'';
            status = (sir.ASI_MFM_Status__c!=null)? sir.ASI_MFM_Status__c:'';
            if(sir.ASI_MFM_Total_Number_Of_Box__c!=null) totalNumBox = sir.ASI_MFM_Total_Number_Of_Box__c;
            if(sir.ASI_MFM_Lot_Quantity__c!=null) lotQty = sir.ASI_MFM_Lot_Quantity__c;
            deliveryDate = (sir.ASI_Delivery_Date__c!=null)? sir.ASI_Delivery_Date__c.format():'';
            if(sir.ASI_MFM_Net_Weight__c!=null) netWeight = sir.ASI_MFM_Net_Weight__c;
			if(sir.ASI_MFM_Box_Net_Weight__c!=null) boxNetWeight = sir.ASI_MFM_Box_Net_Weight__c;
            if(sir.ASI_MFM_Total_Quantity__c!=null) totalQty = sir.ASI_MFM_Total_Quantity__c;
            lotNum = (sir.ASI_MFM_Lot_Number__c!=null)? sir.ASI_MFM_Lot_Number__c:'';
            if(sir.ASI_MFM_Min_Unit_Price__c!=null) minUnitPrice=sir.ASI_MFM_Min_Unit_Price__c;
            if(sir.ASI_MFM_Qty_Per_Box__c!=null) qtyPerBox=sir.ASI_MFM_Qty_Per_Box__c;
            if(sir.ASI_MFM_Total_Qty_Per_Bag_Box__c!=null) totalQtyPerBagBox=sir.ASI_MFM_Total_Qty_Per_Bag_Box__c;
            if(qtyPerBox!=null && totalQtyPerBagBox!=null) qtyPerBagBox=qtyPerBox*totalQtyPerBagBox;
            if(sir.ASI_MFM_Fraction_Qty__c!=null) fractionQty=sir.ASI_MFM_Fraction_Qty__c;
		}
    }
}