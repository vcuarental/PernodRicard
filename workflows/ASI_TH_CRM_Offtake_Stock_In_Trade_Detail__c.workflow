<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_CRM_MY_Update_Region_OfftakeItem</fullName>
        <field>ASI_CRM_Branch__c</field>
        <formula>ASI_TH_CRM_SIT__r.ASI_CRM_Branch__c</formula>
        <name>ASI_CRM_MY_Update_Region_OfftakeItem</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TH_CRM_CalculateEndingStockFinal</fullName>
        <field>ASI_TH_CRM_Ending_Stock_Final__c</field>
        <formula>IF( ISNULL(ASI_TH_CRM_Beginning_Stock__c),0,ASI_TH_CRM_Beginning_Stock__c) 
+ IF( ISNULL(ASI_TH_CRM_Sell_In__c),0,ASI_TH_CRM_Sell_In__c) 
- IF( ISNULL(ASI_TH_CRM_Total_Offtake_Final__c),0,ASI_TH_CRM_Total_Offtake_Final__c)</formula>
        <name>ASI_TH_CRM_CalculateEndingStockFinal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TH_CRM_CalculateOffPremiseOfftake</fullName>
        <field>ASI_TH_CRM_Off_premise_Offtake__c</field>
        <formula>IF( ISNULL(ASI_TH_CRM_Beginning_Stock__c),0,ASI_TH_CRM_Beginning_Stock__c ) 
+ IF(ISNULL(ASI_TH_CRM_Sell_In__c),0,ASI_TH_CRM_Sell_In__c) 
+ IF( ISNULL(ASI_TH_CRM_FOC__c ),0,ASI_TH_CRM_FOC__c ) 
+ IF( ISNULL(ASI_TH_CRM_Others__c ) ,0,ASI_TH_CRM_Others__c ) 
- IF( ISNULL(ASI_TH_CRM_Ending_Stock_Final__c) ,0,ASI_TH_CRM_Ending_Stock_Final__c)
-  IF(ISNULL(ASI_TH_CRM_On_premise_Offtake__c),0,ASI_TH_CRM_On_premise_Offtake__c)</formula>
        <name>ASI_TH_CRM_CalculateOffPremiseOfftake</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TH_CRM_CalculateTotalOfftakeDraft</fullName>
        <field>ASI_TH_CRM_Total_Offtake_Draft__c</field>
        <formula>ASI_TH_CRM_Beginning_Stock__c
+ASI_TH_CRM_Sell_In__c
-ASI_TH_CRM_Ending_Stock_Draft__c</formula>
        <name>ASI_TH_CRM_CalculateTotalOfftakeDraft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_TH_CRM_CalculateTotalOfftakeFinal</fullName>
        <field>ASI_TH_CRM_Total_Offtake_Final__c</field>
        <formula>IF( ISNULL(ASI_TH_CRM_Beginning_Stock__c),0,ASI_TH_CRM_Beginning_Stock__c ) 
+  IF(ISNULL(ASI_TH_CRM_Sell_In__c),0,ASI_TH_CRM_Sell_In__c)
+  IF( ISNULL(ASI_TH_CRM_FOC__c ),0,ASI_TH_CRM_FOC__c )
+  IF( ISNULL(ASI_TH_CRM_Others__c ) ,0,ASI_TH_CRM_Others__c )
-  IF( ISNULL(ASI_TH_CRM_Ending_Stock_Final__c) ,0,ASI_TH_CRM_Ending_Stock_Final__c)</formula>
        <name>ASI_TH_CRM_CalculateTotalOfftakeFinal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_CRM_MY_Update_Region_OfftakeItem</fullName>
        <actions>
            <name>ASI_CRM_MY_Update_Region_OfftakeItem</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI_CRM_MY_WS_Stock_In_Trade_Detail</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ASI_TH_CRM_CalculateOfftake</fullName>
        <actions>
            <name>ASI_TH_CRM_CalculateOffPremiseOfftake</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_TH_CRM_CalculateTotalOfftakeFinal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>ASI_TH_CRM_WS_Stock-In-Trade Detail</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
