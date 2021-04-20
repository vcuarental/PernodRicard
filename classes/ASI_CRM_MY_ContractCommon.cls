/*********************************************************************************
 * Name: ASI_CRM_MY_ContractCommon
 * Description: For all PRMY Contract Manipulation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2014-12-24       Axel                    Initial
 *********************************************************************************/
public class ASI_CRM_MY_ContractCommon {

    // Declaration
    private static boolean blnPreserveReadOnlyTS = true;
    public boolean isKH = false;
    public boolean BYPASS_STD_RULE = false;
    Id loggedUserid = UserInfo.getUserId();
    public Boolean bBypassVR = (Boolean)[SELECT BypassVR__c FROM User WHERE id = :loggedUserid LIMIT 1].BypassVR__c;
    
    private id idRTContractNormal;
    private id idRTContractFinal;
    
    //private string strContractNum; // Source Contract Number
    //private id idContract; // Source Contract ID
    //private decimal dblRevision;
    //private id idCustomer;
    //private ASI_TH_CRM_Contract__c contractHeader;
    // Declaration - End

    public ASI_CRM_MY_ContractCommon() {
        this.idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
        this.idRTContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
        BYPASS_STD_RULE = false;
    }
    
    public ASI_CRM_MY_ContractCommon(String region){
        if(region=='KH'){
            this.isKH = true;
        	this.idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_KH_Contract');
        	this.idRTContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_KH_Contract_Read_Only');
            BYPASS_STD_RULE = false;
        }else{
            this.idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
        	this.idRTContractFinal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_ContractFinal');
            BYPASS_STD_RULE = false;
        }
    }
    
    /**
        To copy the current contract to another copy, including all the specification
    */
    public id copySingleContract(id idFrom, id idToOutlet, id idOwner, String strPType, date dteS, date dteE) {

        system.debug('###### copySingleContract');
        list<ASI_TH_CRM_Contract__c> lstContract = new list<ASI_TH_CRM_Contract__c>();
        lstContract = [SELECT id,
                ASI_CRM_CN_Outlet_WS__c, Name, ASI_CRM_MY_Contract_Number_Base__c, ASI_CRM_Version__c, ASI_TH_CRM_Start_Date__c, 
                ASI_TH_CRM_End_Date__c, ASI_TH_CRM_Contract_Status__c, OwnerID, RecordTypeID, 
                ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_Exchange_Rate__c, ASI_CRM_CN_Currency__c, ASI_CRM_Copied_From__c, 
                ASI_CRM_Signed_Doc_Ready__c, ASI_CRM_Obsolete_Version__c, ASI_CRM_TotalTarget__c, ASI_CRM_TotalCommitment__c, 
                ASI_CRM_NetSalesValue__c, ASI_CRM_CommitmentVSTotalSales__c, ASI_CRM_TotalCommitmentPerCase__c,
                ASI_CRM_MY_Contact_Name__c,ASI_CRM_MY_Contact_Salutation__c,ASI_CRM_MY_Contact_Title__c,ASI_CRM_MY_Proposal_Date__c,ASI_CRM_MY_Show_APInc_CustomerObligation__c,
                ASI_CRM_MY_Show_StaffInc_CustObligation__c,ASI_CRM_MY_Show_StaffIncentiveSection__c,ASI_CRM_MY_StaffInc_CustomerObligation__c,ASI_CRM_MY_UpfrontIncentive_Term__c,
                ASI_CRM_MY_VolumeIncentive_PaymentTerm__c,ASI_CRM_MY_VisibilitySponsorObligation__c,ASI_CRM_MY_ShowVisiSponsorObligation__c,ASI_CRM_MY_VisibilitySponsorContent__c,
                ASI_CRM_MY_UpfrontInc_TermOption__c,ASI_CRM_MY_APIncentive_PaymentTerm__c,ASI_CRM_MY_APInc_CustomerObligation__c 
            FROM ASI_TH_CRM_Contract__c
            WHERE id = :idFrom
            LIMIT 1
        ];
        if (lstContract.size() > 0) {
            lstContract[0].ASI_CRM_CN_Outlet_WS__c = idToOutlet;
            lstContract[0].OwnerID = idOwner;
            lstContract[0].ASI_TH_CRM_Promotion_Type__c = strPType;
            lstContract[0].ASI_TH_CRM_Start_Date__c = dteS;
            lstContract[0].ASI_TH_CRM_End_Date__c = dteE;
        }
        lstContract = copyContracts(lstContract, false, idFrom);
        return (lstContract.size() == 1) ? lstContract[0].id : null;
    }
    
