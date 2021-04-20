/*********************************************************************************
 * Name: ASI_CRM_MO_ContractCommon
 * Description: For all PRMO Contract Manipulation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2015-05-098      Axel LEUNG @ Introv     Initial
 *********************************************************************************/
public class ASI_CRM_MO_ContractCommon {

    // Declaration
    private static boolean blnPreserveReadOnlyTS = true;
    
    public boolean BYPASS_STD_RULE = false;
    
    private id idRTContractNormal;
    private id idRTContractFinal;
    
    //private string strContractNum; // Source Contract Number
    //private id idContract; // Source Contract ID
    //private decimal dblRevision;
    //private id idCustomer;
    //private ASI_TH_CRM_Contract__c contractHeader;
    // Declaration - End

    public ASI_CRM_MO_ContractCommon() {
        this.idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MO_Contract');
        BYPASS_STD_RULE = false;
    }
    
    /**
        To copy the current contract to another copy, including all the specification
    */
    public id copySingleContract(id idFrom, id idToOutlet, id idOwner, date dteS, date dteE) {

        system.debug('###### copySingleContract');
        list<ASI_TH_CRM_Contract__c> lstContract = new list<ASI_TH_CRM_Contract__c>();
        lstContract = [SELECT id,
                ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Exchange_Rate__c,
                ASI_CRM_CN_Description__c, ASI_CRM_Remarks__c,
                ASI_TH_CRM_Outlet__c, ASI_CRM_Version__c, ASI_TH_CRM_Contract_Status__c, OwnerID, RecordTypeID, 
                ASI_CRM_Obsolete_Version__c
            FROM ASI_TH_CRM_Contract__c
            WHERE id = :idFrom
            LIMIT 1
        ];
        if (lstContract.size() > 0) {
            lstContract[0].ASI_TH_CRM_Outlet__c = idToOutlet;
            lstContract[0].OwnerID = idOwner;
            lstContract[0].ASI_TH_CRM_Start_Date__c = dteS;
            lstContract[0].ASI_TH_CRM_End_Date__c = dteE;
        }
        lstContract = copyContracts(lstContract, false, idFrom);
        return (lstContract.size() == 1) ? lstContract[0].id : null;
    }
    
    /**
        To revise current contract content/spec, revision increase
        e.g. revise a revision 3, then modify the current revision to 4
    */  
    public list<ASI_TH_CRM_Contract__c> reviseContracts(list<ASI_TH_CRM_Contract__c> lstContract, list<ASI_TH_CRM_Contract__c> lstContract_OLD) {
        // Declaration
        map<id, String> mapRevision = new map<id, String>(nextRevision(lstContract));
        // Declaration - End

        // Generating History Contract
        copyContracts(lstContract_OLD);
        // Generating History Contract - End
        
        // Revising Contract
        for (ASI_TH_CRM_Contract__c objContract : lstContract) {
            system.debug('---------------------------------------ASI_CRM_MO_ContractCommon.reviseContracts inside for loop : ' + objContract.id);
            objContract.ASI_CRM_Version__c = mapRevision.get(objContract.id);
            objContract.Name = objContract.ASI_CRM_MY_Contract_Number_Base__c + '.' + objContract.ASI_CRM_Version__c;
            objContract.RecordTypeId = idRTContractNormal;
            objContract.ASI_TH_CRM_Contract_Status__c = 'Draft';
            objContract.ASI_CRM_Last_Revision_Date__c = system.now(); // Last Revision Date, Daniel
        }
        // Revising Contract - End
    
        return lstContract;
    }
    
    /** To make contract as "Final" status */
    public list<ASI_TH_CRM_Contract__c> finalContracts(list<ASI_TH_CRM_Contract__c> lstContract) {

        for (ASI_TH_CRM_Contract__c objContract : lstContract) {
            objContract.ASI_TH_CRM_Contract_Status__c = 'Final';
        }
        return lstContract;
    }
    
