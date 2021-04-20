<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ASI_MFM_Copy_Event_Name</fullName>
        <field>Name</field>
        <formula>ASI_MFM_Event__r.Name</formula>
        <name>Copy Event Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_Update_Event_Name</fullName>
        <field>ASI_MFM_Event_Name_Search__c</field>
        <formula>ASI_MFM_Event__r.Name</formula>
        <name>Update Event Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_MFM_Update_Plan_Name</fullName>
        <field>ASI_MFM_Plan_Name_Search__c</field>
        <formula>ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c</formula>
        <name>Update Plan Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ASI_MFM_Event_PP_Searching</fullName>
        <actions>
            <name>ASI_MFM_Copy_Event_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_MFM_Update_Event_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ASI_MFM_Update_Plan_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ASI_MFM_Event_PP__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