    /** To Terminate the contract (To set the earlier end date and withing affecting the contract revising and status) */
    public String terminateSingleContract(id idContract, Date dteEDate) {
        system.debug('###### terminateSingleContract');
        list<ASI_TH_CRM_Contract__c> lstContract = new list<ASI_TH_CRM_Contract__c>();
        lstContract = [SELECT id, ASI_TH_CRM_End_Date__c
            FROM ASI_TH_CRM_Contract__c
            WHERE id = :idContract LIMIT 1
        ];
        if (lstContract.size() == 1) {
            if (dteEDate > lstContract[0].ASI_TH_CRM_End_Date__c) {
                return 'Cannot termiate a contract with a later end date.';
            } else {
                lstContract[0].ASI_CRM_Terminate__c = true;
                lstContract[0].ASI_TH_CRM_End_Date__c = dteEDate;
                if(isKH){
                    lstContract[0].ASI_TH_CRM_Contract_Status__c = 'Terminate';
                }
                update lstContract;
            }
        }
        return ''; // No Error
    }
    
    /**
        To revise current contract content/spec, revision increase
        e.g. revise a revision 3, then modify the current revision to 4
    */  
    public list<ASI_TH_CRM_Contract__c> reviseContracts(list<ASI_TH_CRM_Contract__c> lstContract, list<ASI_TH_CRM_Contract__c> lstContract_OLD) {
        system.debug('---------------------------------------ASI_CRM_MY_ContractCommon.reviseContracts CALL ME : ' + lstContract);
        // Declaration
        map<id, String> mapRevision = new map<id, String>(nextRevision(lstContract));
        // Declaration - End

        // Generating History Contract
        copyContracts(lstContract_OLD);
        // Generating History Contract - End
        
        // Revising Contract
        for (ASI_TH_CRM_Contract__c objContract : lstContract) {
            system.debug('---------------------------------------ASI_CRM_MY_ContractCommon.reviseContracts inside for loop : ' + objContract.id);
            objContract.ASI_CRM_Version__c = mapRevision.get(objContract.id);
            objContract.Name = objContract.ASI_CRM_MY_Contract_Number_Base__c + '.' + objContract.ASI_CRM_Version__c;
            objContract.RecordTypeId = idRTContractNormal;
            objContract.ASI_TH_CRM_Contract_Status__c = 'Draft';
            objContract.ASI_CRM_ROI__c = null;
            objContract.ASI_CRM_Signed_Doc_Ready__c = false;
            objContract.ASI_CRM_Last_Revision_Date__c = system.now(); // Last Revision Date, Daniel
        }
        // Revising Contract - End
    
        return lstContract;
    }
    