    /** To copy contracts, source=list<ASI_TH_CRM_Contract__c> */
    public list<ASI_TH_CRM_Contract__c> copyContracts(list<ASI_TH_CRM_Contract__c> lstContract) { return copyContracts(lstContract, true, null); }
    public list<ASI_TH_CRM_Contract__c> copyContracts(list<ASI_TH_CRM_Contract__c> lstContract, boolean blnMakeHistory, id idSrcContract) { 
        // Declaration
        
        list<ASI_TH_CRM_Contract__c> lstContractHistory = new list<ASI_TH_CRM_Contract__c>();
        map<id, id> mapOldNewContract = new map<id, id>();
        map<id, String> mapOldIDCNum = new map<id, String>();
        map<String, id> mapNewID = new map<String, id>();
        set<id> setContract = new set<id>();
        
        list<ASI_CRM_ContractVolumeIncentive__c> lstContractVol = new list<ASI_CRM_ContractVolumeIncentive__c>();
        list<ASI_CRM_Contract_Cost__c> lstContractCost = new list<ASI_CRM_Contract_Cost__c>();
        ASI_CRM_MO_RunningNumber_TriggerCls clsRunningNum = new ASI_CRM_MO_RunningNumber_TriggerCls('Contract');
        // Declaration - End
        
        // Generating History Contract
        lstContractHistory = lstContract.deepClone(true, blnMakeHistory);
        for (ASI_TH_CRM_Contract__c objContract : lstContractHistory) {
            system.debug('### objContract.id = ' + objContract.id + ', ' + objContract.Name);
            id idKey = objContract.id;
            setContract.add(objContract.id);
            objContract.id = null; // New contract record for either contract history or new contract
            //objContract.ASI_CRM_Obsolete_Version__c = blnMakeHistory;
            objContract.ASI_CRM_Terminate__c = false;
            if (!blnMakeHistory && idSrcContract != null) {
                system.debug('### blnMakeHistory = false');
                objContract.ASI_CRM_Version__c = '1';
                objContract.ASI_TH_CRM_Contract_Status__c = 'Draft';
                objContract.RecordTypeID = idRTContractNormal;
                objContract.ASI_CRM_Copied_From__c = idSrcContract;
                objContract.ASI_CRM_Obsolete_Version__c = false;
                objContract.ASI_CRM_Terminate__c = false;
                objContract.Name = objContract.ASI_CRM_Customer_Code__c + '.' + getFiscalYear(objContract.ASI_TH_CRM_Start_Date__c) + clsRunningNum.nextAutoNumStr() + '.' + objContract.ASI_CRM_Version__c;
                //clsRunningNum.writeToDB();
            }
            mapOldIDCNum.put(idKey, objContract.Name);
        }
        if (lstContractHistory.size() > 0) {
            for (ASI_TH_CRM_Contract__c objContract : lstContractHistory) {
                objContract.ASI_CRM_Is_Processing__c = true;
            }
            insert lstContractHistory;
            
            for (ASI_TH_CRM_Contract__c objContract : lstContractHistory) {
                system.debug('ASI_CRM_MO_ContractCommon: Inserted New History Rec ID: ' + objContract.Name + ' ' + objContract.id);
                mapNewID.put(objContract.Name, objContract.id);
            }
            // To clone volume incentive
            lstContractVol = [SELECT id, ASI_CRM_Contract__c, ASI_CRM_SKU__c, RecordTypeID, ASI_CRM_Incentive_Point_Per_Bottle__c
                FROM ASI_CRM_ContractVolumeIncentive__c
                WHERE ASI_CRM_Contract__c IN :setContract
            ];
            lstContractVol = lstContractVol.deepClone(false, blnPreserveReadOnlyTS);
            for (ASI_CRM_ContractVolumeIncentive__c obj : lstContractVol) {
                obj.ASI_CRM_Contract__c = mapNewID.get(mapOldIDCNum.get(obj.ASI_CRM_Contract__c));
            }
            insert lstContractVol;
            
            // To clone contract cost
            lstContractCost = [SELECT id, ASI_CRM_CN_Contract__c, RecordTypeID,
                ASI_CRM_CN_Cost_Type__c, ASI_CRM_Investment_Payment__c, ASI_CRM_Investment_Value__c, ASI_CRM_Investment_Value_Base__c, 
                ASI_CRM_Payment_Schedule__c, Name
                FROM ASI_CRM_Contract_Cost__c 
                WHERE ASI_CRM_CN_Contract__c IN :setContract
            ];
            lstContractCost = lstContractCost.deepClone(false, blnPreserveReadOnlyTS);
            for (ASI_CRM_Contract_Cost__c obj : lstContractCost) {
                obj.ASI_CRM_CN_Contract__c = mapNewID.get(mapOldIDCNum.get(obj.ASI_CRM_CN_Contract__c));
            }
            insert lstContractCost;
            
            set<id> setTemp = new set<id>();
            for (ASI_TH_CRM_Contract__c objContract : lstContractHistory) {
                setTemp.add(objContract.id);
            }
            
            List <ASI_TH_CRM_Contract__c> lstContractHistory2 = [SELECT id, ASI_CRM_Is_Processing__c, ASI_CRM_Obsolete_Version__c FROM ASI_TH_CRM_Contract__c WHERE id IN :setTemp];
            
            for (ASI_TH_CRM_Contract__c objContract : lstContractHistory2) {
                objContract.ASI_CRM_Is_Processing__c = false;
                objContract.ASI_CRM_Obsolete_Version__c = blnMakeHistory;
            }
            system.debug('-----------------------------------------------ASI_CRM_MO_ContractCommon.copyContracts BEFORE update lstContractHistory : ' + lstContractHistory);
            try{
                update lstContractHistory2;
            }catch(Exception e) {
                system.debug('--------------------------------------------TRY CATCH' + e);
                system.debug('---------------------------------------------TRY CATCH' + lstContractHistory[0].id);
            }
            system.debug('-----------------------------------------------ASI_CRM_MO_ContractCommon.copyContracts AFTER update lstContractHistory : ' + lstContractHistory);
        
        }
        // Generating History Contract - End
        return lstContractHistory;
    }

