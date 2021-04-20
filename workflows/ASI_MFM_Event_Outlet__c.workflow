<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_MFM_Event_Outlet_Gen_EXID</fullName>
        <field>ASI_MFM_EXID__c</field>
        <formula>LOWER( ASI_MFM_Outlet__r.ASI_KOR_Customer_Code__c +  ASI_MFM_Event__r.Name +  TEXT(ASI_MFM_Event_Type__c) + ASI_MFM_Wave__c )</formula>
        <name>ASI_MFM_Event_Outlet_Gen_EXID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