    /** To make contract as "Final" status */
    public list<ASI_TH_CRM_Contract__c> finalContracts(list<ASI_TH_CRM_Contract__c> lstContract) {
        ASI_CRM_MY_ContractDBC clsContractDBC = new ASI_CRM_MY_ContractDBC();
        for (ASI_TH_CRM_Contract__c objContract : lstContract) {
            objContract.RecordTypeId = idRTContractFinal;
            objContract.ASI_TH_CRM_Contract_Status__c = 'Final';
            objContract.ASI_CRM_ROI__c = clsContractDBC.genEstROI(objContract.id);
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
        list<ASI_CRM_ContractTarget__c> lstContractTarget = new list<ASI_CRM_ContractTarget__c>();
        list<ASI_CRM_ContractSalesStaffIncentive__c> lstContractSS = new list<ASI_CRM_ContractSalesStaffIncentive__c>();
        list<ASI_CRM_ContractVolumeIncentive__c> lstContractVol = new list<ASI_CRM_ContractVolumeIncentive__c>();
        list<ASI_CRM_ContractOtherIncentive__c> lstContractOth = new list<ASI_CRM_ContractOtherIncentive__c>();
        list<ASI_CRM_PromoterPlacement__c> lstContractPP = new list<ASI_CRM_PromoterPlacement__c>();
        ASI_CRM_MY_RunningNumber_TriggerClass clsRunningNum = new ASI_CRM_MY_RunningNumber_TriggerClass('Contract');
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
            objContract.ASI_CRM_Signed_Doc_Ready__c = false;
            objContract.ASI_TH_CRM_Contract_External_ID__c = '';
            
            if (!blnMakeHistory && idSrcContract != null) {
                system.debug('### blnMakeHistory = false');
                objContract.ASI_CRM_Version__c = '1';
                objContract.ASI_TH_CRM_Contract_Status__c = 'Draft';
                objContract.RecordTypeID = idRTContractNormal;
                objContract.ASI_CRM_Copied_From__c = idSrcContract;
                objContract.ASI_CRM_ROI__c = null;
                objContract.ASI_CRM_Obsolete_Version__c = false;
                objContract.ASI_CRM_Terminate__c = false;
                objContract.Name = clsRunningNum.nextAutoNumStr() + '.' + objContract.ASI_CRM_Version__c;
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
                system.debug('ASI_CRM_MY_ContractCommon: Inserted New History Rec ID: ' + objContract.Name + ' ' + objContract.id);
                mapNewID.put(objContract.Name, objContract.id);
            }
            // To clone target
            lstContractTarget = [SELECT id,
                                 ASI_CRM_KH_Merchandise_Name__c,ASI_CRM_KH_FOC_Support_in_actual_Bottle__c,ASI_CRM_KH_FOC_Support_in_actual_case__c,
                                 ASI_CRM_KH_Merchandising_Quantity__c,ASI_CRM_KH_Merchandising_Size__c,ASI_CRM_KH_Value_per_Unit__c,
                                 ASI_CRM_Contract__c, ASI_CRM_SKU__c, RecordTypeID, ASI_CRM_MinSPCase__c, ASI_CRM_TargetCase__c FROM ASI_CRM_ContractTarget__c WHERE ASI_CRM_Contract__c IN :setContract];
            lstContractTarget = lstContractTarget.deepClone(false, blnMakeHistory);
            for (ASI_CRM_ContractTarget__c obj : lstContractTarget) {
                System.debug('### obj.ASI_CRM_Contract__c: ' + obj.ASI_CRM_Contract__c);
                System.debug('### Target mapOldIDCNum.get: ' + mapOldIDCNum.get(obj.ASI_CRM_Contract__c));
                System.debug('### Target mapNewID.get: ' + mapNewID.get(mapOldIDCNum.get(obj.ASI_CRM_Contract__c)));
                obj.ASI_CRM_Contract__c = mapNewID.get(mapOldIDCNum.get(obj.ASI_CRM_Contract__c));
            }
            insert lstContractTarget;
            
            // To clone Sales & Staff Incentive
            lstContractSS = [SELECT id, ASI_CRM_Contract__c, ASI_CRM_SKU__c, RecordTypeID, ASI_CRM_MinSPBtl__c,
                ASI_CRM_AchievedBtl__c, ASI_CRM_FOCWS__c, ASI_CRM_FOCPRM__c, ASI_CRM_CashInc__c,
                ASI_CRM_SetupCode__c, ASI_CRM_Total__c
                FROM ASI_CRM_ContractSalesStaffIncentive__c
                WHERE ASI_CRM_Contract__c IN :setContract
            ];
            lstContractSS = lstContractSS.deepClone(false, blnPreserveReadOnlyTS);
            for (ASI_CRM_ContractSalesStaffIncentive__c obj : lstContractSS) {
                obj.ASI_CRM_Contract__c = mapNewID.get(mapOldIDCNum.get(obj.ASI_CRM_Contract__c));
            }
            insert lstContractSS;
            
            // To clone volume incentive
            lstContractVol = [SELECT id, ASI_CRM_Contract__c, ASI_CRM_SKU__c, RecordTypeID,
                ASI_CRM_Description__c, ASI_CRM_ContractTarget__c, ASI_CRM_MinSPBtl__c, ASI_CRM_AchievedBtl__c, 
                ASI_CRM_FOC__c, ASI_CRM_CashInc__c, ASI_CRM_SetupCode__c, ASI_CRM_Total__c
                FROM ASI_CRM_ContractVolumeIncentive__c
                WHERE ASI_CRM_Contract__c IN :setContract
            ];
            lstContractVol = lstContractVol.deepClone(false, blnPreserveReadOnlyTS);
            for (ASI_CRM_ContractVolumeIncentive__c obj : lstContractVol) {
                obj.ASI_CRM_Contract__c = mapNewID.get(mapOldIDCNum.get(obj.ASI_CRM_Contract__c));
            }
            insert lstContractVol;
            
            // To clone Other Incentive
            lstContractOth = [SELECT id, ASI_CRM_Contract__c, ASI_CRM_SKU__c, RecordTypeID,
                ASI_CRM_Type__c, ASI_CRM_Description__c, ASI_CRM_MinSPBtl__c, ASI_CRM_FOC__c,
                ASI_CRM_CashInc__c, ASI_CRM_SetupCode__c, ASI_CRM_Total__c
                FROM ASI_CRM_ContractOtherIncentive__c WHERE ASI_CRM_Contract__c IN :setContract
            ];
            lstContractOth = lstContractOth.deepClone(false, blnPreserveReadOnlyTS);
            for (ASI_CRM_ContractOtherIncentive__c obj : lstContractOth) {
                obj.ASI_CRM_Contract__c = mapNewID.get(mapOldIDCNum.get(obj.ASI_CRM_Contract__c));
            }
            insert lstContractOth;
            
            // To clone promoter placement
            lstContractPP = [SELECT id, ASI_CRM_Contract__c, ASI_CRM_SKU__c, RecordTypeID,
                ASI_CRM_Description__c, ASI_CRM_PromoterCount__c, ASI_CRM_WorkingDay__c, ASI_CRM_DailySalary__c,
                ASI_CRM_WorkingMonth__c, ASI_CRM_SetupCode__c
                FROM ASI_CRM_PromoterPlacement__c WHERE ASI_CRM_Contract__c IN :setContract
            ];
            lstContractPP = lstContractPP.deepClone(false, blnPreserveReadOnlyTS);
            for (ASI_CRM_PromoterPlacement__c obj : lstContractPP) {
                obj.ASI_CRM_Contract__c = mapNewID.get(mapOldIDCNum.get(obj.ASI_CRM_Contract__c));
            }
            insert lstContractPP;
            
            
            set<id> setTemp = new set<id>();
            for (ASI_TH_CRM_Contract__c objContract : lstContractHistory) {
                setTemp.add(objContract.id);
            }
            
            List <ASI_TH_CRM_Contract__c> lstContractHistory2 = [SELECT id, ASI_CRM_Is_Processing__c, ASI_CRM_Obsolete_Version__c FROM ASI_TH_CRM_Contract__c WHERE id IN :setTemp];
            
            for (ASI_TH_CRM_Contract__c objContract : lstContractHistory2) {
                objContract.ASI_CRM_Is_Processing__c = false;
                objContract.ASI_CRM_Obsolete_Version__c = blnMakeHistory;
            }
            system.debug('-----------------------------------------------ASI_CRM_MY_ContractCommon.copyContracts BEFORE update lstContractHistory : ' + lstContractHistory);
            try{
                update lstContractHistory2;
            }catch(Exception e) {
                system.debug('--------------------------------------------TRY CATCH' + e);
                system.debug('---------------------------------------------TRY CATCH' + lstContractHistory[0].id);
            }
            system.debug('-----------------------------------------------ASI_CRM_MY_ContractCommon.copyContracts AFTER update lstContractHistory : ' + lstContractHistory);
        
        }
        // Generating History Contract - End
        return lstContractHistory;
    }
    