    public map<id, String> nextRevision(list<ASI_TH_CRM_Contract__c> lstContract) {
        // Declaration
        map<id, String> mapRevision = new map<id, String>{};
        // Declaration - End
        
        if (lstContract.size() > 0) {
            for (ASI_TH_CRM_Contract__c objContract : lstContract) {
                String strVer = '';
                id idContract = null;
                if (objContract.id == null) {
                    strVer = '1';
                    idContract = null;
                } else {
                    idContract = objContract.id;
                    try {
                        strVer = String.valueOf(Integer.valueOf(objContract.ASI_CRM_Version__c) + 1);
                        system.debug('------------------------------------ASI_CRM_MO_ContractCommon.nextRevision : strVer --> ' + strVer );
                    } catch (Exception e) {
                        strVer = '1';
                    }
                }
            
                mapRevision.put(idContract, strVer);
            }
        }
        return mapRevision;
    }
    public map<id, String> nextRevision(ASI_TH_CRM_Contract__c objContract) {
        return this.nextRevision(new list<ASI_TH_CRM_Contract__c>{objContract});
    }
    
    /** To control if modifying the contract need to revise the "Version" */
    public boolean checkNeedRevise(ASI_TH_CRM_Contract__c objOld, ASI_TH_CRM_Contract__c objNew) {
        // Declaration
        boolean blnCheck = false;
        // Declaration - End
        System.debug('----------------------------ASI_CRM_MO_ContractCommon.checkNeedRevise: beforeChecking ');
        // Check if the contract key field is being modified
        if (objNew.ASI_CRM_Is_Processing__c == false && !BYPASS_STD_RULE) {
            if (objOld.ASI_CRM_CN_Outlet_WS__c != objNew.ASI_CRM_CN_Outlet_WS__c
                || objOld.ASI_TH_CRM_Outlet__c != objNew.ASI_TH_CRM_Outlet__c
                || objOld.ASI_TH_CRM_Start_Date__c != objNew.ASI_TH_CRM_Start_Date__c
                || objOld.ASI_TH_CRM_End_Date__c != objNew.ASI_TH_CRM_End_Date__c
                || objOld.ASI_CRM_CN_Description__c != objNew.ASI_CRM_CN_Description__c
                || objOld.ASI_CRM_Remarks__c != objNew.ASI_CRM_Remarks__c
                || objOld.ASI_CRM_CN_Currency__c != objNew.ASI_CRM_CN_Currency__c
                || objOld.ASI_CRM_CN_Exchange_Rate__c != objNew.ASI_CRM_CN_Exchange_Rate__c
                || objOld.ASI_TH_CRM_Contract_Status__c != objNew.ASI_TH_CRM_Contract_Status__c
                || objOld.ASI_CRM_Last_Revision_Date__c != objNew.ASI_CRM_Last_Revision_Date__c) {
                // If an "Final" contract is being modified
                System.debug('----------------------------ASI_CRM_MO_ContractCommon.checkNeedRevise: Key field modified.');
                if (objOld.ASI_CRM_Obsolete_Version__c == false
                    && objOld.ASI_TH_CRM_Contract_Status__c.toUpperCase() == 'FINAL' 
                    && objNew.ASI_CRM_Terminate__c == false) {
                    blnCheck = true;
                    System.debug('checkNeed`: Modify the contract in FINAL status with NOT obselete & NOT Terminate');
                }
            }
        }
        return blnCheck;
    }
    
    /** To check if the contract is going to finalize */
    public boolean checkGoFinal(ASI_TH_CRM_Contract__c objOld, ASI_TH_CRM_Contract__c objNew) {
        // Declaration
        boolean blnCheck = false;
        // Declaration - End
        
        // If an "Final" contract is being modified
        if (objOld.ASI_TH_CRM_Contract_Status__c.toUpperCase() != 'FINAL' && objNew.ASI_TH_CRM_Contract_Status__c.toUpperCase() == 'FINAL'
           && objOld.ASI_CRM_Obsolete_Version__c == false && objOld.ASI_CRM_Terminate__c == false) {
            blnCheck = true;
        }
        return blnCheck;
    }
    