    /**
        To terminate contract, to change a earlier end date of an contract
    */
    public void terminateContract() {

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
                        system.debug('------------------------------------ASI_CRM_MY_ContractCommon.nextRevision : strVer --> ' + strVer );
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
        System.debug('----------------------------ASI_CRM_MY_ContractCommon.checkNeedRevise: beforeChecking ');
        // Check if the contract key field is being modified
        if (objNew.ASI_CRM_Is_Processing__c == false && !BYPASS_STD_RULE && !bBypassVR) {
            if (objOld.ASI_CRM_CN_Outlet_WS__c != objNew.ASI_CRM_CN_Outlet_WS__c
                || objOld.ASI_TH_CRM_Start_Date__c != objNew.ASI_TH_CRM_Start_Date__c
                || objOld.ASI_TH_CRM_End_Date__c != objNew.ASI_TH_CRM_End_Date__c
                || objOld.ASI_TH_CRM_Promotion_Type__c != objNew.ASI_TH_CRM_Promotion_Type__c
                || objOld.ASI_CRM_CN_Currency__c != objNew.ASI_CRM_CN_Currency__c
                || objOld.ASI_TH_CRM_Contract_Status__c != objNew.ASI_TH_CRM_Contract_Status__c
                || objOld.ASI_CRM_Last_Revision_Date__c != objNew.ASI_CRM_Last_Revision_Date__c) {
                // If an "Final" contract is being modified
                System.debug('----------------------------ASI_CRM_MY_ContractCommon.checkNeedRevise: Key field modified.');
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
        
        system.debug('@@@ '+ objOld.ASI_TH_CRM_Contract_Status__c.toUpperCase());
        system.debug('@@@ '+ objNew.ASI_TH_CRM_Contract_Status__c.toUpperCase());
        system.debug('@@@ '+ objOld.ASI_CRM_Obsolete_Version__c);
        system.debug('@@@ '+ objOld.ASI_CRM_Terminate__c);
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
        //map<id, boolean> mapContractObs = new map<id, boolean>();
        map<id, integer> mapAttCount = new map<id, integer>();
        String strErr = '';
        // Declaration - End
        
        if (BYPASS_STD_RULE || bBypassVR) {
            return '';
        }
        
        // Check if user modifying Terminate/Obsolete Contract
        for (ASI_TH_CRM_Contract__c objContract : lstContract) {
            setContractIDs.add(objContract.id);
            //mapContractObs.put(objContract.id, objContract.ASI_CRM_Obsolete_Version__c);
            
            if(trigger_oldMap.get(objContract.id) != NULL){ // Means not insert cases
                
                // Tempoaray disable for Simon THUNG case
                System.debug('ASI_CRM_MY_ContractCommon: updateValidation: trigger_oldMap.get(objContract.id)');
                System.debug(trigger_oldMap.get(objContract.id));
                System.debug('ASI_CRM_MY_ContractCommon: updateValidation: objContract.Name: ' + objContract.Name);
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
        
        // Check signed document ready's contract attachment
        if (setSignedDoc.size() > 0) {
            // Check Attachments of the Contracts
            AggregateResult[] res = [SELECT ParentID, COUNT(id) AttCount
                FROM Attachment WHERE ParentID in :setSignedDoc
                GROUP BY ParentID
            ];
            for (AggregateResult ar : res) {
                mapAttCount.put((id) ar.get('ParentID'), integer.valueof(ar.get('AttCount')));
            }
            
            for (id idContract : setSignedDoc) {
                system.debug('---------------------------ASI_CRM_MY_Contract_Common ---------------------' + idContract);
                
                if (mapAttCount.get(idContract) == null) {
                    strErr += 'You need to upload contract scanned copy and tick "Signed Document Ready"';
                } else {
                    if (mapAttCount.get(idContract) <= 0) {
                        strErr += 'You need to upload contract scanned copy and tick "Signed Document Ready"';
                    }
                }
            }
        }
    
        return strErr;
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
}