    public String updateValidation(list<ASI_TH_CRM_Contract__c> lstContract, map<id, ASI_TH_CRM_Contract__c> trigger_oldMap) {
        // Declaration
        set<id> setContractIDs = new set<id>();
        set<id> setSignedDoc = new set<id>();
        map<id, integer> mapAttCount = new map<id, integer>();
        String strErr = '';
        // Declaration - End
        
        if (BYPASS_STD_RULE) {
            return '';
        }
        
        // Check if user modifying Terminate/Obsolete Contract
        for (ASI_TH_CRM_Contract__c objContract : lstContract) {
            setContractIDs.add(objContract.id);
            
            if(trigger_oldMap.get(objContract.id) != NULL){ // Means not insert cases
                
                // Tempoaray disable for Simon THUNG case
                System.debug('ASI_CRM_MO_ContractCommon: updateValidation: trigger_oldMap.get(objContract.id)');
                System.debug(trigger_oldMap.get(objContract.id));
                System.debug('ASI_CRM_MO_ContractCommon: updateValidation: objContract.Name: ' + objContract.Name);
                if (trigger_oldMap.get(objContract.id).Name != '' && trigger_oldMap.get(objContract.id).Name != objContract.Name) {
                    //strErr += 'Cannot change Contract No. ';
                }
                
                if ( !( (trigger_oldMap.get(objContract.id)).ASI_CRM_Is_Processing__c == TRUE &&  objContract.ASI_CRM_Is_Processing__c == false) ){
                    if (trigger_oldMap.get(objContract.id).ASI_CRM_Obsolete_Version__c == true || trigger_oldMap.get(objContract.id).ASI_CRM_Terminate__c == true) {
                        System.debug('updateValidation(): objContract.ASI_CRM_Obsolete_Version__c: ' + String.valueOf(objContract.ASI_CRM_Obsolete_Version__c) + ' ' + objContract.Name + ', id:' + objContract.ID);
                        System.debug('updateValidation(): objContract.ASI_CRM_Terminate__c: ' + String.valueOf(objContract.ASI_CRM_Terminate__c) + ' ' + objContract.Name + ', id:' + objContract.ID);
                        strErr += 'Cannot modify terminated/obsoleted contract: ' + objContract.Name + '. ';
                    }
                }
                
                if (trigger_oldMap.get(objContract.id).ASI_TH_CRM_Contract_Status__c != 'Final' && objContract.ASI_CRM_Terminate__c == true) {
                    strErr += 'Only contract in "Final" status can be terminated.';
                }
            }
            
            if (objContract.ASI_CRM_Signed_Doc_Ready__c == true) {
                setSignedDoc.add(objContract.id);
            }
        }
        
        return strErr;
    }
    
    public String finalValidation(list<ASI_TH_CRM_Contract__c> lstContract) {
        // Declaration
        set<id> setContractIDs = new set<id>();
        map<id, integer> mapAttCount = new map<id, integer>();
        String strErr = '';
        // Declaration - End
                
        // Check if there is any attachment
        return (strErr == '') ? strErr : 'The following ' + strErr;
    }
    
    public String terimateValidation(list<ASI_TH_CRM_Contract__c> lstContract) {
        
        //for (ASI_TH_CRM_Contract__c objContract : lstContract) {
          //  if (objContract.)
        //}
        if (BYPASS_STD_RULE) {
            return '';
        }
        
        return '';
    }
    
    public decimal getExRate(String strCurr, Date strEffDate) {
        
        list<ASI_MFM_Exchange_Rate__c> lstEx = [
            SELECT ASI_MFM_Exchange_Rate__c
            FROM ASI_MFM_Exchange_Rate__c
            WHERE ASI_MFM_Country__c = 'HK'
			AND ASI_MFM_Base_Currency__c = 'HKD'
            AND ASI_MFM_Counter_Currency__c = :strCurr
            AND ASI_MFM_Application__c = 'MFM'
            AND ASI_MFM_Effective_Date__c <= :strEffDate
            ORDER BY ASI_MFM_Effective_Date__c DESC
            LIMIT 1
        ];
        
        if (lstEx != null && lstEx.size() == 1) {
            return lstEx[0].ASI_MFM_Exchange_Rate__c;
        } else {
            return 0;
        }
    }
    
    public String getFiscalYear(Date dteDate) {
        if (dteDate.month() >= 7)
            return String.valueOf(dteDate.year()).right(2);
        else 
            return String.valueOf(dteDate.year() - 1).right(2);
    }
}